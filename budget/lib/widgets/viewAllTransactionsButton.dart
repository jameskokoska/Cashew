import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/pages/budgetPage.dart';
import 'package:budget/pages/settingsPage.dart';
import 'package:budget/pages/subscriptionsPage.dart';
import 'package:budget/pages/transactionsListPage.dart';
import 'package:budget/pages/upcomingOverdueTransactionsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/shareBudget.dart';
import 'package:budget/widgets/SelectedTransactionsActionBar.dart';
import 'package:budget/widgets/budgetContainer.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/lineGraph.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:budget/widgets/walletEntry.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:budget/widgets/scrollbarWrap.dart';

class ViewAllTransactionsButton extends StatelessWidget {
  const ViewAllTransactionsButton({this.onPress, super.key});
  final Function? onPress;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      color: getColor(context, "lightDarkAccent"),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: TextFont(
          text: "View All Transactions",
          textAlign: TextAlign.center,
          fontSize: 16,
          textColor: getColor(context, "textLight"),
        ),
      ),
      onTap: () {
        if (onPress != null)
          onPress!();
        else
          PageNavigationFramework.changePage(context, 1, switchNavbar: true);
      },
      borderRadius: 10,
    );
  }
}
