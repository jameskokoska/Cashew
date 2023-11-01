import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/pages/homePage/homePageWalletSwitcher.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
import 'package:budget/pages/walletDetailsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/util/keepAliveClientMixin.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/outlinedButtonStacked.dart';
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
    if (isHomeScreenSectionEnabled(context, "showNetWorth") == false)
      return SizedBox.shrink();
    return KeepAliveClientMixin(
      child: StreamBuilder<List<TransactionWallet>>(
          stream:
              database.getAllPinnedWallets(HomePageWidgetDisplay.NetWorth).$1,
          builder: (context, snapshot) {
            if (snapshot.hasData ||
                appStateSettings["netWorthAllWallets"] == true) {
              List<String>? walletPks =
                  (snapshot.data ?? []).map((item) => item.walletPk).toList();
              if (appStateSettings["netWorthAllWallets"] == true)
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
                          await openBottomSheet(
                            context,
                            NetWorthSettings(),
                          );
                          homePageStateKey.currentState?.refreshState();
                        },
                        label: "net-worth".tr(),
                        absolute: false,
                        currencyKey: Provider.of<AllWallets>(context)
                            .indexedByPk[appStateSettings["selectedWalletPk"]]
                            ?.currency,
                        amountStream: database.watchTotalOfWallet(
                          walletPks,
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
                          walletPks,
                          isIncome: null,
                          followCustomPeriodCycle: true,
                        ),
                        openPage: WalletDetailsPage(wallet: null),
                      ),
                    ),
                  ],
                ),
              );
            }
            return SizedBox.shrink();
          }),
    );
  }
}

class NetWorthSettings extends StatefulWidget {
  const NetWorthSettings({super.key});

  @override
  State<NetWorthSettings> createState() => _NetWorthSettingsState();
}

class _NetWorthSettingsState extends State<NetWorthSettings> {
  bool allWalletsSelected = appStateSettings["netWorthAllWallets"];

  @override
  Widget build(BuildContext context) {
    return PopupFramework(
      title: "net-worth-settings".tr(),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 500),
                  opacity: allWalletsSelected ? 1 : 0.5,
                  child: OutlinedButtonStacked(
                    filled: allWalletsSelected,
                    alignLeft: true,
                    alignBeside: true,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    text: "all-accounts".tr(),
                    iconData: appStateSettings["outlinedIcons"]
                        ? Icons.account_balance_wallet_outlined
                        : Icons.account_balance_wallet_rounded,
                    onTap: () {
                      updateSettings("netWorthAllWallets", !allWalletsSelected,
                          updateGlobalState: false);
                      setState(() {
                        allWalletsSelected = !allWalletsSelected;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          // CheckItems(
          //   triggerInitialOnChanged: false,
          //   minVerticalPadding: 0,
          //   allSelected: allWalletsSelected,
          //   initial: (appStateSettings["netWorthSelectedWalletPks"] ?? [])
          //       .cast<String>(),
          //   items: [
          //     for (String walletPk
          //         in Provider.of<AllWallets>(context, listen: false)
          //             .indexedByPk
          //             .keys)
          //       walletPk
          //   ],
          //   onChanged: (currentValues) {
          //     updateSettings("netWorthAllWallets", false,
          //         updateGlobalState: false);
          //     setState(() {
          //       allWalletsSelected = false;
          //     });
          //   },
          //   displayFilter: (item, itemIndex) {
          //     return Provider.of<AllWallets>(context, listen: false)
          //         .indexedByPk[item]!
          //         .name;
          //   },
          //   colorFilter: (item) {
          //     return dynamicPastel(
          //       context,
          //       lightenPastel(
          //         HexColor(
          //             Provider.of<AllWallets>(context, listen: false)
          //                 .indexedByPk[item]!
          //                 .colour,
          //             defaultColor: Theme.of(context).colorScheme.primary),
          //         amount: 0.2,
          //       ),
          //       amount: 0.1,
          //     );
          //   },
          // ),
          EditHomePagePinnedWalletsPopup(
            includeFramework: false,
            homePageWidgetDisplay: HomePageWidgetDisplay.NetWorth,
            highlightSelected: true,
            useCheckMarks: true,
            onAnySelected: () {
              updateSettings("netWorthAllWallets", false,
                  updateGlobalState: false);
              setState(() {
                allWalletsSelected = false;
              });
            },
            allSelected: allWalletsSelected,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child:
                HorizontalBreakAbove(enabled: true, child: PeriodCyclePicker()),
          ),
        ],
      ),
    );
  }
}
