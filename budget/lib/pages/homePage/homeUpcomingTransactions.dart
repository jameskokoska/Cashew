import 'package:budget/database/tables.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/subscriptionsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/transactionEntry/transactionEntry.dart';
import 'package:flutter/material.dart';

class HomeUpcomingTransactions extends StatelessWidget {
  const HomeUpcomingTransactions(
      {required this.selectedSlidingSelector, super.key});
  final int selectedSlidingSelector;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Transaction>>(
      stream: database.watchAllUpcomingTransactions(
        // upcoming in 3 days
        startDate: DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day + 1),
        endDate: DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day + 4),
        isIncome: selectedSlidingSelector == 1
            ? null
            : selectedSlidingSelector == 2
                ? false
                : true,
        null,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.length <= 0) {
            return SizedBox.shrink();
          }
          List<Widget> children = [];
          for (Transaction transaction in snapshot.data!) {
            children.add(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UpcomingTransactionDateHeader(
                    transaction: transaction,
                    small: true,
                    useHorizontalPaddingConstrained: false,
                  ),
                  TransactionEntry(
                    useHorizontalPaddingConstrained: false,
                    openPage: AddTransactionPage(
                      transaction: transaction,
                      routesToPopAfterDelete: RoutesToPopAfterDelete.One,
                    ),
                    transaction: transaction,
                  ),
                  SizedBox(height: 5),
                ],
              ),
            );
          }
          return Column(children: children);
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
