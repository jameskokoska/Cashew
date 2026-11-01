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

import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/bankSmsParser.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/globalSnackbar.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/util/onAppResume.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  for (final SmsData sms in messages) {
    result.scanned++;
    final ParsedBankSms? parsed =
        BankSmsParser.parse(sms.body, sender: sms.address);
    if (parsed == null) {
      result.notTransactions++;
      final ParsedBankBalance? onlyBalance =
          BankSmsParser.parseBalance(sms.body, sender: sms.address);
      if (onlyBalance != null &&
          _saveBalance(balances, onlyBalance.accountLast4,
              onlyBalance.balance, onlyBalance.bank, sms.date)) {
        balancesChanged = true;
      }
      continue;
    }

    // Remember the latest balance reported for each account
    if (parsed.balance != null && parsed.accountLast4 != null) {
      if (_saveBalance(balances, parsed.accountLast4!, parsed.balance!,
          parsed.bank, sms.date)) {
        balancesChanged = true;
      }
    } else if (parsed.accountLast4 != null &&
        _matchAccountKey(balances, parsed.accountLast4!) == null) {
      // Record the account so it can be linked in settings
      balances[parsed.accountLast4!] = {
        "balance": null,
        "date": sms.date.toIso8601String(),
        "bank": parsed.bank,
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

  if (showSnackbar && result.added > 0) {
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

// Banks print different lengths of the account number ("XX232" vs
// "XXXX0232"), so match on the shorter one being the end of the longer one.
String? _matchAccountKey(Map<String, dynamic> balances, String account) {
  if (balances.containsKey(account)) return account;
  for (final String key in balances.keys) {
    if (key.endsWith(account) || account.endsWith(key)) return key;
  }
  return null;
}

bool _saveBalance(Map<String, dynamic> balances, String account,
    double balance, String? bank, DateTime date) {
  final String key = _matchAccountKey(balances, account) ?? account;
  final dynamic existing = balances[key];
  final DateTime? existingDate = existing is Map
      ? DateTime.tryParse(existing["date"]?.toString() ?? "")
      : null;
  if (existingDate != null && date.isBefore(existingDate)) return false;
  balances[key] = {
    "balance": balance,
    "date": date.toIso8601String(),
    "bank": bank ?? (existing is Map ? existing["bank"] : null),
  };
  return true;
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

  // Account: linked wallet for this account number, else the selected one
  final Map<String, dynamic> accountWallets = _stringMap("smsAccountWallets");
  String walletPk = appStateSettings["selectedWalletPk"]?.toString() ?? "0";
  final dynamic linked = parsed.accountLast4 == null
      ? null
      : accountWallets[_matchAccountKey(accountWallets, parsed.accountLast4!) ??
          parsed.accountLast4];
  if (linked != null &&
      await database.getWalletInstanceOrNull(linked.toString()) != null) {
    walletPk = linked.toString();
  }

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
