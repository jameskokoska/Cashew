import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/pages/budgetPage.dart';
import 'package:budget/pages/subscriptionsPage.dart';
import 'package:budget/pages/transactionsListPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/keepAliveClientMixin.dart';
import 'package:budget/widgets/budgetContainer.dart';
import 'package:budget/widgets/lineGraph.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:budget/widgets/upcomingTransactions.dart';
import 'package:budget/widgets/walletEntry.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePageLineGraph extends StatelessWidget {
  const HomePageLineGraph({super.key, required this.selectedSlidingSelector});
  final int selectedSlidingSelector;
  @override
  Widget build(BuildContext context) {
    return appStateSettings["showSpendingGraph"] == false &&
            enableDoubleColumn(context) == false
        ? SizedBox.shrink()
        : KeepAliveClientMixin(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: Container(
                padding:
                    EdgeInsets.only(left: 5, right: 7, bottom: 12, top: 18),
                margin: EdgeInsets.symmetric(horizontal: 13),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  color: getColor(context, "lightDarkAccentHeavyLight"),
                  boxShadow: boxShadowCheck(boxShadowGeneral(context)),
                ),
                child: appStateSettings["lineGraphReferenceBudgetPk"] == null
                    ? PastSpendingGraph(
                        isIncome: selectedSlidingSelector == 2
                            ? false
                            : selectedSlidingSelector == 3
                                ? true
                                : null,
                      )
                    : StreamBuilder<Budget>(
                        stream: database.getBudget(
                            appStateSettings["lineGraphReferenceBudgetPk"]),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            Budget budget = snapshot.data!;
                            ColorScheme budgetColorScheme =
                                ColorScheme.fromSeed(
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
                                  selectedCategoryPk: -1,
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
    this.walletPks,
    this.extraLeftPaddingIfSmall = 0,
  });
  final bool? isIncome;
  final int monthsToLoad;
  final List<int>? walletPks;
  final double extraLeftPaddingIfSmall;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Transaction>>(
      stream: database.getTransactionsInTimeRangeFromCategories(
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
        [],
        true,
        true,
        isIncome,
        null,
        null,
        walletPks: walletPks,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          bool cumulative = appStateSettings["showCumulativeSpending"];
          double cumulativeTotal = 0;
          List<Pair> points = [];
          for (DateTime indexDay = DateTime(
            DateTime.now().year,
            DateTime.now().month - monthsToLoad,
            DateTime.now().day,
          );
              indexDay.compareTo(DateTime.now()) < 0;
              indexDay =
                  DateTime(indexDay.year, indexDay.month, indexDay.day + 1)) {
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
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
