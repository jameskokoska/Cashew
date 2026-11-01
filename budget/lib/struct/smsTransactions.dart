// Automatically adds transactions from bank SMS (Android only).
//
// How it works:
// - While Cashew is open, new SMS arrive through a live listener and are
//   added straight away.
// - When Cashew is opened or brought back to the foreground, the SMS inbox is
//   scanned for anything that arrived while it was closed.
// - Every message is identified by its UPI/UTR reference (or a hash of its
//   text), so the same payment is never added twice.

import 'dart:async';

import 'package:drift/drift.dart' hide Column, Table;

import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addWalletPage.dart'
    show createCorrectionTransaction;
import 'package:budget/struct/bankSmsParser.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/globalSnackbar.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/util/onAppResume.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:budget/struct/notificationsGlobal.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart' show NumberFormat;

const MethodChannel _smsChannel = MethodChannel("cashew/sms");
const EventChannel _smsEvents = EventChannel("cashew/sms_events");

StreamSubscription<dynamic>? _smsSubscription;
bool _smsBusy = false;

const int _maxProcessedKeys = 3000;
const int _maxLogEntries = 40;

class SmsData {
  SmsData({required this.address, required this.body, required this.date});

  final String address;
  final String body;
  final DateTime date;

  static SmsData? fromMap(dynamic raw) {
    if (raw is! Map) return null;
    final String? body = raw["body"]?.toString();
    if (body == null || body.trim().isEmpty) return null;
    final dynamic date = raw["date"];
    return SmsData(
      address: raw["address"]?.toString() ?? "",
      body: body,
      date: date is int
          ? DateTime.fromMillisecondsSinceEpoch(date)
          : DateTime.now(),
    );
  }
}

class SmsImportResult {
  int scanned = 0;
  int added = 0;
  int duplicates = 0;
  int notTransactions = 0;
  Transaction? lastAdded;
}

bool smsTransactionsSupported() =>
    !kIsWeb && getPlatform(ignoreEmulation: true) == PlatformOS.isAndroid;

bool smsTransactionsEnabled() =>
    smsTransactionsSupported() && appStateSettings["smsTransactions"] == true;

Future<bool> hasSmsPermission() async {
  if (!smsTransactionsSupported()) return false;
  try {
    return await _smsChannel.invokeMethod<bool>("hasPermission") ?? false;
  } catch (e) {
    return false;
  }
}

Future<bool> requestSmsPermission() async {
  if (!smsTransactionsSupported()) return false;
  try {
    return await _smsChannel.invokeMethod<bool>("requestPermission") ?? false;
  } catch (e) {
    return false;
  }
}

Future<List<SmsData>> getInboxSms(
    {required DateTime since, DateTime? until}) async {
  final List<dynamic>? raw = await _smsChannel.invokeMethod<List<dynamic>>(
    "getMessages",
    {
      "since": since.millisecondsSinceEpoch,
      "until": (until ?? DateTime.now()).millisecondsSinceEpoch,
      "limit": 20000,
    },
  );
  final List<SmsData> out = [];
  for (final dynamic m in raw ?? []) {
    final SmsData? sms = SmsData.fromMap(m);
    if (sms != null) out.add(sms);
  }
  return out;
}

// Runs [task] once nothing else is processing SMS, so the live listener and
// an inbox scan can never add the same message at the same time.
Future<T> _withSmsLock<T>(Future<T> Function() task) async {
  while (_smsBusy) {
    await Future.delayed(Duration(milliseconds: 150));
  }
  _smsBusy = true;
  try {
    return await task();
  } finally {
    _smsBusy = false;
  }
}

// ---------------------------------------------------------------------------
// Listening and scanning
// ---------------------------------------------------------------------------

void startSmsListener() {
  if (!smsTransactionsEnabled()) return;
  stopSmsListener();
  _smsSubscription = _smsEvents.receiveBroadcastStream().listen(
    (dynamic event) async {
      final SmsData? sms = SmsData.fromMap(event);
      if (sms == null || !smsTransactionsEnabled()) return;
      await _withSmsLock(() => processSmsMessages([sms]));
    },
    onError: (Object e) {
      print("SMS listener error: " + e.toString());
    },
  );
}

void stopSmsListener() {
  _smsSubscription?.cancel();
  _smsSubscription = null;
}

