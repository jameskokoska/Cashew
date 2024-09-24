import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/budgetPage.dart';
import 'package:budget/pages/transactionFilters.dart';
import 'package:budget/struct/currencyFunctions.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/globalLoadingProgress.dart';
import 'package:budget/widgets/util/keepAliveClientMixin.dart';
import 'package:budget/widgets/lineGraph.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum LineGraphDisplay {
  Default30Days,
  CustomStartDate,
  Budget,
  AllTime,
}

class HomePageLineGraph extends StatelessWidget {
  const HomePageLineGraph({super.key, required this.selectedSlidingSelector});
  final int selectedSlidingSelector;
  @override
  Widget build(BuildContext context) {
    SearchFilters searchFilters = SearchFilters(
      expenseIncome:
          appStateSettings["homePageTransactionsListIncomeAndExpenseOnly"] ==
                  true
              ? [
                  if (selectedSlidingSelector == 2) ExpenseIncome.expense,
                  if (selectedSlidingSelector == 3) ExpenseIncome.income
                ]
              : [],
      positiveCashFlow:
          appStateSettings["homePageTransactionsListIncomeAndExpenseOnly"] ==
                  false
              ? selectedSlidingSelector == 2
                  ? false
                  : selectedSlidingSelector == 3
                      ? true
                      : null
              : null,
    );
    return KeepAliveClientMixin(
      child: Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 13),
        child: Container(
          margin: EdgeInsetsDirectional.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadiusDirectional.all(Radius.circular(15)),
            color: getColor(context, "lightDarkAccentHeavyLight"),
            boxShadow: boxShadowCheck(boxShadowGeneral(context)),
          ),
          child: appStateSettings["lineGraphDisplayType"] ==
                  LineGraphDisplay.Default30Days.index
              ? PastSpendingGraph(
                  isIncome: null,
                  searchFilters: searchFilters,
                )
              : appStateSettings["lineGraphDisplayType"] ==
                      LineGraphDisplay.AllTime.index
                  ? PastSpendingGraph(
                      isIncome: null,
                      searchFilters: searchFilters,
                      allTimeUpToFirstTransaction: true,
                    )
                  : appStateSettings["lineGraphDisplayType"] ==
                          LineGraphDisplay.CustomStartDate.index
                      ? PastSpendingGraph(
                          isIncome: null,
                          searchFilters: searchFilters,
                          customStartDate: DateTime.parse(
                              appStateSettings["lineGraphStartDate"]),
                        )
                      : StreamBuilder<Budget>(
                          stream: database.getBudget(
                              appStateSettings["lineGraphReferenceBudgetPk"]
                                  .toString()),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              Budget budget = snapshot.data!;
                              return BudgetLineGraph(
                                key: ValueKey(budget.budgetPk),
                                budget: budget,
                                dateForRange: DateTime.now(),
                                budgetRange:
                                    getBudgetDate(budget, DateTime.now()),
                                isPastBudget: false,
                                selectedCategory: null,
                                showPastSpending: false,
                              );
                            }
                            return SizedBox.shrink();
                          },
                        ),
        ),
      ),
    );
  }
}

class PastSpendingGraph extends StatelessWidget {
  const PastSpendingGraph({
    super.key,
    required this.isIncome,
    this.monthsToLoad = 1,
    this.customStartDate,
    this.customEndDate,
    this.walletPks,
    this.extraLeftPaddingIfSmall = 0,
    this.followCustomPeriodCycle = false,
    this.cycleSettingsExtension = "",
    this.searchFilters,
    this.forcedDateTimeRange,
    this.hideIfOnlyOneEntry = false,
    this.builder,
    this.allTimeUpToFirstTransaction = false,
  });
  final bool? isIncome;
  final int monthsToLoad;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final List<String>? walletPks;
  final double extraLeftPaddingIfSmall;
  final bool followCustomPeriodCycle;
  final String cycleSettingsExtension;
  final SearchFilters? searchFilters;
  final DateTimeRange? forcedDateTimeRange;
  final bool hideIfOnlyOneEntry;
  final Widget Function(Widget)? builder;
  final bool allTimeUpToFirstTransaction;

