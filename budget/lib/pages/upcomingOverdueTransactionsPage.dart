import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/budgetPage.dart';
import 'package:budget/pages/subscriptionsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/noResults.dart';
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
            title: overdueTransactions ? "Overdue" : "Upcoming",
            dragDownToDismiss: true,
            slivers: [
              SliverToBoxAdapter(
                  child: CenteredAmountAndNumTransactions(
                numTransactionsStream: overdueTransactions
                    ? database.watchCountOfOverdue()
                    : database.watchCountOfUpcoming(),
                totalAmountStream: database.watchTotalOfUpcomingOverdue(
                  Provider.of<AllWallets>(context),
                  overdueTransactions,
                ),
                textColor: overdueTransactions
                    ? getColor(context, "unPaidOverdue")
                    : getColor(context, "unPaidUpcoming"),
              )),
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
                          child: NoResults(
                            message: "No " +
                                (overdueTransactions ? "overdue" : "upcoming") +
                                " transactions.",
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

class CenteredAmountAndNumTransactions extends StatelessWidget {
  const CenteredAmountAndNumTransactions(
      {required this.numTransactionsStream,
      required this.totalAmountStream,
      required this.textColor,
      super.key});

  final Stream<List<int?>> numTransactionsStream;
  final Stream<double?> totalAmountStream;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 20),
        StreamBuilder<double?>(
          stream: totalAmountStream,
          builder: (context, snapshot) {
            return CountNumber(
              count: snapshot.hasData == false || snapshot.data == null
                  ? 0
                  : (snapshot.data ?? 0).abs(),
              duration: Duration(milliseconds: 700),
              dynamicDecimals: true,
              initialCount: (0),
              textBuilder: (number) {
                return TextFont(
                  text: convertToMoney(Provider.of<AllWallets>(context), number,
                      finalNumber:
                          snapshot.hasData == false || snapshot.data == null
                              ? 0
                              : (snapshot.data ?? 0).abs()),
                  fontSize: 30,
                  textColor: textColor,
                  fontWeight: FontWeight.bold,
                );
              },
            );
          },
        ),
        SizedBox(height: 5),
        StreamBuilder<List<int?>>(
          stream: numTransactionsStream,
          builder: (context, snapshot) {
            return TextFont(
              text: snapshot.hasData == false || snapshot.data![0] == null
                  ? "/"
                  : snapshot.data![0].toString() +
                      pluralString(snapshot.data![0] == 1, " transaction"),
              fontSize: 16,
              textColor: getColor(context, "textLight"),
            );
          },
        ),
        SizedBox(height: 15),
      ],
    );
  }
}
