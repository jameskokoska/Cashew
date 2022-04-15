import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/transactionCategory.dart';
import 'package:budget/struct/transactionTag.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/material.dart';
import '../colors.dart';

class CategoryEntry extends StatelessWidget {
  CategoryEntry(
      {Key? key,
      required this.category,
      required this.transactionCount,
      required this.totalSpent})
      : super(key: key);

  final TransactionCategory category;
  final int transactionCount;
  final double totalSpent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 1),
      child: Container(
        margin: EdgeInsets.only(left: 5, right: 10, top: 6, bottom: 6),
        child: Row(
          children: [
            // CategoryIcon(
            //   category: category,
            //   size: 30,
            //   margin: EdgeInsets.zero,
            // ),
            CategoryIcon(
              categoryPk: category.categoryPk,
              size: 33,
              sizePadding: 15,
              margin: EdgeInsets.zero,
            ),
            Container(
              width: 15,
            ),
            Expanded(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFont(
                      text: category.name,
                      fontSize: 20,
                    ),
                    TextFont(
                      text: transactionCount == 1
                          ? transactionCount.toString() + " transaction"
                          : transactionCount.toString() + " transactions",
                      fontSize: 15,
                    )
                  ],
                ),
              ),
            ),
            //TODO: add total amount of this category within time period
            TextFont(
              fontWeight: FontWeight.bold,
              text: convertToMoney(totalSpent),
              fontSize: 23,
            ),
          ],
        ),
      ),
    );
  }
}
