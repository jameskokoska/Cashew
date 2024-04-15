import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/pages/homePage/homePageNetWorth.dart';
import 'package:budget/pages/transactionFilters.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
import 'package:budget/pages/walletDetailsPage.dart';
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
      child: StreamBuilder<List<TransactionWallet>>(
        stream: database
            .getAllPinnedWallets(HomePageWidgetDisplay.AllSpendingSummary)
            .$1,
        builder: (context, snapshot) {
          if (snapshot.hasData ||
              appStateSettings["allSpendingSummaryAllWallets"] == true) {
            List<String>? walletPks =
                (snapshot.data ?? []).map((item) => item.walletPk).toList();
            if (walletPks.length <= 0 ||
                appStateSettings["allSpendingSummaryAllWallets"] == true)
              walletPks = null;
            return Padding(
              padding: const EdgeInsets.only(bottom: 13, left: 13, right: 13),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TransactionsAmountBox(
                      onLongPress: () async {
                        await openAllSpendingSettings(context);
                        homePageStateKey.currentState?.refreshState();
                      },
                      label: "expense".tr(),
                      totalWithCountStream:
                          database.watchTotalWithCountOfWallet(
                        isIncome: false,
                        allWallets: Provider.of<AllWallets>(context),
                        followCustomPeriodCycle: true,
                        cycleSettingsExtension: "AllSpendingSummary",
                        onlyIncomeAndExpense: true,
                        searchFilters:
                            SearchFilters(walletPks: walletPks ?? []),
                      ),
                      textColor: getColor(context, "expenseAmount"),
                      openPage: TransactionsSearchPage(
                        initialFilters: SearchFilters().copyWith(
                          dateTimeRange: getDateTimeRangeForPassedSearchFilters(
                              cycleSettingsExtension: "AllSpendingSummary"),
                          walletPks: walletPks ?? [],
                          expenseIncome: [ExpenseIncome.expense],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 13),
                  Expanded(
                    child: TransactionsAmountBox(
                      onLongPress: () async {
                        await openAllSpendingSettings(context);
                        homePageStateKey.currentState?.refreshState();
                      },
                      label: "income".tr(),
                      totalWithCountStream:
                          database.watchTotalWithCountOfWallet(
                        isIncome: true,
                        allWallets: Provider.of<AllWallets>(context),
                        followCustomPeriodCycle: true,
                        cycleSettingsExtension: "AllSpendingSummary",
                        onlyIncomeAndExpense: true,
                        searchFilters:
                            SearchFilters(walletPks: walletPks ?? []),
                      ),
                      textColor: getColor(context, "incomeAmount"),
                      openPage: TransactionsSearchPage(
                        initialFilters: SearchFilters().copyWith(
                          dateTimeRange: getDateTimeRangeForPassedSearchFilters(
                              cycleSettingsExtension: "AllSpendingSummary"),
                          walletPks: walletPks ?? [],
                          expenseIncome: [ExpenseIncome.income],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}

Future openAllSpendingSettings(BuildContext context) {
  return openBottomSheet(
    context,
    PopupFramework(
      title: "income-and-expenses".tr(),
      subtitle: "applies-to-homepage".tr(),
      child: WalletPickerPeriodCycle(
        allWalletsSettingKey: "allSpendingSummaryAllWallets",
        cycleSettingsExtension: "AllSpendingSummary",
        homePageWidgetDisplay: HomePageWidgetDisplay.AllSpendingSummary,
      ),
    ),
  );
}
