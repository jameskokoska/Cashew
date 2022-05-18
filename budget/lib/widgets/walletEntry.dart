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
import 'package:budget/colors.dart';

class WalletEntry extends StatelessWidget {
  WalletEntry({
    Key? key,
    required this.wallet,
    required this.selected,
  }) : super(key: key);

  final TransactionWallet wallet;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 6),
      child: Tappable(
        borderRadius: 15,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 250),
          decoration: BoxDecoration(
            border: Border.all(
              width: 1.5,
              color: HexColor(wallet.colour).withOpacity(0.7),
            ),
            borderRadius: BorderRadius.circular(15),
            color: selected ? HexColor(wallet.colour) : Colors.transparent,
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 18, right: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFont(
                  text: wallet.name,
                  fontWeight: FontWeight.bold,
                ),
                StreamBuilder<List<double?>>(
                  stream: database.watchTotalOfWallet(wallet.walletPk),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return CountNumber(
                        count: (snapshot.data![0] ?? 0 * -1),
                        duration: Duration(milliseconds: 4000),
                        dynamicDecimals: true,
                        initialCount: (snapshot.data![0] ?? 0 * -1),
                        textBuilder: (number) {
                          return TextFont(
                            textAlign: TextAlign.left,
                            text: convertToMoney(number),
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          );
                        },
                      );
                    } else {
                      return SizedBox();
                    }
                  },
                ),
                StreamBuilder<List<int?>>(
                  stream: database
                      .watchTotalCountOfTransactionsInWallet(wallet.walletPk),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return TextFont(
                        textAlign: TextAlign.left,
                        text: snapshot.data![0] == 1
                            ? (snapshot.data![0].toString() + " transaction")
                            : (snapshot.data![0].toString() + " transactions"),
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
        ),
        onTap: () {
          updateSettings("selectedWallet", wallet.walletPk,
              pagesNeedingRefresh: [0, 1, 2]);
        },
      ),
    );
  }
}

class WalletEntryAdd extends StatelessWidget {
  const WalletEntryAdd({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 6 + 8),
      child: OpenContainerNavigation(
        borderRadius: 15,
        closedColor: Theme.of(context).canvasColor,
        button: (openContainer) {
          return Tappable(
            color: Colors.transparent,
            borderRadius: 15,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1.5,
                  color: Theme.of(context).colorScheme.lightDarkAccentHeavy,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              width: 110,
              child: Center(
                child: TextFont(
                  text: "+",
                  fontWeight: FontWeight.bold,
                  textColor: Theme.of(context).colorScheme.lightDarkAccentHeavy,
                ),
              ),
            ),
            onTap: () {
              openContainer();
            },
          );
        },
        openPage: AddWalletPage(
          title: "Add Wallet",
        ),
      ),
    );
  }
}
