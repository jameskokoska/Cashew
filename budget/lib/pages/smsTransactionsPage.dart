import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/editWalletsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/struct/smsTransactions.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/globalSnackbar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/selectCategory.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SmsTransactionsPage extends StatefulWidget {
  const SmsTransactionsPage({super.key});

  @override
  State<SmsTransactionsPage> createState() => _SmsTransactionsPageState();
}

class _SmsTransactionsPageState extends State<SmsTransactionsPage> {
  bool importing = false;

  IconData _icon(IconData outlined, IconData rounded) =>
      appStateSettings["outlinedIcons"] ? outlined : rounded;

  Future<bool> _toggle(bool value) async {
    if (value) {
      final bool granted = await requestSmsPermission();
      if (!granted) {
        openSnackbar(SnackbarMessage(
          title: "SMS permission needed",
          description:
              "Allow SMS access for Cashew in Android Settings → Apps → Cashew → Permissions.",
          icon: _icon(Icons.sms_failed_outlined, Icons.sms_failed_rounded),
        ));
        return false;
      }
      // Start from now; older SMS can be imported below.
      await updateSettings(
          "smsLastScanMillis", DateTime.now().millisecondsSinceEpoch,
          updateGlobalState: false);
      await updateSettings("smsTransactions", true, updateGlobalState: false);
      startSmsListener();
    } else {
      await updateSettings("smsTransactions", false, updateGlobalState: false);
      stopSmsListener();
    }
    setState(() {});
    return true;
  }

  Future<void> _pickCategory({required bool income}) async {
    final String key = income ? "smsIncomeCategoryPk" : "smsExpenseCategoryPk";
    final List<TransactionCategory> all =
        await database.getAllCategories(includeSubCategories: false);
    final List<String> allowed = [
      for (final TransactionCategory c in all)
        if (c.income == income && c.categoryPk != "0") c.categoryPk
    ];
    await openBottomSheet(
      context,
      PopupFramework(
        title: income ? "Default income category" : "Default expense category",
        subtitle:
            "Used when Cashew hasn't learned a category for the sender yet",
        child: SelectCategory(
          categoryFks: allowed.isEmpty ? null : allowed,
          addButton: false,
          setSelectedCategory: (TransactionCategory category) async {
            await updateSettings(key, category.categoryPk,
                updateGlobalState: false);
            if (mounted) setState(() {});
          },
        ),
      ),
    );
  }

  Future<void> _linkAccount(String last4) async {
    final Map<String, dynamic> links = smsAccountWallets();
    final TransactionWallet? current = links[last4] == null
        ? null
        : await database.getWalletInstanceOrNull(links[last4].toString());
    final TransactionWallet? wallet = await selectWalletPopup(
      context,
      title: "Account for ••$last4",
      subtitle: "Transactions from this bank account or card go here",
      selectedWallet: current,
      allowEditWallet: false,
      allowDeleteWallet: false,
    );
    if (wallet == null) return;
    links[last4] = wallet.walletPk;
    await updateSettings("smsAccountWallets", links, updateGlobalState: false);
    if (mounted) setState(() {});
  }

