import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
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
import 'tappableTextEntry.dart';

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
                  bool isOver = widget.isAbsoluteSpendingLimit
                      ? (snapshot.data ?? 0) > widget.budgetLimit
                      : (snapshot.data ?? 0) > 100;
                  return CountNumber(
                    count: snapshot.data ?? 0,
                    duration: Duration(milliseconds: 700),
                    initialCount: (0),
                    textBuilder: (number) {
                      return TextFont(
                        fontSize: 15,
                        textColor: isOver
                            ? getColor(context, "expenseRed")
                            : getColor(context, "textLight"),
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
    this.isSubCategory = false,
    super.key,
  });

  final TransactionCategory category;
  final double budgetLimit;
  final CategoryBudgetLimit? categoryLimit;
  final String budgetPk;
  final bool isAbsoluteSpendingLimit;
  final bool isSubCategory;

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
    return StreamBuilder<List<TransactionCategory>>(
      stream: database
          .watchAllSubCategoriesOfMainCategory(widget.category.categoryPk),
      builder: (context, snapshot) {
        List<TransactionCategory> subCategories = snapshot.data ?? [];
        bool hasSubCategories = subCategories.length > 0;

        Widget mainCategory = Tappable(
          color: Colors.transparent,
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
            padding: EdgeInsets.symmetric(
              horizontal: widget.isSubCategory || hasSubCategories ? 16 : 25,
              vertical: 3,
            ),
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
                                    : ((selectedAmount / widget.budgetLimit) *
                                            100)
                                        .toInt()
                                        .toString()) +
                                "%" +
                                " " +
                                (widget.isSubCategory == true
                                    ? "of-category".tr()
                                    : "of-budget".tr())
                            : (convertToMoney(Provider.of<AllWallets>(context),
                                    widget.budgetLimit * selectedAmount / 100) +
                                " " +
                                (widget.isSubCategory == true
                                    ? "of-category".tr()
                                    : "of-budget".tr())),
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
                  internalPadding:
                      EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 3),
                ),
              ],
            ),
          ),
        );
        if (hasSubCategories) {
          double subCategoryBudgetLimit = widget.isAbsoluteSpendingLimit
              ? selectedAmount
              : selectedAmount / 100 * widget.budgetLimit;
          return SubCategoriesContainer(
            mainCategory: mainCategory,
            separatorBanner: Column(
              children: [
                HorizontalBreak(padding: EdgeInsets.zero),
                StickyLabelDivider(
                  color: Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .withOpacity(0.3),
                  info: "total".tr(),
                  extraInfoWidget: StreamBuilder<double?>(
                    stream: database
                        .watchTotalOfCategoryLimitsInBudgetWithSubCategories(
                            widget.category.categoryPk),
                    builder: (context, snapshot) {
                      bool isOver = widget.isAbsoluteSpendingLimit
                          ? (snapshot.data ?? 0) > subCategoryBudgetLimit
                          : (snapshot.data ?? 0) > 100;
                      return CountNumber(
                        count: snapshot.data ?? 0,
                        duration: Duration(milliseconds: 700),
                        initialCount: (0),
                        textBuilder: (number) {
                          return TextFont(
                            fontSize: 15,
                            textColor: isOver
                                ? getColor(context, "expenseRed")
                                : getColor(context, "textLight"),
                            text: widget.isAbsoluteSpendingLimit
                                ? (convertToMoney(
                                        Provider.of<AllWallets>(context),
                                        number,
                                        finalNumber: snapshot.data ?? 0) +
                                    " / " +
                                    convertToMoney(
                                        Provider.of<AllWallets>(context),
                                        subCategoryBudgetLimit))
                                : (convertToPercent(number,
                                        finalNumber: snapshot.data ?? 0) +
                                    " / " +
                                    "100%"),
                          );
                        },
                      );
                    },
                  ),
                ),
                HorizontalBreak(padding: EdgeInsets.only(bottom: 5)),
              ],
            ),
            subCategoryEntries: Column(
              children: [
                for (TransactionCategory category in subCategories)
                  StreamBuilder<CategoryBudgetLimit?>(
                    stream: database
                        .getCategoryLimit(widget.budgetPk, category.categoryPk)
                        .$1,
                    builder: (context, snapshot) {
                      return CategoryLimitEntry(
                        category: category,
                        key: ValueKey(category.categoryPk),
                        budgetLimit: subCategoryBudgetLimit,
                        categoryLimit: snapshot.data,
                        budgetPk: widget.budgetPk,
                        isSubCategory: true,
                        isAbsoluteSpendingLimit: widget.isAbsoluteSpendingLimit,
                      );
                    },
                  ),
              ],
            ),
            extraButtonEnd: Padding(
              padding: EdgeInsets.only(top: 5, bottom: 7),
              child: AddButton(
                onTap: () {},
                padding: EdgeInsets.symmetric(horizontal: 7),
                openPage: AddCategoryPage(
                  routesToPopAfterDelete: RoutesToPopAfterDelete.None,
                  mainCategoryPkWhenSubCategory: widget.category.categoryPk,
                ),
                width: null,
              ),
            ),
          );
        } else {
          return mainCategory;
        }
      },
    );
  }
}

class SubCategoriesContainer extends StatelessWidget {
  const SubCategoriesContainer({
    super.key,
    required this.mainCategory,
    this.separatorBanner,
    required this.subCategoryEntries,
    this.extraButtonEnd,
    this.colorScheme,
    this.onTap,
  });

  final Widget mainCategory;
  final Widget? separatorBanner;
  final Widget subCategoryEntries;
  final Widget? extraButtonEnd;
  final ColorScheme? colorScheme;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: (colorScheme ?? Theme.of(context).colorScheme)
                .secondaryContainer
                .withOpacity(getPlatform() == PlatformOS.isIOS ? 0.15 : 0.5),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(
                getPlatform() == PlatformOS.isIOS ? 0 : 14,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(
              vertical: getPlatform() == PlatformOS.isIOS ? 2 : 7),
          child: mainCategory,
        ),
        separatorBanner ?? SizedBox.shrink(),
        subCategoryEntries,
        SizedBox(height: 5),
        extraButtonEnd ?? SizedBox.shrink(),
      ],
    );
    if (getPlatform() == PlatformOS.isIOS)
      return Column(
        children: [
          HorizontalBreak(padding: EdgeInsets.zero),
          Container(
            child: content,
            color: (colorScheme ?? Theme.of(context).colorScheme)
                .secondaryContainer
                .withOpacity(0.3),
          ),
          HorizontalBreak(padding: EdgeInsets.zero),
          SizedBox(height: 6),
        ],
      );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Tappable(
          onTap: onTap,
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: (appStateSettings["materialYou"]
                    ? (colorScheme ?? Theme.of(context).colorScheme)
                        .secondary
                        .withOpacity(0.5)
                    : getColor(context, "lightDarkAccentHeavy")),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: content,
          ),
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
        canEditByLongPress: true,
        onLongPress: () {
          Navigator.pop(context);
        },
        onTap: () {
          Navigator.pop(context);
          pushRoute(
            context,
            AddCategoryPage(
              category: category,
              routesToPopAfterDelete: RoutesToPopAfterDelete.One,
            ),
          );
        },
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
