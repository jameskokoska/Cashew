import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/pastBudgetsPage.dart';
import 'package:budget/pages/transactionsListPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/selectedTransactionsActionBar.dart';
import 'package:budget/widgets/budgetContainer.dart';
import 'package:budget/widgets/categoryEntry.dart';
import 'package:budget/widgets/categoryLimits.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/lineGraph.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/pieChart.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:flutter/scheduler.dart';
import 'package:async/async.dart' show StreamZip;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:budget/widgets/countNumber.dart';

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
  State<_BudgetPageContent> createState() => _BudgetPageContentState();
}

class _BudgetPageContentState extends State<_BudgetPageContent> {
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
    Color? pageBackgroundColor = appStateSettings["materialYou"]
        ? dynamicPastel(context, budgetColorScheme.primary, amount: 0.92)
        : null;
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
            subtitle: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Transform.translate(
                offset: Offset(0, 8),
                child: StreamBuilder<double?>(
                  stream: database.watchTotalSpentByCurrentUserOnly(
                      Provider.of<AllWallets>(context),
                      budgetRange.start,
                      budgetRange.end,
                      widget.budget.budgetPk),
                  builder: (context, snapshotTotalSpentByCurrentUserOnly) {
                    return StreamBuilder<List<CategoryWithTotal>>(
                      stream: database
                          .watchTotalSpentInEachCategoryInTimeRangeFromCategories(
                        Provider.of<AllWallets>(context),
                        budgetRange.start,
                        budgetRange.end,
                        widget.budget.categoryFks ?? [],
                        widget.budget.allCategoryFks,
                        widget.budget.budgetTransactionFilters,
                        widget.budget.memberTransactionFilters,
                        member: selectedMember,
                        onlyShowTransactionsBelongingToBudget:
                            widget.budget.sharedKey != null ||
                                    widget.budget.addedTransactionsOnly == true
                                ? widget.budget.budgetPk
                                : null,
                        budget: widget.budget,
                      ),
                      builder: (context, snapshot) {
                        double totalSpent = 0;
                        if (snapshot.hasData)
                          snapshot.data!.forEach((category) {
                            totalSpent = totalSpent + category.total.abs();
                            totalSpent = totalSpent.abs();
                          });
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
                    );
                  },
                ),
              ),
            ),
            subtitleAlignment: Alignment.bottomLeft,
            subtitleSize: 10,
            subtitleAnimationSpeed: 10,
            backgroundColor: pageBackgroundColor,
            listID: pageId,
            floatingActionButton: AnimateFABDelayed(
              fab: Padding(
                padding: EdgeInsets.only(bottom: bottomPaddingSafeArea),
                child: FAB(
                  tooltip: "Add Transaction",
                  openPage: AddTransactionPage(
                    title: "Add Transaction",
                    selectedBudget: widget.budget.sharedKey != null ||
                            widget.budget.addedTransactionsOnly == true
                        ? widget.budget
                        : null,
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
                  : IconButton(
                      tooltip: "Past budgets",
                      onPressed: () {
                        pushRoute(
                          context,
                          PastBudgetsPage(budgetPk: widget.budget.budgetPk),
                          fancyRoute: true,
                        );
                      },
                      icon: Icon(
                        Icons.history_rounded,
                        color: budgetColorScheme.onSecondaryContainer,
                      ),
                    ),
              IconButton(
                tooltip: "Edit budget",
                onPressed: () {
                  pushRoute(
                    context,
                    AddBudgetPage(
                      title: "Edit Budget",
                      budget: widget.budget,
                    ),
                  );
                },
                icon: Icon(
                  Icons.edit_rounded,
                  color: budgetColorScheme.onSecondaryContainer,
                ),
              ),
            ],
            title: widget.budget.name,
            appBarBackgroundColor: budgetColorScheme.secondaryContainer,
            appBarBackgroundColorStart: budgetColorScheme.secondaryContainer,
            textColor: getColor(context, "black"),
            navbar: false,
            dragDownToDismiss: true,
            dragDownToDissmissBackground: budgetColorScheme.secondaryContainer,
            slivers: [
              StreamBuilder<double?>(
                stream: database.watchTotalSpentByCurrentUserOnly(
                  Provider.of<AllWallets>(context),
                  budgetRange.start,
                  budgetRange.end,
                  widget.budget.budgetPk,
                ),
                builder: (context, snapshotTotalSpentByCurrentUserOnly) {
                  return StreamBuilder<List<CategoryWithTotal>>(
                    stream: database
                        .watchTotalSpentInEachCategoryInTimeRangeFromCategories(
                      Provider.of<AllWallets>(context),
                      budgetRange.start,
                      budgetRange.end,
                      widget.budget.categoryFks ?? [],
                      widget.budget.allCategoryFks,
                      widget.budget.budgetTransactionFilters,
                      widget.budget.memberTransactionFilters,
                      member: selectedMember,
                      onlyShowTransactionsBelongingToBudget:
                          widget.budget.sharedKey != null ||
                                  widget.budget.addedTransactionsOnly == true
                              ? widget.budget.budgetPk
                              : null,
                      budget: widget.budget,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        double totalSpent = 0;
                        List<Widget> categoryEntries = [];
                        snapshot.data!.forEach((category) {
                          totalSpent = totalSpent + category.total.abs();
                          totalSpent = totalSpent.abs();
                        });
                        snapshot.data!.asMap().forEach((index, category) {
                          categoryEntries.add(CategoryEntry(
                            onLongPress: () {
                              enterCategoryLimitPopup(
                                context,
                                category.category,
                                category.categoryBudgetLimit,
                                widget.budget.budgetPk,
                                (p0) => null,
                                widget.budget.isAbsoluteSpendingLimit,
                              );
                            },
                            isAbsoluteSpendingLimit:
                                widget.budget.isAbsoluteSpendingLimit,
                            budgetLimit: widget.budget.amount,
                            categoryBudgetLimit: category.categoryBudgetLimit,
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
                          ));
                        });
                        return SliverToBoxAdapter(
                          child: Column(children: [
                            Transform.translate(
                              offset: Offset(0, -10),
                              child: WidgetSize(
                                onChange: (size) {
                                  budgetHeaderHeight = size.height - 20;
                                },
                                child: Container(
                                  padding: EdgeInsets.only(
                                    top: 20,
                                    bottom: 22,
                                    left: 22,
                                    right: 22,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                        bottom: Radius.circular(10)),
                                    color: budgetColorScheme.secondaryContainer,
                                  ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal:
                                              getHorizontalPaddingConstrained(
                                                  context),
                                        ),
                                        child: BudgetTimeline(
                                          dateForRange: dateForRange,
                                          budget: widget.budget,
                                          large: true,
                                          percent: widget.budget.amount == 0
                                              ? 0
                                              : totalSpent /
                                                  widget.budget.amount *
                                                  100,
                                          yourPercent: totalSpent == 0
                                              ? 0
                                              : snapshotTotalSpentByCurrentUserOnly
                                                          .data! ==
                                                      null
                                                  ? 0
                                                  : (snapshotTotalSpentByCurrentUserOnly
                                                              .data! /
                                                          totalSpent *
                                                          100)
                                                      .abs(),
                                          todayPercent: widget.isPastBudget ==
                                                  true
                                              ? -1
                                              : getPercentBetweenDates(
                                                  budgetRange, dateForRange),
                                        ),
                                      ),
                                      widget.isPastBudget == true
                                          ? SizedBox.shrink()
                                          : DaySpending(
                                              budget: widget.budget,
                                              amount: (widget.budget.amount -
                                                      totalSpent) /
                                                  daysBetween(dateForRange,
                                                      budgetRange.end),
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
                            BudgetSpenderSummary(
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
                            if (snapshot.data!.length > 0) SizedBox(height: 30),
                            if (snapshot.data!.length > 0)
                              Container(
                                decoration: BoxDecoration(
                                    boxShadow: boxShadowCheck(
                                      boxShadowGeneral(context),
                                    ),
                                    borderRadius: BorderRadius.circular(200)),
                                child: PieChartWrapper(
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
                                  isPastBudget: widget.isPastBudget ?? false,
                                  middleColor: appStateSettings["materialYou"]
                                      ? dynamicPastel(
                                          context, budgetColorScheme.primary,
                                          amount: 0.92)
                                      : null,
                                ),
                              ),
                            if (snapshot.data!.length > 0) SizedBox(height: 35),
                            ...categoryEntries,
                            if (snapshot.data!.length > 0) SizedBox(height: 15),
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
                                textColor: getColor(context, "textLight"),
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
                      selectedCategoryPk: selectedCategoryPk,
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
              getTransactionsSlivers(
                budgetRange.start,
                budgetRange.end,
                categoryFks: selectedCategoryPk != -1
                    ? [selectedCategoryPk]
                    : widget.budget.categoryFks ?? [],
                income: false,
                listID: pageId,
                budgetTransactionFilters:
                    widget.budget.budgetTransactionFilters,
                memberTransactionFilters:
                    widget.budget.memberTransactionFilters,
                member: selectedMember,
                onlyShowTransactionsBelongingToBudget:
                    widget.budget.sharedKey != null ||
                            widget.budget.addedTransactionsOnly == true
                        ? widget.budget.budgetPk
                        : null,
                budget: widget.budget,
                dateDividerColor: pageBackgroundColor,
                transactionBackgroundColor: pageBackgroundColor,
                categoryTintColor: budgetColorScheme.primary,
                colorScheme: budgetColorScheme,
              ),
              SliverToBoxAdapter(
                child: StreamBuilder<double?>(
                  stream: database.watchTotalSpentByCurrentUserOnly(
                    Provider.of<AllWallets>(context),
                    budgetRange.start,
                    budgetRange.end,
                    widget.budget.budgetPk,
                  ),
                  builder: (context, snapshotTotalSpentByCurrentUserOnly) {
                    return StreamBuilder<List<CategoryWithTotal>>(
                      stream: database
                          .watchTotalSpentInEachCategoryInTimeRangeFromCategories(
                        Provider.of<AllWallets>(context),
                        budgetRange.start,
                        budgetRange.end,
                        widget.budget.categoryFks ?? [],
                        widget.budget.allCategoryFks,
                        widget.budget.budgetTransactionFilters,
                        widget.budget.memberTransactionFilters,
                        member: selectedMember,
                        onlyShowTransactionsBelongingToBudget:
                            widget.budget.sharedKey != null ||
                                    widget.budget.addedTransactionsOnly == true
                                ? widget.budget.budgetPk
                                : null,
                        budget: widget.budget,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          double totalSpent = 0;
                          int totalTransactions = 0;
                          snapshot.data!.forEach((category) {
                            totalSpent = totalSpent + category.total.abs();
                            totalSpent = totalSpent.abs();
                            totalTransactions =
                                totalTransactions + category.transactionCount;
                          });
                          if (totalSpent == 0 && totalTransactions == 0)
                            return SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                              top: 10,
                              bottom: 8,
                            ),
                            child: TextFont(
                              text: "Total cash flow: " +
                                  convertToMoney(
                                      Provider.of<AllWallets>(context),
                                      totalSpent) +
                                  "\n" +
                                  totalTransactions.toString() +
                                  " transactions",
                              fontSize: 13,
                              textAlign: TextAlign.center,
                              textColor: getColor(context, "textLight"),
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      },
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: widget.budget.sharedDateUpdated == null
                    ? SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, bottom: 0),
                        child: TextFont(
                          text: "Synced " +
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

class BudgetLineGraph extends StatefulWidget {
  const BudgetLineGraph({
    required this.budget,
    required this.dateForRange,
    required this.selectedCategoryPk,
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
  final int selectedCategoryPk;
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
            widget.budget.categoryFks ?? [],
            widget.budget.categoryFks == null ||
                    (widget.budget.categoryFks ?? []).length <= 0
                ? true
                : false,
            true,
            false,
            widget.budget.budgetTransactionFilters,
            widget.budget.memberTransactionFilters,
            onlyShowTransactionsBelongingToBudget:
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<List<Transaction>>>(
      stream: mergedStreamsPastSpendingTotals,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.length <= 0) return SizedBox.shrink();
          bool cumulative = appStateSettings["showCumulativeSpending"];
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
              // dayCount++;

              //can be optimized...
              double totalForDay = 0;
              for (Transaction transaction in snapshot.data![snapshotIndex]) {
                if (widget.selectedCategoryPk == -1 ||
                    -transaction.categoryFk ==
                        -widget.selectedCategoryPk) if (indexDay
                            .year ==
                        transaction.dateCreated.year &&
                    indexDay.month == transaction.dateCreated.month &&
                    indexDay.day == transaction.dateCreated.day) {
                  totalForDay += (transaction.amount *
                          (amountRatioToPrimaryCurrencyGivenPk(
                                  Provider.of<AllWallets>(context),
                                  transaction.walletFk) ??
                              0))
                      .abs();
                }
              }
              cumulativeTotal += totalForDay;
              points.add(Pair(points.length.toDouble(),
                  cumulative ? cumulativeTotal : totalForDay));
              if (totalForDay == 0) totalZeroes++;
            }
            pointsList.add(points);
          }
          Color lineColor =
              widget.selectedCategoryPk != -1 && widget.selectedCategory != null
                  ? HexColor(widget.selectedCategory!.colour)
                  : widget.budgetColorScheme.primary;
          if (widget.showIfNone == false && totalZeroes == pointsList[0].length)
            return SizedBox.shrink();
          return Padding(
            padding: widget.padding,
            child: LineChartWrapper(
              keepHorizontalLineInView:
                  widget.selectedCategory == null ? true : false,
              color: lineColor,
              verticalLineAt: widget.isPastBudget == true
                  ? null
                  : (widget.budgetRange.end
                          .difference((widget.dateForRange ?? DateTime.now()))
                          .inDays)
                      .toDouble(),
              endDate: widget.budgetRange.end,
              points: pointsList,
              isCurved: true,
              colors: [
                for (int index = 0; index < snapshot.data!.length; index++)
                  index == 0
                      ? lineColor
                      : (widget.selectedCategoryPk != -1 &&
                                  widget.selectedCategory != null
                              ? lineColor
                              : widget.budgetColorScheme.tertiary)
                          .withOpacity((index) / snapshot.data!.length)
              ],
              horizontalLineAt: widget.isPastBudget == true ||
                      (widget.budget.addedTransactionsOnly &&
                          widget.budget.endDate.millisecondsSinceEpoch <
                              DateTime.now().millisecondsSinceEpoch)
                  ? widget.budget.amount
                  : widget.budget.amount *
                      ((DateTime.now().millisecondsSinceEpoch -
                              widget.budgetRange.start.millisecondsSinceEpoch) /
                          (widget.budgetRange.end.millisecondsSinceEpoch -
                              widget.budgetRange.start.millisecondsSinceEpoch)),
            ),
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
    return GestureDetector(
      onTap: () {
        _swapTotalSpentDisplay();
      },
      onLongPress: () {
        HapticFeedback.heavyImpact();
        _swapTotalSpentDisplay();
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 200),
          child: widget.budget.amount - widget.totalSpent >= 0
              ? Row(
                  key: ValueKey(showTotalSpent),
                  mainAxisAlignment: enableDoubleColumn(context)
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          child: CountNumber(
                            count: showTotalSpent
                                ? widget.totalSpent
                                : widget.budget.amount - widget.totalSpent,
                            duration: Duration(milliseconds: 400),
                            dynamicDecimals: true,
                            initialCount: (0),
                            textBuilder: (number) {
                              return TextFont(
                                text: convertToMoney(
                                    Provider.of<AllWallets>(context), number,
                                    finalNumber: showTotalSpent
                                        ? widget.totalSpent
                                        : widget.budget.amount -
                                            widget.totalSpent),
                                fontSize: 25,
                                textAlign: TextAlign.left,
                                fontWeight: FontWeight.bold,
                                textColor: widget
                                    .budgetColorScheme.onSecondaryContainer,
                              );
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(bottom: 3.8),
                          child: TextFont(
                            text:
                                (showTotalSpent ? " spent of " : " left of ") +
                                    convertToMoney(
                                        Provider.of<AllWallets>(context),
                                        widget.budget.amount),
                            fontSize: 16,
                            textAlign: TextAlign.left,
                            textColor:
                                widget.budgetColorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: enableDoubleColumn(context)
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      child: CountNumber(
                        count: showTotalSpent
                            ? widget.totalSpent
                            : -1 * (widget.budget.amount - widget.totalSpent),
                        duration: Duration(milliseconds: 400),
                        dynamicDecimals: true,
                        initialCount: (0),
                        textBuilder: (number) {
                          return TextFont(
                            text: convertToMoney(
                                Provider.of<AllWallets>(context), number,
                                finalNumber: showTotalSpent
                                    ? widget.totalSpent
                                    : -1 *
                                        (widget.budget.amount -
                                            widget.totalSpent)),
                            fontSize: 25,
                            textAlign: TextAlign.left,
                            fontWeight: FontWeight.bold,
                            textColor:
                                widget.budgetColorScheme.onSecondaryContainer,
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(bottom: 3.8),
                      child: TextFont(
                        text:
                            (showTotalSpent ? " spent of " : " overspent of ") +
                                convertToMoney(Provider.of<AllWallets>(context),
                                    widget.budget.amount),
                        fontSize: 16,
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
