import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
import 'package:budget/pages/walletDetailsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/keepAliveClientMixin.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/periodCyclePicker.dart';
import 'package:budget/widgets/radioItems.dart';
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
                        appStateSettings["netWorthSelectedWalletPks"],
                        isIncome: null,
                        allWallets: Provider.of<AllWallets>(context),
                        followCustomPeriodCycle: true,
                      ),
                      // getTextColor: (amount) => amount == 0
                      //     ? getColor(context, "black")
                      //     : amount > 0
                      //         ? getColor(context, "incomeAmount")
                      //         : getColor(context, "expenseAmount"),
                      textColor: getColor(context, "black"),
                      transactionsAmountStream:
                          database.watchTotalCountOfTransactionsInWallet(
                        appStateSettings["netWorthSelectedWalletPks"],
                        isIncome: null,
                        followCustomPeriodCycle: true,
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

class NetWorthSettings extends StatefulWidget {
  const NetWorthSettings({super.key});

  @override
  State<NetWorthSettings> createState() => _NetWorthSettingsState();
}

class _NetWorthSettingsState extends State<NetWorthSettings> {
  bool allWalletsSelected =
      appStateSettings["netWorthSelectedWalletPks"] == null;

  @override
  Widget build(BuildContext context) {
    print(allWalletsSelected);
    return PopupFramework(
      title: "net-worth-settings".tr(),
      child: Column(
        children: [
          CheckItems(
            triggerInitialOnChanged: false,
            minVerticalPadding: 0,
            allSelected: allWalletsSelected,
            initial: allWalletsSelected ? ["all"] : [],
            syncWithInitial: true,
            items: ["all"],
            onChanged: (currentValues) {
              updateSettings("netWorthSelectedWalletPks", null,
                  updateGlobalState: false);
              setState(() {
                allWalletsSelected = true;
              });
            },
            displayFilter: (item, itemIndex) {
              return "all-accounts".tr();
            },
            selectedIcon: Icons.radio_button_checked_rounded,
            unSelectedIcon: Icons.radio_button_off_rounded,
          ),
          SizedBox(height: 5),
          CheckItems(
            triggerInitialOnChanged: false,
            minVerticalPadding: 0,
            allSelected: allWalletsSelected,
            initial: (appStateSettings["netWorthSelectedWalletPks"] ?? [])
                .cast<String>(),
            items: [
              for (String walletPk
                  in Provider.of<AllWallets>(context, listen: false)
                      .indexedByPk
                      .keys)
                walletPk
            ],
            onChanged: (currentValues) {
              updateSettings("netWorthSelectedWalletPks", currentValues,
                  updateGlobalState: false);
              setState(() {
                allWalletsSelected = false;
              });
            },
            displayFilter: (item, itemIndex) {
              return Provider.of<AllWallets>(context, listen: false)
                  .indexedByPk[item]!
                  .name;
            },
            colorFilter: (item) {
              return dynamicPastel(
                context,
                lightenPastel(
                  HexColor(Provider.of<AllWallets>(context, listen: false)
                      .indexedByPk[item]!
                      .colour),
                  amount: 0.2,
                ),
                amount: 0.1,
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child:
                HorizontalBreakAbove(enabled: true, child: PeriodCyclePicker()),
          ),
        ],
      ),
    );
  }
}