/// Adds transactions for any bank SMS received since the last scan.
Future<SmsImportResult?> scanNewSms({bool showSnackbar = true}) async {
  if (!smsTransactionsEnabled()) return null;
  if (!await hasSmsPermission()) return null;
  return _withSmsLock(() async {
    final DateTime now = DateTime.now();
    final int lastScan = appStateSettings["smsLastScanMillis"] is int
        ? appStateSettings["smsLastScanMillis"]
        : now.millisecondsSinceEpoch;
    // Small overlap in case an SMS was written to the inbox late.
    final DateTime since = DateTime.fromMillisecondsSinceEpoch(lastScan)
        .subtract(Duration(minutes: 15));
    final List<SmsData> messages = await getInboxSms(since: since, until: now);
    final SmsImportResult result =
        await processSmsMessages(messages, showSnackbar: showSnackbar);
    await updateSettings("smsLastScanMillis", now.millisecondsSinceEpoch,
        updateGlobalState: false);
    return result;
  });
}

/// One-time import of bank SMS between two dates.
Future<SmsImportResult> importSmsBetween(DateTime from, DateTime to) async {
  return _withSmsLock(() async {
    final List<SmsData> messages = await getInboxSms(since: from, until: to);
    return processSmsMessages(messages, showSnackbar: false);
  });
}

// ---------------------------------------------------------------------------
// Turning SMS into transactions
// ---------------------------------------------------------------------------

Future<SmsImportResult> processSmsMessages(List<SmsData> messages,
    {bool showSnackbar = true}) async {
  final SmsImportResult result = SmsImportResult();
  final List<String> processedList = _stringList("smsProcessedKeys");
  final Set<String> processed = processedList.toSet();
  final Map<String, dynamic> balances = _stringMap("smsAccountBalances");
  final List<dynamic> log = List<dynamic>.from(
      appStateSettings["smsRecentLog"] is List
          ? appStateSettings["smsRecentLog"]
          : []);
  bool balancesChanged = false;
  final List<_AddedSms> added = [];


  for (final SmsData sms in messages) {
    result.scanned++;
    final ParsedBankSms? parsed =
        BankSmsParser.parse(sms.body, sender: sms.address);
    if (parsed == null) {
      result.notTransactions++;
      final ParsedBankBalance? onlyBalance =
          BankSmsParser.parseBalance(sms.body, sender: sms.address);
      if (onlyBalance != null) {
        final String? k = _saveBalance(balances, onlyBalance.bank,
            onlyBalance.accountLast4, onlyBalance.balance, sms.date);
        if (k != null) balancesChanged = true;
      }
      continue;
    }

    // Remember the latest balance reported for each account
    if (parsed.balance != null && parsed.accountLast4 != null) {
      final String? k = _saveBalance(balances, parsed.bank,
          parsed.accountLast4!, parsed.balance!, sms.date,
          isCard: parsed.isCard);
      if (k != null) balancesChanged = true;
    } else if (parsed.accountLast4 != null &&
        _matchAccountKey(balances, parsed.bank, parsed.accountLast4!) ==
            null) {
      // Record the account so it shows up in settings
      balances[accountKey(parsed.bank, parsed.accountLast4!)] = {
        "balance": null,
        "date": sms.date.toIso8601String(),
        "bank": parsed.bank,
        "card": parsed.isCard,
      };
      balancesChanged = true;
    }

    final String key = smsDedupeKey(parsed, sms.body);
    if (processed.contains(key)) {
      result.duplicates++;
      continue;
    }

    final Transaction? transaction = await _buildTransaction(parsed, sms);
    if (transaction == null) continue;

    final int? rowId =
        await database.createOrUpdateTransaction(transaction, insert: true);
    processed.add(key);
    processedList.add(key);
    result.added++;
    added.add(_AddedSms(parsed, transaction));
    if (rowId != null) {
      try {
        result.lastAdded = await database.getTransactionFromRowId(rowId);
      } catch (e) {}
    }
    log.insert(0, {
      "title": transaction.name,
      "amount": transaction.amount,
      "date": sms.date.toIso8601String(),
      "account": parsed.accountLast4,
      "bank": parsed.bank,
      "autopay": parsed.isAutopay,
    });
  }

  if (result.added > 0) {
    final List<String> trimmed = processedList.length > _maxProcessedKeys
        ? processedList.sublist(processedList.length - _maxProcessedKeys)
        : processedList;
    await updateSettings("smsProcessedKeys", trimmed,
        updateGlobalState: false);
    await updateSettings("smsRecentLog", log.take(_maxLogEntries).toList(),
        updateGlobalState: false);
  }
  if (balancesChanged) {
    await updateSettings("smsAccountBalances", balances,
        updateGlobalState: false);
  }

  // Make each bank account in Cashew match the latest balance from SMS
  if (appStateSettings["smsMatchBalance"] != false) {
    // Checks every known account (only a few), so older imported SMS or
    // edits are also corrected. Nothing is added when it already matches.
    for (final String k in balances.keys.toList()) {
      try {
        await _reconcileBalance(k, balances[k]);
      } catch (e) {
        print("SMS balance match failed for $k: $e");
      }
    }
  }

  final bool notify = appStateSettings["smsNotifications"] != false;
  if (showSnackbar && notify && added.isNotEmpty) {
    try {
      await _notifyAdded(added);
    } catch (e) {
      print("SMS notification failed: $e");
    }
  }

  if (showSnackbar && !notify && result.added > 0) {
    openSnackbar(
      SnackbarMessage(
        title: result.added == 1
            ? "Added 1 transaction from SMS"
            : "Added ${result.added} transactions from SMS",
        description: result.lastAdded?.name,
        icon: appStateSettings["outlinedIcons"]
            ? Icons.sms_outlined
            : Icons.sms_rounded,
      ),
    );
  }
  return result;
}

