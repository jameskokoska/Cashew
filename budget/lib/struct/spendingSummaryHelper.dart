import 'dart:developer';

import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

// Use this helper when
// countUnassignedTransactions: true,
// includeAllSubCategories: true,
// For database.watchTotalSpentInEachCategoryInTimeRangeFromCategories

class TotalSpentCategoriesSummary {
  double totalSpent;
  Map<String, List<CategoryWithTotal>>
      subCategorySpendingIndexedByMainCategoryPk;
  Map<String, double> totalSpentOfCategoriesRemoveUnassignedTransactions;
  List<CategoryWithTotal> dataFilterUnassignedTransactions;
  bool hasSubCategories;

  TotalSpentCategoriesSummary({
    this.totalSpent = 0,
    this.subCategorySpendingIndexedByMainCategoryPk = const {},
    this.totalSpentOfCategoriesRemoveUnassignedTransactions = const {},
    this.dataFilterUnassignedTransactions = const [],
    this.hasSubCategories = false,
  }) {
    subCategorySpendingIndexedByMainCategoryPk =
        this.subCategorySpendingIndexedByMainCategoryPk.isEmpty
            ? {}
            : this.subCategorySpendingIndexedByMainCategoryPk;
    totalSpentOfCategoriesRemoveUnassignedTransactions =
        this.totalSpentOfCategoriesRemoveUnassignedTransactions.isEmpty
            ? {}
            : this.totalSpentOfCategoriesRemoveUnassignedTransactions;
    dataFilterUnassignedTransactions =
        this.dataFilterUnassignedTransactions.isEmpty == true
            ? []
            : this.dataFilterUnassignedTransactions;
  }
}

TotalSpentCategoriesSummary watchTotalSpentInTimeRangeHelper(
    {required List<CategoryWithTotal> dataInput,
    required bool showAllSubcategories,
    required int multiplyTotalBy,
    bool absoluteTotal = false}) {
  TotalSpentCategoriesSummary s = TotalSpentCategoriesSummary();

  dataInput.forEach(
    (CategoryWithTotal categoryWithTotal) {
      // Don't re-add the subcategory total, since the main category total includes this already
      if (categoryWithTotal.category.mainCategoryPk == null) {
        s.totalSpent = s.totalSpent +
            (absoluteTotal
                ? categoryWithTotal.total.abs()
                : categoryWithTotal.total);
      }

      if (categoryWithTotal.category.mainCategoryPk != null) {
        if (s.subCategorySpendingIndexedByMainCategoryPk[
                categoryWithTotal.category.mainCategoryPk!] ==
            null) {
          s.subCategorySpendingIndexedByMainCategoryPk[
              categoryWithTotal.category.mainCategoryPk!] = [];
        }
        s.subCategorySpendingIndexedByMainCategoryPk[
                categoryWithTotal.category.mainCategoryPk!]!
            .add(categoryWithTotal);
      }

      // if countUnassignedTransactions: true then we need to get the total of the main category
      // Since the main category will have the total of everything
      // If we include subcategories in the pie chart, we need to subtract the total of subcategories from the main category total
      // If we are not showing all subcategories, we only want the total for main categories
      if (showAllSubcategories) {
        if (categoryWithTotal.category.mainCategoryPk == null) {
          s.totalSpentOfCategoriesRemoveUnassignedTransactions[
                  categoryWithTotal.category.categoryPk] =
              (s.totalSpentOfCategoriesRemoveUnassignedTransactions[
                          categoryWithTotal.category.categoryPk] ??
                      0) +
                  categoryWithTotal.total;
        } else {
          s.totalSpentOfCategoriesRemoveUnassignedTransactions[
                  categoryWithTotal.category.mainCategoryPk!] =
              (s.totalSpentOfCategoriesRemoveUnassignedTransactions[
                          categoryWithTotal.category.mainCategoryPk!] ??
                      0) -
                  categoryWithTotal.total;
          s.totalSpentOfCategoriesRemoveUnassignedTransactions[
              categoryWithTotal.category.categoryPk] = categoryWithTotal.total;
        }
      } else {
        if (categoryWithTotal.category.mainCategoryPk == null) {
          s.totalSpentOfCategoriesRemoveUnassignedTransactions[
                  categoryWithTotal.category.categoryPk] =
              (s.totalSpentOfCategoriesRemoveUnassignedTransactions[
                          categoryWithTotal.category.categoryPk] ??
                      0) +
                  categoryWithTotal.total;
        }
      }
    },
  );

  dataInput.forEach((CategoryWithTotal categoryWithTotal) {
    double? newTotal = s.totalSpentOfCategoriesRemoveUnassignedTransactions[
        categoryWithTotal.category.categoryPk];
    if (newTotal != null)
      s.dataFilterUnassignedTransactions.add(
        categoryWithTotal.copyWith(total: newTotal),
      );
  });

  s.hasSubCategories = s.subCategorySpendingIndexedByMainCategoryPk.isNotEmpty;

  s.totalSpent = s.totalSpent * multiplyTotalBy;

  return s;
}

