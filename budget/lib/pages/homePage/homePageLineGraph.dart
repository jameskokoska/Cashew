import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/budgetPage.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/struct/currencyFunctions.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/keepAliveClientMixin.dart';
import 'package:budget/widgets/lineGraph.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum LineGraphDisplay {
  Default30Days,
  CustomStartDate,
  Budget,
}

class HomePageLineGraph extends StatelessWidget {
  const HomePageLineGraph({super.key, required this.selectedSlidingSelector});
  final int selectedSlidingSelector;
  @override
  Widget build(BuildContext context) {
    if (isHomeScreenSectionEnabled(context, "showSpendingGraph") == false)
      return SizedBox.shrink();
    return KeepAliveClientMixin(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 13),
        child: Container(
          padding: EdgeInsets.only(left: 5, right: 7, bottom: 12, top: 18),
          margin: EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            color: getColor(context, "lightDarkAccentHeavyLight"),
            boxShadow: boxShadowCheck(boxShadowGeneral(context)),
          ),
          child: appStateSettings["lineGraphDisplayType"] ==
                  LineGraphDisplay.Default30Days.index
              ? PastSpendingGraph(
                  isIncome: selectedSlidingSelector == 2
                      ? false
                      : selectedSlidingSelector == 3
                          ? true
                          : null,
                )
              : appStateSettings["lineGraphDisplayType"] ==
                      LineGraphDisplay.CustomStartDate.index
                  ? PastSpendingGraph(
                      isIncome: selectedSlidingSelector == 2
                          ? false
                          : selectedSlidingSelector == 3
                              ? true
                              : null,
                      customStartDate: DateTime.parse(
                          appStateSettings["lineGraphStartDate"]),
                    )
                  : StreamBuilder<Budget>(
                      stream: database.getBudget(
                          appStateSettings["lineGraphReferenceBudgetPk"]
                              .toString()),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          Budget budget = snapshot.data!;
                          ColorScheme budgetColorScheme = ColorScheme.fromSeed(
                            seedColor: HexColor(budget.colour,
                                defaultColor:
                                    Theme.of(context).colorScheme.primary),
                            brightness: determineBrightnessTheme(context),
                          );
                          return Column(
                            children: [
                              BudgetLineGraph(
                                key: ValueKey(budget.budgetPk),
                                budget: budget,
                                budgetColorScheme: budgetColorScheme,
                                dateForRange: DateTime.now(),
                                budgetRange:
                                    getBudgetDate(budget, DateTime.now()),
                                isPastBudget: false,
                                selectedCategory: null,
                                showPastSpending: false,
                              ),
                            ],
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
    this.walletPks,
    this.extraLeftPaddingIfSmall = 0,
    this.followCustomPeriodCycle = false,
  });
  final bool? isIncome;
  final int monthsToLoad;
  final DateTime? customStartDate;
  final List<String>? walletPks;
  final double extraLeftPaddingIfSmall;
  final bool followCustomPeriodCycle;

  @override
  Widget build(BuildContext context) {
    DateTime? customStartDateChecked = customStartDate;
    if (customStartDate?.isAfter(DateTime.now()) ?? false) {
      customStartDateChecked = DateTime.now();
    }
    return StreamBuilder<double?>(
      stream: database.getTotalBeforeStartDateInTimeRangeFromCategories(
        customStartDateChecked ??
            DateTime(
              DateTime.now().year,
              DateTime.now().month - monthsToLoad,
              DateTime.now().day,
            ),
        [],
        true,
        true,
        isIncome,
        null,
        null,
        walletPks: walletPks,
        allWallets: Provider.of<AllWallets>(context),
        followCustomPeriodCycle: followCustomPeriodCycle,
      ),
      builder: (context, snapshotTotalSpentBefore) {
        if (snapshotTotalSpentBefore.hasData) {
          double totalSpentBefore = appStateSettings["ignorePastAmountSpent"]
              ? 0
              : snapshotTotalSpentBefore.data!;
          return StreamBuilder<List<Transaction>>(
            stream: database.getTransactionsInTimeRangeFromCategories(
              customStartDateChecked ??
                  DateTime(
                    DateTime.now().year,
                    DateTime.now().month - monthsToLoad,
                    DateTime.now().day,
                  ),
              DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
              ),
              null,
              null,
              true,
              isIncome,
              null,
              null,
              walletPks: walletPks,
              followCustomPeriodCycle: followCustomPeriodCycle,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                bool cumulative = appStateSettings["showCumulativeSpending"];
                double cumulativeTotal = totalSpentBefore;
                List<Pair> points = [];
                for (DateTime indexDay = customStartDateChecked ??
                        DateTime(
                          DateTime.now().year,
                          DateTime.now().month - monthsToLoad,
                          DateTime.now().day,
                        );
                    indexDay.compareTo(DateTime.now()) < 0;
                    indexDay = DateTime(
                        indexDay.year, indexDay.month, indexDay.day + 1)) {
                  //can be optimized...
                  double totalForDay = 0;
                  for (Transaction transaction in snapshot.data!) {
                    if (indexDay.year == transaction.dateCreated.year &&
                        indexDay.month == transaction.dateCreated.month &&
                        indexDay.day == transaction.dateCreated.day) {
                      if (transaction.income) {
                        totalForDay += transaction.amount.abs() *
                            (amountRatioToPrimaryCurrencyGivenPk(
                                    Provider.of<AllWallets>(context),
                                    transaction.walletFk) ??
                                0);
                      } else {
                        totalForDay -= transaction.amount.abs() *
                            (amountRatioToPrimaryCurrencyGivenPk(
                                    Provider.of<AllWallets>(context),
                                    transaction.walletFk) ??
                                0);
                      }
                    }
                  }
                  cumulativeTotal += totalForDay;
                  points.add(Pair(points.length.toDouble(),
                      cumulative ? cumulativeTotal : totalForDay));
                }
                return LineChartWrapper(
                  points: [points],
                  isCurved: true,
                  extraLeftPaddingIfSmall: extraLeftPaddingIfSmall,
                  amountBefore: totalSpentBefore,
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
}