// Accounts are stored as "BANK:digits" (e.g. "CUB:0232") so the same last
// digits at two different banks never get mixed up.
String accountKey(String? bank, String account) => "${bank ?? "?"}:$account";

/// Splits a stored key into (bank, digits). Old keys without a bank give "?".
(String, String) splitAccountKey(String key) {
  final int i = key.lastIndexOf(":");
  if (i < 0) return ("?", key);
  return (key.substring(0, i), key.substring(i + 1));
}

// Banks print different lengths of the account number ("XX232" vs
// "XXXX0232"), so the shorter one being the end of the longer one matches,
// as long as the bank is the same (or unknown).
String? _matchAccountKey(
    Map<String, dynamic> map, String? bank, String account) {
  final String exact = accountKey(bank, account);
  if (map.containsKey(exact)) return exact;
  for (final String key in map.keys) {
    final (String keyBank, String keyAccount) = splitAccountKey(key);
    final bool sameBank = keyBank == "?" || bank == null || keyBank == bank;
    if (sameBank &&
        (keyAccount.endsWith(account) || account.endsWith(keyAccount))) {
      return key;
    }
  }
  return null;
}

/// Stores the balance if it's newer than what we have. Returns the key used,
/// or null when the stored balance is already newer.
String? _saveBalance(Map<String, dynamic> balances, String? bank,
    String account, double balance, DateTime date,
    {bool isCard = false}) {
  final String key =
      _matchAccountKey(balances, bank, account) ?? accountKey(bank, account);
  final dynamic existing = balances[key];
  final DateTime? existingDate =
      existing is Map && existing["balance"] != null
          ? DateTime.tryParse(existing["date"]?.toString() ?? "")
          : null;
  if (existingDate != null && date.isBefore(existingDate)) return null;
  balances[key] = {
    "balance": balance,
    "date": date.toIso8601String(),
    "bank": bank ?? (existing is Map ? existing["bank"] : null),
    "card": isCard || (existing is Map && existing["card"] == true),
  };
  return key;
}

// ---------------------------------------------------------------------------
// Bank-wise accounts
// ---------------------------------------------------------------------------

String _normalizeName(String s) =>
    s.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]"), "");

