import 'dart:developer';
import 'dart:math';

import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/editBudgetLimitsPage.dart';
import 'package:budget/pages/pastBudgetsPage.dart';
import 'package:budget/pages/premiumPage.dart';
import 'package:budget/pages/transactionFilters.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/struct/spendingSummaryHelper.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/selectedTransactionsAppBar.dart';
import 'package:budget/widgets/budgetContainer.dart';
import 'package:budget/widgets/categoryEntry.dart';
import 'package:budget/widgets/categoryLimits.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/lineGraph.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/pieChart.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntries.dart';
import 'package:budget/widgets/transactionEntry/transactionEntry.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:async/async.dart' show StreamZip;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:budget/widgets/countNumber.dart';
import 'package:budget/struct/currencyFunctions.dart';

import '../widgets/util/widgetSize.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({
    super.key,
    required this.budgetPk,
    this.dateForRange,
    this.isPastBudget = false,
    this.isPastBudgetButCurrentPeriod = false,
  });
  final String budgetPk;
  final DateTime? dateForRange;
  final bool? isPastBudget;
  final bool? isPastBudgetButCurrentPeriod;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Budget>(
        stream: database.getBudget(budgetPk),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _BudgetPageContent(
              budget: snapshot.data!,
              dateForRange: dateForRange,
              isPastBudget: isPastBudget,
              isPastBudgetButCurrentPeriod: isPastBudgetButCurrentPeriod,
            );
          }
          return SizedBox.shrink();
        });
    ;
  }
}

class _BudgetPageContent extends StatefulWidget {
  const _BudgetPageContent({
    Key? key,
    required Budget this.budget,
    this.dateForRange,
    this.isPastBudget = false,
    this.isPastBudgetButCurrentPeriod = false,
  }) : super(key: key);

  final Budget budget;
  final DateTime? dateForRange;
  final bool? isPastBudget;
  final bool? isPastBudgetButCurrentPeriod;

  @override
  State<_BudgetPageContent> createState() => _BudgetPageContentState();
}

