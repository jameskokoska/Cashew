import 'package:budget/database/tables.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/pages/subscriptionsPage.dart';
import 'package:budget/pages/transactionsListPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/keepAliveClientMixin.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:budget/widgets/walletEntry.dart';
import 'package:flutter/material.dart';

class HomeUpcomingTransactionSlivers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: Duration(milliseconds: 600),
      curve: Curves.easeInOutCubicEmphasized,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: StreamBuilder<List<Transaction>>(
          stream: database.watchAllUpcomingTransactions(
            // upcoming in 3 days
            endDate: DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day + 4),
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
                          title: "Edit Transaction",
                          transaction: transaction,
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
        ),
      ),
    );
  }
}