  Widget buildLineChart(BuildContext context,
      {DateTime? earliestTransactionDate, DateTime? latestTransactionDate}) {
    DateTime? customStartDateCheckedNull =
        earliestTransactionDate ?? customStartDate;
    if (customStartDate?.isAfter(DateTime.now()) ?? false) {
      customStartDateCheckedNull = DateTime.now();
    }
    DateTime customStartDateChecked = customStartDateCheckedNull ??
        DateTime.now().justDay(monthOffset: -monthsToLoad);

    DateTime customEndDateChecked =
        customEndDate ?? latestTransactionDate ?? DateTime.now();

    // Days limit no longer needed, it was incorporated into calculatePoints()
    // by using 'resolution'
    // int daysLimit = 365 * 250;
    // Duration difference =
    //     customStartDateChecked.difference(customEndDateChecked);
    // if (difference.inDays.abs() > daysLimit) {
    //   print("daysLimitReached!");
    //   customStartDateChecked =
    //       customEndDateChecked.subtract(Duration(days: daysLimit));
    // }

    return StreamBuilder<double?>(
      stream: database.getTotalBeforeStartDateInTimeRangeFromCategories(
        customStartDateChecked,
        [],
        true,
        true,
        isIncome,
        null,
        null,
        walletPks: walletPks,
        allWallets: Provider.of<AllWallets>(context),
        followCustomPeriodCycle: followCustomPeriodCycle,
        cycleSettingsExtension: cycleSettingsExtension,
        searchFilters: searchFilters,
        forcedDateTimeRange: forcedDateTimeRange,
      ),
      builder: (context, snapshotTotalSpentBefore) {
        if (snapshotTotalSpentBefore.hasData) {
          double totalSpentBefore = appStateSettings["ignorePastAmountSpent"]
              ? 0
              : snapshotTotalSpentBefore.data!;
          return StreamBuilder<List<Transaction>>(
            stream: database.getTransactionsInTimeRangeFromCategories(
              customStartDateChecked,
              customEndDateChecked,
              null,
              null,
              true,
              isIncome,
              null,
              null,
              walletPks: walletPks,
              followCustomPeriodCycle: followCustomPeriodCycle,
              cycleSettingsExtension: cycleSettingsExtension,
              searchFilters: searchFilters,
              forcedDateTimeRange: forcedDateTimeRange,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return FutureBuilder<List<Pair>>(
                  future: compute(
                    calculatePoints,
                    CalculatePointsParams(
                      transactions: snapshot.data ?? [],
                      customStartDate: customStartDateChecked,
                      customEndDate: customEndDateChecked,
                      totalSpentBefore: totalSpentBefore,
                      isIncome: isIncome,
                      allWallets:
                          Provider.of<AllWallets>(context, listen: false),
                      showCumulativeSpending:
                          appStateSettings["showCumulativeSpending"],
                      appStateSettingsPassed: appStateSettings,
                    ),
                  ),
                  builder: (context, snapshotPoints) {
                    Widget lineChartWidget;
                    if (snapshotPoints.hasData == false) {
                      lineChartWidget = IndeterminateProgressBar();
                    } else {
                      List<Pair> points = snapshotPoints.data ?? [];
                      if (points.length <= 1 && hideIfOnlyOneEntry == true) {
                        return SizedBox.shrink();
                      }
                      lineChartWidget = LineChartWrapper(
                        points: [points],
                        isCurved: true,
                        extraLeftPaddingIfSmall: extraLeftPaddingIfSmall,
                        amountBefore: totalSpentBefore,
                        endDate: customEndDateChecked,
                      );
                    }
                    if (builder != null) {
                      return builder!(lineChartWidget);
                    } else {
                      return lineChartWidget;
                    }
                  },
                );
              }
              return SizedBox.shrink();
            },
          );
        }
        return SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (allTimeUpToFirstTransaction) {
      return StreamBuilder<EarliestLatestDateTime?>(
        stream: database.watchEarliestLatestTransactionDateTime(
            searchFilters: searchFilters),
        builder: (context, snapshot) {
          if (snapshot.hasData == false) return SizedBox.shrink();
          return buildLineChart(
            context,
            earliestTransactionDate: snapshot.data?.earliest,
            latestTransactionDate: snapshot.data?.latest,
          );
        },
      );
    }
    return buildLineChart(context);
  }
}

class CalculatePointsParams {
  final List<Transaction> transactions;
  final DateTime customStartDate;
  final DateTime customEndDate;
  final double totalSpentBefore;
  final bool? isIncome;
  final bool? removeBalanceCorrection;
  final AllWallets allWallets;
  final bool showCumulativeSpending;
  final Map<String, dynamic> appStateSettingsPassed;
  final bool invertPolarity;
  final bool cycleThroughAllDays;
  final bool isPaidOnly;

