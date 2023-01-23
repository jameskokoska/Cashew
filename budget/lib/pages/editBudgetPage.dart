import 'dart:developer';

import 'package:animations/animations.dart';
import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/editCategoriesPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/shareBudget.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/editRowEntry.dart';
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
      floatingActionButton: AnimateFABDelayed(
        fab: Padding(
          padding: EdgeInsets.only(bottom: bottomPaddingSafeArea),
          child: FAB(
            tooltip: "Add Budget",
            openPage: AddBudgetPage(
              title: "Add Budget",
            ),
          ),
        ),
      ),
      actions: [
        Container(
          padding: EdgeInsets.only(top: 12.5, right: 5),
          child: RefreshButton(onTap: () async {
            loadingIndeterminateKey.currentState!.setVisibility(true);
            await syncPendingQueueOnServer();
            await getCloudBudgets();
            loadingIndeterminateKey.currentState!.setVisibility(false);
          }),
        ),
      ],
      slivers: [
        SliverToBoxAdapter(
          child: SettingsContainerSwitch(
            title: "Total Spent Label",
            description: "Instead of the remaining amount",
            onSwitched: (value) {
              updateSettings("showTotalSpentForBudget", value,
                  pagesNeedingRefresh: [0, 2], updateGlobalState: false);
            },
            initialValue: appStateSettings["showTotalSpentForBudget"],
            icon: Icons.data_array_rounded,
          ),
        ),
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
                          defaultColor: Theme.of(context).colorScheme.primary),
                      amountLight: 0.55,
                      amountDark: 0.35);
                  return Stack(
                    key: ValueKey(index),
                    children: [
                      EditRowEntry(
                        extraIcon: budget.pinned
                            ? Icons.push_pin_rounded
                            : Icons.push_pin_outlined,
                        onExtra: () async {
                          Budget updatedBudget =
                              budget.copyWith(pinned: !budget.pinned);
                          await database.createOrUpdateBudget(updatedBudget);
                        },
                        canReorder: (snapshot.data ?? []).length != 1,
                        currentReorder:
                            currentReorder != -1 && currentReorder != index,
                        backgroundColor: backgroundColor,
                        onDelete: () {
                          deleteBudgetPopup(context, budget);
                        },
                        openPage: AddBudgetPage(
                          title: "Edit Budget",
                          budget: budget,
                        ),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFont(
                              text: budget.name,
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
                                // budget.reoccurrence!.index != 0
                                //     ? TextFont(
                                //         text: budget.periodLength.toString() + " ",
                                //         fontWeight: FontWeight.bold,
                                //         fontSize: 16,
                                //       )
                                //     : SizedBox(),
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
                            budget.sharedKey == null
                                ? TextFont(
                                    text: budget.categoryFks == null ||
                                            budget.categoryFks!.length == 0
                                        ? "All categories budget"
                                        : budget.categoryFks!.length
                                                .toString() +
                                            " category budget",
                                    fontSize: 14,
                                  )
                                : FutureBuilder<List<int?>>(
                                    future: database
                                        .getTotalCountOfTransactionsInBudget(
                                            budget.budgetPk),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData &&
                                          snapshot.data != null) {
                                        return TextFont(
                                          textAlign: TextAlign.left,
                                          text: snapshot.data![0].toString() +
                                              pluralString(
                                                  snapshot.data![0] == 1,
                                                  " transaction"),
                                          fontSize: 14,
                                          textColor: Theme.of(context)
                                              .colorScheme
                                              .black
                                              .withOpacity(0.65),
                                        );
                                      } else {
                                        return TextFont(
                                          textAlign: TextAlign.left,
                                          text: "/ transactions",
                                          fontSize: 14,
                                          textColor: Theme.of(context)
                                              .colorScheme
                                              .black
                                              .withOpacity(0.65),
                                        );
                                      }
                                    },
                                  ),
                            // List transaction category names on edit budgets page
                            // Wrap(
                            //   spacing: 0,
                            //   runSpacing: 0,
                            //   children: [
                            //     ...budget.categoryFks!
                            //         .asMap()
                            //         .entries
                            //         .map((categoryFk) {
                            //       return Padding(
                            //         padding: const EdgeInsets.only(top: 1.4),
                            //         child: FutureBuilder(
                            //             future: database
                            //                 .getCategoryInstance(categoryFk.value),
                            //             builder: (context,
                            //                 AsyncSnapshot<TransactionCategory>
                            //                     snapshot) {
                            //               if (snapshot.hasData) {
                            //                 return Opacity(
                            //                   opacity: 0.4,
                            //                   child: TextFont(
                            //                     text: (snapshot.data?.name ?? "") +
                            //                         (budget.categoryFks!.length -
                            //                                     1 ==
                            //                                 categoryFk.key.toInt()
                            //                             ? ""
                            //                             : ", "),
                            //                     fontSize: 13,
                            //                   ),
                            //                 );
                            //               } else {
                            //                 return TextFont(
                            //                   text: " ",
                            //                   fontSize: 13,
                            //                 );
                            //               }
                            //             }),
                            //       );
                            //     }).toList(),
                            //   ],
                            // ),
                          ],
                        ),
                        index: index,
                      ),
                      budget.sharedKey != null
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(top: 15, right: 20),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Icon(
                                  Icons.people_alt_rounded,
                                  size: 18,
                                  color: budget.colour == null
                                      ? Theme.of(context).colorScheme.secondary
                                      : dynamicPastel(
                                          context, HexColor(budget.colour),
                                          inverse: true, amount: 0.5),
                                ),
                              ),
                            )
                          : SizedBox.shrink(),
                    ],
                  );
                },
                itemCount: snapshot.data!.length,
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
              );
            }
            return SliverToBoxAdapter(
              child: Container(),
            );
          },
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: 85),
        ),
      ],
    );
  }
}

Future<dynamic> deleteBudgetPopup(context, Budget budget,
    {Function? afterDelete}) async {
  return openPopup(
    context,
    title: "Delete " + budget.name + "?",
    icon: Icons.delete_rounded,
    onCancel: () {
      Navigator.pop(context, false);
    },
    onCancelLabel: "Cancel",
    onSubmit: () async {
      Navigator.pop(context, true);
      await database.deleteBudget(context, budget);
      openSnackbar(SnackbarMessage(title: "Deleted budget"));
      if (afterDelete != null) afterDelete();
    },
    onSubmitLabel: "Delete",
  );
}

Future<dynamic> deleteSharedBudgetPopup(context, Budget budget) {
  if (budget.sharedOwnerMember == SharedOwnerMember.owner) {
    return openPopup(
      context,
      title: "Delete Shared Category?",
      description:
          "You own this category. Deleting it will remove it from the server. All transactions belonging to this budget will no longer be connected to a budget.",
      icon: Icons.delete_rounded,
      onCancel: () {
        Navigator.pop(context, false);
      },
      onCancelLabel: "Cancel",
      onSubmit: () async {
        Navigator.pop(context, true);
      },
      onSubmitLabel: "Delete",
    );
  } else {
    return openPopup(
      context,
      title: "Leave Shared Category?",
      description:
          "You are a member of this category. Deleting it will remove you from the shared group. All transactions belonging to this budget will no longer be connected to a budget, until you are added back.",
      icon: Icons.delete_rounded,
      onCancel: () {
        Navigator.pop(context, false);
      },
      onCancelLabel: "Cancel",
      onSubmit: () async {
        Navigator.pop(context, true);
      },
      onSubmitLabel: "Delete",
    );
  }
}
