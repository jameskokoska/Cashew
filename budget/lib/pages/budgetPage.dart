import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/pastBudgetsPage.dart';
import 'package:budget/pages/transactionsListPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/SelectedTransactionsActionBar.dart';
import 'package:budget/widgets/budgetContainer.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/categoryEntry.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/lineGraph.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/pieChart.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:flutter/scheduler.dart';
import 'dart:developer';

class BudgetPage extends StatelessWidget {
  const BudgetPage({
    super.key,
    required int this.budgetPk,
    this.dateForRange,
    this.isPastBudget = false,
    this.isPastBudgetButCurrentPeriod = false,
  });
  final int budgetPk;
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
  State<_BudgetPageContent> createState() => __BudgetPageContentState();
}

class __BudgetPageContentState extends State<_BudgetPageContent> {
  double budgetHeaderHeight = 0;
  int selectedCategoryPk = -1;
  String? selectedMember = null;
  TransactionCategory? selectedCategory =
      null; //We shouldn't always rely on this, if for example the user changes the category and we are still on this page. But for less important info and O(1) we can reference it quickly.
  GlobalKey<PieChartDisplayState> _pieChartDisplayStateKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
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
        budgetRange.end.millisecondsSinceEpoch.toString();
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
            listID: pageId,
            floatingActionButton: AnimateFABDelayed(
              fab: Padding(
                padding: EdgeInsets.only(bottom: bottomPaddingSafeArea),
                child: FAB(
                  tooltip: "Add Transaction",
                  openPage: AddTransactionPage(
                    title: "Add Transaction",
                    selectedBudget:
                        widget.budget.sharedKey != null ? widget.budget : null,
                  ),
                  color: budgetColorScheme.secondary,
                  colorPlus: budgetColorScheme.onSecondary,
                ),
              ),
            ),
            actions: [
              widget.budget.reoccurrence == BudgetReoccurence.custom ||
                      widget.isPastBudget == true ||
                      widget.isPastBudgetButCurrentPeriod == true
                  ? SizedBox.shrink()
                  : Container(
                      padding: EdgeInsets.only(top: 12.5, right: 5),
                      child: IconButton(
                        onPressed: () {
                          pushRoute(context,
                              PastBudgetsPage(budgetPk: widget.budget.budgetPk),
                              fancyRoute: true);
                        },
                        icon: Icon(Icons.history_rounded),
                      ),
                    ),
              Container(
                padding: EdgeInsets.only(top: 12.5, right: 5),
                child: IconButton(
                  onPressed: () {
                    pushRoute(
                      context,
                      AddBudgetPage(
                        title: "Edit Budget",
                        budget: widget.budget,
                      ),
                    );
                  },
                  icon: Icon(Icons.edit_rounded),
                ),
              ),
            ],
            title: widget.budget.name,
            appBarBackgroundColor: budgetColorScheme.secondaryContainer,
            appBarBackgroundColorStart: budgetColorScheme.secondaryContainer,
            textColor: Theme.of(context).colorScheme.black,
            navbar: false,
            dragDownToDismiss: true,
            dragDownToDissmissBackground: budgetColorScheme.secondaryContainer,
            slivers: [
              StreamBuilder<double?>(
                stream: database.watchTotalSpentByCurrentUserOnly(
                  budgetRange.start,
                  budgetRange.end,
                  widget.budget.budgetPk,
                ),
                builder: (context, snapshotTotalSpentByCurrentUserOnly) {
                  return StreamBuilder<List<CategoryWithTotal>>(
                    stream: database
                        .watchTotalSpentInEachCategoryInTimeRangeFromCategories(
                      budgetRange.start,
                      budgetRange.end,
                      widget.budget.categoryFks ?? [],
                      widget.budget.allCategoryFks,
                      widget.budget.sharedTransactionsShow,
                      member: selectedMember,
                      onlyShowTransactionsBelongingToBudget:
                          widget.budget.sharedKey != null ||
                                  widget.budget.addedTransactionsOnly == true
                              ? widget.budget.budgetPk
                              : null,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.length <= 0)
                          return SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: NoResults(
                                message:
                                    "There are no transactions for this budget",
                              ),
                            ),
                          );
                        double totalSpent = 0;
                        List<Widget> categoryEntries = [];
                        snapshot.data!.forEach((category) {
                          totalSpent = totalSpent + category.total.abs();
                          totalSpent = totalSpent.abs();
                        });
                        snapshot.data!.asMap().forEach((index, category) {
                          categoryEntries.add(
                            CategoryEntry(
                              budgetColorScheme: budgetColorScheme,
                              category: category.category,
                              totalSpent: totalSpent,
                              transactionCount: category.transactionCount,
                              categorySpent: category.total.abs(),
                              onTap: () {
                                if (selectedCategoryPk ==
                                    category.category.categoryPk) {
                                  setState(() {
                                    selectedCategoryPk = -1;
                                    selectedCategory = null;
                                  });
                                  _pieChartDisplayStateKey.currentState!
                                      .setTouchedIndex(-1);
                                } else {
                                  setState(() {
                                    selectedCategoryPk =
                                        category.category.categoryPk;
                                    selectedCategory = category.category;
                                  });
                                  _pieChartDisplayStateKey.currentState!
                                      .setTouchedIndex(index);
                                }
                              },
                              selected: selectedCategoryPk ==
                                  category.category.categoryPk,
                              allSelected: selectedCategoryPk == -1,
                            ),
                          );
                        });
                        return SliverToBoxAdapter(
                          child: Column(children: [
                            Transform.translate(
                              offset: Offset(0, -20),
                              child: WidgetSize(
                                onChange: (size) {
                                  budgetHeaderHeight = size.height - 20;
                                },
                                child: Container(
                                  padding: EdgeInsets.only(
                                      top: 15, bottom: 22, left: 22, right: 22),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                        bottom: Radius.circular(10)),
                                    color: budgetColorScheme.secondaryContainer,
                                  ),
                                  child: Column(
                                    children: [
                                      widget.budget.amount - totalSpent >= 0
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      child: CountUp(
                                                        count: appStateSettings[
                                                                "showTotalSpentForBudget"]
                                                            ? totalSpent
                                                            : widget.budget
                                                                    .amount -
                                                                totalSpent,
                                                        prefix:
                                                            getCurrencyString(),
                                                        duration: Duration(
                                                            milliseconds: 700),
                                                        fontSize: 25,
                                                        textAlign:
                                                            TextAlign.left,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        decimals: moneyDecimals(
                                                            widget
                                                                .budget.amount),
                                                        textColor: budgetColorScheme
                                                            .onSecondaryContainer,
                                                      ),
                                                    ),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 3.8),
                                                      child: TextFont(
                                                        text: (appStateSettings[
                                                                    "showTotalSpentForBudget"]
                                                                ? " spent of "
                                                                : " left of ") +
                                                            convertToMoney(
                                                                widget.budget
                                                                    .amount),
                                                        fontSize: 16,
                                                        textAlign:
                                                            TextAlign.left,
                                                        textColor: budgetColorScheme
                                                            .onSecondaryContainer,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Container(
                                                  child: CountUp(
                                                    count: appStateSettings[
                                                            "showTotalSpentForBudget"]
                                                        ? totalSpent
                                                        : -1 *
                                                            (widget.budget
                                                                    .amount -
                                                                totalSpent),
                                                    prefix: getCurrencyString(),
                                                    duration: Duration(
                                                        milliseconds: 700),
                                                    fontSize: 25,
                                                    textAlign: TextAlign.left,
                                                    fontWeight: FontWeight.bold,
                                                    decimals: moneyDecimals(
                                                        widget.budget.amount),
                                                    textColor: budgetColorScheme
                                                        .onSecondaryContainer,
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 3.8),
                                                  child: TextFont(
                                                    text: (appStateSettings[
                                                                "showTotalSpentForBudget"]
                                                            ? " spent of "
                                                            : " overspent of ") +
                                                        convertToMoney(widget
                                                            .budget.amount),
                                                    fontSize: 16,
                                                    textAlign: TextAlign.left,
                                                    textColor: budgetColorScheme
                                                        .onSecondaryContainer,
                                                  ),
                                                ),
                                              ],
                                            ),
                                      Container(height: 10),
                                      BudgetTimeline(
                                        dateForRange: dateForRange,
                                        budget: widget.budget,
                                        large: true,
                                        percent: totalSpent /
                                            widget.budget.amount *
                                            100,
                                        yourPercent: totalSpent == 0
                                            ? 0
                                            : snapshotTotalSpentByCurrentUserOnly
                                                        .data ==
                                                    null
                                                ? 0
                                                : (snapshotTotalSpentByCurrentUserOnly
                                                            .data! /
                                                        totalSpent *
                                                        100)
                                                    .abs(),
                                        todayPercent:
                                            widget.isPastBudget == true
                                                ? -1
                                                : getPercentBetweenDates(
                                                    budgetRange, dateForRange),
                                      ),
                                      widget.isPastBudget == true
                                          ? SizedBox.shrink()
                                          : Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 15, bottom: 5),
                                              child: DaySpending(
                                                budget: widget.budget,
                                                amount: (widget.budget.amount -
                                                        totalSpent) /
                                                    daysBetween(dateForRange,
                                                        budgetRange.end),
                                                large: true,
                                                budgetRange: budgetRange,
                                              ),
                                            ),
                                      Container(height: 3),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Transform.translate(
                              offset: Offset(0, -10),
                              child: BudgetSpenderSummary(
                                budget: widget.budget,
                                budgetRange: budgetRange,
                                budgetColorScheme: budgetColorScheme,
                                setSelectedMember: (member) {
                                  setState(() {
                                    selectedMember = member;
                                    selectedCategory = null;
                                    selectedCategoryPk = -1;
                                  });
                                  _pieChartDisplayStateKey.currentState!
                                      .setTouchedIndex(-1);
                                },
                              ),
                            ),
                            Container(height: 20),
                            PieChartWrapper(
                                pieChartDisplayStateKey:
                                    _pieChartDisplayStateKey,
                                data: snapshot.data ?? [],
                                totalSpent: totalSpent,
                                setSelectedCategory: (categoryPk, category) {
                                  setState(() {
                                    selectedCategoryPk = categoryPk;
                                    selectedCategory = category;
                                  });
                                },
                                isPastBudget: widget.isPastBudget ?? false),
                            Container(height: 35),
                            ...categoryEntries,
                            Container(height: 15),
                          ]),
                        );
                      }
                      return SliverToBoxAdapter(child: Container());
                    },
                  );
                },
              ),
              SliverToBoxAdapter(
                child: AnimatedSize(
                  duration: Duration(milliseconds: 1000),
                  curve: Curves.easeInOutCubicEmphasized,
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: selectedCategoryPk != -1
                        ? Padding(
                            key: ValueKey(1),
                            padding: const EdgeInsets.only(
                                left: 13, right: 15, top: 5, bottom: 15),
                            child: Center(
                              child: TextFont(
                                text:
                                    "Showing transactions from selected category",
                                maxLines: 10,
                                textAlign: TextAlign.center,
                                fontSize: 13,
                                textColor:
                                    Theme.of(context).colorScheme.textLight,
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : Container(
                            key: ValueKey(0),
                          ),
                  ),
                ),
              ),
              StreamBuilder<List<Transaction>>(
                stream: database.getTransactionsInTimeRangeFromCategories(
                  budgetRange.start,
                  budgetRange.end,
                  widget.budget.categoryFks ?? [],
                  widget.budget.categoryFks == null ||
                          (widget.budget.categoryFks ?? []).length <= 0
                      ? true
                      : false,
                  true,
                  false,
                  widget.budget.sharedTransactionsShow,
                  member: selectedMember,
                  onlyShowTransactionsBelongingToBudget:
                      widget.budget.sharedKey != null ||
                              widget.budget.addedTransactionsOnly == true
                          ? widget.budget.budgetPk
                          : null,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.length <= 0)
                      return SliverToBoxAdapter(
                        child: SizedBox.shrink(),
                      );
                    bool cumulative =
                        appStateSettings["showCumulativeSpending"];
                    double cumulativeTotal = 0;
                    List<Pair> points = [];
                    for (DateTime indexDay = budgetRange.start;
                        indexDay.compareTo(budgetRange.end) <= 0;
                        indexDay = DateTime(
                            indexDay.year, indexDay.month, indexDay.day + 1)) {
                      //can be optimized...
                      double totalForDay = 0;
                      for (Transaction transaction in snapshot.data!) {
                        // if (selectedSlidingSelector == 3 &&
                        //     transaction.income == false) {
                        //   continue;
                        // }
                        // if (selectedSlidingSelector == 2 &&
                        //     transaction.income == true) {
                        //   continue;
                        // }
                        if (selectedCategoryPk == -1 ||
                            transaction.categoryFk ==
                                selectedCategoryPk) if (indexDay
                                    .year ==
                                transaction.dateCreated.year &&
                            indexDay.month == transaction.dateCreated.month &&
                            indexDay.day == transaction.dateCreated.day) {
                          totalForDay += transaction.amount;
                        }
                      }
                      cumulativeTotal += totalForDay;
                      points.add(Pair(points.length.toDouble(),
                          cumulative ? cumulativeTotal : totalForDay));
                    }
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 13),
                        child: Container(
                          padding: EdgeInsets.only(left: 10, right: 5),
                          child: LineChartWrapper(
                            endDate: budgetRange.end,
                            points: points,
                            isCurved: true,
                            color: selectedCategoryPk != -1 &&
                                    selectedCategory != null
                                ? HexColor(selectedCategory!.colour)
                                : budgetColorScheme.primary,
                            verticalLineAt: widget.isPastBudget == true
                                ? null
                                : (budgetRange.end
                                        .difference(dateForRange)
                                        .inDays)
                                    .toDouble(),
                            horizontalLineAt: -widget.budget.amount *
                                ((DateTime.now().millisecondsSinceEpoch -
                                        budgetRange
                                            .start.millisecondsSinceEpoch) /
                                    (budgetRange.end.millisecondsSinceEpoch -
                                        budgetRange
                                            .start.millisecondsSinceEpoch)),
                          ),
                        ),
                      ),
                    );
                  }
                  return SliverToBoxAdapter();
                },
              ),
              ...getTransactionsSlivers(
                budgetRange.start,
                budgetRange.end,
                categoryFks: selectedCategoryPk != -1
                    ? [selectedCategoryPk]
                    : widget.budget.categoryFks ?? [],
                income: false,
                listID: pageId,
                sharedTransactionsShow: widget.budget.sharedTransactionsShow,
                member: selectedMember,
                onlyShowTransactionsBelongingToBudget:
                    widget.budget.sharedKey != null ||
                            widget.budget.addedTransactionsOnly == true
                        ? widget.budget.budgetPk
                        : null,
              ),
              SliverToBoxAdapter(
                child: widget.budget.sharedDateUpdated == null
                    ? SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 28),
                        child: TextFont(
                          text: "Synced " +
                              getTimeAgo(
                                widget.budget.sharedDateUpdated!,
                              ).toLowerCase() +
                              "\n Created by " +
                              getMemberNickname(
                                  (widget.budget.sharedMembers ?? [""])[0]),
                          fontSize: 13,
                          textColor: Theme.of(context).colorScheme.textLight,
                          textAlign: TextAlign.center,
                          maxLines: 4,
                        ),
                      ),
              ),
              // Wipe all remaining pixels off - sometimes graphics artifacts are left behind
              SliverToBoxAdapter(
                child: Container(
                    height: 1, color: Theme.of(context).colorScheme.background),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 10))
            ],
          ),
          SelectedTransactionsActionBar(
            pageID: pageId,
          ),
        ],
      ),
    );
  }
}

class WidgetSize extends StatefulWidget {
  final Widget child;
  final Function onChange;

  const WidgetSize({
    Key? key,
    required this.onChange,
    required this.child,
  }) : super(key: key);

  @override
  _WidgetSizeState createState() => _WidgetSizeState();
}

class _WidgetSizeState extends State<WidgetSize> {
  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
    return Container(
      key: widgetKey,
      child: widget.child,
    );
  }

  var widgetKey = GlobalKey();
  var oldSize;

  void postFrameCallback(_) {
    var context = widgetKey.currentContext;
    if (context == null) return;

    var newSize = context.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    widget.onChange(newSize);
  }
}
