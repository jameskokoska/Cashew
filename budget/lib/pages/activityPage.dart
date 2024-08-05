import 'dart:convert';
import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart' hide AppSettings;
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/dateDivider.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/globalSnackbar.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/selectedTransactionsAppBar.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry/transactionEntry.dart';
import 'package:budget/widgets/transactionEntry/transactionLabel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:budget/functions.dart';

List<MapEntry<String, Transaction>> recentlyDeletedTransactions = [];

void addTransactionToRecentlyDeleted(Transaction transaction,
    {bool save = true}) {
  while (recentlyDeletedTransactions.length >= 50) {
    recentlyDeletedTransactions.removeAt(0);
  }
  recentlyDeletedTransactions
      .add(MapEntry(transaction.transactionPk, transaction));
  if (save) saveRecentlyDeletedTransactions();
}

Transaction? getTransactionFromRecentlyDeleted(String transactionPk) {
  for (final entry in recentlyDeletedTransactions) {
    if (entry.key == transactionPk) {
      return entry.value;
    }
  }
  return null;
}

Future<void> saveRecentlyDeletedTransactions() async {
  List<Map<String, dynamic>> encodedData = recentlyDeletedTransactions
      .map((entry) => {
            'key': entry.key,
            'value': entry.value.toJson(),
          })
      .toList();
  String jsonString = jsonEncode(encodedData);
  print(jsonString);
  await sharedPreferences.setString("recentlyDeletedTransactions", jsonString);
}

Future<void> loadRecentlyDeletedTransactions() async {
  String? jsonString =
      sharedPreferences.getString("recentlyDeletedTransactions");

  if (jsonString != null) {
    try {
      List<dynamic> decodedData = jsonDecode(jsonString);
      recentlyDeletedTransactions = decodedData
          .map((entry) => MapEntry<String, Transaction>(
                entry['key'] as String,
                Transaction.fromJson(entry['value'] as Map<String, dynamic>),
              ))
          .toList();
    } catch (e) {
      print("Error loading recently deleted transactions: " + e.toString());
    }
  }
}

void restoreTransaction(
    BuildContext context, DeleteLog deleteLog, Transaction transaction) async {
  if (await database.getCategoryInstanceOrNull(transaction.categoryFk) ==
      null) {
    openPopup(
      context,
      title: "category-not-available".tr(),
      description: "the-original-category-has-been-deleted".tr(),
      onSubmitLabel: "ok".tr(),
      onSubmit: () async {
        popRoute(context);
      },
      icon: appStateSettings["outlinedIcons"]
          ? Icons.search_off_outlined
          : Icons.search_off_rounded,
    );
  } else {
    String transactionLabel = await getTransactionLabel(transaction);
    openPopup(
      context,
      title: "restore-transaction".tr(),
      subtitle: transactionLabel,
      onCancelLabel: "cancel".tr(),
      onCancel: () => popRoute(context),
      onSubmitLabel: "restore".tr(),
      icon: appStateSettings["outlinedIcons"]
          ? Icons.restore_page_outlined
          : Icons.restore_page_rounded,
      onSubmit: () async {
        try {
          await database.createOrUpdateTransaction(transaction);
          await database.deleteDeleteLog(deleteLog.deleteLogPk);
          openSnackbar(
            SnackbarMessage(
              title: "transaction-restored".tr(),
              description: transactionLabel,
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.restore_page_outlined
                  : Icons.restore_page_rounded,
            ),
          );
        } catch (e) {
          openSnackbar(
            SnackbarMessage(
              title: "error-restoring".tr(),
              description: e.toString(),
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.warning_outlined
                  : Icons.warning_rounded,
            ),
          );
        }

        popRoute(context);
      },
    );
  }
}

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => ActivityPageState();
}

class ActivityPageState extends State<ActivityPage> {
  GlobalKey<PageFrameworkState> pageState = GlobalKey();
  String pageId = "ActivityLog";

