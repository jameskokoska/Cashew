import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/editCategoriesPage.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/material.dart';
import 'package:budget/widgets/animatedCircularProgress.dart';
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
    required this.budgetColorScheme,
    this.isTiled = false,
  }) : super(key: key);

  final TransactionCategory category;
  final int transactionCount;
  final double totalSpent;
  final double categorySpent;
  final VoidCallback onTap;
  final bool selected;
  final bool allSelected;
  final ColorScheme budgetColorScheme;
  final bool isTiled;

  @override
  Widget build(BuildContext context) {
    Widget component;
    if (isTiled) {
      component = Container(
        width: 70,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              CategoryIconPercent(
                category: category,
                percent: categorySpent / totalSpent * 100,
                progressBackgroundColor: selected
                    ? Theme.of(context).colorScheme.white
                    : Theme.of(context).colorScheme.lightDarkAccentHeavy,
              ),
              SizedBox(height: 5),
              TextFont(
                autoSizeText: true,
                minFontSize: 8,
                maxLines: 1,
                text: convertToMoney(categorySpent),
                fontSize: 13,
                textColor: Theme.of(context).colorScheme.textLight,
              ),
            ],
          ),
        ),
      );
    } else {
      component = Row(
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
            size: 28,
            insetPadding: 18,
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
                    fontSize: 18,
                  ),
                  SizedBox(
                    height: 1,
                  ),
                  TextFont(
                    text:
                        (categorySpent / totalSpent * 100).toStringAsFixed(0) +
                            "% of budget",
                    fontSize: 14,
                    textColor: selected
                        ? Theme.of(context).colorScheme.black.withOpacity(0.4)
                        : Theme.of(context).colorScheme.textLight,
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
                fontSize: 20,
              ),
              SizedBox(
                height: 0,
              ),
              TextFont(
                text: transactionCount.toString() +
                    pluralString(transactionCount == 1, " transaction"),
                fontSize: 14,
                textColor: selected
                    ? Theme.of(context).colorScheme.black.withOpacity(0.4)
                    : Theme.of(context).colorScheme.textLight,
              )
            ],
          ),
        ],
      );
    }
    return WillPopScope(
      onWillPop: () async {
        if (allSelected == false && selected) {
          onTap();
          return false;
        }
        return true;
      },
      child: AnimatedSize(
        duration: Duration(milliseconds: 1000),
        curve: Curves.easeInOutCubicEmphasized,
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 200),
          child: !selected && !allSelected && isTiled == false
              ? Container(
                  key: ValueKey(2),
                )
              : Tappable(
                  borderRadius: isTiled ? 15 : 0,
                  key: ValueKey(isTiled),
                  onTap: onTap,
                  onLongPress: () => pushRoute(
                    context,
                    AddCategoryPage(
                      title: "Edit Category",
                      category: category,
                    ),
                  ),
                  color: Colors.transparent,
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 300),
                    opacity: allSelected
                        ? 1
                        : selected
                            ? 1
                            : 0.3,
                    child: AnimatedContainer(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(isTiled ? 15 : 0),
                        color: selected
                            ? dynamicPastel(context, budgetColorScheme.primary,
                                    amount: 0.3)
                                .withAlpha(80)
                            : Colors.transparent,
                      ),
                      curve: Curves.easeInOut,
                      duration: Duration(milliseconds: 500),
                      padding: isTiled
                          ? null
                          : EdgeInsets.only(
                              left: 20, right: 25, top: 8, bottom: 8),
                      child: component,
                    ),
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
    return Stack(alignment: Alignment.center, children: [
      Padding(
        padding: EdgeInsets.all(insetPadding / 2),
        child: Image(
          image: AssetImage("assets/categories/" + (category.iconName ?? "")),
          width: size - 3,
        ),
      ),
      AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: Container(
          key: ValueKey(progressBackgroundColor.toString()),
          height: size + insetPadding,
          width: size + insetPadding,
          child: AnimatedCircularProgress(
            percent: percent / 100,
            backgroundColor: progressBackgroundColor,
            foregroundColor: HexColor(category.colour,
                defaultColor: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    ]);
  }
}