/// The Cashew account (wallet) for a bank account or card. Uses the linked
/// one, else an existing account whose name matches the bank, else creates
/// a new one like "CUB ••0232".
Future<String> walletForBankAccount(
    {required String? bank, required String? account, bool isCard = false}) async {
  final String fallback =
      appStateSettings["selectedWalletPk"]?.toString() ?? "0";
  if (account == null) return fallback;

  final Map<String, dynamic> links = _stringMap("smsAccountWallets");
  final String? linkedKey = _matchAccountKey(links, bank, account);
  if (linkedKey != null) {
    final TransactionWallet? linked =
        await database.getWalletInstanceOrNull(links[linkedKey].toString());
    if (linked != null) return linked.walletPk;
  }
  if (appStateSettings["smsAutoCreateAccounts"] == false) return fallback;

  final String key = linkedKey ?? accountKey(bank, account);
  final List<TransactionWallet> wallets = await database.getAllWallets();
  final Set<String> alreadyLinked =
      links.values.map((e) => e.toString()).toSet();
  TransactionWallet? match;

  // 1. A wallet whose name contains these account digits ("SBI 1234")
  for (final TransactionWallet w in wallets) {
    if (alreadyLinked.contains(w.walletPk)) continue;
    if (RegExp("(?<![0-9])$account(?![0-9])").hasMatch(w.name)) {
      match = w;
      break;
    }
  }

  // 2. A wallet named after the bank ("City Union Bank"), not already used
  //    for another account at that bank. Cards only match wallets named "card".
  BankInfo? info;
  for (final BankInfo b in BankSmsParser.banks) {
    if (b.shortName == bank) info = b;
  }
  if (match == null && info != null) {
    for (final TransactionWallet w in wallets) {
      if (alreadyLinked.contains(w.walletPk)) continue;
      final bool walletIsCard = w.name.toLowerCase().contains("card");
      if (walletIsCard != isCard) continue;
      final String n = _normalizeName(w.name);
      if (n.contains(_normalizeName(info.fullName)) ||
          n == _normalizeName(info.shortName) ||
          info.pattern.hasMatch(w.name)) {
        match = w;
        break;
      }
    }
  }

  // 3. Create a new account
  if (match == null) {
    String name = bank ?? "Bank";
    if (isCard && !name.toLowerCase().contains("card")) name += " Card";
    name += " ••$account";
    final TransactionWallet? selected =
        await database.getWalletInstanceOrNull(fallback);
    final int count = (await database.getTotalCountOfWallets())[0] ?? 0;
    final int rowId = await database.createOrUpdateWallet(
      TransactionWallet(
        walletPk: "-1",
        name: name,
        colour: null,
        iconName: null,
        dateCreated: DateTime.now(),
        dateTimeModified: null,
        order: count,
        currency: selected?.currency ?? "inr",
        currencyFormat: selected?.currencyFormat,
        decimals: 2,
        homePageWidgetDisplay: defaultWalletHomePageWidgetDisplay,
      ),
      insert: true,
    );
    match = await database.getWalletFromRowId(rowId);
  }

  links[key] = match.walletPk;
  await updateSettings("smsAccountWallets", links, updateGlobalState: false);
  return match.walletPk;
}

/// Adds a "balance correction" so the Cashew account equals the bank's
/// balance at the time of that SMS.
Future<void> _reconcileBalance(String key, dynamic info) async {
  if (info is! Map || info["balance"] is! num) return;
  final DateTime? at = DateTime.tryParse(info["date"]?.toString() ?? "");
  if (at == null) return;
  final (String bank, String account) = splitAccountKey(key);
  final String walletPk = await walletForBankAccount(
    bank: bank == "?" ? info["bank"]?.toString() : bank,
    account: account,
    isCard: info["card"] == true,
  );
  final TransactionWallet? wallet =
      await database.getWalletInstanceOrNull(walletPk);
  if (wallet == null) return;

  // Corrections are saved at :30/:31 seconds, so count the whole minute.
  final DateTime until = DateTime(at.year, at.month, at.day, at.hour, at.minute)
      .add(Duration(seconds: 59, milliseconds: 999));
  final double total = await _walletTotalUntil(wallet.walletPk, until);
  final double bankBalance = (info["balance"] as num).toDouble();
  final double difference =
      ((bankBalance - total) * 100).roundToDouble() / 100;
  if (difference.abs() < 0.01) return;

  await createCorrectionTransaction(
    difference,
    wallet,
    title: "Balance matched to bank",
    note: "Added from SMS so this account matches the bank balance of "
        "${bankBalance.toStringAsFixed(2)}",
    dateTime: until.subtract(Duration(seconds: 29)),
  );
}

Future<double> _walletTotalUntil(String walletPk, DateTime until) async {
  final Expression<double> totalAmt = database.transactions.amount.sum();
  final query = database.selectOnly(database.transactions)
    ..addColumns([totalAmt])
    ..where(database.transactions.walletFk.equals(walletPk) &
        database.transactions.paid.equals(true) &
        database.transactions.dateCreated.isSmallerOrEqualValue(until));
  final TypedResult? row = await query.getSingleOrNull();
  return row?.read(totalAmt) ?? 0;
}