  CalculatePointsParams({
    required this.transactions,
    required this.customStartDate,
    required this.customEndDate,
    required this.totalSpentBefore,
    required this.isIncome,
    this.removeBalanceCorrection = null,
    required this.allWallets,
    required this.showCumulativeSpending,
    required this.appStateSettingsPassed,
    this.invertPolarity = false,
    this.cycleThroughAllDays = false,
    this.isPaidOnly = false,
  });
}

List<Pair> calculatePoints(CalculatePointsParams p) {
  double cumulativeTotal = p.totalSpentBefore;
  List<Pair> points = [];
  Map<DateTime, double> dailyTotals = {};
  double transactionsBeforeStartDateTotal = 0;
  int invertPolarity = p.invertPolarity ? -1 : 1;

  for (Transaction transaction in p.transactions) {
    // Remove balance correction transactions if not showing all transactions
    if (p.isIncome != null && transaction.categoryFk == "0") continue;

    if (p.removeBalanceCorrection == true && transaction.categoryFk == "0")
      continue;

    if (p.isPaidOnly && transaction.paid == false) continue;

    DateTime day = transaction.dateCreated.justDay();
    double amount = transaction.amount *
        amountRatioToPrimaryCurrencyGivenPk(
          p.allWallets,
          transaction.walletFk,
          appStateSettingsPassed: p.appStateSettingsPassed,
        ) *
        invertPolarity;

    if (p.customStartDate.millisecondsSinceEpoch >
        transaction.dateCreated.millisecondsSinceEpoch) {
      transactionsBeforeStartDateTotal += (transaction.amount *
              (amountRatioToPrimaryCurrencyGivenPk(
                p.allWallets,
                transaction.walletFk,
                appStateSettingsPassed: p.appStateSettingsPassed,
              ))) *
          invertPolarity;
    }

    dailyTotals[day] = (dailyTotals[day] ?? 0) + amount;
  }

  cumulativeTotal += transactionsBeforeStartDateTotal;

  if (p.cycleThroughAllDays) {
    int index = -1;
    for (DateTime indexDay = p.customStartDate;
        indexDay.compareTo(p.customEndDate) <= 0;
        indexDay = indexDay.justDay(dayOffset: 1)) {
      index++;
      if (indexDay == p.customStartDate) {
        indexDay = p.customStartDate.justDay();
      }

      double totalForDay = dailyTotals[indexDay] ?? 0;
      cumulativeTotal += totalForDay;
      points.add(
        Pair(
          index.toDouble(),
          p.showCumulativeSpending ? cumulativeTotal : totalForDay,
          dateTime: indexDay,
        ),
      );
    }
  } else {
    // Higher number is more resolution!
    // Means for every resolutionThreshold point, it will skip one
    double resolutionThreshold = 500;
    double resolution =
        (dailyTotals.length / resolutionThreshold).round().toDouble();
    if (resolution <= 1) resolution = 1;

    DateTime customStartDateStatic = p.customStartDate.justDay();

    DateTime customEndDateStatic = p.customEndDate.justDay();

    final List<DateTime> filteredDates = dailyTotals.keys
        .where((date) =>
            !date.isBefore(customStartDateStatic) &&
            !date.isAfter(customEndDateStatic))
        .toList();

    if (!filteredDates.contains(customStartDateStatic))
      filteredDates.add(customStartDateStatic);

    if (!filteredDates.contains(customEndDateStatic))
      filteredDates.insert(0, customEndDateStatic);

    // We assume the transactions are passed in in order!

    for (int i = filteredDates.length - 1; i >= 0; i--) {
      DateTime indexDay = filteredDates[i];
      int index = indexDay.difference(customStartDateStatic).inDays;
      double totalForDay = dailyTotals[indexDay] ?? 0;
      cumulativeTotal += totalForDay;
      if (indexDay != customStartDateStatic &&
          indexDay != customEndDateStatic &&
          index % resolution >= 1) continue;
      points.add(
        Pair(
          index.toDouble(),
          p.showCumulativeSpending ? cumulativeTotal : totalForDay,
          dateTime: indexDay,
        ),
      );
    }
  }

  return points;
}
