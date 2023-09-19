import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/categoryEntry.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/countNumber.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:provider/provider.dart';
import 'package:budget/widgets/framework/popupFramework.dart';

import 'sliverStickyLabelDivider.dart';

class CategoryLimits extends StatefulWidget {
  const CategoryLimits({
    required this.budgetPk,
    required this.budgetLimit,
    required this.categoryFks,
    required this.categoryFksExclude,
    required this.showAddCategoryButton,
    required this.isAbsoluteSpendingLimit,
    super.key,
  });
  final String budgetPk;
  final List<String>? categoryFks;
  final List<String>? categoryFksExclude;
  final double budgetLimit;
  final bool showAddCategoryButton;
  final bool isAbsoluteSpendingLimit;

  @override
  State<CategoryLimits> createState() => _CategoryLimitsState();
}

class _CategoryLimitsState extends State<CategoryLimits> {
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(
          horizontal: getHorizontalPaddingConstrained(context)),
      sliver: StreamBuilder<List<TransactionCategory>>(
        stream: database.watchAllCategories(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return SliverStickyLabelDivider(
              info: "category-spending-goals".tr(),
              extraInfoWidget: StreamBuilder<double?>(
                stream:
                    database.watchTotalOfCategoryLimitsInBudgetWithCategories(
                  widget.budgetPk,
                  widget.categoryFks,
                  widget.categoryFksExclude,
                ),
                builder: (context, snapshot) {
                  return CountNumber(
                    count: snapshot.data ?? 0,
                    duration: Duration(milliseconds: 700),
                    initialCount: (0),
                    textBuilder: (number) {
                      return TextFont(
                        fontSize: 15,
                        textColor: getColor(context, "textLight"),
                        text: widget.isAbsoluteSpendingLimit
                            ? (convertToMoney(
                                    Provider.of<AllWallets>(context), number,
                                    finalNumber: snapshot.data ?? 0) +
                                " / " +
                                convertToMoney(Provider.of<AllWallets>(context),
                                    widget.budgetLimit))
                            : (convertToPercent(number,
                                    finalNumber: snapshot.data ?? 0) +
                                " / " +
                                "100%"),
                      );
                    },
                  );
                },
              ),
              sliver: ColumnSliver(
                children: [
                  SizedBox(height: 5),
                  for (TransactionCategory category in snapshot.data!)
                    database.isInCategoryCheck(category.categoryPk,
                            widget.categoryFks, widget.categoryFksExclude)
                        ? StreamBuilder<CategoryBudgetLimit?>(
                            stream: database
                                .getCategoryLimit(
                                    widget.budgetPk, category.categoryPk)
                                .$1,
                            builder: (context, snapshot) {
                              return CategoryLimitEntry(
                                category: category,
                                key: ValueKey(category.categoryPk),
                                budgetLimit: widget.budgetLimit,
                                categoryLimit: snapshot.data,
                                budgetPk: widget.budgetPk,
                                isAbsoluteSpendingLimit:
                                    widget.isAbsoluteSpendingLimit,
                              );
                            },
                          )
                        : Container(
                            key: ValueKey(
                                category.categoryPk.toString() + "Container"),
                          ),
                  widget.showAddCategoryButton == false
                      ? SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          child: AddButton(
                            onTap: () {},
                            padding: EdgeInsets.zero,
                            openPage: AddCategoryPage(
                              routesToPopAfterDelete:
                                  RoutesToPopAfterDelete.None,
                            ),
                            width: null,
                          ),
                        ),
                  SizedBox(height: 5),
                ],
              ),
            );
          }
          return SliverToBoxAdapter(child: SizedBox.shrink());
        },
      ),
    );
  }
}

class CategoryLimitEntry extends StatefulWidget {
  const CategoryLimitEntry({
    required this.category,
    required this.budgetLimit,
    required this.categoryLimit,
    required this.budgetPk,
    required this.isAbsoluteSpendingLimit,
    super.key,
  });

