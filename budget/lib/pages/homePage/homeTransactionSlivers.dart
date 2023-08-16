import 'package:budget/widgets/animatedExpanded.dart';
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
    return AnimatedSizeSwitcher(
      child: SizedBox(
        key: ValueKey(selectedSlidingSelector),
        child: TransactionEntries(
          showNoResults: false,
          DateTime(
            DateTime.now().year,
            DateTime.now().month - 1,
            DateTime.now().day,
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
          pastDaysLimitToShow: 7,
        ),
      ),
    );
  }
}
