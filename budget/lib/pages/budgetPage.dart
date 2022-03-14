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
          backgroundColor: HexColor(budget.colour),
          floating: false,
          pinned: true,
          expandedHeight: 200.0,
          collapsedHeight: 65,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
            title: TextFont(
              fontSize: 26,
              text: budget.name,
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.left,
            ),
            background: Container(
              color: HexColor(budget.colour),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              //offset to remove 1 pixel line
              Transform.translate(
                offset: Offset(0, -1),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 22, vertical: 0),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(10)),
                    color: HexColor(budget.colour),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            child: CountUp(
                              count: budget.amount,
                              prefix: getCurrencyString(),
                              duration: Duration(milliseconds: 1500),
                              fontSize: 25,
                              textAlign: TextAlign.left,
                              fontWeight: FontWeight.bold,
                              decimals: moneyDecimals(budget.amount),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(bottom: 4.8),
                            child: TextFont(
                              text: " left of " + convertToMoney(budget.amount),
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
        StreamBuilder<List<Transaction>>(
          stream: database.getTransactionsInTimeRangeFromCategories(
              getBudgetDate(budget, DateTime.now()).start,
              getBudgetDate(budget, DateTime.now()).end,
              budget.categoryFks ?? [],
              budget.allCategoryFks),
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
