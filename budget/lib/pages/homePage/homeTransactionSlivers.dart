import 'package:budget/widgets/transactionEntries.dart';
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
          child: TransactionEntries(
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
