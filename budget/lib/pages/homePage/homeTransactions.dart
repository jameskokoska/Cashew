import 'package:budget/database/tables.dart';
import 'package:budget/pages/transactionFilters.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/transactionEntries.dart';
import 'package:flutter/material.dart';

class HomeTransactions extends StatelessWidget {
  const HomeTransactions({
    super.key,
    required this.selectedSlidingSelector,
  });
  final int selectedSlidingSelector;
  @override
  Widget build(BuildContext context) {
    int numberOfFutureDays = appStateSettings["futureTransactionDaysHomePage"];
    return TransactionEntries(
      showNumberOfDaysUntilForFutureDates: true,
      renderType: TransactionEntriesRenderType.nonSlivers,
      showNoResults: false,
      DateTime(
        DateTime.now().year,
        DateTime.now().month - 1,
        DateTime.now().day,
      ),
      DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day + numberOfFutureDays,
      ),
      dateDividerColor: Colors.transparent,
      useHorizontalPaddingConstrained: false,
      pastDaysLimitToShow: 7,
      limitPerDay: 50,
      searchFilters: SearchFilters().copyWith(
          expenseIncome: (selectedSlidingSelector == 1)
              ? null
              : [
                  if (selectedSlidingSelector == 2) ExpenseIncome.expense,
                  if (selectedSlidingSelector == 3) ExpenseIncome.income,
                ]),
    );
  }
}