  void scrollToTop() {
    pageState.currentState?.scrollToTop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if ((globalSelectedID.value[pageId] ?? []).length > 0) {
          globalSelectedID.value[pageId] = [];
          globalSelectedID.notifyListeners();
          return false;
        } else {
          return true;
        }
      },
      child: PageFramework(
        key: pageState,
        dragDownToDismiss: true,
        title: "activity-log".tr(),
        listID: pageId,
        floatingActionButton: AnimateFABDelayed(
          fab: AddFAB(
            tooltip: "add-transaction".tr(),
            openPage: AddTransactionPage(
              routesToPopAfterDelete: RoutesToPopAfterDelete.None,
            ),
          ),
        ),
        slivers: [
          StreamBuilder<List<TransactionActivityLog>>(
            stream: database.watchAllTransactionActivityLog(limit: 30),
            builder: (context, snapshot1) {
              return Container(
                child: StreamBuilder<List<TransactionActivityLog>>(
                  stream:
                      database.watchAllTransactionDeleteActivityLog(limit: 30),
                  builder: (context, snapshot2) {
                    // print(snapshot1.data);
                    // print(snapshot2.data);
                    if (snapshot1.hasData == false &&
                        snapshot2.hasData == false) {
                      return SliverToBoxAdapter();
                    }
                    List<TransactionActivityLog> activityLogList = [
                      ...(snapshot1.data ?? []),
                      ...(snapshot2.data ?? [])
                    ]..sort((a, b) => b.dateTime.compareTo(a.dateTime));
                    if (activityLogList.length <= 0) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child:
                              NoResults(message: "no-transactions-found".tr()),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        childCount: activityLogList.length,
                        (BuildContext context, int index) {
                          TransactionActivityLog item = activityLogList[index];
                          bool wasADeletedTransaction = item.deleteLog != null;
                          Transaction? transaction = item.transaction;
                          TransactionCategory? category =
                              item.transactionWithCategory?.category;
                          TransactionCategory? subCategory =
                              item.transactionWithCategory?.subCategory;
                          Budget? budget = item.transactionWithCategory?.budget;
                          Objective? objective =
                              item.transactionWithCategory?.objective;
                          Objective? objectiveLoan =
                              item.transactionWithCategory?.objectiveLoan;
                          Widget noTransactionFound = Padding(
                            padding: EdgeInsetsDirectional.symmetric(
                                horizontal:
                                    getHorizontalPaddingConstrained(context) +
                                        16,
                                vertical: 5),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Tappable(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer
                                        .withOpacity(0.2),
                                    borderRadius: 5,
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.symmetric(
                                              vertical: 8.0, horizontal: 10),
                                      child: TextFont(
                                        text: "transaction-no-longer-available"
                                            .tr(),
                                        textColor:
                                            getColor(context, "textLight"),
                                        fontSize: 15,
                                        maxLines: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                          Widget transactionEntry = transaction != null
                              ? Tappable(
                                  color: Colors.transparent,
                                  // Disable required for iOS so we can still use the pointer
                                  disable: wasADeletedTransaction == false,
                                  onTap: wasADeletedTransaction
                                      ? () {
                                          if (wasADeletedTransaction &&
                                              item.deleteLog != null &&
                                              item.transaction != null)
                                            restoreTransaction(
                                              context,
                                              item.deleteLog!,
                                              item.transaction!,
                                            );
                                        }
                                      : null,

                                  child: Opacity(
                                    opacity: wasADeletedTransaction ? 0.4 : 1,
                                    child: IgnorePointer(
                                      ignoring: wasADeletedTransaction,
                                      child: TransactionEntry(
                                        containerColor: wasADeletedTransaction
                                            ? Colors.transparent
                                            : null,
                                        openPage: AddTransactionPage(
                                          transaction: transaction,
                                          routesToPopAfterDelete:
                                              RoutesToPopAfterDelete.One,
                                        ),
                                        transaction: transaction,
                                        category: category,
                                        subCategory: subCategory,
                                        budget: budget,
                                        objective: objective,
                                        objectiveLoan: objectiveLoan,
                                        listID: pageId,
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox.shrink();
                          return Column(
                            key: ValueKey(
                                (item.transaction?.transactionPk ?? "") +
                                    (item.deleteLog?.deleteLogPk ?? "")),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DateDivider(
                                date: transaction?.dateCreated ?? item.dateTime,
                                maxLines: 2,
                                afterDate: " • " +
                                    (wasADeletedTransaction
                                            ? "deleted"
                                            : "modified")
                                        .tr()
                                        .capitalizeFirst +
                                    " " +
                                    getTimeAgo(item.dateTime),
                              ),
                              transaction == null
                                  ? noTransactionFound
                                  : transactionEntry,
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 75),
          ),
        ],
        selectedTransactionsAppBar: SelectedTransactionsAppBar(
          pageID: pageId,
        ),
      ),
    );
  }
}
