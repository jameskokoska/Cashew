import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/pages/subscriptionsPage.dart';
import 'package:budget/pages/transactionsListPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/keepAliveClientMixin.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:budget/widgets/walletEntry.dart';
import 'package:flutter/material.dart';

class HomePageUsername extends StatelessWidget {
  final AnimationController animationControllerHeader;
  final AnimationController animationControllerHeader2;
  final bool showUsername;
  final Map<String, dynamic> appStateSettings;
  final Function enterNameBottomSheet;

  HomePageUsername({
    required this.animationControllerHeader,
    required this.animationControllerHeader2,
    required this.showUsername,
    required this.appStateSettings,
    required this.enterNameBottomSheet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        !showUsername
            ? SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9),
                child: AnimatedBuilder(
                  animation: animationControllerHeader,
                  builder: (_, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        20 - 20 * (animationControllerHeader.value),
                      ),
                      child: child,
                    );
                  },
                  child: FadeTransition(
                    opacity: animationControllerHeader2,
                    child: TextFont(
                      text: getWelcomeMessage(),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
        AnimatedBuilder(
          animation: animationControllerHeader,
          builder: (_, child) {
            return Transform.scale(
              alignment: Alignment.bottomLeft,
              scale: animationControllerHeader.value < 0.5
                  ? 0.25 + 0.5
                  : (animationControllerHeader.value) * 0.5 + 0.5,
              child: Tappable(
                onTap: () {
                  enterNameBottomSheet(context);
                },
                onLongPress: () {
                  enterNameBottomSheet(context);
                },
                borderRadius: 15,
                child: child ?? SizedBox.shrink(),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9),
            child: TextFont(
              text: !showUsername ? "Home" : appStateSettings["username"] ?? "",
              fontWeight: FontWeight.bold,
              fontSize: 39,
              textColor: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}
