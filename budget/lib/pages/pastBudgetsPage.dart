import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/transactionsListPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/barGraph.dart';
import 'package:budget/widgets/budgetContainer.dart';
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

class PastBudgetsPage extends StatefulWidget {
  const PastBudgetsPage({Key? key, required Budget this.budget})
      : super(key: key);

  final Budget budget;

  @override
  State<PastBudgetsPage> createState() => _PastBudgetsPageState();
}

GlobalKey<PageFrameworkState> budgetHistoryKey = GlobalKey();

class _PastBudgetsPageState extends State<PastBudgetsPage> {
  int amountLoaded = 3;

  @override
  Widget build(BuildContext context) {
    DateTimeRange budgetRange = getBudgetDate(widget.budget, DateTime.now());
    ColorScheme budgetColorScheme = ColorScheme.fromSeed(
      seedColor: HexColor(widget.budget.colour,
          defaultColor: Theme.of(context).colorScheme.primary),
      brightness: getSettingConstants(appStateSettings)["theme"] ==
              ThemeMode.system
          ? MediaQuery.of(context).platformBrightness
          : getSettingConstants(appStateSettings)["theme"] == ThemeMode.light
              ? Brightness.light
              : getSettingConstants(appStateSettings)["theme"] == ThemeMode.dark
                  ? Brightness.dark
                  : Brightness.light,
    );

    List<DateTimeRange> dateTimeRanges = [];
    List<Stream<double?>> watchedBudgetTotals = [];
    for (int index = 0; index <= 7; index++) {
      DateTime datePast = DateTime(
        DateTime.now().year -
            (widget.budget.reoccurrence == BudgetReoccurence.yearly
                ? index
                : 0),
        DateTime.now().month -
            (widget.budget.reoccurrence == BudgetReoccurence.monthly
                ? index
                : 0),
        DateTime.now().day -
            (widget.budget.reoccurrence == BudgetReoccurence.daily
                ? index
                : 0) -
            (widget.budget.reoccurrence == BudgetReoccurence.weekly
                ? index * 7
                : 0),
      );
      DateTimeRange budgetRange = getBudgetDate(widget.budget, datePast);
      dateTimeRanges.add(budgetRange);
      watchedBudgetTotals.add(database.watchTotalSpentInTimeRangeFromCategories(
          budgetRange.start,
          budgetRange.end,
          widget.budget.categoryFks,
          widget.budget.allCategoryFks));
    }
    Stream<List<double?>> mergedStreams = StreamZip(watchedBudgetTotals);

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
      dragDownToDissmissBackground: Theme.of(context).canvasColor,
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
                    HexColor(widget.budget.colour),
                  ),
                );
                initialBars.add(
                  makeGroupData(
                    i,
                    0.001,
                    0,
                    HexColor(widget.budget.colour),
                  ),
                );
              }

              return SliverToBoxAdapter(
                child: BarGraph(
                  color: HexColor(widget.budget.colour),
                  dateRanges: dateTimeRanges,
                  maxY: maxY,
                  bars: bars,
                  initialBars: initialBars,
                  horizontalLineAt: widget.budget.amount,
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
                          ? index
                          : 0),
                  DateTime.now().month -
                      (widget.budget.reoccurrence == BudgetReoccurence.monthly
                          ? index
                          : 0),
                  DateTime.now().day -
                      (widget.budget.reoccurrence == BudgetReoccurence.daily
                          ? index
                          : 0) -
                      (widget.budget.reoccurrence == BudgetReoccurence.weekly
                          ? index * 7
                          : 0),
                );
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: index == amountLoaded - 1 ? 0 : 16.0),
                  child: BudgetContainer(
                    budget: widget.budget,
                    smallBudgetContainer: true,
                    showTodayForSmallBudget: (index == 0 ? true : false),
                    dateForRange: datePast,
                    isPastBudget: index == 0 ? false : true,
                    isPastBudgetButCurrentPeriod: index == 0,
                  ),
                );
              },
              childCount: amountLoaded, //snapshot.data?.length
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Center(
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
                  budgetHistoryKey.currentState!.scrollToBottom(duration: 4000);
                });
              },
              borderRadius: 10,
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 10)),
      ],
    );
  }
}
