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
    required this.onTap,
    required this.selected,
    required this.allSelected,
  }) : super(key: key);

  final TransactionCategory category;
  final int transactionCount;
  final double totalSpent;
  final double categorySpent;
  final VoidCallback onTap;
  final bool selected;
  final bool allSelected;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      color: Colors.transparent,
      child: AnimatedScale(
        curve: ElasticOutCurve(0.6),
        duration: Duration(milliseconds: 1300),
        scale: allSelected
            ? 1
            : selected
                ? 1
                : 0.95,
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 300),
          opacity: allSelected
              ? 1
              : selected
                  ? 1
                  : 0.3,
          child: AnimatedContainer(
            curve: Curves.easeInOut,
            duration: Duration(milliseconds: 500),
            color: selected
                ? dynamicPastel(
                    context, Theme.of(context).colorScheme.secondaryContainer,
                    amount: 0.5)
                : Colors.transparent,
            padding: EdgeInsets.only(left: 20, right: 25, top: 11, bottom: 11),
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
                  progressBackgroundColor: selected
                      ? Theme.of(context).colorScheme.white
                      : Theme.of(context).colorScheme.lightDarkAccentHeavy,
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
    required this.progressBackgroundColor,
  }) : super(key: key);

  final TransactionCategory category;
  final double size;
  final double percent;
  final double insetPadding;
  final Color progressBackgroundColor;

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
      AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: Container(
          key: ValueKey(progressBackgroundColor.toString()),
          height: size + insetPadding,
          width: size + insetPadding,
          child: CircularProgressIndicator(
            value: percent / 100,
            backgroundColor: progressBackgroundColor,
            strokeWidth: 3,
            color: HexColor(category.colour),
          ),
        ),
      ),
    ]);
  }
}
