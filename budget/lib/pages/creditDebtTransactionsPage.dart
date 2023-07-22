import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/widgets/selectedTransactionsActionBar.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budget/widgets/countNumber.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';

class CreditDebtTransactions extends StatelessWidget {
  const CreditDebtTransactions({required this.isCredit, super.key});
  final bool isCredit;

  @override
  Widget build(BuildContext context) {
    String pageId = isCredit ? "Credit" : "Debt";
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
            floatingActionButton: AnimateFABDelayed(
              fab: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewPadding.bottom),
                child: FAB(
                  tooltip: isCredit ? "Add Credit" : "Add Debt",
                  openPage: AddTransactionPage(
                    selectedType: isCredit
                        ? TransactionSpecialType.credit
                        : TransactionSpecialType.debt,
                  ),
                ),
              ),
            ),
            listID: pageId,
            title: isCredit ? "lent".tr() : "borrowed".tr(),
            dragDownToDismiss: true,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    StreamBuilder<double?>(
                      stream: database.watchTotalOfCreditDebt(
                        Provider.of<AllWallets>(context),
                        isCredit,
                      ),
                      builder: (context, snapshot) {
                        return CountNumber(
                          count:
                              snapshot.hasData == false || snapshot.data == null
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
                              fontSize: 30,
                              textColor: isCredit
                                  ? getColor(context, "unPaidUpcoming")
                                  : getColor(context, "unPaidOverdue"),
                              fontWeight: FontWeight.bold,
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(height: 5),
                    StreamBuilder<List<int?>>(
                      stream: database.watchCountOfCreditDebt(isCredit),
                      builder: (context, snapshot) {
                        return TextFont(
                          text: snapshot.hasData == false ||
                                  snapshot.data![0] == null
                              ? "/"
                              : snapshot.data![0].toString() +
                                  " " +
                                  (snapshot.data![0] == 1
                                      ? "transaction".tr().toLowerCase()
                                      : "transactions".tr().toLowerCase()),
                          fontSize: 16,
                          textColor: getColor(context, "textLight"),
                        );
                      },
                    ),
                    SizedBox(height: 15),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
              StreamBuilder<List<Transaction>>(
                stream:
                    database.watchAllCreditDebtTransactions(isCredit, false),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.length <= 0) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: NoResults(
                            message: "No " +
                                (isCredit ? "credit" : "debt") +
                                " transactions.",
                          ),
                        ),
                      );
                    }

                    return SliverImplicitlyAnimatedList<Transaction>(
                      items: snapshot.data!,
                      areItemsTheSame: (a, b) =>
                          a.transactionPk == b.transactionPk,
                      insertDuration: Duration(milliseconds: 500),
                      removeDuration: Duration(milliseconds: 500),
                      updateDuration: Duration(milliseconds: 500),
                      itemBuilder: (BuildContext context,
                          Animation<double> animation,
                          Transaction item,
                          int index) {
                        return SizeFadeTransition(
                          sizeFraction: 0.7,
                          curve: Curves.easeInOut,
                          animation: animation,
                          child: TransactionEntry(
                            openPage: AddTransactionPage(
                              transaction: item,
                            ),
                            transaction: item,
                            listID: pageId,
                            key: ValueKey(item.transactionPk),
                          ),
                        );
                      },
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
