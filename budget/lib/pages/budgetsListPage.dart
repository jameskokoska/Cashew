import 'package:budget/database/tables.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/budgetContainer.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BudgetsListPage extends StatefulWidget {
  const BudgetsListPage({Key? key}) : super(key: key);

  @override
  State<BudgetsListPage> createState() => BudgetsListPageState();
}

class BudgetsListPageState extends State<BudgetsListPage>
    with AutomaticKeepAliveClientMixin {
  GlobalKey<PageFrameworkState> pageState = GlobalKey();

  late Color selectedColor = Colors.red;
  void refreshState() {
    setState(() {});
  }

  void scrollToTop() {
    pageState.currentState!.scrollToTop();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      sharedBudgetRefresh: true,
      key: pageState,
      title: "Budgets",
      backButton: false,
      horizontalPadding: getHorizontalPaddingConstrained(context),
      slivers: [
        StreamBuilder<List<Budget>>(
          stream: database.watchAllBudgets(),
          builder: (context, snapshot) {
            if (snapshot.hasData && (snapshot.data ?? []).length <= 0) {
              return SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 85, right: 15, left: 15),
                    child: TextFont(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        text: "No budgets created."),
                  ),
                ),
              );
            }
            if (snapshot.hasData) {
              return SliverPadding(
                padding: EdgeInsets.symmetric(vertical: 7, horizontal: 13),
                sliver: SliverReorderableList(
                  onReorder: (_intPrevious, _intNew) async {
                    Budget oldBudget = snapshot.data![_intPrevious];

                    // print(oldBudget.name);
                    // print(oldBudget.order);

                    if (_intNew > _intPrevious) {
                      await database.moveBudget(
                          oldBudget.budgetPk, _intNew - 1, oldBudget.order);
                    } else {
                      await database.moveBudget(
                          oldBudget.budgetPk, _intNew, oldBudget.order);
                    }
                  },
                  onReorderStart: (index) {
                    HapticFeedback.heavyImpact();
                  },
                  itemBuilder: (context, index) {
                    return ReorderableDelayedDragStartListener(
                      index: index,
                      key: ValueKey(snapshot.data![index].budgetPk),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: BudgetContainer(
                          budget: snapshot.data![index],
                          longPressToEdit: false,
                        ),
                      ),
                    );
                  },
                  itemCount: snapshot.data!.length,
                ),
              );

              //   SliverList(
              //     delegate: SliverChildBuilderDelegate(
              //       (BuildContext context, int index) {
              //         return Padding(
              //           padding: const EdgeInsets.only(bottom: 16.0),
              //           child: BudgetContainer(
              //             budget: snapshot.data![index],
              //           ),
              //         );
              //       },
              //       childCount: snapshot.data?.length, //snapshot.data?.length
              //     ),
              //   ),
              // );
            } else {
              return SliverToBoxAdapter();
            }
          },
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: 40),
        ),
      ],
    );
  }
}