class PieChartOptions extends StatelessWidget {
  const PieChartOptions({
    required this.isIncomeBudget,
    required this.hasSubCategories,
    required this.selectedCategory,
    required this.onClearSelection,
    required this.onEditSpendingGoals,
    required this.toggleAllSubCategories,
    required this.showAllSubcategories,
    this.useHorizontalPaddingConstrained = true,
    super.key,
  });
  final bool isIncomeBudget;
  final bool hasSubCategories;
  final TransactionCategory? selectedCategory;
  final VoidCallback onClearSelection;
  final VoidCallback? onEditSpendingGoals;
  final VoidCallback toggleAllSubCategories;
  final bool showAllSubcategories;
  final bool useHorizontalPaddingConstrained;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: getHorizontalPaddingConstrained(context,
                  enabled: useHorizontalPaddingConstrained) +
              2),
      child: Transform.translate(
        offset: Offset(0, 5),
        child: Align(
          alignment: Alignment.bottomRight,
          child: Builder(builder: (context) {
            bool showClearButton = selectedCategory != null;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                AnimatedScaleOpacity(
                  animateIn: showClearButton,
                  child: Tooltip(
                    message: "clear-selection".tr(),
                    child: IconButton(
                      padding: EdgeInsets.all(15),
                      onPressed: onClearSelection,
                      icon: Icon(
                        appStateSettings["outlinedIcons"]
                            ? Icons.clear_outlined
                            : Icons.clear_rounded,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    if (hasSubCategories)
                      Transform.translate(
                        key: ValueKey(showClearButton),
                        offset: Offset(onEditSpendingGoals != null ? 10 : 0, 0),
                        child: Tooltip(
                          message: "view-subcategories".tr(),
                          child: IconButton(
                            padding: EdgeInsets.all(15),
                            onPressed: toggleAllSubCategories,
                            icon: ScaledAnimatedSwitcher(
                              keyToWatch: showAllSubcategories.toString(),
                              child: Icon(
                                showAllSubcategories
                                    ? (appStateSettings["outlinedIcons"]
                                        ? Icons.unfold_less_outlined
                                        : Icons.unfold_less_rounded)
                                    : (appStateSettings["outlinedIcons"]
                                        ? Icons.unfold_more_outlined
                                        : Icons.unfold_more_rounded),
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (onEditSpendingGoals != null)
                      Tooltip(
                        message: isIncomeBudget
                            ? "edit-saving-goals".tr()
                            : "edit-spending-goals".tr(),
                        child: IconButton(
                          padding: EdgeInsets.all(15),
                          onPressed: onEditSpendingGoals,
                          icon: Icon(
                            appStateSettings["outlinedIcons"]
                                ? Icons.fact_check_outlined
                                : Icons.fact_check_rounded,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
