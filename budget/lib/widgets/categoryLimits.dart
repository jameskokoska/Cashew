import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/categoryEntry.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/countNumber.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:provider/provider.dart';
import 'package:budget/widgets/framework/popupFramework.dart';

class CategoryLimits extends StatefulWidget {
  const CategoryLimits({
    required this.budgetPk,
    required this.budgetLimit,
    required this.selectedCategories,
    required this.showAddCategoryButton,
    required this.isAbsoluteSpendingLimit,
    super.key,
  });
  final int budgetPk;
  final List<int> selectedCategories;
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
          if (snapshot.hasData) {
            List<int> allCategoryFks = [
              for (TransactionCategory category in snapshot.data!)
                category.categoryPk
            ];
            return SliverStickyLabelDivider(
              info: "category-spending-goals".tr(),
              extraInfoWidget: StreamBuilder<double?>(
                stream:
                    database.watchTotalOfCategoryLimitsInBudgetWithCategories(
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
                        fontSize: 15,
                        textColor: getColor(context, "textLight"),
                        text: widget.isAbsoluteSpendingLimit
                            ? (convertToMoney(
                                    Provider.of<AllWallets>(context), number,
                                    finalNumber: snapshot.data ?? 0) +
                                " / " +
                                convertToMoney(Provider.of<AllWallets>(context),
                                    widget.budgetLimit))
                            : (convertToPercent(number, snapshot.data ?? 0) +
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
                    AnimatedSize(
                      duration: Duration(milliseconds: 800),
                      curve: Curves.easeInOutCubicEmphasized,
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child: widget.selectedCategories.isEmpty ||
                                widget.selectedCategories
                                    .contains(category.categoryPk)
                            ? StreamBuilder<CategoryBudgetLimit?>(
                                stream: database
                                    .getCategoryLimit(
                                        widget.budgetPk, category.categoryPk)
                                    .$1,
                                builder: (context, snapshot) {
                                  return CategoryLimitEntry(
                                    category: category,
                                    key: ValueKey(1),
                                    budgetLimit: widget.budgetLimit,
                                    categoryLimit: snapshot.data,
                                    budgetPk: widget.budgetPk,
                                    isAbsoluteSpendingLimit:
                                        widget.isAbsoluteSpendingLimit,
                                  );
                                },
                              )
                            : Container(
                                key: ValueKey(2),
                              ),
                      ),
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
                              title: "add-category".tr(),
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
  final int budgetPk;
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
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
                      text: widget.isAbsoluteSpendingLimit
                          ? (widget.budgetLimit == 0
                                  ? "0"
                                  : ((selectedAmount / widget.budgetLimit) *
                                          100)
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
              ],
            ),
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
  int budgetPk,
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
              amountPassed: removeLastCharacter(convertToPercent(amount)),
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
      CategoryBudgetLimit(
        categoryLimitPk: DateTime.now().millisecondsSinceEpoch,
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