  final TransactionCategory category;
  final double budgetLimit;
  final CategoryBudgetLimit? categoryLimit;
  final String budgetPk;
  final bool isAbsoluteSpendingLimit;

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
    // when the snapshot loads the data, add it
    if (widget.categoryLimit != null) {
      setState(() {
        selectedAmount = widget.categoryLimit!.amount;
      });
    }
  }

  void setAmount(double selectedAmountPassed) async {
    setState(() {
      selectedAmount = selectedAmountPassed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: () async {
        enterCategoryLimitPopup(
          context,
          widget.category,
          widget.categoryLimit,
          widget.budgetPk,
          setAmount,
          widget.isAbsoluteSpendingLimit,
        );
      },
      onLongPress: () {
        pushRoute(
          context,
          AddCategoryPage(
            category: widget.category,
            routesToPopAfterDelete: RoutesToPopAfterDelete.One,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 3),
        child: Row(
          children: [
            CategoryIconPercent(
              category: widget.category,
              percent: widget.isAbsoluteSpendingLimit
                  ? (widget.budgetLimit == 0
                      ? 0
                      : (selectedAmount / widget.budgetLimit) * 100)
                  : selectedAmount,
              progressBackgroundColor:
                  getColor(context, "lightDarkAccentHeavy"),
              size: 28,
              insetPadding: 18,
            ),
            SizedBox(
              width: 13,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFont(
                    text: widget.category.name,
                    fontSize: 17,
                  ),
                  SizedBox(
                    height: 1,
                  ),
                  TextFont(
                    text: widget.isAbsoluteSpendingLimit
                        ? (widget.budgetLimit == 0
                                ? "0"
                                : ((selectedAmount / widget.budgetLimit) * 100)
                                    .toInt()
                                    .toString()) +
                            "%" +
                            " " +
                            "of-budget".tr()
                        : (convertToMoney(Provider.of<AllWallets>(context),
                                widget.budgetLimit * selectedAmount / 100) +
                            " " +
                            "of-budget".tr()),
                    fontSize: 14,
                    textColor: getColor(context, "textLight"),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            TappableTextEntry(
              title: widget.isAbsoluteSpendingLimit
                  ? convertToMoney(
                      Provider.of<AllWallets>(context), selectedAmount)
                  : convertToPercent(selectedAmount),
              placeholder: widget.isAbsoluteSpendingLimit
                  ? convertToMoney(Provider.of<AllWallets>(context), 0)
                  : convertToPercent(0),
              showPlaceHolderWhenTextEquals: widget.isAbsoluteSpendingLimit
                  ? convertToMoney(Provider.of<AllWallets>(context), 0)
                  : convertToPercent(0),
              onTap: () {
                enterCategoryLimitPopup(
                  context,
                  widget.category,
                  widget.categoryLimit,
                  widget.budgetPk,
                  setAmount,
                  widget.isAbsoluteSpendingLimit,
                );
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

void enterCategoryLimitPopup(
  context,
  TransactionCategory category,
  CategoryBudgetLimit? categoryLimit,
  String budgetPk,
  Function(double) setSelectedAmount,
  bool isAbsoluteSpendingLimit,
) async {
  double amount = categoryLimit != null ? categoryLimit.amount : 0;
  await openBottomSheet(
    context,
    PopupFramework(
      title: "enter-limit".tr(),
      subtitle: category.name,
      icon: CategoryIcon(
        categoryPk: category.categoryPk,
        size: 35,
        borderRadius: 500,
        margin: EdgeInsets.zero,
      ),
      underTitleSpace: false,
      child: isAbsoluteSpendingLimit == false
          ? SelectAmountValue(
              setSelectedAmount: (selectedAmountPassed, _) async {
                if (selectedAmountPassed > 1000) {
                  selectedAmountPassed = 1000;
                }
                selectedAmountPassed = selectedAmountPassed.abs();
                amount = selectedAmountPassed;
              },
              // Keep all the decimals, so don't use convertToPercent(amount)
              amountPassed: removeTrailingZeroes(amount.toString()),
              next: () async {
                Navigator.pop(context);
              },
              nextLabel: "set-limit".tr(),
              allowZero: true,
              suffix: "%",
            )
          : SelectAmount(
              amountPassed: amount.toString(),
              allowZero: true,
              setSelectedAmount: (selectedAmountPassed, _) async {
                selectedAmountPassed = selectedAmountPassed.abs();
                amount = selectedAmountPassed;
              },
              next: () async {
                Navigator.pop(context);
              },
              nextLabel: "set-limit".tr(),
              onlyShowCurrencyIcon: true,
            ),
    ),
  );
  setSelectedAmount(amount);
  if (amount == 0) {
    try {
      database.deleteCategoryBudgetLimit(
        categoryLimit!.categoryLimitPk,
      );
    } catch (e) {
      print(e.toString());
    }
  } else if (categoryLimit == null) {
    database.createOrUpdateCategoryLimit(
      insert: true,
      CategoryBudgetLimit(
        categoryLimitPk: "-1",
        categoryFk: category.categoryPk,
        budgetFk: budgetPk,
        amount: amount,
        dateTimeModified: null,
      ),
    );
  } else {
    database.createOrUpdateCategoryLimit(
      CategoryBudgetLimit(
        categoryLimitPk: categoryLimit.categoryLimitPk,
        categoryFk: categoryLimit.categoryFk,
        budgetFk: categoryLimit.budgetFk,
        amount: amount,
        dateTimeModified: null,
      ),
    );
  }
}
