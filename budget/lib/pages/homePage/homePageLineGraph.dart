import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/budgetPage.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/pages/transactionFilters.dart';
import 'package:budget/struct/currencyFunctions.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/globalLoadingProgress.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/util/keepAliveClientMixin.dart';
import 'package:budget/widgets/lineGraph.dart';
import 'package:budget/widgets/navigationSidebar.dart';
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
        padding: const EdgeInsets.only(bottom: 13),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
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
        DateTime(
          DateTime.now().year,
          DateTime.now().month - monthsToLoad,
          DateTime.now().day,
        );

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
  final AllWallets allWallets;
  final bool showCumulativeSpending;
  final Map<String, dynamic> appStateSettingsPassed;
  final bool invertPolarity;

  CalculatePointsParams({
    required this.transactions,
    required this.customStartDate,
    required this.customEndDate,
    required this.totalSpentBefore,
    required this.isIncome,
    required this.allWallets,
    required this.showCumulativeSpending,
    required this.appStateSettingsPassed,
    this.invertPolarity = false,
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
    if (p.isIncome != null && transaction.categoryFk == "0") {
      continue;
    }

    DateTime day = DateTime(transaction.dateCreated.year,
        transaction.dateCreated.month, transaction.dateCreated.day);
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

  // Higher number is more resolution!
  // Means for every resolutionThreshold point, it will skip one
  double resolutionThreshold = 500;
  double resolution =
      (dailyTotals.length / resolutionThreshold).round().toDouble();
  if (resolution <= 1) resolution = 1;

  //print("Input length: " + dailyTotals.length.toString());

  int index = -1;

  for (DateTime indexDay = p.customStartDate;
      indexDay.compareTo(p.customEndDate) <= 0;
      indexDay = DateTime(indexDay.year, indexDay.month, indexDay.day + 1)) {
    index++;
    if (indexDay == p.customStartDate) {
      indexDay = DateTime(p.customStartDate.year, p.customStartDate.month,
          p.customStartDate.day);
    }

    double totalForDay = dailyTotals[indexDay] ?? 0;
    cumulativeTotal += totalForDay;
    if (indexDay !=
            DateTime(p.customStartDate.year, p.customStartDate.month,
                p.customStartDate.day) &&
        indexDay !=
            DateTime(p.customEndDate.year, p.customEndDate.month,
                p.customEndDate.day) &&
        index % resolution >= 1) continue;
    points.add(
      Pair(
        index.toDouble(),
        p.showCumulativeSpending ? cumulativeTotal : totalForDay,
        dateTime: indexDay,
      ),
    );
  }

  //print("Output length: " + points.length.toString());

  return points;
}
