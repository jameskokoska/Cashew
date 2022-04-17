import 'package:budget/database/tables.dart';
import 'package:budget/pages/addWalletPage.dart';
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
        color: selected ? HexColor(wallet.colour) : Colors.transparent,
        borderRadius: 15,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: selected ? 0 : 1.5,
              color: HexColor(wallet.colour).withOpacity(0.7),
            ),
            borderRadius: BorderRadius.circular(15),
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
                TextFont(
                  text: "\$ -9,700",
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                TextFont(
                  text: "5 transactions",
                  fontSize: 14,
                  textColor:
                      Theme.of(context).colorScheme.black.withOpacity(0.65),
                ),
              ],
            ),
          ),
        ),
        onTap: () {},
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