String smsDedupeKey(ParsedBankSms parsed, String body) {
  if (parsed.reference != null) {
    return "ref:${parsed.type.name}:${parsed.reference}";
  }
  final String normalized = body.replaceAll(RegExp(r"\s+"), " ").trim();
  return "h:${_fnv1a(normalized)}:${normalized.length}";
}

String _fnv1a(String s) {
  int hash = 0x811c9dc5;
  for (final int unit in s.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash.toRadixString(16);
}

Future<Transaction?> _buildTransaction(
    ParsedBankSms parsed, SmsData sms) async {
  final bool income = !parsed.isDebit;

  // Bank-wise: each bank account / card goes to its own Cashew account
  final String walletPk = await walletForBankAccount(
    bank: parsed.bank,
    account: parsed.accountLast4,
    isCard: parsed.isCard,
  );

  final TransactionCategory? category =
      await _pickCategory(parsed, income: income);
  if (category == null) return null;

  final bool isSubCategory = category.mainCategoryPk != null;

  return Transaction(
    transactionPk: "-1",
    name: parsed.title,
    amount: parsed.amount.abs() * (income ? 1 : -1),
    note: _buildNote(parsed),
    categoryFk: isSubCategory ? category.mainCategoryPk! : category.categoryPk,
    subCategoryFk: isSubCategory ? category.categoryPk : null,
    walletFk: walletPk,
    dateCreated: sms.date,
    dateTimeModified: null,
    income: income,
    paid: true,
    skipPaid: false,
    methodAdded: MethodAdded.sms,
  );
}

Future<TransactionCategory?> _pickCategory(ParsedBankSms parsed,
    {required bool income}) async {
  // 1. A category Cashew already learned for this merchant name
  if (parsed.merchant != null) {
    try {
      final TransactionAssociatedTitleWithCategory? found = (await database
              .getSimilarAssociatedTitles(title: parsed.merchant!, limit: 1))
          .firstOrNull;
      if (found != null &&
          found.category.income == income &&
          found.title.title.toLowerCase().trim() ==
              parsed.merchant!.toLowerCase().trim()) {
        return found.category;
      }
    } catch (e) {}
  }

  // 2. The default category chosen in SMS settings
  final String defaultPk = (appStateSettings[
              income ? "smsIncomeCategoryPk" : "smsExpenseCategoryPk"] ??
          "")
      .toString();
  if (defaultPk != "") {
    final TransactionCategory? category =
        await database.getCategoryInstanceOrNull(defaultPk);
    if (category != null) return category;
  }

  // 3. The first category of the right type
  final List<TransactionCategory> all = await database.getAllCategories();
  for (final TransactionCategory c in all) {
    if (c.income == income && c.categoryPk != "0") return c;
  }
  for (final TransactionCategory c in all) {
    if (c.categoryPk != "0") return c;
  }
  return null;
}

String _buildNote(ParsedBankSms parsed) {
  final List<String> details = [
    if (parsed.bank != null) parsed.bank!,
    if (parsed.accountLast4 != null) "A/c ••${parsed.accountLast4}",
    if (parsed.channel != null) parsed.channel!,
    if (parsed.reference != null) "Ref ${parsed.reference}",
  ];
  final List<String> lines = [
    parsed.isAutopay ? "Autopay · added from SMS" : "Added from SMS",
    if (details.isNotEmpty) details.join(" · "),
  ];
  return lines.join("\n");
}

List<String> _stringList(String key) {
  final dynamic value = appStateSettings[key];
  if (value is List) return value.map((e) => e.toString()).toList();
  return [];
}

Map<String, dynamic> _stringMap(String key) {
  final dynamic value = appStateSettings[key];
  if (value is Map) {
    return value.map((k, v) => MapEntry(k.toString(), v));
  }
  return {};
}

/// Account number -> latest known balance info from SMS.
Map<String, dynamic> smsAccountBalances() => _stringMap("smsAccountBalances");

/// Account number -> Cashew wallet (account) pk.
Map<String, dynamic> smsAccountWallets() => _stringMap("smsAccountWallets");

// ---------------------------------------------------------------------------
// App wiring
// ---------------------------------------------------------------------------

/// Wrap the app with this to scan on start / resume and listen for new SMS.
class InitializeSmsTransactions extends StatefulWidget {
  const InitializeSmsTransactions({required this.child, super.key});

  final Widget child;

  @override
  State<InitializeSmsTransactions> createState() =>
      _InitializeSmsTransactionsState();
}

class _InitializeSmsTransactionsState extends State<InitializeSmsTransactions> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1500), () async {
      if (!smsTransactionsEnabled()) return;
      startSmsListener();
      await scanNewSms();
    });
  }

  @override
  void dispose() {
    stopSmsListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnAppResume(
      onAppResume: () async {
        if (!smsTransactionsEnabled()) return;
        if (_smsSubscription == null) startSmsListener();
        await scanNewSms();
      },
      child: widget.child,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifications
// ---------------------------------------------------------------------------

class _AddedSms {
  _AddedSms(this.parsed, this.transaction);
  final ParsedBankSms parsed;
  final Transaction transaction;
}

int _notificationCounter = 0;

final NumberFormat _rupees =
    NumberFormat.currency(locale: "en_IN", symbol: "₹", decimalDigits: 2);

String _formatRupees(double amount) {
  final String text = _rupees.format(amount.abs());
  // "₹1,000.00" -> "₹1,000" for whole amounts
  final String trimmed =
      text.endsWith(".00") ? text.substring(0, text.length - 3) : text;
  return amount < 0 ? "-$trimmed" : trimmed;
}

String _notificationTitle(ParsedBankSms p) {
  final String amount = _formatRupees(p.amount);
  final String? who = p.merchant;
  if (p.isAutopay) {
    return who != null ? "$amount autopay to $who" : "$amount autopay debited";
  }
  if (p.channel == "ATM" && p.isDebit) return "$amount withdrawn at ATM";
  if (p.isDebit) {
    if (p.isCard) return who != null ? "$amount spent at $who" : "$amount spent on card";
    return who != null ? "$amount paid to $who" : "$amount debited";
  }
  return who != null ? "$amount received from $who" : "$amount credited";
}

Future<void> _notifyAdded(List<_AddedSms> items) async {
  const AndroidNotificationDetails android = AndroidNotificationDetails(
    'smsTransactions',
    'SMS Transactions',
    channelDescription: 'A notification each time a bank SMS is added',
    importance: Importance.high,
    priority: Priority.high,
  );
  const NotificationDetails details = NotificationDetails(android: android);

  // Many at once (e.g. after the app was closed for a while): one summary
  if (items.length > 5) {
    double spent = 0, received = 0;
    for (final _AddedSms i in items) {
      if (i.parsed.isDebit) {
        spent += i.parsed.amount;
      } else {
        received += i.parsed.amount;
      }
    }
    await flutterLocalNotificationsPlugin.show(
      7000 + (_notificationCounter++ % 500),
      "Added ${items.length} transactions from SMS",
      "Spent ${_formatRupees(spent)} · Received ${_formatRupees(received)}",
      details,
      payload: "smsTransactions",
    );
    return;
  }

  for (final _AddedSms i in items) {
    final TransactionWallet? wallet =
        await database.getWalletInstanceOrNull(i.transaction.walletFk);
    final List<String> parts = [
      [
        wallet?.name ?? i.parsed.bank ?? "Bank",
        if (i.parsed.accountLast4 != null &&
            !(wallet?.name.contains(i.parsed.accountLast4!) ?? false))
          "••${i.parsed.accountLast4}",
      ].join(" "),
    ];

    // Remaining: the bank's own figure if the SMS has it, else Cashew's total
    if (i.parsed.balance != null) {
      parts.add("Balance ${_formatRupees(i.parsed.balance!)}");
    } else if (wallet != null) {
      final double total =
          await _walletTotalUntil(wallet.walletPk, DateTime(9999));
      if (i.parsed.isCard) {
        if (total < 0) parts.add("Card outstanding ${_formatRupees(-total)}");
      } else {
        parts.add("Balance ${_formatRupees(total)}");
      }
    }

    await flutterLocalNotificationsPlugin.show(
      7000 + (_notificationCounter++ % 500),
      _notificationTitle(i.parsed),
      parts.join(" · "),
      details,
      payload: "smsTransactions",
    );
  }
}
