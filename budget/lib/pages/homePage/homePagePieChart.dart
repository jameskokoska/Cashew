import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/pages/transactionFilters.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
import 'package:budget/pages/walletDetailsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/struct/spendingSummaryHelper.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/categoryEntry.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/iconButtonScaled.dart';
import 'package:budget/widgets/incomeExpenseTabSelector.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/transactionEntry/incomeAmountArrow.dart';
import 'package:budget/widgets/util/keepAliveClientMixin.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/pieChart.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionsAmountBox.dart';
import 'package:budget/widgets/util/widgetSize.dart';
import 'package:budget/widgets/viewAllTransactionsButton.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expandable_page_view/expandable_page_view.dart';

import '../../widgets/pageIndicator.dart';

class HomePagePieChart extends StatefulWidget {
  const HomePagePieChart({super.key});

  @override
  State<HomePagePieChart> createState() => _HomePagePieChartState();
}

class _HomePagePieChartState extends State<HomePagePieChart>
    with SingleTickerProviderStateMixin {
  void openPieChartSettings() async {
    await openPieChartHomePageBottomSheetSettings(context);
    homePageStateKey.currentState?.refreshState();
  }

  @override
  Widget build(BuildContext context) {
    final PageController _pageController = PageController(
        initialPage: appStateSettings["pieChartTotal"] != "incoming" ? 0 : 1);
    TransactionCategory? selectedCategory;

    const double borderRadius = 15;
    return KeepAliveClientMixin(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 13, left: 13, right: 13),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: boxShadowCheck(boxShadowGeneral(context)),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Tappable(
              borderRadius: borderRadius,
              onLongPress: openPieChartSettings,
              onTap: () {
                setState(() {
                  selectedCategory = null;
                });
              },
              color: getColor(context, "lightDarkAccentHeavyLight"),
              child: LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxWidth < 320 * 2 + 50) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ExpandablePageView(
                          estimatedPageSize: 255,
                          onPageChanged: (value) {
                            updateSettings(
                              "pieChartTotal",
                              value == 0 ? "outgoing" : "incoming",
                              updateGlobalState: false,
                            );
                          },
                          animationDuration: Duration(milliseconds: 500),
                          animateFirstPage: true,
                          pageSnapping: true,
                          clipBehavior: Clip.none,
                          controller: _pageController,
                          children: [
                            PieChartHomeAndCategorySummary(
                                isIncome: false,
                                selectedCategory: selectedCategory),
                            PieChartHomeAndCategorySummary(
                                isIncome: true,
                                selectedCategory: selectedCategory)
                          ],
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: -10,
                          child: PageIndicator(
                            controller: _pageController,
                            itemCount: 2,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IncomeOutcomeArrowPageIndicator(
                            controller: _pageController,
                            onTap: (isIncome) {
                              _pageController.animateToPage(
                                isIncome ? 0 : 1,
                                duration: Duration(milliseconds: 600),
                                curve: Curves.easeInOutCubicEmphasized,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: PieChartHomeAndCategorySummary(
                          isIncome: false,
                          animatedSizeCategoryContainer: true,
                          selectedCategory: selectedCategory,
                        ),
                      ),
                      Expanded(
                        child: PieChartHomeAndCategorySummary(
                          isIncome: true,
                          animatedSizeCategoryContainer: true,
                          selectedCategory: selectedCategory,
                        ),
                      )
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class IncomeOutcomeArrowPageIndicator extends StatelessWidget {
  final PageController controller;
  final Function(bool isIncome) onTap;

  IncomeOutcomeArrowPageIndicator({
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        int currentPage =
            controller.page?.round().toInt() ?? controller.initialPage;
        bool isIncome = currentPage != 0;
        return Tappable(
          borderRadius: 100,
          onTap: () => onTap(isIncome),
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: IncomeOutcomeArrow(
              iconSize: 30,
              width: 30,
              isIncome: isIncome,
              color: isIncome
                  ? getColor(context, "incomeAmount")
                  : getColor(context, "expenseAmount"),
            ),
          ),
        );
      },
    );
  }
}

class PieChartHomeAndCategorySummary extends StatefulWidget {
  const PieChartHomeAndCategorySummary(
      {required this.isIncome,
      this.animatedSizeCategoryContainer = false,
      this.selectedCategory,
      super.key});
  final bool isIncome;
  final bool animatedSizeCategoryContainer;
  final TransactionCategory? selectedCategory;

  @override
  State<PieChartHomeAndCategorySummary> createState() =>
      _PieChartHomeAndCategorySummaryState();
}

class _PieChartHomeAndCategorySummaryState
    extends State<PieChartHomeAndCategorySummary> {
  GlobalKey<PieChartDisplayState> pieChartDisplayStateKey = GlobalKey();
  late TransactionCategory? selectedCategory = widget.selectedCategory;
  bool expandCategorySelection = false;
  bool showAllSubcategories = appStateSettings["showAllSubcategories"];

  @override
  void didUpdateWidget(covariant oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCategory != selectedCategory) {
      if (widget.selectedCategory == null) {
        clearCategorySelection();
      } else {
        setState(() {
          selectedCategory = widget.selectedCategory;
        });
      }
    }
  }

  clearCategorySelection() {
    pieChartDisplayStateKey.currentState?.setTouchedIndex(-1);
    setState(() {
      expandCategorySelection = false;
    });
  }

  void openPieChartSettings() async {
    await openPieChartHomePageBottomSheetSettings(context);
    homePageStateKey.currentState?.refreshState();
  }

  void toggleAllSubcategories() {
    setState(() {
      showAllSubcategories = !showAllSubcategories;
    });
    Future.delayed(Duration(milliseconds: 10), () {
      if (expandCategorySelection)
        pieChartDisplayStateKey.currentState
            ?.setTouchedCategoryPk(selectedCategory?.categoryPk);
    });

    updateSettings("showAllSubcategories", showAllSubcategories,
        updateGlobalState: false);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TransactionWallet>>(
      stream: database.getAllPinnedWallets(HomePageWidgetDisplay.PieChart).$1,
      builder: (context, snapshot) {
        if (snapshot.hasData ||
            appStateSettings["pieChartAllWallets"] == true) {
          List<String>? walletPks =
              (snapshot.data ?? []).map((item) => item.walletPk).toList();
          if (walletPks.length <= 0 ||
              appStateSettings["pieChartAllWallets"] == true) walletPks = null;
          return StreamBuilder<List<CategoryWithTotal>>(
            stream:
                database.watchTotalSpentInEachCategoryInTimeRangeFromCategories(
              allWallets: Provider.of<AllWallets>(context),
              start: DateTime.now(),
              end: DateTime.now(),
              categoryFks: null,
              categoryFksExclude: null,
              budgetTransactionFilters: null,
              memberTransactionFilters: null,
              allTime: true,
              walletPks: walletPks,
              isIncome: widget.isIncome,
              followCustomPeriodCycle: true,
              cycleSettingsExtension: "PieChart",
              countUnassignedTransactions: true,
              includeAllSubCategories: true,
              searchFilters: SearchFilters(expenseIncome: [
                if (appStateSettings["pieChartIncomeAndExpenseOnly"] == true)
                  (widget.isIncome == true
                      ? ExpenseIncome.income
                      : ExpenseIncome.expense)
              ]),
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                TotalSpentCategoriesSummary s =
                    watchTotalSpentInTimeRangeHelper(
                  dataInput: snapshot.data ?? [],
                  showAllSubcategories: showAllSubcategories,
                  multiplyTotalBy: 1,
                  absoluteTotal: true,
                );

                List<Widget> categoryEntries = [];
                double totalSpentPercent = 45 / 360;
                snapshot.data!.asMap().forEach(
                  (index, category) {
                    if (selectedCategory?.categoryPk ==
                            category.category.categoryPk ||
                        selectedCategory?.mainCategoryPk ==
                            category.category.categoryPk)
                      categoryEntries.add(
                        CategoryEntry(
                          percentageOffset: totalSpentPercent,
                          getPercentageAfterText: (double categorySpent) {
                            return "of-total".tr().toLowerCase();
                          },
                          useHorizontalPaddingConstrained: false,
                          expandSubcategories: showAllSubcategories ||
                              category.category.categoryPk ==
                                  selectedCategory?.categoryPk ||
                              category.category.categoryPk ==
                                  selectedCategory?.mainCategoryPk,
                          subcategoriesWithTotalMap:
                              s.subCategorySpendingIndexedByMainCategoryPk,
                          todayPercent: 0,
                          overSpentColor: category.total > 0
                              ? getColor(context, "incomeAmount")
                              : getColor(context, "expenseAmount"),
                          showIncomeExpenseIcons: true,
                          onLongPress: (TransactionCategory category,
                              CategoryBudgetLimit? categoryBudgetLimit) {
                            pushRoute(
                              context,
                              AddCategoryPage(
                                routesToPopAfterDelete:
                                    RoutesToPopAfterDelete.One,
                                category: category,
                              ),
                            );
                          },
                          categoryBudgetLimit: category.categoryBudgetLimit,
                          category: category.category,
                          totalSpent: s.totalSpent,
                          transactionCount: category.transactionCount,
                          categorySpent: category.total,
                          onTap: (TransactionCategory tappedCategory, _) {
                            pushRoute(
                              context,
                              TransactionsSearchPage(
                                initialFilters: SearchFilters().copyWith(
                                  dateTimeRange:
                                      getDateTimeRangeForPassedSearchFilters(
                                          cycleSettingsExtension: "PieChart"),
                                  categoryPks: selectedCategory
                                              ?.mainCategoryPk !=
                                          null
                                      ? [selectedCategory!.mainCategoryPk ?? ""]
                                      : selectedCategory == null
                                          ? null
                                          : [selectedCategory!.categoryPk],
                                  subcategoryPks: selectedCategory != null &&
                                          selectedCategory?.mainCategoryPk !=
                                              null
                                      ? [selectedCategory!.categoryPk]
                                      : null,
                                  positiveCashFlow: appStateSettings[
                                              "pieChartIncomeAndExpenseOnly"] ==
                                          true
                                      ? null
                                      : widget.isIncome,
                                  expenseIncome: [
                                    if (appStateSettings[
                                            "pieChartIncomeAndExpenseOnly"] ==
                                        true)
                                      (widget.isIncome == true
                                          ? ExpenseIncome.income
                                          : ExpenseIncome.expense)
                                  ],
                                ),
                              ),
                            );
                          },
                          selected: false,
                          allSelected: true,
                        ),
                      );
                    if (s.totalSpent != 0)
                      totalSpentPercent += category.total.abs() / s.totalSpent;
                  },
                );

                return Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: 10, right: 10, bottom: 15, top: 30),
                          child: LayoutBuilder(
                            builder: (_, boxConstraints) {
                              bool showTopCategoriesLegend =
                                  boxConstraints.maxWidth > 320 &&
                                      snapshot.data!.length > 0;
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (showTopCategoriesLegend)
                                    Flexible(
                                      flex: 1,
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 12),
                                        child: TopCategoriesSpentLegend(
                                          categoriesWithTotal: snapshot.data!
                                              .take(
                                                boxConstraints.maxWidth < 420
                                                    ? 3
                                                    : 5,
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                  Flexible(
                                    flex: 2,
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      alignment: Alignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              right: showTopCategoriesLegend
                                                  ? 20
                                                  : 0),
                                          child: PieChartWrapper(
                                            disableLarge: true,
                                            pieChartDisplayStateKey:
                                                pieChartDisplayStateKey,
                                            isPastBudget: true,
                                            data: s
                                                .dataFilterUnassignedTransactions,
                                            totalSpent: s.totalSpent,
                                            setSelectedCategory:
                                                (categoryPk, category) {
                                              if (category == null) {
                                                clearCategorySelection();
                                              } else {
                                                setState(() {
                                                  selectedCategory = category;
                                                  expandCategorySelection =
                                                      true;
                                                });
                                              }
                                            },
                                            middleColor: getColor(context,
                                                "lightDarkAccentHeavyLight"),
                                          ),
                                        ),
                                        if (snapshot.data!.length <= 0)
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              children: [
                                                ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                      maxWidth: boxConstraints
                                                                      .maxWidth -
                                                                  50 <=
                                                              10
                                                          ? 10
                                                          : boxConstraints
                                                                  .maxWidth -
                                                              50),
                                                  child: TextFont(
                                                    text: widget.isIncome
                                                        ? appStateSettings[
                                                                    "pieChartIncomeAndExpenseOnly"] ==
                                                                true
                                                            ? "no-income-within-period"
                                                                .tr()
                                                            : "no-incoming-within-period"
                                                                .tr()
                                                        : appStateSettings[
                                                                    "pieChartIncomeAndExpenseOnly"] ==
                                                                true
                                                            ? "no-expense-within-period"
                                                                .tr()
                                                            : "no-outgoing-within-period"
                                                                .tr(),
                                                    textAlign: TextAlign.center,
                                                    maxLines: 20,
                                                    fontSize: 17,
                                                  ),
                                                ),
                                                SizedBox(height: 15),
                                                LowKeyButton(
                                                  onTap: openPieChartSettings,
                                                  text: "select-period"
                                                      .tr()
                                                      .capitalizeFirstofEach,
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        Positioned(
                          bottom: -2,
                          left: 0,
                          right: 0,
                          child: PieChartOptions(
                            isIncomeBudget: false,
                            hasSubCategories: s.hasSubCategories,
                            selectedCategory: expandCategorySelection
                                ? selectedCategory
                                : null,
                            onClearSelection: clearCategorySelection,
                            onEditSpendingGoals: null,
                            showAllSubcategories: true,
                            toggleAllSubCategories: toggleAllSubcategories,
                            useHorizontalPaddingConstrained: false,
                          ),
                        ),
                      ],
                    ),
                    widget.animatedSizeCategoryContainer
                        ? AnimatedSizeSwitcher(
                            child: expandCategorySelection == false
                                ? Container(key: ValueKey(1), height: 10)
                                : Column(
                                    children: categoryEntries,
                                    key: ValueKey(
                                        selectedCategory?.categoryPk ?? ""),
                                  ),
                          )
                        : AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            child: expandCategorySelection == false
                                ? Container(key: ValueKey(1), height: 10)
                                : Column(
                                    children: categoryEntries,
                                    key: ValueKey(
                                        selectedCategory?.categoryPk ?? ""),
                                  ),
                          ),
                  ],
                );
              }
              return SizedBox(height: 255);
            },
          );
        }
        return SizedBox(height: 255);
      },
    );
  }
}

class TopCategoriesSpentLegend extends StatelessWidget {
  const TopCategoriesSpentLegend(
      {required this.categoriesWithTotal, super.key});
  final List<CategoryWithTotal> categoriesWithTotal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (CategoryWithTotal categoryWithTotal in categoriesWithTotal)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: HexColor(categoryWithTotal.category.colour),
                  ),
                ),
                SizedBox(width: 5),
                Flexible(
                  child: TextFont(
                    text: categoryWithTotal.category.name,
                    fontSize: 15,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
