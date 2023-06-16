import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/pages/budgetPage.dart';
import 'package:budget/pages/subscriptionsPage.dart';
import 'package:budget/pages/transactionsListPage.dart';
import 'package:budget/pages/upcomingOverdueTransactionsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/keepAliveClientMixin.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:budget/widgets/walletEntry.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budget/widgets/countNumber.dart';

class UpcomingTransactions extends StatelessWidget {
  const UpcomingTransactions({
    Key? key,
    bool this.overdueTransactions = false,
  }) : super(key: key);
  final overdueTransactions;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(boxShadow: boxShadowCheck(boxShadowGeneral(context))),
      child: OpenContainerNavigation(
        closedColor: getColor(context, "lightDarkAccentHeavyLight"),
        openPage: UpcomingOverdueTransactions(
            overdueTransactions: overdueTransactions),
        borderRadius: 15,
        button: (openContainer) {
          return Tappable(
            color: getColor(context, "lightDarkAccentHeavyLight"),
            onTap: () {
              openContainer();
            },
            child: Container(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFont(
                      text: overdueTransactions ? "Overdue" : "Upcoming",
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 6),
                    StreamBuilder<double?>(
                      stream: database.watchTotalOfUpcomingOverdue(
                        Provider.of<AllWallets>(context),
                        overdueTransactions,
                      ),
                      builder: (context, snapshot) {
                        return CountNumber(
                          count:
                              snapshot.hasData == false || snapshot.data == null
                                  ? 0
                                  : (snapshot.data ?? 0).abs(),
                          duration: Duration(milliseconds: 1500),
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
                              textColor: overdueTransactions
                                  ? getColor(context, "unPaidOverdue")
                                  : getColor(context, "unPaidUpcoming"),
                              fontWeight: FontWeight.bold,
                              autoSizeText: true,
                              fontSize: 24,
                              maxFontSize: 24,
                              minFontSize: 10,
                              maxLines: 1,
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(height: 5),
                    StreamBuilder<List<int?>>(
                      stream: overdueTransactions
                          ? database.watchCountOfOverdue()
                          : database.watchCountOfUpcoming(),
                      builder: (context, snapshot) {
                        return TextFont(
                          text: snapshot.hasData == false ||
                                  snapshot.data![0] == null
                              ? "/"
                              : snapshot.data![0].toString() +
                                  pluralString(
                                      snapshot.data![0] == 1, " transaction"),
                          fontSize: 13,
                          textColor: getColor(context, "textLight"),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
