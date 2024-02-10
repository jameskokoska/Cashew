import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/pages/homePage/homePageWalletSwitcher.dart';
import 'package:budget/struct/currencyFunctions.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/util/keepAliveClientMixin.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/walletEntry.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../addButton.dart';

class HomePageWalletList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const double borderRadius = 15;
    return KeepAliveClientMixin(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 13, left: 13, right: 13),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: boxShadowCheck(boxShadowGeneral(context)),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Tappable(
              color: getColor(context, "lightDarkAccentHeavyLight"),
              borderRadius: borderRadius,
              onLongPress: () async {
                await openBottomSheet(
                  context,
                  EditHomePagePinnedWalletsPopup(
                    homePageWidgetDisplay: HomePageWidgetDisplay.WalletList,
                    showCyclePicker: true,
                  ),
                  useCustomController: true,
                );
                homePageStateKey.currentState?.refreshState();
              },
              child: Column(
                children: [
                  StreamBuilder<List<WalletWithDetails>>(
                    stream: database.watchAllWalletsWithDetails(
                        homePageWidgetDisplay:
                            HomePageWidgetDisplay.WalletList),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            if (snapshot.hasData && snapshot.data!.length > 0)
                              SizedBox(height: 8),
                            for (WalletWithDetails walletDetails
                                in snapshot.data!)
                              WalletEntryRow(
                                selected:
                                    appStateSettings["selectedWalletPk"] ==
                                        walletDetails.wallet.walletPk,
                                walletWithDetails: walletDetails,
                              ),
                            if (snapshot.hasData && snapshot.data!.length > 0)
                              SizedBox(height: 8),
                            if (snapshot.hasData && snapshot.data!.length <= 0)
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: AddButton(
                                      onTap: () async {
                                        await openBottomSheet(
                                          context,
                                          EditHomePagePinnedWalletsPopup(
                                            homePageWidgetDisplay:
                                                HomePageWidgetDisplay
                                                    .WalletList,
                                          ),
                                          useCustomController: true,
                                        );
                                        homePageStateKey.currentState
                                            ?.refreshState();
                                      },
                                      height: null,
                                      labelUnder: "account".tr(),
                                      icon: Icons.format_list_bulleted_add,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        );
                      }
                      return Container();
                    },
                  ),
                  if (appStateSettings["walletsListCurrencyBreakdown"] ==
                          true &&
                      Provider.of<AllWallets>(context)
                              .allContainSameCurrency() ==
                          false &&
                      Provider.of<AllWallets>(context)
                              .containsMultipleAccountsWithSameCurrency() ==
                          true)
                    HorizontalBreakAbove(
                      padding: EdgeInsets.zero,
                      child: StreamBuilder<List<WalletWithDetails>>(
                        stream: database.watchAllWalletsWithDetails(
                            mergeLikeCurrencies: true),
                        builder: (context, snapshot) {
                          double totalAmountSpent = (snapshot.data ?? []).fold(
                              0.0, (double acc, WalletWithDetails wallet) {
                            return acc +
                                (wallet.totalSpent ?? 0.0) *
                                    amountRatioToPrimaryCurrency(
                                        Provider.of<AllWallets>(context),
                                        wallet.wallet.currency);
                          });

                          if (snapshot.hasData) {
                            return Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                if (snapshot.hasData &&
                                    snapshot.data!.length > 0)
                                  SizedBox(height: 8),
                                for (WalletWithDetails walletDetails
                                    in snapshot.data!)
                                  WalletEntryRow(
                                    selected: Provider.of<AllWallets>(context)
                                            .indexedByPk[appStateSettings[
                                                "selectedWalletPk"]]
                                            ?.currency ==
                                        walletDetails.wallet.currency,
                                    walletWithDetails: walletDetails,
                                    isCurrencyRow: true,
                                    percent: (totalAmountSpent == 0
                                                ? 0
                                                : ((walletDetails.totalSpent ??
                                                            0) *
                                                        amountRatioToPrimaryCurrency(
                                                            Provider.of<
                                                                    AllWallets>(
                                                                context),
                                                            walletDetails.wallet
                                                                .currency)) /
                                                    totalAmountSpent)
                                            .abs() *
                                        100
                                    // * ((walletDetails.totalSpent ?? 0) < 0
                                    //     ? -1
                                    //     : 1)
                                    ,
                                  ),
                                if (snapshot.hasData &&
                                    snapshot.data!.length > 0)
                                  SizedBox(height: 8),
                              ],
                            );
                          }
                          return Container();
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
