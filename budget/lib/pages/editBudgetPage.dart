import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/editCategoriesPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/struct/shareBudget.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/editRowEntry.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide SliverReorderableList;
import 'package:flutter/services.dart' hide TextInput;
import 'package:budget/modified/reorderable_list.dart';
import 'package:provider/provider.dart';

class EditBudgetPage extends StatefulWidget {
  EditBudgetPage({
    Key? key,
  }) : super(key: key);

  @override
  _EditBudgetPageState createState() => _EditBudgetPageState();
}

class _EditBudgetPageState extends State<EditBudgetPage> {
  bool dragDownToDismissEnabled = true;
  int currentReorder = -1;
  String searchValue = "";

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      database.fixOrderBudgets();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (searchValue != "") {
          setState(() {
            searchValue = "";
          });
          return false;
        } else {
          return true;
        }
      },
      child: PageFramework(
        horizontalPadding: getHorizontalPaddingConstrained(context),
        dragDownToDismiss: true,
        dragDownToDismissEnabled: dragDownToDismissEnabled,
        title: "edit-budgets".tr(),
        floatingActionButton: AnimateFABDelayed(
          fab: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewPadding.bottom),
            child: FAB(
              tooltip: "add-budget".tr(),
              openPage: AddBudgetPage(),
            ),
          ),
        ),
        actions: [
          appStateSettings["sharedBudgets"] == false
              ? SizedBox.shrink()
              : RefreshButton(onTap: () async {
                  loadingIndeterminateKey.currentState!.setVisibility(true);
                  await syncPendingQueueOnServer();
                  await getCloudBudgets();
                  loadingIndeterminateKey.currentState!.setVisibility(false);
                }),
        ],
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextInput(
                labelText: "search-budgets-placeholder".tr(),
                icon: Icons.search_rounded,
                onSubmitted: (value) {
                  setState(() {
                    searchValue = value;
                  });
                },
                onChanged: (value) {
                  setState(() {
                    searchValue = value;
                  });
                },
                autoFocus: false,
              ),
            ),
          ),
          StreamBuilder<List<Budget>>(
            stream: database.watchAllBudgets(
                searchFor: searchValue == "" ? null : searchValue),
            builder: (context, snapshot) {
              if (snapshot.hasData && (snapshot.data ?? []).length <= 0) {
                return SliverToBoxAdapter(
                  child: NoResults(
                    message: "No budgets found.",
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
                    Color accentColor = dynamicPastel(
                        context,
                        HexColor(budget.colour,
                            defaultColor:
                                Theme.of(context).colorScheme.primary),
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
                          canReorder: searchValue == "" &&
                              (snapshot.data ?? []).length != 1,
                          currentReorder:
                              currentReorder != -1 && currentReorder != index,
                          accentColor: accentColor,
                          onDelete: () {
                            deleteBudgetPopup(context, budget);
                          },
                          openPage: AddBudgetPage(
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
                                    text: convertToMoney(
                                        Provider.of<AllWallets>(context),
                                        budget.amount),
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
                                            .toString()
                                            .toLowerCase()
                                            .tr()
                                            .toLowerCase()
                                        : namesRecurrence[budget.reoccurrence]
                                            .toString()
                                            .toLowerCase()
                                            .tr()
                                            .toLowerCase(),
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
                              budget.sharedKey == null &&
                                      !budget.addedTransactionsOnly
                                  ? TextFont(
                                      text: budget.categoryFks == null ||
                                              budget.categoryFks!.length == 0
                                          ? "all-categories-budget".tr()
                                          : budget.categoryFks!.length
                                                  .toString() +
                                              " " +
                                              "category-budget".tr(),
                                      fontSize: 14,
                                    )
                                  : FutureBuilder<int?>(
                                      future: database
                                          .getTotalCountOfTransactionsInBudget(
                                              budget.budgetPk),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData &&
                                            snapshot.data != null) {
                                          return TextFont(
                                            textAlign: TextAlign.left,
                                            text: snapshot.data!.toString() +
                                                " " +
                                                (snapshot.data! == 1
                                                    ? "transaction"
                                                        .tr()
                                                        .toLowerCase()
                                                    : "transactions"
                                                        .tr()
                                                        .toLowerCase()),
                                            fontSize: 14,
                                            textColor:
                                                getColor(context, "black")
                                                    .withOpacity(0.65),
                                          );
                                        } else {
                                          return TextFont(
                                            textAlign: TextAlign.left,
                                            text:
                                                "/" + " " + "transactions".tr(),
                                            fontSize: 14,
                                            textColor:
                                                getColor(context, "black")
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
                                        ? Theme.of(context)
                                            .colorScheme
                                            .secondary
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
                    return true;
                  },
                );
              }
              return SliverToBoxAdapter(
                child: Container(),
              );
            },
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 75),
          ),
        ],
      ),
    );
  }
}

Future<dynamic> deleteBudgetPopup(context, Budget budget,
    {Function? afterDelete}) async {
  return openPopup(
    context,
    title: "delete".tr().capitalizeFirst + budget.name + "?",
    icon: Icons.delete_rounded,
    onCancel: () {
      Navigator.pop(context, false);
    },
    onCancelLabel: "cancel".tr(),
    onSubmit: () async {
      Navigator.pop(context, true);
      int result = await database.deleteBudget(context, budget);
      if (result == -1) return;
      openSnackbar(SnackbarMessage(title: "deleted-budget".tr()));
      if (afterDelete != null) afterDelete();
    },
    onSubmitLabel: "delete".tr(),
  );
}

Future<dynamic> deleteAddedTransactionsOnlyBudgetPopup(context, Budget budget) {
  return openPopup(
    context,
    title: "delete-budget-question".tr(),
    description: "delete-budget-added-warning".tr(),
    icon: Icons.delete_rounded,
    onCancel: () {
      Navigator.pop(context, false);
    },
    onCancelLabel: "cancel".tr(),
    onSubmit: () async {
      Navigator.pop(context, true);
    },
    onSubmitLabel: "delete".tr(),
  );
}

Future<dynamic> deleteSharedBudgetPopup(context, Budget budget) {
  if (budget.sharedOwnerMember == SharedOwnerMember.owner) {
    return openPopup(
      context,
      title: "Delete Shared Budget?",
      description:
          "You own this budget. Deleting it will remove it from the server. All transactions belonging to this budget will no longer be connected to a budget.",
      icon: Icons.delete_rounded,
      onCancel: () {
        Navigator.pop(context, false);
      },
      onCancelLabel: "cancel".tr(),
      onSubmit: () async {
        Navigator.pop(context, true);
      },
      onSubmitLabel: "delete".tr(),
    );
  } else {
    return openPopup(
      context,
      title: "Leave Shared Budget?",
      description:
          "You are a member of this budget. Deleting it will remove you from the shared group. All transactions belonging to this budget will no longer be connected to a budget, until you are added back.",
      icon: Icons.delete_rounded,
      onCancel: () {
        Navigator.pop(context, false);
      },
      onCancelLabel: "cancel".tr(),
      onSubmit: () async {
        Navigator.pop(context, true);
      },
      onSubmitLabel: "delete".tr(),
    );
  }
}
