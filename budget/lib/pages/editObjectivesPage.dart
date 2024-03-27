import 'dart:async';
import 'dart:math';

import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/addObjectivePage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/objectivePage.dart';
import 'package:budget/pages/objectivesListPage.dart';
import 'package:budget/struct/currencyFunctions.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/globalSnackbar.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/radioItems.dart';
import 'package:budget/widgets/selectCategory.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide SliverReorderableList;
import 'package:flutter/services.dart' hide TextInput;
import 'package:budget/widgets/editRowEntry.dart';
import 'package:budget/modified/reorderable_list.dart';
import 'package:provider/provider.dart';

import 'addButton.dart';

class EditObjectivesPage extends StatefulWidget {
  EditObjectivesPage({
    required this.objectiveType,
    Key? key,
  }) : super(key: key);
  final ObjectiveType objectiveType;

  @override
  _EditObjectivesPageState createState() => _EditObjectivesPageState();
}

class _EditObjectivesPageState extends State<EditObjectivesPage> {
  bool dragDownToDismissEnabled = true;
  int currentReorder = -1;
  String searchValue = "";
  bool isFocused = false;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      database.fixOrderObjectives(objectiveType: widget.objectiveType);
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
        title: widget.objectiveType == ObjectiveType.loan
            ? "loans".tr()
            : "goals".tr(),
        scrollToTopButton: true,
        floatingActionButton: AnimateFABDelayed(
          fab: AddFAB(
            tooltip: widget.objectiveType == ObjectiveType.loan
                ? "add-loan".tr()
                : "add-goal".tr(),
            openPage: AddObjectivePage(
              routesToPopAfterDelete: RoutesToPopAfterDelete.None,
              objectiveType: widget.objectiveType,
            ),
          ),
        ),
        actions: [
          IconButton(
            padding: EdgeInsets.all(15),
            tooltip: widget.objectiveType == ObjectiveType.loan
                ? "add-loan".tr()
                : "add-goal".tr(),
            onPressed: () {
              pushRoute(
                context,
                AddObjectivePage(
                  routesToPopAfterDelete: RoutesToPopAfterDelete.None,
                  objectiveType: widget.objectiveType,
                ),
              );
            },
            icon: Icon(appStateSettings["outlinedIcons"]
                ? Icons.add_outlined
                : Icons.add_rounded),
          ),
        ],
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Focus(
                onFocusChange: (value) {
                  setState(() {
                    isFocused = value;
                  });
                },
                child: TextInput(
                  labelText: widget.objectiveType == ObjectiveType.loan
                      ? "search-loans-placeholder".tr()
                      : "search-goals-placeholder".tr(),
                  icon: appStateSettings["outlinedIcons"]
                      ? Icons.search_outlined
                      : Icons.search_rounded,
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
          ),
          SliverToBoxAdapter(
            child: AnimatedExpanded(
              expand: hideIfSearching(searchValue, isFocused, context) == false,
              child: TotalSpentToggle(isForGoalTotal: true),
            ),
          ),
          StreamBuilder<List<Objective>>(
            stream: database.watchAllObjectives(
              objectiveType: widget.objectiveType,
              searchFor: searchValue == "" ? null : searchValue,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData && (snapshot.data ?? []).length <= 0) {
                return SliverToBoxAdapter(
                  child: NoResults(
                    message: widget.objectiveType == ObjectiveType.loan
                        ? "no-loans-found".tr()
                        : "no-goals-found".tr(),
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
                    Objective objective = snapshot.data![index];
                    return EditRowEntry(
                      key: ValueKey(objective.objectivePk),
                      extraIcon: objective.archived
                          ? appStateSettings["outlinedIcons"]
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_off_rounded
                          : appStateSettings["outlinedIcons"]
                              ? Icons.visibility_outlined
                              : Icons.visibility_rounded,
                      onExtra: () async {
                        Objective updatedObjective =
                            objective.copyWith(archived: !objective.archived);
                        await database
                            .createOrUpdateObjective(updatedObjective);
                      },
                      opacity: objective.archived ? 0.5 : 1,
                      canReorder: searchValue == "" &&
                          (snapshot.data ?? []).length != 1,
                      currentReorder:
                          currentReorder != -1 && currentReorder != index,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      content: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CategoryIcon(
                            categoryPk: "-1",
                            size: 31,
                            category: TransactionCategory(
                              categoryPk: "-1",
                              name: "",
                              dateCreated: DateTime.now(),
                              dateTimeModified: null,
                              order: 0,
                              income: false,
                              iconName: objective.iconName,
                              colour: objective.colour,
                              emojiIconName: objective.emojiIconName,
                            ),
                            canEditByLongPress: false,
                            borderRadius: 1000,
                            sizePadding: 23,
                          ),
                          SizedBox(width: 5),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFont(
                                  text: objective.name,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19,
                                ),
                                TextFont(
                                  textAlign: TextAlign.left,
                                  text: getIsDifferenceOnlyLoan(objective)
                                      ? "difference-loan".tr()
                                      : objective.income
                                          ? widget.objectiveType ==
                                                  ObjectiveType.loan
                                              ? "lent-funds".tr()
                                              : "savings-goal".tr()
                                          : widget.objectiveType ==
                                                  ObjectiveType.loan
                                              ? "borrowed-funds".tr()
                                              : "expense-goal".tr(),
                                  fontSize: 14,
                                  textColor: getColor(context, "black")
                                      .withOpacity(0.65),
                                ),
                                WatchTotalAndAmountOfObjective(
                                  objective: objective,
                                  builder: (double objectiveAmount,
                                      double totalAmount,
                                      double percentageTowardsGoal) {
                                    bool showTotalSpent = appStateSettings[
                                        "showTotalSpentForObjective"];
                                    String amountSpentLabel =
                                        getObjectiveAmountSpentLabel(
                                      objective: objective,
                                      context: context,
                                      showTotalSpent: showTotalSpent,
                                      objectiveAmount: objectiveAmount,
                                      totalAmount: totalAmount,
                                    );
                                    String amountRemainingLabel =
                                        objectiveRemainingAmountText(
                                      objectiveAmount: objectiveAmount,
                                      totalAmount: totalAmount,
                                      context: context,
                                    );
                                    String differenceOnlyLoanLabel =
                                        getIsDifferenceOnlyLoan(objective)
                                            ? (percentageTowardsGoal == 1
                                                ? "all-settled".tr()
                                                : (getDifferenceOfLoan(
                                                            objective,
                                                            totalAmount,
                                                            objectiveAmount) >
                                                        0)
                                                    ? "to-pay".tr()
                                                    : "to-collect".tr())
                                            : "";
                                    return TextFont(
                                      textAlign: TextAlign.left,
                                      text: getIsDifferenceOnlyLoan(objective)
                                          ? (amountSpentLabel +
                                              " " +
                                              differenceOnlyLoanLabel
                                                  .toLowerCase())
                                          : (amountSpentLabel +
                                              amountRemainingLabel),
                                      fontSize: 14,
                                      textColor: getColor(context, "black")
                                          .withOpacity(0.65),
                                      maxLines: 2,
                                    );
                                  },
                                ),
                                // StreamBuilder<int?>(
                                //   stream: database
                                //       .getTotalCountOfTransactionsInObjective(
                                //           objective.objectivePk)
                                //       .$1,
                                //   builder: (context, snapshot) {
                                //     if (snapshot.hasData &&
                                //         snapshot.data != null) {
                                //       return TextFont(
                                //         textAlign: TextAlign.left,
                                //         text: snapshot.data.toString() +
                                //             " " +
                                //             (snapshot.data == 1
                                //                 ? "transaction"
                                //                     .tr()
                                //                     .toLowerCase()
                                //                 : "transactions"
                                //                     .tr()
                                //                     .toLowerCase()),
                                //         fontSize: 14,
                                //         textColor:
                                //             getColor(context, "black")
                                //                 .withOpacity(0.65),
                                //       );
                                //     } else {
                                //       return TextFont(
                                //         textAlign: TextAlign.left,
                                //         text: "/ transactions",
                                //         fontSize: 14,
                                //         textColor:
                                //             getColor(context, "black")
                                //                 .withOpacity(0.65),
                                //       );
                                //     }
                                //   },
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      index: index,
                      onDelete: () async {
                        deleteObjectivePopup(context,
                            objective: objective,
                            routesToPopAfterDelete:
                                RoutesToPopAfterDelete.None);
                        return true;
                      },
                      openPage: AddObjectivePage(
                        objective: objective,
                        routesToPopAfterDelete: RoutesToPopAfterDelete.One,
                      ),
                    );
                  },
                  itemCount: snapshot.data!.length,
                  onReorder: (_intPrevious, _intNew) async {
                    Objective oldObjective = snapshot.data![_intPrevious];
                    if (_intNew > _intPrevious) {
                      await database.moveObjective(oldObjective.objectivePk,
                          _intNew - 1, oldObjective.order,
                          objectiveType: widget.objectiveType);
                    } else {
                      await database.moveObjective(
                          oldObjective.objectivePk, _intNew, oldObjective.order,
                          objectiveType: widget.objectiveType);
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

Future<DeletePopupAction?> deleteObjectivePopup(
  BuildContext context, {
  required Objective objective,
  required RoutesToPopAfterDelete routesToPopAfterDelete,
}) async {
  DeletePopupAction? action = await openDeletePopup(
    context,
    title: objective.type == ObjectiveType.loan
        ? "delete-loan-question".tr()
        : "delete-goal-question".tr(),
    subtitle: objective.name,
  );
  if (action == DeletePopupAction.Delete) {
    dynamic result = true;
    int? numTransactions = await database
        .getTotalCountOfTransactionsInObjective(objective.objectivePk)
        .$2;
    if (numTransactions != null && numTransactions > 0) {
      result = await openPopup(
        context,
        title: objective.type == ObjectiveType.loan
            ? "remove-transactions-from-loan-question".tr()
            : "remove-transactions-from-goal-question".tr(),
        description: objective.type == ObjectiveType.loan
            ? "delete-loan-warning".tr()
            : "delete-goal-warning".tr(),
        icon: appStateSettings["outlinedIcons"]
            ? Icons.warning_outlined
            : Icons.warning_rounded,
        onCancel: () {
          Navigator.pop(context, false);
        },
        onCancelLabel: "cancel".tr(),
        onSubmit: () async {
          Navigator.pop(context, true);
        },
        onSubmitLabel: objective.type == ObjectiveType.loan
            ? "delete-loan".tr()
            : "delete-goal".tr(),
      );
    }
    if (result == true) {
      if (routesToPopAfterDelete == RoutesToPopAfterDelete.All) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else if (routesToPopAfterDelete == RoutesToPopAfterDelete.One) {
        Navigator.of(context).pop();
      }
      openLoadingPopupTryCatch(() async {
        await database.deleteObjective(context, objective);
        openSnackbar(
          SnackbarMessage(
            title: objective.type == ObjectiveType.loan
                ? "deleted-loan".tr()
                : "deleted-goal".tr(),
            icon: Icons.delete,
            description: objective.name,
          ),
        );
      });
    }
  }
  return action;
}

// either "none", null, or a Objective type
Future<dynamic> selectObjectivePopup(
  BuildContext context, {
  Objective? selectedObjective,
  includeAmount = false,
  bool canSelectNoGoal = true,
  bool showAddButton = false,
  ObjectiveType objectiveType = ObjectiveType.goal,
}) async {
  dynamic objective = await openBottomSheet(
    context,
    PopupFramework(
      title: objectiveType == ObjectiveType.loan
          ? "select-loan".tr()
          : "select-goal".tr(),
      child: Column(
        children: [
          StreamBuilder<List<Objective>>(
            stream: database.watchAllObjectives(objectiveType: objectiveType),
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  (snapshot.data != null && snapshot.data!.length > 0)) {
                List<Objective> addableObjectives = snapshot.data!;
                return RadioItems(
                  ifNullSelectNone: true,
                  items: [if (canSelectNoGoal) null, ...addableObjectives],
                  onLongPress: (Objective? objective) {
                    pushRoute(
                      context,
                      AddObjectivePage(
                        routesToPopAfterDelete: RoutesToPopAfterDelete.One,
                        objective: objective,
                      ),
                    );
                  },
                  colorFilter: (Objective? objective) {
                    if (objective == null) return null;
                    return dynamicPastel(
                      context,
                      lightenPastel(
                        HexColor(
                          objective.colour,
                          defaultColor: Theme.of(context).colorScheme.primary,
                        ),
                        amount: 0.2,
                      ),
                      amount: 0.1,
                    );
                  },
                  displayFilter: (Objective? objective) {
                    return (objective?.name ??
                            (objectiveType == ObjectiveType.loan
                                ? "no-loan".tr()
                                : "no-goal".tr())) +
                        (includeAmount &&
                                objective != null &&
                                objectiveType != ObjectiveType.loan
                            ? (" (" +
                                convertToMoney(
                                  Provider.of<AllWallets>(context),
                                  objectiveAmountToPrimaryCurrency(
                                          Provider.of<AllWallets>(context),
                                          objective) *
                                      ((objective.income) ? 1 : -1),
                                ) +
                                ")")
                            : "");
                  },
                  initial: selectedObjective,
                  onChanged: (Objective? objective) async {
                    if (objective == null)
                      Navigator.of(context).pop("none");
                    else
                      Navigator.of(context).pop(objective);
                  },
                );
              } else {
                return NoResultsCreate(
                  message: "no-goals-found".tr(),
                  buttonLabel: "create-goal".tr(),
                  route: AddObjectivePage(
                    routesToPopAfterDelete: RoutesToPopAfterDelete.None,
                    objectiveType: objectiveType,
                  ),
                );
              }
            },
          ),
          if (showAddButton)
            Row(
              children: [
                Expanded(
                  child: AddButton(
                    margin: EdgeInsets.only(top: 7),
                    onTap: () {
                      pushRoute(
                        context,
                        AddObjectivePage(
                          routesToPopAfterDelete: RoutesToPopAfterDelete.None,
                          objectiveType: objectiveType,
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
        ],
      ),
    ),
  );

  if (objective is Objective) return objective;
  if (objective == "none") return "none";
  return null;
}

class ObjectiveSettings extends StatelessWidget {
  const ObjectiveSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return TotalSpentToggle(isForGoalTotal: true);
  }
}

// First entry is numberOfInstallmentPaymentsDisplay
// Second entry is amountPerInstallmentPaymentDisplay
List<double> getInstallmentPaymentCalculations({
  required AllWallets allWallets,
  required Objective objective,
  required int? numberOfInstallmentPayments,
  required double? amountPerInstallmentPayment,
  required String amountPerInstallmentPaymentWalletPk,
}) {
  double amountPerInstallmentPaymentInCurrentCurrency =
      (amountPerInstallmentPayment ?? 0) *
          amountRatioToPrimaryCurrencyGivenPk(
              allWallets, amountPerInstallmentPaymentWalletPk);
  double objectiveTotalInCurrentCurrency =
      objectiveAmountToPrimaryCurrency(allWallets, objective);
  double numberOfInstallmentPaymentsDisplay =
      (numberOfInstallmentPayments ?? 0) * 1.0;
  double amountPerInstallmentPaymentDisplay =
      amountPerInstallmentPaymentInCurrentCurrency;
  if (numberOfInstallmentPayments == null) {
    numberOfInstallmentPaymentsDisplay =
        objectiveTotalInCurrentCurrency / amountPerInstallmentPaymentDisplay;
    amountPerInstallmentPaymentDisplay = amountPerInstallmentPayment ?? 0;
  } else if (amountPerInstallmentPayment == null) {
    // We add a small decimal because we need to make sure the amount reaches the actual goal when dividing
    // We need the percentage goal achieved to reach above 100% so it stops creating transactions
    // And also so we actually achieve our goal
    amountPerInstallmentPaymentDisplay =
        objectiveTotalInCurrentCurrency / numberOfInstallmentPaymentsDisplay +
            0.00000000000001;
  }
  amountPerInstallmentPaymentDisplay =
      amountPerInstallmentPaymentDisplay * (objective.income ? 1 : -1);
  return [
    numberOfInstallmentPaymentsDisplay,
    amountPerInstallmentPaymentDisplay
  ];
}