class _BudgetPageContentState extends State<_BudgetPageContent> {
  double budgetHeaderHeight = 0;
  String? selectedMember = null;
  bool showAllSubcategories = appStateSettings["showAllSubcategories"];
  TransactionCategory? selectedCategory =
      null; //We shouldn't always rely on this, if for example the user changes the category and we are still on this page. But for less important info and O(1) we can reference it quickly.
  GlobalKey<PieChartDisplayState> _pieChartDisplayStateKey = GlobalKey();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if (widget.isPastBudget == true) premiumPopupPastBudgets(context);
    });
    super.initState();
  }

  void toggleAllSubcategories() {
    setState(() {
      showAllSubcategories = !showAllSubcategories;
    });
    Future.delayed(Duration(milliseconds: 10), () {
      _pieChartDisplayStateKey.currentState!
          .setTouchedCategoryPk(selectedCategory?.categoryPk);
    });

    updateSettings("showAllSubcategories", showAllSubcategories,
        updateGlobalState: false);
  }

  Widget pieChart({
    required double totalSpent,
    required ColorScheme budgetColorScheme,
    required DateTimeRange budgetRange,
    required bool showAllSubcategories,
    required VoidCallback toggleAllSubCategories,
    required List<CategoryWithTotal> dataFilterUnassignedTransactions,
    required bool hasSubCategories,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              boxShadow: boxShadowCheck(
                boxShadowGeneral(context),
              ),
              borderRadius: BorderRadius.circular(200)),
          child: PieChartWrapper(
            pieChartDisplayStateKey: _pieChartDisplayStateKey,
            data: dataFilterUnassignedTransactions,
            totalSpent: totalSpent,
            setSelectedCategory: (categoryPk, category) async {
              setState(() {
                selectedCategory = category;
              });
              // If we want to select the subcategories main category when tapped
              // if (category?.mainCategoryPk != null) {
              //   TransactionCategory mainCategory = await database
              //       .getCategoryInstance(category!.mainCategoryPk!);
              //   setState(() {
              //     selectedCategory = mainCategory;
              //   });
              // } else {
              //   setState(() {
              //     selectedCategory = category;
              //   });
              // }
            },
            isPastBudget: widget.isPastBudget ?? false,
            middleColor: appStateSettings["materialYou"]
                ? dynamicPastel(context, budgetColorScheme.primary,
                    amount: 0.92)
                : null,
          ),
        ),
        PieChartOptions(
          hasSubCategories: hasSubCategories,
          selectedCategory: selectedCategory,
          onClearSelection: () {
            setState(() {
              selectedCategory = null;
            });
            _pieChartDisplayStateKey.currentState!.setTouchedIndex(-1);
          },
          colorScheme: budgetColorScheme,
          onEditSpendingGoals: () {
            pushRoute(
              context,
              EditBudgetLimitsPage(
                budget: widget.budget,
              ),
            );
          },
          showAllSubcategories: showAllSubcategories,
          toggleAllSubCategories: toggleAllSubCategories,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double budgetAmount = budgetAmountToPrimaryCurrency(
        Provider.of<AllWallets>(context, listen: true), widget.budget);
    DateTime dateForRange =
        widget.dateForRange == null ? DateTime.now() : widget.dateForRange!;
    DateTimeRange budgetRange = getBudgetDate(widget.budget, dateForRange);
    ColorScheme budgetColorScheme = ColorScheme.fromSeed(
      seedColor: HexColor(widget.budget.colour,
          defaultColor: Theme.of(context).colorScheme.primary),
      brightness: determineBrightnessTheme(context),
    );
    String pageId = budgetRange.start.millisecondsSinceEpoch.toString() +
        widget.budget.name +
        budgetRange.end.millisecondsSinceEpoch.toString() +
        widget.budget.budgetPk;
    Color? pageBackgroundColor = appStateSettings["materialYou"]
        ? dynamicPastel(context, budgetColorScheme.primary, amount: 0.92)
        : null;
    bool showIncomeExpenseIcons = widget.budget.budgetTransactionFilters == null
        ? true
        : widget.budget.budgetTransactionFilters
                    ?.contains(BudgetTransactionFilters.includeIncome) ==
                true
            ? true
            : false;
    final double todayPercent = getPercentBetweenDates(
      budgetRange,
      //dateForRange,
      DateTime.now(),
    );
    return WillPopScope(
      onWillPop: () async {
        if ((globalSelectedID.value[pageId] ?? []).length > 0) {
          globalSelectedID.value[pageId] = [];
          globalSelectedID.notifyListeners();
          return false;
        } else {
          return true;
        }
      },
      child: Stack(
        children: [
          PageFramework(
            belowAppBarPaddingWhenCenteredTitleSmall: 0,
            subtitle: StreamBuilder<List<CategoryWithTotal>>(
              stream: database
                  .watchTotalSpentInEachCategoryInTimeRangeFromCategories(
                allWallets: Provider.of<AllWallets>(context),
                start: budgetRange.start,
                end: budgetRange.end,
                categoryFks: widget.budget.categoryFks,
                categoryFksExclude: widget.budget.categoryFksExclude,
                budgetTransactionFilters:
                    widget.budget.budgetTransactionFilters,
                memberTransactionFilters:
                    widget.budget.memberTransactionFilters,
                member: selectedMember,
                onlyShowTransactionsBelongingToBudgetPk:
                    widget.budget.sharedKey != null ||
                            widget.budget.addedTransactionsOnly == true
                        ? widget.budget.budgetPk
                        : null,
                budget: widget.budget,
              ),
              builder: (context, snapshot) {
                double totalSpent = 0;
                if (snapshot.hasData) {
                  snapshot.data!.forEach((category) {
                    totalSpent = totalSpent + category.total;
                  });
                  totalSpent = totalSpent * -1;
                }

                if (snapshot.hasData) {
                  return TotalSpent(
                    budget: widget.budget,
                    budgetColorScheme: budgetColorScheme,
                    totalSpent: totalSpent,
                  );
                } else {
                  return SizedBox.shrink();
                }
              },
            ),
            subtitleAlignment: Alignment.bottomLeft,
            subtitleSize: 10,
            backgroundColor: pageBackgroundColor,
            listID: pageId,
            floatingActionButton: AnimateFABDelayed(
              fab: FAB(
                tooltip: "add-transaction".tr(),
                openPage: AddTransactionPage(
                  selectedBudget: widget.budget.sharedKey != null ||
                          widget.budget.addedTransactionsOnly == true
                      ? widget.budget
                      : null,
                  routesToPopAfterDelete: RoutesToPopAfterDelete.One,
                ),
                color: budgetColorScheme.secondary,
                colorPlus: budgetColorScheme.onSecondary,
              ),
            ),
            actions: [
              CustomPopupMenuButton(
                colorScheme: budgetColorScheme,
                showButtons: enableDoubleColumn(context),
                keepOutFirst: true,
                items: [
                  DropdownItemMenu(
                    id: "edit-budget",
                    label: "edit-budget".tr(),
                    icon: appStateSettings["outlinedIcons"]
                        ? Icons.edit_outlined
                        : Icons.edit_rounded,
                    action: () {
                      pushRoute(
                        context,
                        AddBudgetPage(
                          budget: widget.budget,
                          routesToPopAfterDelete: RoutesToPopAfterDelete.All,
                        ),
                      );
                    },
                  ),
                  if (widget.budget.reoccurrence != BudgetReoccurence.custom &&
                      widget.isPastBudget == false &&
                      widget.isPastBudgetButCurrentPeriod == false)
                    DropdownItemMenu(
                      id: "budget-history",
                      label: "budget-history".tr(),
                      icon: appStateSettings["outlinedIcons"]
                          ? Icons.history_outlined
                          : Icons.history_rounded,
                      action: () {
                        pushRoute(
                          context,
                          PastBudgetsPage(budgetPk: widget.budget.budgetPk),
                        );
                      },
                    ),
                  DropdownItemMenu(
                    id: "spending-goals",
                    label: "spending-goals".tr(),
                    icon: appStateSettings["outlinedIcons"]
                        ? Icons.fact_check_outlined
                        : Icons.fact_check_rounded,
                    action: () {
                      pushRoute(
                        context,
                        EditBudgetLimitsPage(
                          budget: widget.budget,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
            title: widget.budget.name,
            appBarBackgroundColor: budgetColorScheme.secondaryContainer,
            appBarBackgroundColorStart: budgetColorScheme.secondaryContainer,
            textColor: getColor(context, "black"),
            dragDownToDismiss: true,
            slivers: [
              StreamBuilder<List<CategoryWithTotal>>(
                stream: database
                    .watchTotalSpentInEachCategoryInTimeRangeFromCategories(
                  allWallets: Provider.of<AllWallets>(context),
                  start: budgetRange.start,
                  end: budgetRange.end,
                  categoryFks: widget.budget.categoryFks,
                  categoryFksExclude: widget.budget.categoryFksExclude,
                  budgetTransactionFilters:
                      widget.budget.budgetTransactionFilters,
                  memberTransactionFilters:
                      widget.budget.memberTransactionFilters,
                  member: selectedMember,
                  onlyShowTransactionsBelongingToBudgetPk:
                      widget.budget.sharedKey != null ||
                              widget.budget.addedTransactionsOnly == true
                          ? widget.budget.budgetPk
                          : null,
                  budget: widget.budget,
                  // Set to countUnassignedTransactons: false for the pie chart
                  //  includeAllSubCategories: showAllSubcategories,
                  // If implementing pie chart summary for subcategories, also need to implement ability to tap a subcategory from the pie chart
                  countUnassignedTransactions: true,
                  includeAllSubCategories: true,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    TotalSpentCategoriesSummary s =
                        watchTotalSpentInTimeRangeHelper(
                            dataInput: snapshot.data ?? [],
                            showAllSubcategories: showAllSubcategories);
                    List<Widget> categoryEntries = [];

                    snapshot.data!.asMap().forEach(
                      (index, category) {
                        categoryEntries.add(
                          CategoryEntry(
                            selectedSubCategoryPk: selectedCategory?.categoryPk,
                            expandSubcategories: showAllSubcategories ||
                                category.category.categoryPk ==
                                    selectedCategory?.categoryPk ||
                                category.category.categoryPk ==
                                    selectedCategory?.mainCategoryPk,
                            subcategoriesWithTotalMap:
                                s.subCategorySpendingIndexedByMainCategoryPk,
                            todayPercent: todayPercent,
                            overSpentColor: showIncomeExpenseIcons
                                ? category.total > 0
                                    ? getColor(context, "incomeAmount")
                                    : getColor(context, "expenseAmount")
                                : null,
                            showIncomeExpenseIcons: showIncomeExpenseIcons,
                            onLongPress: (TransactionCategory category,
                                CategoryBudgetLimit? categoryBudgetLimit) {
                              enterCategoryLimitPopup(
                                context,
                                category,
                                categoryBudgetLimit,
                                widget.budget.budgetPk,
                                (p0) => null,
                                widget.budget.isAbsoluteSpendingLimit,
                              );
                            },
                            isAbsoluteSpendingLimit:
                                widget.budget.isAbsoluteSpendingLimit,
                            budgetLimit: budgetAmount,
                            categoryBudgetLimit: category.categoryBudgetLimit,
                            budgetColorScheme: budgetColorScheme,
                            category: category.category,
                            totalSpent: s.totalSpent,
                            transactionCount: category.transactionCount,
                            categorySpent: showIncomeExpenseIcons == true
                                ? category.total
                                : category.total.abs(),
                            onTap: (TransactionCategory tappedCategory, _) {
                              if (selectedCategory?.categoryPk ==
                                  tappedCategory.categoryPk) {
                                setState(() {
                                  selectedCategory = null;
                                });
                                _pieChartDisplayStateKey.currentState!
                                    .setTouchedIndex(-1);
                              } else {
                                if (showAllSubcategories ||
                                    tappedCategory.mainCategoryPk == null) {
                                  setState(() {
                                    selectedCategory = tappedCategory;
                                  });
                                  _pieChartDisplayStateKey.currentState!
                                      .setTouchedCategoryPk(
                                          tappedCategory.categoryPk);
                                } else {
                                  // We are tapping a subcategoryEntry and it is not in the pie chart
                                  // because showAllSubcategories is false and mainCategoryPk is not null
                                  setState(() {
                                    selectedCategory = tappedCategory;
                                  });
                                  _pieChartDisplayStateKey.currentState!
                                      .setTouchedCategoryPk(
                                          tappedCategory.mainCategoryPk);
                                }
                              }
                            },
                            selected: category.category.categoryPk ==
                                    selectedCategory?.mainCategoryPk ||
                                selectedCategory?.categoryPk ==
                                    category.category.categoryPk,
                            allSelected: selectedCategory == null,
                          ),
                        );
                      },
                    );
                    print(s.totalSpent);
                    return SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Transform.translate(
                            offset: Offset(0, -10),
                            child: WidgetSize(
                              onChange: (Size size) {
                                budgetHeaderHeight = size.height - 20;
                              },
                              child: Container(
                                padding: EdgeInsets.only(
                                  top: 10,
                                  bottom: 22,
                                  left: 22,
                                  right: 22,
                                ),
                                decoration: BoxDecoration(
                                  // borderRadius: BorderRadius.vertical(
                                  //     bottom: Radius.circular(10)),
                                  color: budgetColorScheme.secondaryContainer,
                                ),
                                child: Column(
                                  children: [
                                    Transform.scale(
                                      alignment: Alignment.bottomCenter,
                                      scale: 1500,
                                      child: Container(
                                        height: 10,
                                        width: 100,
                                        color: budgetColorScheme
                                            .secondaryContainer,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal:
                                            getHorizontalPaddingConstrained(
                                                context),
                                      ),
                                      child: StreamBuilder<double?>(
                                        stream: database.watchTotalOfBudget(
                                          allWallets:
                                              Provider.of<AllWallets>(context),
                                          start: budgetRange.start,
                                          end: budgetRange.end,
                                          categoryFks:
                                              widget.budget.categoryFks,
                                          categoryFksExclude:
                                              widget.budget.categoryFksExclude,
                                          budgetTransactionFilters: widget
                                              .budget.budgetTransactionFilters,
                                          memberTransactionFilters: widget
                                              .budget.memberTransactionFilters,
                                          member: selectedMember,
                                          onlyShowTransactionsBelongingToBudgetPk:
                                              widget.budget.sharedKey != null ||
                                                      widget.budget
                                                              .addedTransactionsOnly ==
                                                          true
                                                  ? widget.budget.budgetPk
                                                  : null,
                                          budget: widget.budget,
                                          searchFilters: SearchFilters(
                                              paidStatus: [PaidStatus.notPaid]),
                                          paidOnly: false,
                                        ),
                                        builder: (context, snapshot) {
                                          return BudgetTimeline(
                                            dateForRange: dateForRange,
                                            budget: widget.budget,
                                            large: true,
                                            percent: budgetAmount == 0
                                                ? 0
                                                : s.totalSpent /
                                                    budgetAmount *
                                                    100,
                                            yourPercent: 0,
                                            todayPercent:
                                                widget.isPastBudget == true
                                                    ? -1
                                                    : todayPercent,
                                            ghostPercent: budgetAmount == 0
                                                ? 0
                                                : (((snapshot.data ?? 0) * -1) /
                                                        budgetAmount) *
                                                    100,
                                          );
                                        },
                                      ),
                                    ),
                                    widget.isPastBudget == true
                                        ? SizedBox.shrink()
                                        : DaySpending(
                                            budget: widget.budget,
                                            totalAmount: s.totalSpent,
                                            large: true,
                                            budgetRange: budgetRange,
                                            padding: const EdgeInsets.only(
                                                top: 15, bottom: 0),
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          appStateSettings["sharedBudgets"]
                              ? BudgetSpenderSummary(
                                  budget: widget.budget,
                                  budgetRange: budgetRange,
                                  budgetColorScheme: budgetColorScheme,
                                  setSelectedMember: (member) {
                                    setState(() {
                                      selectedMember = member;
                                      selectedCategory = null;
                                    });
                                    _pieChartDisplayStateKey.currentState!
                                        .setTouchedIndex(-1);
                                  },
                                )
                              : SizedBox.shrink(),
                          if (snapshot.data!.length > 0) SizedBox(height: 30),

                          if (snapshot.data!.length > 0)
                            pieChart(
                              budgetRange: budgetRange,
                              totalSpent: s.totalSpent,
                              budgetColorScheme: budgetColorScheme,
                              showAllSubcategories: showAllSubcategories,
                              toggleAllSubCategories: toggleAllSubcategories,
                              dataFilterUnassignedTransactions:
                                  s.dataFilterUnassignedTransactions,
                              hasSubCategories: s.hasSubCategories,
                            ),
                          // if (snapshot.data!.length > 0)
                          //   SizedBox(height: 35),
                          ...categoryEntries,
                          if (snapshot.data!.length > 0) SizedBox(height: 15),
                        ],
                      ),
                    );
                  }
                  return SliverToBoxAdapter(child: Container());
                },
              ),
              SliverToBoxAdapter(
                child: AnimatedExpanded(
                    expand: selectedCategory != null,
                    child: Padding(
                      key: ValueKey(1),
                      padding: const EdgeInsets.only(
                          left: 13, right: 15, top: 5, bottom: 15),
                      child: Center(
                        child: TextFont(
                          text: "transactions-for-selected-category".tr(),
                          maxLines: 10,
                          textAlign: TextAlign.center,
                          fontSize: 13,
                          textColor: getColor(context, "textLight"),
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 13),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 13),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      color: appStateSettings["materialYou"]
                          ? dynamicPastel(
                              context, budgetColorScheme.secondaryContainer,
                              amount: 0.5)
                          : getColor(context, "lightDarkAccentHeavyLight"),
                      boxShadow: boxShadowCheck(boxShadowGeneral(context)),
                    ),
                    child: BudgetLineGraph(
                      budget: widget.budget,
                      dateForRange: dateForRange,
                      isPastBudget: widget.isPastBudget,
                      selectedCategory: selectedCategory,
                      budgetRange: budgetRange,
                      budgetColorScheme: budgetColorScheme,
                      showIfNone: false,
                      padding: EdgeInsets.only(
                          left: 5, right: 7, bottom: 12, top: 18),
                    ),
                  ),
                ),
              ),
              TransactionEntries(
                budgetRange.start,
                budgetRange.end,
                categoryFks: selectedCategory != null
                    ? [selectedCategory!.categoryPk]
                    : widget.budget.categoryFks,
                categoryFksExclude: selectedCategory != null
                    ? null
                    : widget.budget.categoryFksExclude,
                income: null,
                listID: pageId,
                budgetTransactionFilters:
                    widget.budget.budgetTransactionFilters,
                memberTransactionFilters:
                    widget.budget.memberTransactionFilters,
                member: selectedMember,
                onlyShowTransactionsBelongingToBudgetPk:
                    widget.budget.sharedKey != null ||
                            widget.budget.addedTransactionsOnly == true
                        ? widget.budget.budgetPk
                        : null,
                walletFks: widget.budget.walletFks ?? [],
                budget: widget.budget,
                dateDividerColor: pageBackgroundColor,
                transactionBackgroundColor: pageBackgroundColor,
                categoryTintColor: budgetColorScheme.primary,
                colorScheme: budgetColorScheme,
                noResultsExtraWidget: widget.budget.reoccurrence !=
                            BudgetReoccurence.custom &&
                        widget.isPastBudget == false &&
                        widget.isPastBudgetButCurrentPeriod == false
                    ? Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Tappable(
                          borderRadius: 15,
                          color: dynamicPastel(
                            context,
                            budgetColorScheme.secondaryContainer,
                            amountLight:
                                appStateSettings["materialYou"] ? 0.25 : 0.4,
                            amountDark:
                                appStateSettings["materialYou"] ? 0.4 : 0.55,
                          ),
                          onTap: () {
                            pushRoute(
                              context,
                              PastBudgetsPage(budgetPk: widget.budget.budgetPk),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ButtonIcon(
                                  onTap: () {
                                    pushRoute(
                                      context,
                                      PastBudgetsPage(
                                          budgetPk: widget.budget.budgetPk),
                                    );
                                  },
                                  icon: appStateSettings["outlinedIcons"]
                                      ? Icons.history_outlined
                                      : Icons.history_rounded,
                                  color: dynamicPastel(
                                      context,
                                      HexColor(widget.budget.colour,
                                          defaultColor: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                      amount: 0.5),
                                  iconColor: dynamicPastel(
                                      context,
                                      HexColor(widget.budget.colour,
                                          defaultColor: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                      amount: 0.7,
                                      inverse: true),
                                  size: 38,
                                  iconPadding: 18,
                                ),
                                SizedBox(width: 10),
                                Flexible(
                                  child: TextFont(
                                    text: "view-previous-budget-periods".tr(),
                                    fontSize: 17,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
                showTotalCashFlow: true,
              ),
              SliverToBoxAdapter(
                child: widget.budget.sharedDateUpdated == null
                    ? SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, bottom: 0),
                        child: TextFont(
                          text: "synced".tr() +
                              " " +
                              getTimeAgo(
                                widget.budget.sharedDateUpdated!,
                              ).toLowerCase() +
                              "\n Created by " +
                              getMemberNickname(
                                  (widget.budget.sharedMembers ?? [""])[0]),
                          fontSize: 13,
                          textColor: getColor(context, "textLight"),
                          textAlign: TextAlign.center,
                          maxLines: 4,
                        ),
                      ),
              ),
              // Wipe all remaining pixels off - sometimes graphics artifacts are left behind
              SliverToBoxAdapter(
                child: Container(height: 1, color: pageBackgroundColor),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 45))
            ],
          ),
          SelectedTransactionsAppBar(
            pageID: pageId,
            colorScheme: budgetColorScheme,
          ),
        ],
      ),
    );
  }
}

class WidgetPosition extends StatefulWidget {
  final Widget child;
  final Function(Offset position) onChange;

  const WidgetPosition({
    Key? key,
    required this.onChange,
    required this.child,
  }) : super(key: key);

  @override
  _WidgetPositionState createState() => _WidgetPositionState();
}

class _WidgetPositionState extends State<WidgetPosition> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(postFrameCallback);
    return Container(
      key: widgetKey,
      child: widget.child,
    );
  }

  var widgetKey = GlobalKey();
  var oldPosition;

  void postFrameCallback(_) {
    var context = widgetKey.currentContext;
    if (context == null) return;

    RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    Offset newPosition = renderBox.localToGlobal(Offset.zero);
    if (oldPosition == newPosition) return;

    oldPosition = newPosition;
    widget.onChange(newPosition);
  }
}

class BudgetLineGraph extends StatefulWidget {
  const BudgetLineGraph({
    required this.budget,
    required this.dateForRange,
    required this.isPastBudget,
    required this.selectedCategory,
    required this.budgetRange,
    required this.budgetColorScheme,
    this.showPastSpending = true,
    this.showIfNone = true,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final Budget budget;
  final DateTime? dateForRange;
  final bool? isPastBudget;
  final TransactionCategory? selectedCategory;
  final DateTimeRange budgetRange;
  final ColorScheme budgetColorScheme;
  final bool showPastSpending;
  final bool showIfNone;
  final EdgeInsets padding;

  @override
  State<BudgetLineGraph> createState() => _BudgetLineGraphState();
}

class _BudgetLineGraphState extends State<BudgetLineGraph> {
  Stream<List<List<Transaction>>>? mergedStreamsPastSpendingTotals;
  List<DateTimeRange> dateTimeRanges = [];
  int longestDateRange = 0;

  void didUpdateWidget(oldWidget) {
    if (oldWidget != widget) {
      _init();
    }
  }

  initState() {
    _init();
  }

  _init() {
    Future.delayed(
      Duration.zero,
      () async {
        dateTimeRanges = [];
        List<Stream<List<Transaction>>> watchedPastSpendingTotals = [];
        for (int index = 0;
            index <=
                (widget.showPastSpending == false
                    ? 0
                    : (appStateSettings["showPastSpendingTrajectory"] == true
                        ? 2
                        : 0));
            index++) {
          DateTime datePast = DateTime(
            (widget.dateForRange ?? DateTime.now()).year -
                (widget.budget.reoccurrence == BudgetReoccurence.yearly
                    ? index * widget.budget.periodLength
                    : 0),
            (widget.dateForRange ?? DateTime.now()).month -
                (widget.budget.reoccurrence == BudgetReoccurence.monthly
                    ? index * widget.budget.periodLength
                    : 0),
            (widget.dateForRange ?? DateTime.now()).day -
                (widget.budget.reoccurrence == BudgetReoccurence.daily
                    ? index * widget.budget.periodLength
                    : 0) -
                (widget.budget.reoccurrence == BudgetReoccurence.weekly
                    ? index * 7 * widget.budget.periodLength
                    : 0),
            0,
            0,
            1,
          );

          DateTimeRange budgetRange = getBudgetDate(widget.budget, datePast);
          dateTimeRanges.add(budgetRange);
          watchedPastSpendingTotals
              .add(database.getTransactionsInTimeRangeFromCategories(
            budgetRange.start,
            budgetRange.end,
            widget.budget.categoryFks,
            widget.budget.categoryFksExclude,
            true,
            null,
            widget.budget.budgetTransactionFilters,
            widget.budget.memberTransactionFilters,
            onlyShowTransactionsBelongingToBudgetPk:
                widget.budget.sharedKey != null ||
                        widget.budget.addedTransactionsOnly == true
                    ? widget.budget.budgetPk
                    : null,
            budget: widget.budget,
          ));
          if (budgetRange.duration.inDays > longestDateRange) {
            longestDateRange = budgetRange.duration.inDays;
          }
        }

        setState(() {
          mergedStreamsPastSpendingTotals =
              StreamZip(watchedPastSpendingTotals);
        });
      },
    );
  }

  // Whether to always show all the days of the budget in the line graph
  bool showCompressedView = appStateSettings["showCompressedViewBudgetGraph"];

  @override
  Widget build(BuildContext context) {
    double budgetAmount = budgetAmountToPrimaryCurrency(
        Provider.of<AllWallets>(context, listen: true), widget.budget);

    return StreamBuilder<List<List<Transaction>>>(
      stream: mergedStreamsPastSpendingTotals,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.length <= 0) return SizedBox.shrink();
          bool cumulative = appStateSettings["showCumulativeSpending"];
          DateTime budgetRangeEnd = widget.budgetRange.end;
          if (showCompressedView && budgetRangeEnd.isAfter(DateTime.now())) {
            budgetRangeEnd = DateTime.now();
          }
          int totalZeroes = 0;
          List<List<Pair>> pointsList = [];
          for (int snapshotIndex = 0;
              snapshotIndex < snapshot.data!.length;
              snapshotIndex++) {
            double cumulativeTotal = 0;
            List<Pair> points = [];
            // day limit used to keep max days shown to that of the current length of the current budget (for example, some monthly periods will be 28 days because of February)
            // this should be eventually fixed better
            // as some days are no longer accounted for in the previous budgets term

            // get longest month, add those days as an offset difference of the current duration
            // TODO day count broken for some days...
            // int dayCount = (dateTimeRanges[snapshotIndex].duration.inDays -
            //         longestDateRange)
            //     .abs();
            // for (int dayCounter = 0; dayCounter < dayCount; dayCounter++) {
            //   points.add(Pair(points.length.toDouble(), 0));
            // }

            for (DateTime indexDay = dateTimeRanges[snapshotIndex].start;
                indexDay.compareTo(dateTimeRanges[snapshotIndex].end) <= 0;
                indexDay =
                    DateTime(indexDay.year, indexDay.month, indexDay.day + 1)) {
              if (showCompressedView && indexDay.isAfter(DateTime.now())) break;
              // dayCount++;

              //can be optimized...
              double totalForDay = 0;

              for (Transaction transaction in snapshot.data![snapshotIndex]) {
                if (widget.selectedCategory == null ||
                    transaction.categoryFk ==
                        widget.selectedCategory?.categoryPk ||
                    transaction.subCategoryFk ==
                        widget.selectedCategory?.categoryPk) {
                  if (indexDay.year == transaction.dateCreated.year &&
                      indexDay.month == transaction.dateCreated.month &&
                      indexDay.day == transaction.dateCreated.day) {
                    totalForDay += (transaction.amount *
                            (amountRatioToPrimaryCurrencyGivenPk(
                                Provider.of<AllWallets>(context),
                                transaction.walletFk))) *
                        -1;
                  }

                  // If it is the first day of a custom time period and it is a added budget
                  // We want to get the total spent of all before this day!
                  if (indexDay == dateTimeRanges[0].start &&
                      widget.budget.addedTransactionsOnly &&
                      widget.budget.reoccurrence == BudgetReoccurence.custom &&
                      indexDay.millisecondsSinceEpoch >
                          transaction.dateCreated.millisecondsSinceEpoch) {
                    print(indexDay);
                    totalForDay += (transaction.amount *
                            (amountRatioToPrimaryCurrencyGivenPk(
                                Provider.of<AllWallets>(context),
                                transaction.walletFk))) *
                        -1;
                  }
                }
              }
              cumulativeTotal += totalForDay;
              points.add(Pair(points.length.toDouble(),
                  cumulative ? cumulativeTotal : totalForDay));
              if (totalForDay == 0) totalZeroes++;
            }
            pointsList.add(points);
          }
          Color lineColor = widget.selectedCategory?.categoryPk != null &&
                  widget.selectedCategory != null
              ? HexColor(widget.selectedCategory!.colour,
                  defaultColor: Theme.of(context).colorScheme.primary)
              : widget.budgetColorScheme.primary;
          if (widget.showIfNone == false && totalZeroes == pointsList[0].length)
            return SizedBox.shrink();
          return Stack(
            children: [
              Padding(
                padding: widget.padding,
                child: LineChartWrapper(
                  keepHorizontalLineInView:
                      widget.selectedCategory == null ? true : false,
                  color: lineColor,
                  verticalLineAt: widget.isPastBudget == true
                      ? null
                      : (budgetRangeEnd
                              .difference(
                                  (widget.dateForRange ?? DateTime.now()))
                              .inDays)
                          .toDouble(),
                  endDate: budgetRangeEnd,
                  points: pointsList,
                  isCurved: true,
                  colors: [
                    for (int index = 0; index < snapshot.data!.length; index++)
                      index == 0
                          ? lineColor
                          : (widget.selectedCategory?.categoryPk != null &&
                                      widget.selectedCategory != null
                                  ? lineColor
                                  : widget.budgetColorScheme.tertiary)
                              .withOpacity((index) / snapshot.data!.length)
                  ],
                  horizontalLineAt: widget.isPastBudget == true ||
                          (widget.budget.reoccurrence ==
                                  BudgetReoccurence.custom &&
                              widget.budget.endDate.millisecondsSinceEpoch <
                                  DateTime.now().millisecondsSinceEpoch) ||
                          (widget.budget.addedTransactionsOnly &&
                              widget.budget.endDate.millisecondsSinceEpoch <
                                  DateTime.now().millisecondsSinceEpoch)
                      ? budgetAmount
                      : budgetAmount *
                          ((DateTime.now().millisecondsSinceEpoch -
                                  widget.budgetRange.start
                                      .millisecondsSinceEpoch) /
                              (widget.budgetRange.end.millisecondsSinceEpoch -
                                  widget.budgetRange.start
                                      .millisecondsSinceEpoch)),
                ),
              ),
              if (widget.isPastBudget == false &&
                  widget.budgetRange.end.isAfter(DateTime.now()))
                Positioned(
                  right: 0,
                  top: 0,
                  child: Transform.translate(
                    offset: Offset(5, -5),
                    child: Tooltip(
                      message: showCompressedView
                          ? "view-all-days".tr()
                          : "view-to-today".tr(),
                      child: IconButton(
                        color: widget.budgetColorScheme.primary,
                        icon: Transform.rotate(
                          angle: pi / 2,
                          child: ScaledAnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            keyToWatch: showCompressedView.toString(),
                            child: Icon(
                              showCompressedView
                                  ? appStateSettings["outlinedIcons"]
                                      ? Icons.expand_outlined
                                      : Icons.expand_rounded
                                  : appStateSettings["outlinedIcons"]
                                      ? Icons.compress_outlined
                                      : Icons.compress_rounded,
                              size: 22,
                              color: widget.budgetColorScheme.primary
                                  .withOpacity(0.8),
                            ),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            showCompressedView = !showCompressedView;
                          });
                          updateSettings("showCompressedViewBudgetGraph",
                              showCompressedView,
                              updateGlobalState: false);
                        },
                      ),
                    ),
                  ),
                ),
            ],
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}

class TotalSpent extends StatefulWidget {
  const TotalSpent({
    super.key,
    required this.budgetColorScheme,
    required this.totalSpent,
    required this.budget,
  });

  final ColorScheme budgetColorScheme;
  final double totalSpent;
  final Budget budget;

  @override
  State<TotalSpent> createState() => _TotalSpentState();
}

class _TotalSpentState extends State<TotalSpent> {
  bool showTotalSpent = appStateSettings["showTotalSpentForBudget"];

  _swapTotalSpentDisplay() {
    setState(() {
      showTotalSpent = !showTotalSpent;
    });
    updateSettings("showTotalSpentForBudget", showTotalSpent,
        pagesNeedingRefresh: [0, 2], updateGlobalState: false);
  }

  @override
  Widget build(BuildContext context) {
    double budgetAmount = budgetAmountToPrimaryCurrency(
        Provider.of<AllWallets>(context, listen: true), widget.budget);

    return GestureDetector(
      onTap: () {
        _swapTotalSpentDisplay();
      },
      onLongPress: () {
        HapticFeedback.heavyImpact();
        _swapTotalSpentDisplay();
      },
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: IntrinsicWidth(
          child: budgetAmount - widget.totalSpent >= 0
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      child: CountNumber(
                        count: showTotalSpent
                            ? widget.totalSpent
                            : budgetAmount - widget.totalSpent,
                        duration: Duration(milliseconds: 400),
                        initialCount: (0),
                        textBuilder: (number) {
                          return TextFont(
                            text: convertToMoney(
                                Provider.of<AllWallets>(context), number,
                                finalNumber: showTotalSpent
                                    ? widget.totalSpent
                                    : budgetAmount - widget.totalSpent),
                            fontSize: 22,
                            textAlign: TextAlign.left,
                            fontWeight: FontWeight.bold,
                            textColor:
                                widget.budgetColorScheme.onSecondaryContainer,
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(bottom: 1.5),
                      child: TextFont(
                        text: (showTotalSpent
                                ? " " + "spent-amount-of".tr() + " "
                                : " " + "remaining-amount-of".tr() + " ") +
                            convertToMoney(
                                Provider.of<AllWallets>(context), budgetAmount),
                        fontSize: 15,
                        textAlign: TextAlign.left,
                        textColor:
                            widget.budgetColorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      child: CountNumber(
                        count: showTotalSpent
                            ? widget.totalSpent
                            : -1 * (budgetAmount - widget.totalSpent),
                        duration: Duration(milliseconds: 400),
                        initialCount: (0),
                        textBuilder: (number) {
                          return TextFont(
                            text: convertToMoney(
                                Provider.of<AllWallets>(context), number,
                                finalNumber: showTotalSpent
                                    ? widget.totalSpent
                                    : -1 * (budgetAmount - widget.totalSpent)),
                            fontSize: 22,
                            textAlign: TextAlign.left,
                            fontWeight: FontWeight.bold,
                            textColor:
                                widget.budgetColorScheme.onSecondaryContainer,
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(bottom: 1.5),
                      child: TextFont(
                        text: (showTotalSpent
                                ? " " + "spent-amount-of".tr() + " "
                                : " " + "overspent-amount-of".tr() + " ") +
                            convertToMoney(
                                Provider.of<AllWallets>(context), budgetAmount),
                        fontSize: 15,
                        textAlign: TextAlign.left,
                        textColor:
                            widget.budgetColorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
