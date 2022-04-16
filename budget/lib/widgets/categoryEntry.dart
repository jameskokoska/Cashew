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
  CategoryEntry({
    Key? key,
    required this.category,
    required this.transactionCount,
    required this.categorySpent,
    required this.totalSpent,
  }) : super(key: key);

  final TransactionCategory category;
  final int transactionCount;
  final double totalSpent;
  final double categorySpent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 1),
      child: Container(
        margin: EdgeInsets.only(left: 5, right: 10, top: 6, bottom: 14),
        child: Row(
          children: [
            // CategoryIcon(
            //   category: category,
            //   size: 30,
            //   margin: EdgeInsets.zero,
            // ),
            CategoryIconPercent(
              category: category,
              percent: categorySpent / totalSpent * 100,
            ),
            Container(
              width: 15,
            ),
            Expanded(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextFont(
                      text: category.name,
                      fontSize: 20,
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    TextFont(
                      text: (categorySpent / totalSpent * 100)
                              .toStringAsFixed(0) +
                          "% of budget",
                      fontSize: 15,
                      textColor: Theme.of(context).colorScheme.textLight,
                    )
                  ],
                ),
              ),
            ),
            //TODO: add total amount of this category within time period
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextFont(
                  fontWeight: FontWeight.bold,
                  text: convertToMoney(categorySpent),
                  fontSize: 23,
                ),
                SizedBox(
                  height: 1,
                ),
                TextFont(
                  text: transactionCount == 1
                      ? transactionCount.toString() + " transaction"
                      : transactionCount.toString() + " transactions",
                  fontSize: 15,
                  textColor: Theme.of(context).colorScheme.textLight,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryIconPercent extends StatelessWidget {
  CategoryIconPercent({
    Key? key,
    required this.category,
    this.size = 30,
    required this.percent,
    this.insetPadding = 23,
  }) : super(key: key);

  final TransactionCategory category;
  final double size;
  final double percent;
  final double insetPadding;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Padding(
        padding: EdgeInsets.all(insetPadding / 2),
        child: Image(
          image: AssetImage("assets/categories/" + (category.iconName ?? "")),
          width: size,
        ),
      ),
      Container(
        height: size + insetPadding,
        width: size + insetPadding,
        child: CircularProgressIndicator(
          value: percent / 100,
          backgroundColor: Theme.of(context).colorScheme.lightDarkAccentHeavy,
          strokeWidth: 3,
          color: HexColor(category.colour),
        ),
      ),
    ]);
  }
}
