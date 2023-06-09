import 'package:budget/database/tables.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/pages/subscriptionsPage.dart';
import 'package:budget/pages/transactionsListPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/keepAliveClientMixin.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:budget/widgets/upcomingTransactions.dart';
import 'package:budget/widgets/walletEntry.dart';
import 'package:flutter/material.dart';

class HomePageUpcomingTransactions extends StatelessWidget {
  const HomePageUpcomingTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    return !appStateSettings["showOverdueUpcoming"] &&
            enableDoubleColumn(context) == false
        ? SizedBox.shrink()
        : KeepAliveClientMixin(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 13, left: 13, right: 13),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: UpcomingTransactions()),
                  SizedBox(width: 13),
                  Expanded(
                    child: UpcomingTransactions(
                      overdueTransactions: true,
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
