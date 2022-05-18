import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
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

  @override
  Widget build(BuildContext context) {
    DateTimeRange budgetRange = getBudgetDate(widget.budget, DateTime.now());
    return PageFramework(
      title: widget.budget.name,
      appBarBackgroundColor: HexColor(widget.budget.colour),
      navbar: false,
      showElevationAfterScrollPast: budgetHeaderHeight,
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
            if (snapshot.hasData && (snapshot.data ?? []).length > 0) {
              double totalSpent = 0;
              List<Widget> categoryEntries = [];
              snapshot.data!.forEach((category) {
                totalSpent = totalSpent + category.total;
              });
              snapshot.data!.forEach((category) {
                categoryEntries.add(CategoryEntry(
                  category: category.category,
                  totalSpent: totalSpent,
                  transactionCount: category.transactionCount,
                  categorySpent: category.total,
                ));
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
                          color: HexColor(widget.budget.colour),
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
                                          duration:
                                              Duration(milliseconds: 2500),
                                          fontSize: 25,
                                          textAlign: TextAlign.left,
                                          fontWeight: FontWeight.bold,
                                          decimals: moneyDecimals(
                                              widget.budget.amount),
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
                                          duration:
                                              Duration(milliseconds: 2500),
                                          fontSize: 25,
                                          textAlign: TextAlign.left,
                                          fontWeight: FontWeight.bold,
                                          decimals: moneyDecimals(
                                              widget.budget.amount),
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
                  Container(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: TextFont(
                      text: "Categories",
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(height: 20),
                  PieChartWrapper(
                    data: snapshot.data ?? [],
                    totalSpent: totalSpent,
                  ),
                  Container(height: 45),
                  ...categoryEntries,
                ]),
              );
            }
            return SliverToBoxAdapter(child: Container());
          },
        ),
        SliverPadding(
          padding: EdgeInsets.only(top: 25, left: 18, right: 18, bottom: 8),
          sliver: SliverToBoxAdapter(
            child: TextFont(
              text: "Transactions",
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...getTransactionsSlivers(budgetRange.start, budgetRange.end,
            categoryFks: widget.budget.categoryFks ?? []),
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
    SchedulerBinding.instance!.addPostFrameCallback(postFrameCallback);
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
