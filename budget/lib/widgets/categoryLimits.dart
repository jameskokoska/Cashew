import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/currencyFunctions.dart';
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
                  allWallets: Provider.of<AllWallets>(context),
                  budgetPk: widget.budgetPk,
                  categoryPks: widget.categoryFks,
                  categoryPksExclude: widget.categoryFksExclude,
                  isAbsoluteSpendingLimit: widget.isAbsoluteSpendingLimit,
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
                                categoryFks: widget.categoryFks,
                                categoryFksExclude: widget.categoryFksExclude,
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

class CategoryLimitEntry extends StatelessWidget {
  const CategoryLimitEntry({
    required this.category,
    required this.budgetLimit,
    required this.categoryLimit,
    required this.budgetPk,
    required this.categoryFks,
    required this.categoryFksExclude,
    required this.isAbsoluteSpendingLimit,
    this.isSubCategory = false,
    super.key,
  });

  final TransactionCategory category;
  final double budgetLimit;
  final CategoryBudgetLimit? categoryLimit;
  final String budgetPk;
  final List<String>? categoryFks;
  final List<String>? categoryFksExclude;
  final bool isAbsoluteSpendingLimit;
  final bool isSubCategory;

  @override
  Widget build(BuildContext context) {
    double categoryLimitAmount = categoryLimit == null
        ? 0
        : isAbsoluteSpendingLimit
            ? categoryBudgetLimitToPrimaryCurrency(
                Provider.of<AllWallets>(context, listen: true), categoryLimit!)
            : categoryLimit!.amount;
    return StreamBuilder<List<TransactionCategory>>(
      stream: database.watchAllSubCategoriesOfMainCategory(category.categoryPk),
      builder: (context, snapshot) {
        List<TransactionCategory> subCategories = snapshot.data ?? [];
        bool hasSubCategories = subCategories.length > 0;

        Widget mainCategory = Tappable(
          color: Colors.transparent,
          onTap: () async {
            enterCategoryLimitPopup(
              context,
              category,
              categoryLimit,
              budgetPk,
              (_) {},
              isAbsoluteSpendingLimit,
            );
          },
          onLongPress: () {
            pushRoute(
              context,
              AddCategoryPage(
                category: category,
                routesToPopAfterDelete: RoutesToPopAfterDelete.One,
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSubCategory || hasSubCategories ? 16 : 25,
              vertical: 3,
            ),
            child: Row(
              children: [
                CategoryIconPercent(
                  category: category,
                  percent: isAbsoluteSpendingLimit
                      ? (budgetLimit == 0
                          ? 0
                          : (categoryLimitAmount / budgetLimit) * 100)
                      : categoryLimitAmount,
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
                        text: category.name,
                        fontSize: 17,
                      ),
                      SizedBox(
                        height: 1,
                      ),
                      TextFont(
                        text: isAbsoluteSpendingLimit
                            ? (budgetLimit == 0
                                    ? "0"
                                    : ((categoryLimitAmount / budgetLimit) *
                                            100)
                                        .toInt()
                                        .toString()) +
                                "%" +
                                " " +
                                (isSubCategory == true
                                    ? "of-category".tr()
                                    : "of-budget".tr())
                            : (convertToMoney(Provider.of<AllWallets>(context),
                                    budgetLimit * categoryLimitAmount / 100) +
                                " " +
                                (isSubCategory == true
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
                  title: isAbsoluteSpendingLimit
                      ? convertToMoney(Provider.of<AllWallets>(context),
                          categoryLimit?.amount ?? 0,
                          currencyKey:
                              Provider.of<AllWallets>(context, listen: true)
                                  .indexedByPk[categoryLimit?.walletFk ??
                                      appStateSettings["selectedWalletPk"]]
                                  ?.currency)
                      : convertToPercent(categoryLimit?.amount ?? 0),
                  placeholder: isAbsoluteSpendingLimit
                      ? convertToMoney(Provider.of<AllWallets>(context), 0,
                          currencyKey:
                              Provider.of<AllWallets>(context, listen: true)
                                  .indexedByPk[categoryLimit?.walletFk ??
                                      appStateSettings["selectedWalletPk"]]
                                  ?.currency)
                      : convertToPercent(0),
                  showPlaceHolderWhenTextEquals: isAbsoluteSpendingLimit
                      ? convertToMoney(Provider.of<AllWallets>(context), 0,
                          currencyKey:
                              Provider.of<AllWallets>(context, listen: true)
                                  .indexedByPk[categoryLimit?.walletFk ??
                                      appStateSettings["selectedWalletPk"]]
                                  ?.currency)
                      : convertToPercent(0),
                  onTap: () {
                    enterCategoryLimitPopup(
                      context,
                      category,
                      categoryLimit,
                      budgetPk,
                      (_) {},
                      isAbsoluteSpendingLimit,
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
          double subCategoryBudgetLimit = isAbsoluteSpendingLimit
              ? categoryLimitAmount
              : categoryLimitAmount / 100 * budgetLimit;
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
                      allWallets:
                          Provider.of<AllWallets>(context, listen: true),
                      mainCategoryPk: category.categoryPk,
                      budgetPk: budgetPk,
                      categoryPks: categoryFks,
                      categoryPksExclude: categoryFksExclude,
                      isAbsoluteSpendingLimit: isAbsoluteSpendingLimit,
                    ),
                    builder: (context, snapshot) {
                      bool isOver = isAbsoluteSpendingLimit
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
                            text: isAbsoluteSpendingLimit
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
                        .getCategoryLimit(budgetPk, category.categoryPk)
                        .$1,
                    builder: (context, snapshot) {
                      return CategoryLimitEntry(
                        category: category,
                        key: ValueKey(category.categoryPk),
                        budgetLimit: subCategoryBudgetLimit,
                        categoryLimit: snapshot.data,
                        budgetPk: budgetPk,
                        isSubCategory: true,
                        isAbsoluteSpendingLimit: isAbsoluteSpendingLimit,
                        categoryFks: categoryFks,
                        categoryFksExclude: categoryFksExclude,
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
                  mainCategoryPkWhenSubCategory: category.categoryPk,
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
  String selectedWalletPk =
      categoryLimit?.walletFk ?? appStateSettings["selectedWalletPk"];
  await openBottomSheet(
    context,
    PopupFramework(
      title: "enter-limit".tr(),
      subtitle: category.name,
      hasPadding: isAbsoluteSpendingLimit == false,
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
              enableWalletPicker: true,
              padding: EdgeInsets.symmetric(horizontal: 18),
              selectedWalletPk: selectedWalletPk,
              walletPkForCurrency: selectedWalletPk,
              setSelectedWalletPk: (walletPkPassed) {
                selectedWalletPk = walletPkPassed;
              },
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
        walletFk: selectedWalletPk,
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
        walletFk: selectedWalletPk,
      ),
    );
  }
}
