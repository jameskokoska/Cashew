import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/budgetPage.dart';
import 'package:budget/pages/transactionsListPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/animatedCircularProgress.dart';
import 'package:budget/widgets/barGraph.dart';
import 'package:budget/widgets/budgetContainer.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/categoryEntry.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/lineGraph.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/pieChart.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:flutter/scheduler.dart';
import 'dart:developer';
import 'package:async/async.dart' show StreamZip;
import 'package:googleapis/admob/v1.dart';

class PastBudgetsPage extends StatelessWidget {
  const PastBudgetsPage({super.key, required int this.budgetPk});
  final int budgetPk;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Budget>(
        stream: database.getBudget(budgetPk),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _PastBudgetsPageContent(budget: snapshot.data!);
          }
          return SizedBox.shrink();
        });
    ;
  }
}

class _PastBudgetsPageContent extends StatefulWidget {
  const _PastBudgetsPageContent({Key? key, required Budget this.budget})
      : super(key: key);

  final Budget budget;

  @override
  State<_PastBudgetsPageContent> createState() =>
      __PastBudgetsPageContentState();
}

GlobalKey<PageFrameworkState> budgetHistoryKey = GlobalKey();

class __PastBudgetsPageContentState extends State<_PastBudgetsPageContent> {
  late Stream<List<double?>> mergedStreams;
  List<DateTimeRange> dateTimeRanges = [];
  int amountLoaded = 3;

  initState() {
    List<Stream<double?>> watchedBudgetTotals = [];
    for (int index = 0; index <= 7; index++) {
      DateTime datePast = DateTime(
        DateTime.now().year -
            (widget.budget.reoccurrence == BudgetReoccurence.yearly
                ? index * widget.budget.periodLength
                : 0),
        DateTime.now().month -
            (widget.budget.reoccurrence == BudgetReoccurence.monthly
                ? index * widget.budget.periodLength
                : 0),
        DateTime.now().day -
            (widget.budget.reoccurrence == BudgetReoccurence.daily
                ? index * widget.budget.periodLength
                : 0) -
            (widget.budget.reoccurrence == BudgetReoccurence.weekly
                ? index * 7 * widget.budget.periodLength
                : 0),
      );
      DateTimeRange budgetRange = getBudgetDate(widget.budget, datePast);
      dateTimeRanges.add(budgetRange);
      watchedBudgetTotals.add(database.watchTotalSpentInTimeRangeFromCategories(
        budgetRange.start,
        budgetRange.end,
        widget.budget.categoryFks,
        widget.budget.allCategoryFks,
        onlyShowTransactionsBelongingToBudget:
            widget.budget.sharedKey == null ? null : widget.budget.budgetPk,
      ));
    }
    mergedStreams = StreamZip(watchedBudgetTotals);
    // mergedStreams.listen(
    //   (event) {
    //     print("EVENT");
    //     print(event.length);
    //   },
    // );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTimeRange budgetRange = getBudgetDate(widget.budget, DateTime.now());
    ColorScheme budgetColorScheme = ColorScheme.fromSeed(
      seedColor: HexColor(widget.budget.colour,
          defaultColor: Theme.of(context).colorScheme.primary),
      brightness: determineBrightnessTheme(context),
    );

    return PageFramework(
      key: budgetHistoryKey,
      title: "Budget History",
      subtitle: Padding(
        padding: const EdgeInsets.only(left: 20, bottom: 6),
        child: TextFont(
          text: widget.budget.name,
          fontSize: 20,
          maxLines: 5,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitleSize: 10,
      subtitleAnimationSpeed: 9.8,
      subtitleAlignment: Alignment.bottomLeft,
      appBarBackgroundColor: budgetColorScheme.secondaryContainer,
      textColor: Theme.of(context).colorScheme.black,
      navbar: false,
      dragDownToDismiss: true,
      dragDownToDissmissBackground: Theme.of(context).colorScheme.background,
      slivers: [
        StreamBuilder<List<double?>>(
          stream: mergedStreams,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              double maxY = 100;
              List<BarChartGroupData> bars = [];
              List<BarChartGroupData> initialBars = [];

              for (int i = snapshot.data!.length - 1; i >= 0; i--) {
                if ((snapshot.data![i] ?? 0).abs() > maxY)
                  maxY = (snapshot.data![i] ?? 0).abs();
                bars.add(
                  makeGroupData(
                    i,
                    (snapshot.data![i] ?? 0).abs() == 0
                        ? 0.001
                        : (snapshot.data![i] ?? 0).abs(),
                    50, //In the future put income here
                    budgetColorScheme.primary,
                  ),
                );
                initialBars.add(
                  makeGroupData(
                    i,
                    0.001,
                    0,
                    budgetColorScheme.secondary,
                  ),
                );
              }

              return SliverToBoxAdapter(
                child: BarGraph(
                  color: budgetColorScheme.secondary,
                  dateRanges: dateTimeRanges,
                  maxY: maxY,
                  bars: bars,
                  horizontalLineAt: widget.budget.amount,
                  initialBars: initialBars,
                  budget: widget.budget,
                ),
              );
            } else {
              return SliverToBoxAdapter();
            }
          },
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 13),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                DateTime datePast = DateTime(
                  DateTime.now().year -
                      (widget.budget.reoccurrence == BudgetReoccurence.yearly
                          ? index * widget.budget.periodLength
                          : 0),
                  DateTime.now().month -
                      (widget.budget.reoccurrence == BudgetReoccurence.monthly
                          ? index * widget.budget.periodLength
                          : 0),
                  DateTime.now().day -
                      (widget.budget.reoccurrence == BudgetReoccurence.daily
                          ? index * widget.budget.periodLength
                          : 0) -
                      (widget.budget.reoccurrence == BudgetReoccurence.weekly
                          ? index * 7 * widget.budget.periodLength
                          : 0),
                );
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: index == amountLoaded - 1 ? 0 : 13.0),
                  child: PastBudgetContainer(
                    budget: widget.budget,
                    smallBudgetContainer: true,
                    showTodayForSmallBudget: (index == 0 ? true : false),
                    dateForRange: datePast,
                    isPastBudget: index == 0 ? false : true,
                    isPastBudgetButCurrentPeriod: index == 0,
                    budgetColorScheme: budgetColorScheme,
                  ),
                );
              },
              childCount: amountLoaded, //snapshot.data?.length
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Tappable(
                color: Theme.of(context).colorScheme.lightDarkAccent,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: TextFont(
                    text: "View More",
                    textAlign: TextAlign.center,
                    fontSize: 16,
                    textColor: Theme.of(context).colorScheme.textLight,
                  ),
                ),
                onTap: () {
                  setState(() {
                    amountLoaded += 3;
                  });
                  Future.delayed(Duration(milliseconds: 150), () {
                    budgetHistoryKey.currentState!
                        .scrollToBottom(duration: 4000);
                  });
                },
                borderRadius: 10,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 10)),
      ],
    );
  }
}

