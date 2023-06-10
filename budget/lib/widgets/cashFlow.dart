import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/widgets/scrollbarWrap.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/budgetPage.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/shareBudget.dart';
import 'package:budget/widgets/selectedTransactionsActionBar.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/monthSelector.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:budget/main.dart';
import 'package:budget/colors.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'dart:math';
import 'package:flutter/rendering.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:budget/widgets/util/sliverPinnedOverlapInjector.dart';
import 'package:budget/widgets/util/multiDirectionalInfiniteScroll.dart';

class CashFlow extends StatelessWidget {
  const CashFlow(this.startDate, this.endDate, {super.key});

  final DateTime startDate;
  final DateTime endDate;

  @override
  Widget build(BuildContext context) {
    return WatchAllWallets(
      childFunction: (wallets) => StreamBuilder<double?>(
        stream: database.watchTotalSpentInTimeRangeFromCategories(
            startDate, endDate, [], true, wallets, null, null,
            allCashFlow: true),
        builder: (context, snapshot) {
          if (snapshot.data != null && snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 17),
              child: TextFont(
                text: "Total cash flow: " + convertToMoney(snapshot.data!),
                fontSize: 13,
                textAlign: TextAlign.center,
                textColor: getColor(context, "textLight"),
              ),
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}
