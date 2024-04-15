import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/pages/homePage/homePageWalletSwitcher.dart';
import 'package:budget/pages/transactionFilters.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
import 'package:budget/pages/walletDetailsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/animatedExpanded.dart';
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
    return KeepAliveClientMixin(
      child: StreamBuilder<List<TransactionWallet>>(
          stream:
              database.getAllPinnedWallets(HomePageWidgetDisplay.NetWorth).$1,
          builder: (context, snapshot) {
            if (snapshot.hasData ||
                appStateSettings["netWorthAllWallets"] == true) {
              List<String>? walletPks =
                  (snapshot.data ?? []).map((item) => item.walletPk).toList();
              if (walletPks.length <= 0 ||
                  appStateSettings["netWorthAllWallets"] == true)
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
                          await openNetWorthSettings(context);
                          homePageStateKey.currentState?.refreshState();
                        },
                        label: "net-worth".tr(),
                        absolute: false,
                        currencyKey: Provider.of<AllWallets>(context)
                            .indexedByPk[appStateSettings["selectedWalletPk"]]
                            ?.currency,
                        totalWithCountStream:
                            database.watchTotalWithCountOfWallet(
                          isIncome: null,
                          allWallets: Provider.of<AllWallets>(context),
                          followCustomPeriodCycle: true,
                          cycleSettingsExtension: "NetWorth",
                          searchFilters:
                              SearchFilters(walletPks: walletPks ?? []),
                        ),
                        // getTextColor: (amount) => amount == 0
                        //     ? getColor(context, "black")
                        //     : amount > 0
                        //         ? getColor(context, "incomeAmount")
                        //         : getColor(context, "expenseAmount"),
                        textColor: getColor(context, "black"),
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

class WalletPickerPeriodCycle extends StatefulWidget {
  const WalletPickerPeriodCycle({
    required this.allWalletsSettingKey,
    required this.cycleSettingsExtension,
    required this.homePageWidgetDisplay,
    this.onlyShowCycleOption = false,
    super.key,
  });
  final String? allWalletsSettingKey;
  final String cycleSettingsExtension;
  final HomePageWidgetDisplay? homePageWidgetDisplay;
  final bool onlyShowCycleOption;

  @override
  State<WalletPickerPeriodCycle> createState() =>
      _WalletPickerPeriodCycleState();
}

class _WalletPickerPeriodCycleState extends State<WalletPickerPeriodCycle> {
  late bool allWalletsSelected =
      appStateSettings[widget.allWalletsSettingKey] == true;

  @override
  Widget build(BuildContext context) {
    // We can hide the all wallets selection if only one wallet
    // If no wallets selected, all of them are by default, so even if user removes one
    // and we didn't have any selected, we are okay!
    bool showAllWalletsSelection = widget.homePageWidgetDisplay != null &&
        widget.allWalletsSettingKey != null &&
        Provider.of<AllWallets>(context).list.length > 1;
    return Column(
      children: [
        if (showAllWalletsSelection)
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
                    padding: EdgeInsets.only(
                        left: 20, right: 15, top: 15, bottom: 15),
                    showToggleSwitch: true,
                    text: "all-accounts".tr(),
                    iconData: appStateSettings["outlinedIcons"]
                        ? Icons.account_balance_wallet_outlined
                        : Icons.account_balance_wallet_rounded,
                    onTap: () {
                      updateSettings(
                          widget.allWalletsSettingKey!, !allWalletsSelected,
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
        if (showAllWalletsSelection) SizedBox(height: 10),
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
        if (showAllWalletsSelection)
          AnimatedExpanded(
            axis: Axis.vertical,
            expand: allWalletsSelected == false,
            child: EditHomePagePinnedWalletsPopup(
              includeFramework: false,
              homePageWidgetDisplay: widget.homePageWidgetDisplay!,
              highlightSelected: true,
              useCheckMarks: true,
              onAnySelected: () {
                updateSettings(widget.allWalletsSettingKey!, false,
                    updateGlobalState: false);
                setState(() {
                  allWalletsSelected = false;
                });
              },
              allSelected: allWalletsSelected,
            ),
          ),
        Padding(
          padding: showAllWalletsSelection
              ? EdgeInsets.zero
              : const EdgeInsets.only(top: 8.0),
          child: HorizontalBreakAbove(
            enabled: showAllWalletsSelection,
            child: PeriodCyclePicker(
              cycleSettingsExtension: widget.cycleSettingsExtension,
              onlyShowCycleOption: widget.onlyShowCycleOption,
            ),
          ),
        ),
      ],
    );
  }
}

Future openNetWorthSettings(BuildContext context) {
  return openBottomSheet(
    context,
    PopupFramework(
      title: "net-worth".tr(),
      subtitle: "applies-to-homepage".tr() +
          (getPlatform(ignoreEmulation: true) == PlatformOS.isAndroid
              ? " " + "and-applies-to-widget".tr()
              : ""),
      child: WalletPickerPeriodCycle(
        allWalletsSettingKey: "netWorthAllWallets",
        cycleSettingsExtension: "NetWorth",
        homePageWidgetDisplay: HomePageWidgetDisplay.NetWorth,
      ),
    ),
  );
}
