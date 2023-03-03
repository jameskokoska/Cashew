import 'dart:async';

import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/categoryEntry.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';

class CategoryLimits extends StatefulWidget {
  const CategoryLimits({
    required this.budgetPk,
    required this.budgetLimit,
    required this.selectedCategories,
    super.key,
  });
  final int budgetPk;
  final List<int> selectedCategories;
  final double budgetLimit;

  @override
  State<CategoryLimits> createState() => _CategoryLimitsState();
}

class _CategoryLimitsState extends State<CategoryLimits> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: getHorizontalPaddingConstrained(context)),
      child: StreamBuilder<List<TransactionCategory>>(
        stream: database.watchAllCategories(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<int> allCategoryFks = [
              for (TransactionCategory category in snapshot.data!)
                category.categoryPk
            ];
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextFont(
                        text: "Category Spending Goals",
                        textColor: Theme.of(context).colorScheme.textLight,
                        fontSize: 16,
                      ),
                      StreamBuilder<double?>(
                        stream: database
                            .watchTotalOfCategoryLimitsInBudgetWithCategories(
                                widget.budgetPk,
                                widget.selectedCategories.length <= 0
                                    ? allCategoryFks
                                    : widget.selectedCategories),
                        builder: (context, snapshot) {
                          return CountNumber(
                            count: snapshot.data ?? 0,
                            duration: Duration(milliseconds: 700),
                            dynamicDecimals: true,
                            initialCount: (0),
                            textBuilder: (number) {
                              return TextFont(
                                fontSize: 16,
                                textColor:
                                    Theme.of(context).colorScheme.textLight,
                                text: convertToMoney(number) +
                                    " / " +
                                    convertToMoney(widget.budgetLimit),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                for (TransactionCategory category in snapshot.data!)
                  AnimatedSize(
                    duration: Duration(milliseconds: 800),
                    curve: Curves.easeInOutCubicEmphasized,
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      child: widget.selectedCategories.isEmpty ||
                              widget.selectedCategories
                                  .contains(category.categoryPk)
                          ? StreamBuilder<CategoryBudgetLimit>(
                              stream: database.watchCategoryLimit(
                                  widget.budgetPk, category.categoryPk),
                              builder: (context, snapshot) {
                                return CategoryLimitEntry(
                                  category: category,
                                  key: ValueKey(1),
                                  budgetLimit: widget.budgetLimit,
                                  categoryLimit: snapshot.data,
                                  budgetPk: widget.budgetPk,
                                );
                              },
                            )
                          : Container(
                              key: ValueKey(2),
                            ),
                    ),
                  )
              ],
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}

class CategoryLimitEntry extends StatefulWidget {
  const CategoryLimitEntry(
      {required this.category,
      required this.budgetLimit,
      required this.categoryLimit,
      required this.budgetPk,
      super.key});

  final TransactionCategory category;
  final double budgetLimit;
  final CategoryBudgetLimit? categoryLimit;
  final int budgetPk;

  @override
  State<CategoryLimitEntry> createState() => _CategoryLimitEntryState();
}

class _CategoryLimitEntryState extends State<CategoryLimitEntry> {
  double selectedAmount = 0;

  @override
  void initState() {
    super.initState();
  }

  void didUpdateWidget(oldWidget) {
    if (widget.categoryLimit != null) {
      setState(() {
        selectedAmount = widget.categoryLimit!.amount;
      });
    } else if (oldWidget != widget) {
      setState(() {
        selectedAmount = 0;
      });
    }
  }

  void selectAmount(context) {
    openBottomSheet(
      context,
      PopupFramework(
        title: "Enter Limit",
        subtitle: widget.category.name,
        icon: CategoryIcon(
          categoryPk: widget.category.categoryPk,
          size: 35,
          borderRadius: 500,
          margin: EdgeInsets.zero,
        ),
        underTitleSpace: false,
        child: SelectAmount(
          allowZero: true,
          setSelectedAmount: (selectedAmountPassed, _) async {
            selectedAmountPassed = selectedAmountPassed.abs();
            setState(() {
              selectedAmount = selectedAmountPassed;
            });
            if (selectedAmountPassed == 0) {
              try {
                await database.deleteCategoryBudgetLimit(
                  widget.categoryLimit!.categoryLimitPk,
                );
              } catch (e) {
                print(e.toString());
              }
            } else if (widget.categoryLimit == null) {
              database.createOrUpdateCategoryLimit(
                CategoryBudgetLimit(
                  categoryLimitPk: DateTime.now().millisecondsSinceEpoch,
                  categoryFk: widget.category.categoryPk,
                  budgetFk: widget.budgetPk,
                  amount: selectedAmountPassed,
                ),
              );
            } else {
              database.createOrUpdateCategoryLimit(
                CategoryBudgetLimit(
                  categoryLimitPk: widget.categoryLimit!.categoryLimitPk,
                  categoryFk: widget.categoryLimit!.categoryFk,
                  budgetFk: widget.categoryLimit!.budgetFk,
                  amount: selectedAmountPassed,
                ),
              );
            }
          },
          next: () async {
            Navigator.pop(context);
          },
          nextLabel: "Set Limit",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: () {
        selectAmount(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CategoryIconPercent(
                  category: widget.category,
                  percent: (selectedAmount / widget.budgetLimit) * 100,
                  progressBackgroundColor:
                      Theme.of(context).colorScheme.lightDarkAccentHeavy,
                  size: 28,
                  insetPadding: 18,
                ),
                SizedBox(
                  width: 13,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFont(
                      text: widget.category.name,
                      fontSize: 18,
                    ),
                    SizedBox(
                      height: 1,
                    ),
                    TextFont(
                      text: ((selectedAmount / widget.budgetLimit) * 100)
                              .toInt()
                              .toString() +
                          "% of budget",
                      fontSize: 14,
                      textColor: Theme.of(context).colorScheme.textLight,
                    ),
                  ],
                ),
              ],
            ),
            TappableTextEntry(
              title: convertToMoney(selectedAmount),
              placeholder: convertToMoney(0),
              showPlaceHolderWhenTextEquals: convertToMoney(0),
              onTap: () {
                selectAmount(context);
              },
              fontSize: 23,
              fontWeight: FontWeight.bold,
              internalPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 3),
            ),
          ],
        ),
      ),
    );
  }
}
