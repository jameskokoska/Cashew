import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
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
    return PageFramework(
      title: widget.budget.name,
      appBarBackgroundColor: HexColor(widget.budget.colour),
      navbar: false,
      showElevationAfterScrollPast: budgetHeaderHeight,
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate(
            [
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
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(10)),
                      color: HexColor(widget.budget.colour),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              child: CountUp(
                                count: widget.budget.amount,
                                prefix: getCurrencyString(),
                                duration: Duration(milliseconds: 1500),
                                fontSize: 25,
                                textAlign: TextAlign.left,
                                fontWeight: FontWeight.bold,
                                decimals: moneyDecimals(widget.budget.amount),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(bottom: 4.8),
                              child: TextFont(
                                text: " left of " +
                                    convertToMoney(widget.budget.amount),
                                fontSize: 16,
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                        Container(height: 10),
                        BudgetTimeline(budget: widget.budget, large: true),
                        Container(height: 15),
                        DaySpending(budget: widget.budget, large: true),
                        Container(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Container(height: 30),
              TextFont(
                text: "Categories",
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              Container(height: 25),
              PieChartWrapper(data: [3, 3, 5, 80]),
              PieChartWrapper(data: [3, 3, 5, 80]),
              PieChartWrapper(data: [3, 3, 5, 80]),
              Container(height: 15),
            ]),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(vertical: 10),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return CategoryEntry(
                  category: TransactionCategoryOld(
                      title: "Shopping",
                      icon: "shopping.png",
                      id: "12901-",
                      color: Colors.red),
                );
              },
              childCount: 2,
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Container(height: 20),
              TextFont(
                text: "Transactions",
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ]),
          ),
        ),
        StreamBuilder<List<Transaction>>(
          stream: database.getTransactionsInTimeRangeFromCategories(
              getBudgetDate(widget.budget, DateTime.now()).start,
              getBudgetDate(widget.budget, DateTime.now()).end,
              widget.budget.categoryFks ?? [],
              widget.budget.allCategoryFks),
          builder: (context, snapshot) {
            if (snapshot.hasData && (snapshot.data ?? []).length > 0) {
              return SliverPadding(
                padding: EdgeInsets.symmetric(vertical: 10),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return TransactionEntry(
                        openPage: AddTransactionPage(
                          title: "Edit Transaction",
                          transaction: snapshot.data![index],
                        ),
                        transaction: Transaction(
                          transactionPk: snapshot.data![index].transactionPk,
                          name: snapshot.data![index].name,
                          amount: snapshot.data![index].amount,
                          note: snapshot.data![index].note,
                          budgetFk: snapshot.data![index].budgetFk,
                          categoryFk: snapshot.data![index].categoryFk,
                          dateCreated: snapshot.data![index].dateCreated,
                        ),
                      );
                    },
                    childCount: snapshot.data?.length,
                  ),
                ),
              );
            }
            return SliverToBoxAdapter(child: SizedBox());
          },
        ),
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
