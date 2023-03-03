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
import 'package:budget/widgets/openBottomSheet.dart';
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
import 'package:async/async.dart' show StreamZip;

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
              WatchAllWallets(
                noDataWidget: SliverToBoxAdapter(child: SizedBox.shrink()),
                childFunction: (wallets) => StreamBuilder<double?>(
                  stream: database.watchTotalSpentByCurrentUserOnly(
                    budgetRange.start,
                    budgetRange.end,
                    widget.budget.budgetPk,
                    wallets,
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
                        wallets,
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
                          if (snapshot.data!.length <= 0)
                            return SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: NoResults(
                                  tintColor: budgetColorScheme.primary,
                                  message:
                                      "There are no transactions for this budget within the current dates.",
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
                              StreamBuilder<CategoryBudgetLimit>(
                                stream: database.watchCategoryLimit(
                                    widget.budget.budgetPk,
                                    category.category.categoryPk),
                                builder: (context, snapshot) {
                                  return CategoryEntry(
                                    categoryBudgetLimit: snapshot.data,
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
                                  );
                                },
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
                                        top: 15,
                                        bottom: 22,
                                        left: 22,
                                        right: 22),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.vertical(
                                          bottom: Radius.circular(10)),
                                      color:
                                          budgetColorScheme.secondaryContainer,
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
                                                        child: CountNumber(
                                                          count: appStateSettings[
                                                                  "showTotalSpentForBudget"]
                                                              ? totalSpent
                                                              : widget.budget
                                                                      .amount -
                                                                  totalSpent,
                                                          duration: Duration(
                                                              milliseconds:
                                                                  700),
                                                          dynamicDecimals: true,
                                                          initialCount: (0),
                                                          textBuilder:
                                                              (number) {
                                                            return TextFont(
                                                              text:
                                                                  convertToMoney(
                                                                      number),
                                                              fontSize: 25,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              textColor:
                                                                  budgetColorScheme
                                                                      .onSecondaryContainer,
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
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
                                                          textColor:
                                                              budgetColorScheme
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
                                                    child: CountNumber(
                                                      count: appStateSettings[
                                                              "showTotalSpentForBudget"]
                                                          ? totalSpent
                                                          : -1 *
                                                              (widget.budget
                                                                      .amount -
                                                                  totalSpent),
                                                      duration: Duration(
                                                          milliseconds: 700),
                                                      dynamicDecimals: true,
                                                      initialCount: (0),
                                                      textBuilder: (number) {
                                                        return TextFont(
                                                          text: convertToMoney(
                                                              number),
                                                          fontSize: 25,
                                                          textAlign:
                                                              TextAlign.left,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          textColor:
                                                              budgetColorScheme
                                                                  .onSecondaryContainer,
                                                        );
                                                      },
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
                                        widget.isPastBudget == true
                                            ? SizedBox.shrink()
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 18, bottom: 0),
                                                child: DaySpending(
                                                  budget: widget.budget,
                                                  amount:
                                                      (widget.budget.amount -
                                                              totalSpent) /
                                                          daysBetween(
                                                              dateForRange,
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
                                  wallets: wallets,
                                ),
                              ),
                              SizedBox(height: 20),
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
                              SizedBox(height: 35),
                              ...categoryEntries,
                              SizedBox(height: 15),
                            ]),
                          );
                        }
                        return SliverToBoxAdapter(child: Container());
                      },
                    );
                  },
                ),
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 13),
                  child: Container(
                    padding: EdgeInsets.only(left: 10, right: 5),
                    child: BudgetLineGraph(
                      budget: widget.budget,
                      dateForRange: dateForRange,
                      selectedCategoryPk: selectedCategoryPk,
                      isPastBudget: widget.isPastBudget,
                      selectedCategory: selectedCategory,
                      budgetRange: budgetRange,
                      budgetColorScheme: budgetColorScheme,
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
                sharedTransactionsShow: widget.budget.sharedTransactionsShow,
                member: selectedMember,
                onlyShowTransactionsBelongingToBudget:
                    widget.budget.sharedKey != null ||
                            widget.budget.addedTransactionsOnly == true
                        ? widget.budget.budgetPk
                        : null,
                budget: widget.budget,
              ),
              SliverToBoxAdapter(
                child: WatchAllWallets(
                  noDataWidget: SliverToBoxAdapter(child: SizedBox.shrink()),
                  childFunction: (wallets) => StreamBuilder<double?>(
                    stream: database.watchTotalSpentByCurrentUserOnly(
                      budgetRange.start,
                      budgetRange.end,
                      widget.budget.budgetPk,
                      wallets,
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
                          wallets,
                          member: selectedMember,
                          onlyShowTransactionsBelongingToBudget:
                              widget.budget.sharedKey != null ||
                                      widget.budget.addedTransactionsOnly ==
                                          true
                                  ? widget.budget.budgetPk
                                  : null,
                          budget: widget.budget,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            double totalSpent = 0;
                            snapshot.data!.forEach((category) {
                              totalSpent = totalSpent + category.total.abs();
                              totalSpent = totalSpent.abs();
                            });
                            return Padding(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                                top: 10,
                                bottom: 8,
                              ),
                              child: TextFont(
                                text: "Total cash flow: " +
                                    convertToMoney(totalSpent),
                                fontSize: 13,
                                textAlign: TextAlign.center,
                                textColor:
                                    Theme.of(context).colorScheme.textLight,
                              ),
                            );
                          }
                          return SizedBox.shrink();
                        },
                      );
                    },
                  ),
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

class WatchAllWallets extends StatelessWidget {
  const WatchAllWallets(
      {required Widget Function(List<TransactionWallet>) this.childFunction,
      Widget this.noDataWidget = const SizedBox.shrink(),
      super.key});

  final Widget Function(List<TransactionWallet>) childFunction;
  final Widget noDataWidget;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TransactionWallet>>(
      stream: database.watchAllWallets(),
      builder: (context, snapshotWallets) {
        if (snapshotWallets.hasData)
          return childFunction(snapshotWallets.data!);
        else
          return childFunction([]);
        // return noDataWidget;
      },
    );
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
            widget.budget.sharedTransactionsShow,
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
                                  transaction.walletFk) ??
                              0))
                      .abs();
                }
              }
              cumulativeTotal += totalForDay;
              points.add(Pair(points.length.toDouble(),
                  cumulative ? cumulativeTotal : totalForDay));
            }
            pointsList.add(points);
          }
          Color lineColor =
              widget.selectedCategoryPk != -1 && widget.selectedCategory != null
                  ? HexColor(widget.selectedCategory!.colour)
                  : widget.budgetColorScheme.primary;
          return LineChartWrapper(
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
            horizontalLineAt: widget.budget.amount *
                ((DateTime.now().millisecondsSinceEpoch -
                        widget.budgetRange.start.millisecondsSinceEpoch) /
                    (widget.budgetRange.end.millisecondsSinceEpoch -
                        widget.budgetRange.start.millisecondsSinceEpoch)),
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
