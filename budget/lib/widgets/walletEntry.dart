import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:budget/pages/walletDetailsPage.dart';
import 'package:budget/colors.dart';

class WalletEntry extends StatelessWidget {
  const WalletEntry({super.key, required this.wallet, required this.selected});
  final TransactionWallet wallet;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 6, right: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: boxShadowCheck(boxShadowGeneral(context)),
      ),
      child: OpenContainerNavigation(
        borderRadius: 15,
        openPage: WatchedWalletDetailsPage(walletPk: wallet.walletPk),
        button: (openContainer) {
          return Tappable(
            color: getColor(context, "lightDarkAccentHeavyLight"),
            borderRadius: 15,
            child: AnimatedContainer(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  width: 2,
                  color: selected
                      ? HexColor(wallet.colour,
                              defaultColor:
                                  Theme.of(context).colorScheme.primary)
                          .withOpacity(0.7)
                      : Colors.transparent,
                ),
              ),
              duration: Duration(milliseconds: 450),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      right: -11,
                      top: -5,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: HexColor(wallet.colour,
                                  defaultColor:
                                      Theme.of(context).colorScheme.primary)
                              .withOpacity(0.7),
                        ),
                        width: 20,
                        height: 20,
                      ),
                    ),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 17),
                            child: TextFont(
                              text: wallet.name,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          StreamBuilder<double?>(
                            stream:
                                database.watchTotalOfWallet(wallet.walletPk),
                            builder: (context, snapshot) {
                              return CountNumber(
                                count: (snapshot.data ?? 0 * -1),
                                duration: Duration(milliseconds: 1500),
                                dynamicDecimals: true,
                                decimals: wallet.decimals,
                                initialCount: (snapshot.data ?? 0 * -1),
                                textBuilder: (number) {
                                  return TextFont(
                                    walletPkForCurrency: wallet.walletPk,
                                    textAlign: TextAlign.left,
                                    text: convertToMoney(
                                      number,
                                      showCurrency: false,
                                      finalNumber: snapshot.data ?? 0 * -1,
                                    ),
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  );
                                },
                              );
                            },
                          ),
                          StreamBuilder<List<int?>>(
                            stream:
                                database.watchTotalCountOfTransactionsInWallet(
                                    wallet.walletPk),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                return TextFont(
                                  textAlign: TextAlign.left,
                                  text: snapshot.data![0].toString() +
                                      pluralString(snapshot.data![0] == 1,
                                          " transaction"),
                                  fontSize: 14,
                                  textColor: getColor(context, "black")
                                      .withOpacity(0.65),
                                );
                              } else {
                                return SizedBox();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () async {
              if (selected) {
                openContainer();
              } else {
                setPrimaryWallet(wallet);
              }
            },
            onLongPress: () {
              pushRoute(
                  context, AddWalletPage(title: "Edit Wallet", wallet: wallet));
            },
          );
        },
      ),
    );
  }
}

Future<bool> setPrimaryWallet(TransactionWallet wallet) async {
  await updateSettings("selectedWallet", wallet.walletPk,
      pagesNeedingRefresh: [0, 1, 2]);
  TransactionWallet defaultWallet =
      await database.getWalletInstance(wallet.walletPk);
  updateSettings("selectedWalletCurrency", defaultWallet.currency,
      updateGlobalState: true, pagesNeedingRefresh: [0, 1, 2, 3]);
  updateSettings("selectedWalletDecimals", defaultWallet.decimals,
      updateGlobalState: true, pagesNeedingRefresh: [0, 1, 2, 3]);
  return true;
}

Future<bool> checkPrimaryWallet() async {
  TransactionWallet primaryWallet =
      await database.getWalletInstance(appStateSettings["selectedWallet"]);
  if (primaryWallet.currency == appStateSettings["selectedWalletCurrency"]) {
    return true;
  }
  return false;
}
