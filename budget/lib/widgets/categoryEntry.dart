import 'dart:math';

import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:budget/widgets/animatedCircularProgress.dart';
import 'package:provider/provider.dart';
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
    this.highlightIfSelected = true,
    required this.allSelected,
    required this.budgetColorScheme,
    this.categoryBudgetLimit,
    this.isTiled = false,
    this.onLongPress,
    this.extraText,
    this.showIncomeExpenseIcons = false,
    this.isAbsoluteSpendingLimit = false,
    this.budgetLimit = 0,
    this.overSpentColor,
    this.todayPercent,
  }) : super(key: key);

  final TransactionCategory category;
  final int transactionCount;
  final double totalSpent;
  final double categorySpent;
  final VoidCallback onTap;
  final bool selected;
  final bool highlightIfSelected;
  final bool allSelected;
  final ColorScheme budgetColorScheme;
  final bool isTiled;
  final CategoryBudgetLimit? categoryBudgetLimit;
  final Function? onLongPress;
  final String? extraText;
  final bool showIncomeExpenseIcons;
  final bool isAbsoluteSpendingLimit;
  final double budgetLimit;
  final Color? overSpentColor;
  final double? todayPercent;

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
                    ? getColor(context, "white")
                    : getColor(context, "lightDarkAccentHeavy"),
              ),
              SizedBox(height: 5),
              TextFont(
                autoSizeText: true,
                minFontSize: 8,
                maxLines: 1,
                text: convertToMoney(
                    Provider.of<AllWallets>(context), categorySpent),
                fontSize: 13,
                textColor: getColor(context, "textLight"),
              ),
            ],
          ),
        ),
      );
    } else {
      double percentSpent = categoryBudgetLimit == null
          ? (categorySpent / totalSpent).abs()
          : isAbsoluteSpendingLimit
              ? ((categorySpent / categoryBudgetLimit!.amount).abs() > 1
                  ? 1
                  : (categorySpent / categoryBudgetLimit!.amount).abs())
              : ((categorySpent /
                              (categoryBudgetLimit!.amount / 100 * budgetLimit))
                          .abs() >
                      1
                  ? 1
                  : (categorySpent /
                          (categoryBudgetLimit!.amount / 100 * budgetLimit))
                      .abs());
      double amountSpent = categorySpent.abs();
      double spendingLimit = categoryBudgetLimit == null
          ? 0
          : isAbsoluteSpendingLimit
              ? categoryBudgetLimit!.amount
              : categoryBudgetLimit!.amount / 100 * budgetLimit;
      bool isOverspent = categoryBudgetLimit == null
          ? false
          : isAbsoluteSpendingLimit
              ? categorySpent > (categoryBudgetLimit?.amount ?? 0)
              : categorySpent >
                  (categoryBudgetLimit!.amount / 100 * budgetLimit);
      component = Padding(
        padding: EdgeInsets.symmetric(
          horizontal: getHorizontalPaddingConstrained(context),
        ),
        child: Row(
          children: [
            // CategoryIcon(
            //   category: category,
            //   size: 30,
            //   margin: EdgeInsets.zero,
            // ),
            CategoryIconPercent(
              category: category,
              percent: percentSpent * 100,
              progressBackgroundColor: appStateSettings["materialYou"]
                  ? budgetColorScheme.secondaryContainer
                  : selected
                      ? getColor(context, "white")
                      : getColor(context, "lightDarkAccentHeavy"),
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
                    Row(
                      children: [
                        Expanded(
                          child: TextFont(
                            text: category.name,
                            fontSize: 17,
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(width: 10),
                        categorySpent == 0 || showIncomeExpenseIcons == false
                            ? SizedBox.shrink()
                            : Transform.translate(
                                offset: Offset(3, 0),
                                child: Transform.rotate(
                                  angle: categorySpent >= 0 ? pi : 0,
                                  child: Icon(
                                    appStateSettings["outlinedIcons"]
                                        ? Icons.arrow_drop_down_outlined
                                        : Icons.arrow_drop_down_rounded,
                                    color: showIncomeExpenseIcons
                                        ? categorySpent > 0
                                            ? getColor(context, "incomeAmount")
                                            : getColor(context, "expenseAmount")
                                        : getColor(context, "black"),
                                  ),
                                ),
                              ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TextFont(
                              fontWeight: FontWeight.bold,
                              text: convertToMoney(
                                  Provider.of<AllWallets>(context),
                                  amountSpent),
                              fontSize: 20,
                              textColor: isOverspent
                                  ? overSpentColor ??
                                      getColor(context, "expenseAmount")
                                  : showIncomeExpenseIcons && categorySpent != 0
                                      ? categorySpent > 0
                                          ? getColor(context, "incomeAmount")
                                          : getColor(context, "expenseAmount")
                                      : getColor(context, "black"),
                            ),
                            categoryBudgetLimit == null
                                ? SizedBox.shrink()
                                : Padding(
                                    padding: const EdgeInsets.only(bottom: 1),
                                    child: TextFont(
                                      text: " / " +
                                          convertToMoney(
                                              Provider.of<AllWallets>(context),
                                              spendingLimit),
                                      fontSize: 14,
                                      textColor: isOverspent
                                          ? overSpentColor ??
                                              getColor(context, "expenseAmount")
                                          : getColor(context, "black")
                                              .withOpacity(0.3),
                                    ),
                                  ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 1,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: categoryBudgetLimit != null
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                    top: 3,
                                    right: 13,
                                    bottom: 3,
                                  ),
                                  child: ThinProgress(
                                    backgroundColor:
                                        appStateSettings["materialYou"]
                                            ? budgetColorScheme
                                                .secondaryContainer
                                            : selected
                                                ? getColor(context, "white")
                                                : getColor(context,
                                                    "lightDarkAccentHeavy"),
                                    color: HexColor(category.colour,
                                        defaultColor: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                    progress: percentSpent,
                                    dotProgress: todayPercent == null
                                        ? null
                                        : (todayPercent ?? 0) / 100,
                                  ),
                                )
                              : TextFont(
                                  text: (totalSpent == 0
                                          ? "0"
                                          : (categorySpent / totalSpent * 100)
                                              .abs()
                                              .toStringAsFixed(0)) +
                                      "% " +
                                      (extraText ?? "of-spending")
                                          .toString()
                                          .tr(),
                                  fontSize: 14,
                                  textColor: selected
                                      ? getColor(context, "black")
                                          .withOpacity(0.4)
                                      : getColor(context, "textLight"),
                                ),
                        ),
                        TextFont(
                          text: transactionCount.toString() +
                              " " +
                              (transactionCount == 1
                                  ? "transaction".tr().toLowerCase()
                                  : "transactions".tr().toLowerCase()),
                          fontSize: 14,
                          textColor: selected
                              ? getColor(context, "black").withOpacity(0.4)
                              : getColor(context, "textLight"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
      child: AnimatedExpanded(
        expand: !(!selected && !allSelected && isTiled == false),
        duration: Duration(milliseconds: 650),
        sizeCurve: Curves.easeInOutCubic,
        child: Tappable(
          borderRadius: isTiled ? 15 : 0,
          key: ValueKey(isTiled),
          onTap: onTap,
          onLongPress: onLongPress != null
              ? () => onLongPress!()
              : () => pushRoute(
                    context,
                    AddCategoryPage(
                      category: category,
                      routesToPopAfterDelete: RoutesToPopAfterDelete.One,
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
                color: highlightIfSelected && selected
                    ? dynamicPastel(context, budgetColorScheme.primary,
                            amount: 0.3)
                        .withAlpha(80)
                    : Colors.transparent,
              ),
              curve: Curves.easeInOut,
              duration: Duration(milliseconds: 500),
              padding: isTiled
                  ? null
                  : EdgeInsets.only(left: 20, right: 25, top: 8, bottom: 8),
              child: component,
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
    Color backgroundColor = dynamicPastel(
        context,
        HexColor(category.colour,
            defaultColor: Theme.of(context).colorScheme.primary),
        amountLight: 0.55,
        amountDark: 0.35);
    return Stack(alignment: Alignment.center, children: [
      // Padding(
      //   padding: EdgeInsets.all(insetPadding / 2),
      //   child: SimpleShadow(
      //     child: Image.asset(
      //       "assets/categories/" + (category.iconName ?? ""),
      //       width: size - 3,
      //     ),
      //     opacity: 0.8,
      //     color: HexColor(category.colour),
      //     offset: Offset(0, 0),
      //     sigma: 1,
      //   ),
      // ),
      category.iconName != null && category.emojiIconName == null
          ? Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? backgroundColor
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              height: size + insetPadding,
              width: size + insetPadding,
              padding: EdgeInsets.all(10),
              child: CacheCategoryIcon(
                iconName: category.iconName ?? "",
                size: size,
              ),
            )
          : SizedBox.shrink(),
      category.emojiIconName != null
          ? Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? backgroundColor
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  height: size + insetPadding,
                  width: size + insetPadding,
                  padding: EdgeInsets.all(10),
                ),
                EmojiIcon(
                  emojiIconName: category.emojiIconName,
                  size: size * 0.92,
                ),
              ],
            )
          : SizedBox.shrink(),

      AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: Container(
          key: ValueKey(progressBackgroundColor.toString()),
          height: size + insetPadding,
          width: size + insetPadding,
          child: AnimatedCircularProgress(
            percent: percent / 100,
            backgroundColor: progressBackgroundColor,
            foregroundColor: dynamicPastel(
              context,
              HexColor(
                category.colour,
                defaultColor: Theme.of(context).colorScheme.primary,
              ),
              inverse: true,
              amountLight: 0.1,
              amountDark: 0.25,
            ),
          ),
        ),
      ),
    ]);
  }
}

class ThinProgress extends StatelessWidget {
  final Color color;
  final Color backgroundColor;
  final double progress;
  final double? dotProgress;

  ThinProgress({
    required this.color,
    required this.backgroundColor,
    required this.progress,
    this.dotProgress,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, boxConstraints) {
        double x = boxConstraints.maxWidth * (dotProgress ?? 0);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Stack(
                children: [
                  Container(
                    color: backgroundColor,
                    height: 5,
                  ),
                  AnimatedFractionallySizedBox(
                    duration: Duration(milliseconds: 1000),
                    curve: Curves.easeInOutCubicEmphasized,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        color: color,
                        height: 5,
                      ),
                    ),
                    widthFactor: progress,
                  ),
                ],
              ),
            ),
            if (dotProgress != null)
              Positioned(
                left: x - 5,
                top: -3 / 2,
                child: Container(
                  height: 8,
                  width: 4,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
