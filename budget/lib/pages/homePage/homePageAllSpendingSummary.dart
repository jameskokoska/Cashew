import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/pages/transactionFilters.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/periodCyclePicker.dart';
import 'package:budget/widgets/util/keepAliveClientMixin.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/transactionsAmountBox.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePageAllSpendingSummary extends StatelessWidget {
  const HomePageAllSpendingSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return KeepAliveClientMixin(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 13, left: 13, right: 13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: TransactionsAmountBox(
                onLongPress: () async {
                  await openBottomSheet(
                    context,
                    PopupFramework(
                      title: "select-period".tr(),
                      child: PeriodCyclePicker(
                        cycleSettingsExtension: "AllSpendingSummary",
                      ),
                    ),
                  );
                  homePageStateKey.currentState?.refreshState();
                },
                label: "expense".tr(),
                totalWithCountStream: database.watchTotalWithCountOfWallet(
                  isIncome: false,
                  allWallets: Provider.of<AllWallets>(context),
                  followCustomPeriodCycle: true,
                  cycleSettingsExtension: "AllSpendingSummary",
                  onlyIncomeAndExpense: true,
                ),
                textColor: getColor(context, "expenseAmount"),
                openPage: TransactionsSearchPage(
                  initialFilters: SearchFilters(
                    expenseIncome: [ExpenseIncome.expense],
                  ),
                ),
              ),
            ),
            SizedBox(width: 13),
            Expanded(
              child: TransactionsAmountBox(
                onLongPress: () async {
                  await openBottomSheet(
                    context,
                    PopupFramework(
                      title: "select-period".tr(),
                      child: PeriodCyclePicker(
                        cycleSettingsExtension: "AllSpendingSummary",
                      ),
                    ),
                  );
                  homePageStateKey.currentState?.refreshState();
                },
                label: "income".tr(),
                totalWithCountStream: database.watchTotalWithCountOfWallet(
                  isIncome: true,
                  allWallets: Provider.of<AllWallets>(context),
                  followCustomPeriodCycle: true,
                  cycleSettingsExtension: "AllSpendingSummary",
                  onlyIncomeAndExpense: true,
                ),
                textColor: getColor(context, "incomeAmount"),
                openPage: TransactionsSearchPage(
                  initialFilters: SearchFilters(
                    expenseIncome: [ExpenseIncome.income],
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
