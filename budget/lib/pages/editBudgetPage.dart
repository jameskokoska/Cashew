import 'dart:developer';

import 'package:animations/animations.dart';
import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditBudgetPage extends StatefulWidget {
  EditBudgetPage({
    Key? key,
    required this.title,
  }) : super(key: key);
  final String title;

  @override
  _EditBudgetPageState createState() => _EditBudgetPageState();
}

class _EditBudgetPageState extends State<EditBudgetPage> {
  bool dragDownToDismissEnabled = true;
  int currentReorder = -1;
  @override
  Widget build(BuildContext context) {
    return PageFramework(
      dragDownToDismiss: true,
      dragDownToDismissEnabled: dragDownToDismissEnabled,
      title: widget.title,
      navbar: false,
      floatingActionButton: AnimatedScaleDelayed(
        child: FAB(
          tooltip: "Add Budget",
          openPage: AddBudgetPage(
            title: "Add Budget",
          ),
        ),
      ),
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
            if (snapshot.hasData && (snapshot.data ?? []).length > 0) {
              return SliverReorderableList(
                onReorderStart: (index) {
                  HapticFeedback.heavyImpact();
                  setState(() {
                    dragDownToDismissEnabled = false;
                    currentReorder = index;
                  });
                },
                onReorderEnd: (_) {
                  setState(() {
                    dragDownToDismissEnabled = true;
                    currentReorder = -1;
                  });
                },
                itemBuilder: (context, index) {
                  Budget budget = snapshot.data![index];
                  DateTimeRange budgetRange =
                      getBudgetDate(budget, DateTime.now());
                  Color backgroundColor = dynamicPastel(
                      context,
                      HexColor(budget.colour,
                          Theme.of(context).colorScheme.lightDarkAccent),
                      amountLight: 0.55,
                      amountDark: 0.35);
                  return EditRowEntry(
                    currentReorder:
                        currentReorder != -1 && currentReorder != index,
                    backgroundColor: backgroundColor,
                    onDelete: () {
                      openPopup(
                        context,
                        title: "Delete " + budget.name + "?",
                        icon: Icons.delete_rounded,
                        onCancel: () {
                          Navigator.pop(context);
                        },
                        onCancelLabel: "Cancel",
                        onSubmit: () {
                          database.deleteBudget(budget.budgetPk);
                          Navigator.pop(context);
                          openSnackbar(context, "Deleted " + budget.name);
                        },
                        onSubmitLabel: "Delete",
                      );
                    },
                    openPage: AddBudgetPage(
                      title: "Edit Budget",
                      budget: budget,
                    ),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFont(
                          text: budget.name + " - " + budget.order.toString(),
                          fontWeight: FontWeight.bold,
                          fontSize: 21,
                        ),
                        Container(height: 2),
                        Row(
                          children: [
                            TextFont(
                              text: convertToMoney(budget.amount),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            TextFont(
                              text: " / ",
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            budget.reoccurrence!.index != 0
                                ? TextFont(
                                    text: budget.periodLength.toString() + " ",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  )
                                : SizedBox(),
                            TextFont(
                              text: budget.periodLength == 1
                                  ? nameRecurrence[budget.reoccurrence]
                                  : namesRecurrence[budget.reoccurrence],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ],
                        ),
                        TextFont(
                          text: getWordedDateShort(budgetRange.start) +
                              " - " +
                              getWordedDateShort(budgetRange.end),
                          fontSize: 15,
                        ),
                        Container(height: 2),
                        TextFont(
                          text: budget.categoryFks == null ||
                                  budget.categoryFks!.length == 0
                              ? "All categories budget"
                              : budget.categoryFks!.length.toString() +
                                  " category budget",
                          fontSize: 14,
                        ),
                        Wrap(
                          spacing: 0,
                          runSpacing: 0,
                          children: [
                            ...budget.categoryFks!
                                .asMap()
                                .entries
                                .map((categoryFk) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 1.4),
                                child: FutureBuilder(
                                    future: database
                                        .getCategoryInstance(categoryFk.value),
                                    builder: (context,
                                        AsyncSnapshot<TransactionCategory>
                                            snapshot) {
                                      if (snapshot.hasData) {
                                        return Opacity(
                                          opacity: 0.4,
                                          child: TextFont(
                                            text: (snapshot.data?.name ?? "") +
                                                (budget.categoryFks!.length -
                                                            1 ==
                                                        categoryFk.key.toInt()
                                                    ? ""
                                                    : ", "),
                                            fontSize: 13,
                                          ),
                                        );
                                      } else {
                                        return TextFont(
                                          text: " ",
                                          fontSize: 13,
                                        );
                                      }
                                    }),
                              );
                            }).toList(),
                          ],
                        ),
                      ],
                    ),
                    index: index,
                    key: ValueKey(index),
                  );
                },
                itemCount: snapshot.data!.length,
                onReorder: (_intPrevious, _intNew) async {
                  Budget oldBudget = snapshot.data![_intPrevious];

                  print(oldBudget.name);
                  print(oldBudget.order);

                  if (_intNew > _intPrevious) {
                    await database.moveBudget(
                        oldBudget.budgetPk, _intNew - 1, oldBudget.order);
                  } else {
                    await database.moveBudget(
                        oldBudget.budgetPk, _intNew, oldBudget.order);
                  }
                },
              );
            }
            return SliverToBoxAdapter(
              child: Container(),
            );
          },
        ),
      ],
    );
  }
}

class EditRowEntry extends StatelessWidget {
  const EditRowEntry(
      {required this.index,
      required this.content,
      required this.backgroundColor,
      required this.openPage,
      required this.onDelete,
      this.onTap,
      this.padding,
      this.currentReorder = false,
      Key? key})
      : super(key: key);
  final int index;
  final Widget content;
  final Color backgroundColor;
  final Widget openPage;
  final VoidCallback onDelete;
  final EdgeInsets? padding;
  final bool currentReorder;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      scale: currentReorder ? 0.95 : 1,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: ReorderableDelayedDragStartListener(
          index: index,
          child: OpenContainerNavigation(
            openPage: openPage,
            closedColor: backgroundColor,
            borderRadius: 18,
            button: (openContainer) {
              return Tappable(
                borderRadius: 18,
                color: backgroundColor,
                onTap: () {
                  if (onTap != null)
                    onTap!();
                  else
                    openContainer();
                },
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Container(
                          padding: padding ??
                              EdgeInsets.only(
                                left: 25,
                                right: 10,
                                top: 15,
                                bottom: 15,
                              ),
                          child: content,
                        ),
                      ),
                      Tappable(
                        color: Colors.transparent,
                        borderRadius: 18,
                        child: Container(
                            height: double.infinity,
                            width: 40,
                            child: Icon(Icons.delete_rounded)),
                        onTap: onDelete,
                      ),
                      ReorderableDragStartListener(
                        index: index,
                        child: Tappable(
                          color: Colors.transparent,
                          borderRadius: 18,
                          child: Container(
                              margin: EdgeInsets.only(right: 10),
                              width: 40,
                              height: double.infinity,
                              child: Icon(Icons.drag_handle_rounded)),
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
