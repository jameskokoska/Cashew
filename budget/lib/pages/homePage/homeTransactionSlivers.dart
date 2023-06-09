import 'package:budget/database/tables.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/pages/transactionsListPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/keepAliveClientMixin.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/walletEntry.dart';
import 'package:flutter/material.dart';

class HomeTransactionSlivers extends StatelessWidget {
  const HomeTransactionSlivers({
    super.key,
    required this.selectedSlidingSelector,
  });
  final int selectedSlidingSelector;
  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: Duration(milliseconds: 600),
      curve: Curves.easeInOutCubicEmphasized,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: SizedBox(
          key: ValueKey(selectedSlidingSelector),
          child: getTransactionsSlivers(
            showNoResults: false,
            DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day - 7,
            ),
            DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
            ),
            income: selectedSlidingSelector == 1
                ? null
                : selectedSlidingSelector == 2
                    ? false
                    : true,
            sticky: false,
            slivers: false,
            dateDividerColor: Colors.transparent,
            useHorizontalPaddingConstrained: false,
          ),
        ),
      ),
    );
  }
}
