import 'package:budget/functions.dart';
import 'package:budget/struct/budget.dart';
import 'package:budget/struct/transaction.dart';
import 'package:budget/struct/transactionCategory.dart';
import 'package:budget/widgets/budgetContainer.dart';
import 'package:budget/widgets/categoryEntry.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/pieChart.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({Key? key, required Budget this.budget}) : super(key: key);

  final Budget budget;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          leading: Container(),
          backgroundColor: budget.color,
          floating: false,
          pinned: true,
          expandedHeight: 200.0,
          collapsedHeight: 65,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
            title: TextFont(
              fontSize: 26,
              text: budget.title,
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.left,
            ),
            background: Container(
              color: budget.color,
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 22, vertical: 0),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(10)),
                  color: budget.color,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          child: CountUp(
                            count: budget.spent,
                            prefix: getCurrencyString(),
                            duration: Duration(milliseconds: 1500),
                            fontSize: 25,
                            textAlign: TextAlign.left,
                            fontWeight: FontWeight.bold,
                            decimals: moneyDecimals(budget.spent),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(bottom: 4.8),
                          child: TextFont(
                            text: " left of " + convertToMoney(budget.total),
                            fontSize: 16,
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                    Container(height: 10),
                    BudgetTimeline(budget: budget, large: true),
                    Container(height: 15),
                    DaySpending(budget: budget, large: true),
                    Container(height: 17),
                  ],
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
        // SliverPadding(
        //   padding: EdgeInsets.symmetric(vertical: 5),
        //   sliver: SliverList(
        //     delegate: SliverChildBuilderDelegate(
        //       (BuildContext context, int index) {
        //         return TransactionEntry(
        //           openPage: OpenTestPage(),
        //           transaction: Transaction(
        //             title: "Uber",
        //             amount: 50,
        //             categoryID: "id",
        //             date: DateTime.now(),
        //             note: "this is a transaction",
        //             tagIDs: ["id1"],
        //           ),
        //         );
        //       },
        //       childCount: 2,
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
