import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/subscriptionsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/SelectedTransactionsActionBar.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class UpcomingOverdueTransactions extends StatelessWidget {
  const UpcomingOverdueTransactions(
      {required this.overdueTransactions, super.key});
  final bool overdueTransactions;

  @override
  Widget build(BuildContext context) {
    String pageId = overdueTransactions ? "Overdue" : "Upcoming";
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
      child: Stack(
        children: [
          PageFramework(
            navbar: false,
            title: overdueTransactions ? "Overdue" : "Upcoming",
            dragDownToDismiss: true,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      StreamBuilder<List<double?>>(
                        stream: overdueTransactions
                            ? database.watchTotalOfOverdue()
                            : database.watchTotalOfUpcoming(),
                        builder: (context, snapshot) {
                          return CountNumber(
                            count: snapshot.hasData == false ||
                                    snapshot.data![0] == null
                                ? 0
                                : (snapshot.data![0] ?? 0).abs(),
                            duration: Duration(milliseconds: 700),
                            dynamicDecimals: true,
                            initialCount: (0),
                            textBuilder: (number) {
                              return TextFont(
                                text: convertToMoney(number),
                                fontSize: 25,
                                textColor: overdueTransactions
                                    ? Theme.of(context).colorScheme.unPaidRed
                                    : Theme.of(context)
                                        .colorScheme
                                        .unPaidYellow,
                                fontWeight: FontWeight.bold,
                              );
                            },
                          );
                        },
                      ),
                      SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: StreamBuilder<List<int?>>(
                          stream: overdueTransactions
                              ? database.watchCountOfOverdue()
                              : database.watchCountOfUpcoming(),
                          builder: (context, snapshot) {
                            return TextFont(
                              text: snapshot.hasData == false ||
                                      snapshot.data![0] == null
                                  ? "/"
                                  : snapshot.data![0].toString() +
                                      pluralString(snapshot.data![0] == 1,
                                          " transaction"),
                              fontSize: 15,
                              textColor:
                                  Theme.of(context).colorScheme.textLight,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
              StreamBuilder<List<Transaction>>(
                stream: overdueTransactions
                    ? database.watchAllOverdueTransactions()
                    : database.watchAllUpcomingTransactions(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.length <= 0) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 35, right: 30, left: 30),
                            child: TextFont(
                              maxLines: 4,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              text: "No " +
                                  (overdueTransactions
                                      ? "overdue"
                                      : "upcoming") +
                                  " transactions.",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          Transaction transaction = snapshot.data![index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              UpcomingTransactionDateHeader(
                                  transaction: transaction),
                              TransactionEntry(
                                openPage: AddTransactionPage(
                                  title: "Edit Transaction",
                                  transaction: transaction,
                                ),
                                transaction: transaction,
                                listID: pageId,
                              ),
                              SizedBox(height: 12),
                            ],
                          );
                        },
                        childCount: snapshot.data?.length,
                      ),
                    );
                  } else {
                    return SliverToBoxAdapter();
                  }
                },
              ),
            ],
          ),
          SelectedTransactionsActionBar(
            pageID: pageId,
          ),
        ],
      ),
    );
  }
}
