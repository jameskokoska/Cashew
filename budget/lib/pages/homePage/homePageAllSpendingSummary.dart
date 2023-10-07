import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/keepAliveClientMixin.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/transactionsAmountBox.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePageAllSpendingSummary extends StatelessWidget {
  const HomePageAllSpendingSummary({super.key});

  @override
  Widget build(BuildContext context) {
    if (isHomeScreenSectionEnabled(context, "showAllSpendingSummary") == false)
      return SizedBox.shrink();
    return KeepAliveClientMixin(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 13, left: 13, right: 13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: TransactionsAmountBox(
                label: "income".tr(),
                amountStream: database.watchTotalOfWallet(
                  null,
                  isIncome: true,
                  allWallets: Provider.of<AllWallets>(context),
                  followCustomPeriodCycle: true,
                ),
                textColor: getColor(context, "incomeAmount"),
                transactionsAmountStream:
                    database.watchTotalCountOfTransactionsInWallet(
                  null,
                  isIncome: true,
                  followCustomPeriodCycle: true,
                ),
                openPage: TransactionsSearchPage(
                  initialFilters: SearchFilters(
                    expenseIncome: [ExpenseIncome.income],
                  ),
                ),
              ),
            ),
            SizedBox(width: 13),
            Expanded(
              child: TransactionsAmountBox(
                label: "expense".tr(),
                amountStream: database.watchTotalOfWallet(
                  null,
                  isIncome: false,
                  allWallets: Provider.of<AllWallets>(context),
                  followCustomPeriodCycle: true,
                ),
                textColor: getColor(context, "expenseAmount"),
                transactionsAmountStream:
                    database.watchTotalCountOfTransactionsInWallet(
                  null,
                  isIncome: false,
                  followCustomPeriodCycle: true,
                ),
                openPage: TransactionsSearchPage(
                  initialFilters: SearchFilters(
                    expenseIncome: [ExpenseIncome.expense],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
