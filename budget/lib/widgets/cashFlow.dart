import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:provider/provider.dart';

class CashFlow extends StatelessWidget {
  const CashFlow(this.startDate, this.endDate, {super.key});

  final DateTime startDate;
  final DateTime endDate;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double?>(
      stream: database.watchTotalSpentInTimeRangeFromCategories(
        allWallets: Provider.of<AllWallets>(context),
        start: startDate,
        end: endDate,
        categoryFks: null,
        categoryFksExclude: null,
        budgetTransactionFilters: null,
        memberTransactionFilters: null,
        allCashFlow: true,
      ),
      builder: (context, snapshot) {
        if (snapshot.data != null && snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: TextFont(
              text: "total-cash-flow".tr() +
                  ": " +
                  convertToMoney(
                      Provider.of<AllWallets>(context), snapshot.data!),
              fontSize: 13,
              textAlign: TextAlign.center,
              textColor: getColor(context, "textLight"),
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