  Future<void> _importPast() async {
    final DateTime now = DateTime.now();
    final DateTimeRange? range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: now,
      ),
      helpText: "Import bank SMS from",
    );
    if (range == null) return;
    setState(() => importing = true);
    try {
      final DateTime end = DateTime(
          range.end.year, range.end.month, range.end.day, 23, 59, 59);
      final DateTime to = end.isAfter(now) ? now : end;
      final SmsImportResult result =
          await importSmsBetween(range.start, to);
      openSnackbar(SnackbarMessage(
        title: result.added == 1
            ? "Imported 1 transaction"
            : "Imported ${result.added} transactions",
        description: "Checked ${result.scanned} SMS"
            "${result.duplicates > 0 ? " · ${result.duplicates} already added" : ""}",
        icon: _icon(Icons.download_done_outlined, Icons.download_done_rounded),
      ));
    } catch (e) {
      openSnackbar(SnackbarMessage(
        title: "Couldn't read SMS",
        description: e.toString(),
        icon: _icon(Icons.error_outline, Icons.error_rounded),
      ));
    }
    if (mounted) setState(() => importing = false);
  }

  Widget _sectionHeader(String text) => Padding(
        padding: const EdgeInsetsDirectional.only(
            start: 20, end: 20, top: 18, bottom: 6),
        child: TextFont(
          text: text,
          fontSize: 15,
          fontWeight: FontWeight.bold,
          textColor: Theme.of(context).colorScheme.primary,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final bool enabled = appStateSettings["smsTransactions"] == true;
    final AllWallets allWallets = Provider.of<AllWallets>(context);
    final Map<String, dynamic> balances = smsAccountBalances();
    final Map<String, dynamic> links = smsAccountWallets();
    final List<dynamic> log = appStateSettings["smsRecentLog"] is List
        ? appStateSettings["smsRecentLog"]
        : [];

    String money(double amount) => convertToMoney(allWallets, amount);

    return PageFramework(
      dragDownToDismiss: true,
      title: "SMS Transactions",
      listWidgets: [
        Padding(
          padding:
              const EdgeInsetsDirectional.only(bottom: 8, start: 20, end: 20),
          child: TextFont(
            text:
                "Cashew reads transaction SMS from your bank and adds them for you: debits, credits, UPI, card spends, ATM withdrawals and autopay. OTPs, offers, failed payments and \"will be debited\" reminders are skipped. Messages stay on your phone.",
            fontSize: 14,
            maxLines: 10,
          ),
        ),
        SettingsContainerSwitch(
          title: "Add transactions from SMS",
          description: enabled
              ? "New bank SMS are added while Cashew is open, and any missed ones are added when you open it."
              : "Needs permission to read SMS.",
          initialValue: enabled,
          onSwitched: (bool value) => _toggle(value),
          icon: _icon(Icons.sms_outlined, Icons.sms_rounded),
        ),
        if (enabled) ...[
          _sectionHeader("Categories"),
          FutureBuilder<TransactionCategory?>(
            future: database.getCategoryInstanceOrNull(
                appStateSettings["smsExpenseCategoryPk"]?.toString() ?? ""),
            builder: (context, snapshot) => SettingsContainer(
              title: "Expenses go to",
              description: snapshot.data?.name ?? "First expense category",
              icon: _icon(Icons.arrow_upward_outlined,
                  Icons.arrow_upward_rounded),
              onTap: () => _pickCategory(income: false),
            ),
          ),
          FutureBuilder<TransactionCategory?>(
            future: database.getCategoryInstanceOrNull(
                appStateSettings["smsIncomeCategoryPk"]?.toString() ?? ""),
            builder: (context, snapshot) => SettingsContainer(
              title: "Income goes to",
              description: snapshot.data?.name ?? "First income category",
              icon: _icon(Icons.arrow_downward_outlined,
                  Icons.arrow_downward_rounded),
              onTap: () => _pickCategory(income: true),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 20, vertical: 4),
            child: TextFont(
              text:
                  "Tip: when you add a transaction with a merchant name (e.g. \"Swiggy\") under a category, future SMS from that merchant use the same category.",
              fontSize: 13,
              maxLines: 5,
            ),
          ),
          _sectionHeader("Bank accounts & balances"),
          if (balances.isEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 20, vertical: 6),
              child: TextFont(
                text:
                    "Accounts will appear here after the first bank SMS. Link each one to a Cashew account.",
                fontSize: 14,
                maxLines: 5,
              ),
            ),
          for (final MapEntry<String, dynamic> entry in balances.entries)
            Builder(builder: (context) {
              final Map info = entry.value is Map ? entry.value : {};
              final dynamic bal = info["balance"];
              final DateTime? date =
                  DateTime.tryParse(info["date"]?.toString() ?? "");
              final String? linkedPk = links[entry.key]?.toString();
              final String linkedName = linkedPk == null
                  ? "Not linked · uses your selected account"
                  : (allWallets.indexedByPk[linkedPk]?.name ??
                      "Not linked · uses your selected account");
              final String balanceText = bal is num
                  ? "Balance ${money(bal.toDouble())}"
                      "${date != null ? " · ${getWordedDateShort(date)}" : ""}"
                  : "No balance in SMS yet";
              return SettingsContainer(
                title: "${info["bank"] ?? "Bank"} ••${entry.key}",
                description: "$balanceText\n→ $linkedName",
                icon: _icon(Icons.account_balance_outlined,
                    Icons.account_balance_rounded),
                onTap: () => _linkAccount(entry.key),
              );
            }),
          _sectionHeader("Past SMS"),
          SettingsContainer(
            title: importing ? "Importing…" : "Import old bank SMS",
            description:
                "Pick a date range. Payments already added are skipped.",
            icon: _icon(Icons.history_outlined, Icons.history_rounded),
            onTap: importing ? null : _importPast,
          ),
          SettingsContainer(
            title: "Check for new SMS now",
            icon: _icon(Icons.refresh_outlined, Icons.refresh_rounded),
            onTap: () async {
              final SmsImportResult? r = await scanNewSms();
              if (r != null && r.added == 0) {
                openSnackbar(SnackbarMessage(
                  title: "No new bank transactions",
                  icon: _icon(Icons.check_outlined, Icons.check_rounded),
                ));
              }
              if (mounted) setState(() {});
            },
          ),
          if (log.isNotEmpty) ...[
            _sectionHeader("Recently added"),
            for (final dynamic item in log.take(15))
              if (item is Map)
                Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 20, vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFont(
                              text: item["title"]?.toString() ?? "",
                              fontSize: 15,
                              maxLines: 1,
                            ),
                            TextFont(
                              text: [
                                if (item["bank"] != null) item["bank"],
                                if (item["account"] != null)
                                  "••${item["account"]}",
                                if (DateTime.tryParse(
                                        item["date"]?.toString() ?? "") !=
                                    null)
                                  getWordedDateShort(
                                      DateTime.parse(item["date"])),
                              ].join(" · "),
                              fontSize: 12,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      TextFont(
                        text: item["amount"] is num
                            ? money((item["amount"] as num).toDouble())
                            : "",
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
          ],
        ],
        SizedBox(height: 40),
      ],
    );
  }
}
