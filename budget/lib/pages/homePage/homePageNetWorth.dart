import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
import 'package:budget/pages/walletDetailsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/keepAliveClientMixin.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/transactionsAmountBox.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePageNetWorth extends StatelessWidget {
  const HomePageNetWorth({super.key});

  @override
  Widget build(BuildContext context) {
    return !appStateSettings["showNetWorth"] &&
            enableDoubleColumn(context) == false
        ? SizedBox.shrink()
        : KeepAliveClientMixin(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 13, left: 13, right: 13),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TransactionsAmountBox(
                      label: "net-worth".tr(),
                      absolute: false,
                      currencyKey: Provider.of<AllWallets>(context)
                          .indexedByPk[appStateSettings["selectedWalletPk"]]
                          ?.currency,
                      amountStream: database.watchTotalOfWallet(
                        null,
                        isIncome: null,
                        allWallets: Provider.of<AllWallets>(context),
                        startDate: appStateSettings["netWorthStartDate"] == null
                            ? null
                            : DateTime.parse(
                                appStateSettings["netWorthStartDate"]),
                      ),
                      // getTextColor: (amount) => amount == 0
                      //     ? getColor(context, "black")
                      //     : amount > 0
                      //         ? getColor(context, "incomeAmount")
                      //         : getColor(context, "expenseAmount"),
                      textColor: getColor(context, "black"),
                      transactionsAmountStream:
                          database.watchTotalCountOfTransactionsInWallet(
                        null,
                        isIncome: null,
                        startDate: appStateSettings["netWorthStartDate"] == null
                            ? null
                            : DateTime.parse(
                                appStateSettings["netWorthStartDate"]),
                      ),
                      openPage: WalletDetailsPage(wallet: null),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
