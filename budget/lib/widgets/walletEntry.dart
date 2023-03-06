import 'dart:developer';

import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:budget/pages/walletDetailsPage.dart';
import 'package:budget/colors.dart';

class WalletEntry extends StatefulWidget {
  WalletEntry({
    Key? key,
    required this.wallet,
    required this.selected,
  }) : super(key: key);

  final TransactionWallet wallet;
  final bool selected;

  @override
  State<WalletEntry> createState() => _WalletEntryState();
}

class _WalletEntryState extends State<WalletEntry>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

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
        openPage: WalletDetailsPage(wallet: widget.wallet),
        button: (openContainer) {
          return Tappable(
            color: Theme.of(context).colorScheme.lightDarkAccentHeavyLight,
            borderRadius: 15,
            child: AnimatedContainer(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  width: 2,
                  color: widget.selected
                      ? HexColor(widget.wallet.colour,
                              defaultColor:
                                  Theme.of(context).colorScheme.primary)
                          .withOpacity(0.7)
                      : Colors.transparent,
                ),
              ),
              duration: Duration(milliseconds: 450),
              child: Padding(
                padding: const EdgeInsets.only(left: 18, right: 18),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      right: -10,
                      top: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: HexColor(widget.wallet.colour,
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
                              text: widget.wallet.name,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          StreamBuilder<double?>(
                            stream: database
                                .watchTotalOfWallet(widget.wallet.walletPk),
                            builder: (context, snapshot) {
                              return CountNumber(
                                count: (snapshot.data ?? 0 * -1),
                                duration: Duration(milliseconds: 4000),
                                dynamicDecimals: true,
                                initialCount: (snapshot.data ?? 0 * -1),
                                textBuilder: (number) {
                                  return TextFont(
                                    walletPkForCurrency: widget.wallet.walletPk,
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
                                    widget.wallet.walletPk),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                return TextFont(
                                  textAlign: TextAlign.left,
                                  text: snapshot.data![0].toString() +
                                      pluralString(snapshot.data![0] == 1,
                                          " transaction"),
                                  fontSize: 14,
                                  textColor: Theme.of(context)
                                      .colorScheme
                                      .black
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
              if (widget.selected) {
                openContainer();
              } else {
                updateSettings("selectedWallet", widget.wallet.walletPk,
                    pagesNeedingRefresh: [0, 1, 2]);
                TransactionWallet defaultWallet =
                    await database.getWalletInstance(widget.wallet.walletPk);
                updateSettings("selectedWalletCurrency", defaultWallet.currency,
                    updateGlobalState: true, pagesNeedingRefresh: [0, 1, 2, 3]);
              }
            },
            onLongPress: () {
              pushRoute(context,
                  AddWalletPage(title: "Edit Wallet", wallet: widget.wallet));
            },
          );
        },
      ),
    );
  }
}