class PastBudgetContainer extends StatelessWidget {
  PastBudgetContainer({
    Key? key,
    required this.budget,
    this.smallBudgetContainer = false,
    this.showTodayForSmallBudget = true,
    this.dateForRange,
    this.isPastBudget = false,
    this.isPastBudgetButCurrentPeriod = false,
    required this.budgetColorScheme,
  }) : super(key: key);

  final Budget budget;
  final bool smallBudgetContainer;
  final bool showTodayForSmallBudget;
  final DateTime? dateForRange;
  final bool? isPastBudget;
  final bool? isPastBudgetButCurrentPeriod;
  final ColorScheme budgetColorScheme;

  @override
  Widget build(BuildContext context) {
    DateTime dateForRangeLocal =
        dateForRange == null ? DateTime.now() : dateForRange!;
    DateTimeRange budgetRange = getBudgetDate(budget, dateForRangeLocal);
    var widget = StreamBuilder<double?>(
        stream: database.watchTotalSpentByCurrentUserOnly(
          budgetRange.start,
          budgetRange.end,
          budget.budgetPk,
        ),
        builder: (context, snapshotTotalSpentByCurrentUserOnly) {
          double smallContainerHeight = 100;
          return StreamBuilder<List<CategoryWithTotal>>(
            stream:
                database.watchTotalSpentInEachCategoryInTimeRangeFromCategories(
              budgetRange.start,
              budgetRange.end,
              budget.categoryFks ?? [],
              budget.allCategoryFks,
              budget.sharedTransactionsShow,
              onlyShowTransactionsBelongingToBudget:
                  budget.sharedKey != null ? budget.budgetPk : null,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                double totalSpent = 0;
                snapshot.data!.forEach((category) {
                  totalSpent = totalSpent + category.total.abs();
                  totalSpent = totalSpent.abs();
                });
                return Container(
                  height: smallContainerHeight,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                TextFont(
                                  text:
                                      getWordedDateShortMore(budgetRange.start),
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 2,
                                    left: 5,
                                  ),
                                  child: TextFont(
                                    text: budgetRange.start.year !=
                                            DateTime.now().year
                                        ? budgetRange.start.year.toString()
                                        : "",
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2),
                            budget.amount - totalSpent >= 0
                                ? Row(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            child: CountUp(
                                              count: appStateSettings[
                                                      "showTotalSpentForBudget"]
                                                  ? totalSpent
                                                  : budget.amount - totalSpent,
                                              prefix: getCurrencyString(),
                                              duration:
                                                  Duration(milliseconds: 700),
                                              fontSize: 18,
                                              textAlign: TextAlign.left,
                                              fontWeight: FontWeight.bold,
                                              decimals:
                                                  moneyDecimals(budget.amount),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 1.7),
                                            child: Container(
                                              child: TextFont(
                                                text: (appStateSettings[
                                                            "showTotalSpentForBudget"]
                                                        ? " spent of "
                                                        : " left of ") +
                                                    convertToMoney(
                                                        budget.amount),
                                                fontSize: 14,
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        child: CountUp(
                                          count: appStateSettings[
                                                  "showTotalSpentForBudget"]
                                              ? totalSpent
                                              : -1 *
                                                  (budget.amount - totalSpent),
                                          prefix: getCurrencyString(),
                                          duration:
                                              Duration(milliseconds: 1000),
                                          fontSize: 18,
                                          textAlign: TextAlign.left,
                                          fontWeight: FontWeight.bold,
                                          decimals:
                                              moneyDecimals(budget.amount),
                                        ),
                                      ),
                                      Container(
                                        padding:
                                            const EdgeInsets.only(bottom: 1.5),
                                        child: TextFont(
                                          text: (appStateSettings[
                                                      "showTotalSpentForBudget"]
                                                  ? " spent of "
                                                  : " overspent of ") +
                                              convertToMoney(budget.amount),
                                          fontSize: 13,
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(5 / 2),
                            child: Container(
                              width: 50,
                              child: CountNumber(
                                count: budget.amount == 0
                                    ? 0
                                    : (totalSpent / budget.amount * 100),
                                duration: Duration(milliseconds: 1000),
                                dynamicDecimals: false,
                                initialCount: (0),
                                textBuilder: (value) {
                                  return TextFont(
                                    autoSizeText: true,
                                    text: value.toStringAsFixed(0) + "%",
                                    fontSize: 18,
                                    textAlign: TextAlign.center,
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                    maxLines: 1,
                                  );
                                },
                              ),
                            ),
                          ),
                          Container(
                            height: 70,
                            width: 70,
                            child: AnimatedCircularProgress(
                              percent: (totalSpent / budget.amount).abs(),
                              backgroundColor:
                                  budgetColorScheme.secondaryContainer,
                              foregroundColor: budgetColorScheme.primary,
                              overageColor: budgetColorScheme.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              } else {
                return Container(
                    height: smallContainerHeight, width: double.infinity);
              }
            },
          );
        });
    return Container(
      decoration: BoxDecoration(
        boxShadow: boxShadowCheck(boxShadowGeneral(context)),
      ),
      child: OpenContainerNavigation(
        borderRadius: 20,
        closedColor: Theme.of(context).colorScheme.lightDarkAccentHeavyLight,
        button: (openContainer) {
          return Tappable(
            onTap: () {
              openContainer();
            },
            onLongPress: () {
              pushRoute(
                context,
                AddBudgetPage(
                  title: "Edit Budget",
                  budget: budget,
                ),
              );
            },
            borderRadius: 20,
            child: widget,
            color: Theme.of(context).colorScheme.lightDarkAccentHeavyLight,
          );
        },
        openPage: BudgetPage(
          budgetPk: budget.budgetPk,
          dateForRange: dateForRangeLocal,
          isPastBudget: isPastBudget,
          isPastBudgetButCurrentPeriod: isPastBudgetButCurrentPeriod,
        ),
      ),
    );
  }
}
