import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/budgetPage.dart';
import 'package:budget/pages/subscriptionsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/selectedTransactionsActionBar.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budget/widgets/countNumber.dart';

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
            listID: pageId,
            navbar: false,
            title: overdueTransactions ? "Overdue" : "Upcoming",
            dragDownToDismiss: true,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: enableDoubleColumn(context)
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.start,
                    children: [
                      StreamBuilder<double?>(
                        stream: database.watchTotalOfUpcomingOverdue(
                          Provider.of<AllWallets>(context),
                          overdueTransactions,
                        ),
                        builder: (context, snapshot) {
                          return CountNumber(
                            count: snapshot.hasData == false ||
                                    snapshot.data == null
                                ? 0
                                : (snapshot.data ?? 0).abs(),
                            duration: Duration(milliseconds: 700),
                            dynamicDecimals: true,
                            initialCount: (0),
                            textBuilder: (number) {
                              return TextFont(
                                text: convertToMoney(
                                    Provider.of<AllWallets>(context), number,
                                    finalNumber: snapshot.hasData == false ||
                                            snapshot.data == null
                                        ? 0
                                        : (snapshot.data ?? 0).abs()),
                                fontSize: 25,
                                textColor: overdueTransactions
                                    ? getColor(context, "unPaidOverdue")
                                    : getColor(context, "unPaidUpcoming"),
                                fontWeight: FontWeight.bold,
                              );
                            },
                          );
                        },
                      ),
                      SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3.0),
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
                              textColor: getColor(context, "textLight"),
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
