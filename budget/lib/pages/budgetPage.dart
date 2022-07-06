import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/transactionsListPage.dart';
import 'package:budget/struct/budget.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/transactionCategory.dart';
import 'package:budget/widgets/budgetContainer.dart';
import 'package:budget/widgets/categoryEntry.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/pieChart.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:flutter/scheduler.dart';
import 'dart:developer';

class BudgetPage extends StatefulWidget {
  const BudgetPage({Key? key, required Budget this.budget}) : super(key: key);

  final Budget budget;

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  double budgetHeaderHeight = 0;
  int selectedCategoryPk = -1;

  @override
  Widget build(BuildContext context) {
    DateTimeRange budgetRange = getBudgetDate(widget.budget, DateTime.now());
    ColorScheme budgetColorScheme = ColorScheme.fromSeed(
      seedColor: HexColor(widget.budget.colour),
      brightness: getSettingConstants(appStateSettings)["theme"] ==
              ThemeMode.system
          ? MediaQuery.of(context).platformBrightness
          : getSettingConstants(appStateSettings)["theme"] == ThemeMode.light
              ? Brightness.light
              : getSettingConstants(appStateSettings)["theme"] == ThemeMode.dark
                  ? Brightness.dark
                  : Brightness.light,
    );
    return PageFramework(
      title: widget.budget.name,
      appBarBackgroundColor: budgetColorScheme.secondaryContainer,
      appBarBackgroundColorStart: budgetColorScheme.secondaryContainer,
      textColor: Theme.of(context).colorScheme.black,
      navbar: false,
      showElevationAfterScrollPast: budgetHeaderHeight,
      dragDownToDismiss: true,
      dragDownToDissmissBackground: budgetColorScheme.secondaryContainer,
      slivers: [
        StreamBuilder<List<CategoryWithTotal>>(
          stream:
              database.watchTotalSpentInEachCategoryInTimeRangeFromCategories(
            budgetRange.start,
            budgetRange.end,
            widget.budget.categoryFks ?? [],
            widget.budget.allCategoryFks,
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
                categoryEntries.add(
                  CategoryEntry(
                    category: category.category,
                    totalSpent: totalSpent,
                    transactionCount: category.transactionCount,
                    categorySpent: category.total.abs(),
                    onTap: () {
                      if (selectedCategoryPk == category.category.categoryPk) {
                        setState(() {
                          selectedCategoryPk = -1;
                        });
                        pieChartDisplayStateKey.currentState!
                            .setTouchedIndex(-1);
                      } else {
                        setState(() {
                          selectedCategoryPk = category.category.categoryPk;
                        });
                        pieChartDisplayStateKey.currentState!
                            .setTouchedIndex(index);
                      }
                    },
                    selected:
                        selectedCategoryPk == category.category.categoryPk,
                    allSelected: selectedCategoryPk == -1,
                  ),
                );
              });
              return SliverList(
                delegate: SliverChildListDelegate([
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        child: CountUp(
                                          count:
                                              widget.budget.amount - totalSpent,
                                          prefix: getCurrencyString(),
                                          duration: Duration(milliseconds: 700),
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
                                            const EdgeInsets.only(bottom: 3.8),
                                        child: TextFont(
                                          text: " left of " +
                                              convertToMoney(
                                                  widget.budget.amount),
                                          fontSize: 16,
                                          textAlign: TextAlign.left,
                                          textColor: budgetColorScheme
                                              .onSecondaryContainer,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        child: CountUp(
                                          count: -1 *
                                              (widget.budget.amount -
                                                  totalSpent),
                                          prefix: getCurrencyString(),
                                          duration: Duration(milliseconds: 700),
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
                                            const EdgeInsets.only(bottom: 3.8),
                                        child: TextFont(
                                          text: " overspent of " +
                                              convertToMoney(
                                                  widget.budget.amount),
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
                              budget: widget.budget,
                              large: true,
                              percent: totalSpent / widget.budget.amount * 100,
                              todayPercent: getPercentBetweenDates(
                                  budgetRange, DateTime.now()),
                            ),
                            Container(height: 15),
                            DaySpending(
                              budget: widget.budget,
                              amount: (widget.budget.amount - totalSpent) /
                                  daysBetween(DateTime.now(), budgetRange.end),
                              large: true,
                            ),
                            Container(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(height: 20),
                  snapshot.data!.length > 0
                      ? PieChartWrapper(
                          data: snapshot.data ?? [],
                          totalSpent: totalSpent,
                          setSelectedCategory: (categoryPk) {
                            setState(() {
                              selectedCategoryPk = categoryPk;
                            });
                          })
                      : Center(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 35, right: 30, left: 30),
                            child: TextFont(
                              maxLines: 4,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              text: "No transactions for this budget.",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                  Container(height: 35),
                  ...categoryEntries,
                  Container(height: 15),
                ]),
              );
            }
            return SliverToBoxAdapter(child: Container());
          },
        ),
        SliverToBoxAdapter(
          child: selectedCategoryPk != -1
              ? Padding(
                  padding: const EdgeInsets.only(
                      left: 13, right: 15, top: 5, bottom: 15),
                  child: Center(
                    child: TextFont(
                      text: "Showing transactions from selected category",
                      maxLines: 10,
                      textAlign: TextAlign.center,
                      fontSize: 14,
                      textColor: Theme.of(context).colorScheme.textLight,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : SizedBox(),
        ),
        ...getTransactionsSlivers(budgetRange.start, budgetRange.end,
            categoryFks: selectedCategoryPk != -1
                ? [selectedCategoryPk]
                : widget.budget.categoryFks ?? []),
        SliverToBoxAdapter(child: SizedBox(height: 100))
      ],
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
