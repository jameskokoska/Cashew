import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/editCategoriesPage.dart';
import 'package:budget/pages/editObjectivesPage.dart';
import 'package:budget/pages/editWalletsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/moreIcons.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/selectCategory.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry/transactionEntry.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budget/widgets/countNumber.dart';
import 'package:budget/widgets/framework/popupFramework.dart';

import 'tappableTextEntry.dart';

import 'tappableTextEntry.dart';

class SelectedTransactionsAppBar extends StatelessWidget {
  const SelectedTransactionsAppBar(
      {Key? key, required this.pageID, this.colorScheme})
      : super(key: key);

  final String pageID;
  final ColorScheme? colorScheme;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = this.colorScheme ?? Theme.of(context).colorScheme;
    return ValueListenableBuilder(
      valueListenable: globalSelectedID,
      builder: (context, value, widget) {
        List<String> listOfIDs = (value)[pageID] ?? [];
        bool animateIn = (value)[pageID] != null && (value)[pageID]!.length > 0;
        return AnimatedPositioned(
          left: 0,
          right: 0,
          duration: Duration(milliseconds: 500),
          top: animateIn ? 0 : -(MediaQuery.paddingOf(context).top + 80),
          curve: Curves.easeInOutCubic,
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Container(
                  padding:
                      EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
                  decoration: BoxDecoration(
                    // borderRadius: BorderRadius.only(
                    //   bottomLeft: Radius.circular(
                    //       getIsFullScreen(context) ? 20 : 10),
                    //   bottomRight: Radius.circular(
                    //       getIsFullScreen(context) ? 20 : 10),
                    // ),
                    boxShadow: boxShadowCheck(boxShadowSharp(context)),
                    color: colorScheme.secondaryContainer,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            IconButton(
                              padding: EdgeInsets.all(15),
                              color: colorScheme.secondary,
                              icon: Icon(
                                getPlatform() == PlatformOS.isIOS
                                    ? appStateSettings["outlinedIcons"]
                                        ? Icons.chevron_left_outlined
                                        : Icons.chevron_left_rounded
                                    : appStateSettings["outlinedIcons"]
                                        ? Icons.arrow_back_outlined
                                        : Icons.arrow_back_rounded,
                                color: colorScheme.secondary,
                              ),
                              onPressed: () {
                                globalSelectedID.value[pageID] = [];
                                globalSelectedID.notifyListeners();
                              },
                            ),
                            Expanded(
                              child: StreamBuilder<double?>(
                                stream: database.watchTotalSpentGivenList(
                                  Provider.of<AllWallets>(context),
                                  listOfIDs,
                                ),
                                builder: (context, snapshot) {
                                  return CountNumber(
                                    count:
                                        snapshot.hasData ? snapshot.data! : 0,
                                    duration: Duration(milliseconds: 250),
                                    initialCount: (0),
                                    textBuilder: (number) {
                                      return Wrap(
                                        alignment: WrapAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            child: TextFont(
                                              text:
                                                  listOfIDs.length.toString() +
                                                      " " +
                                                      "selected".tr(),
                                              fontSize: 17.5,
                                              textAlign: TextAlign.left,
                                              maxLines: 1,
                                            ),
                                          ),
                                          Transform.translate(
                                            offset: Offset(10, 0),
                                            child: Tappable(
                                              color: Colors.transparent,
                                              borderRadius: 15,
                                              onLongPress: () {
                                                copyToClipboard(
                                                  convertToMoney(
                                                    Provider.of<AllWallets>(
                                                        context,
                                                        listen: false),
                                                    number,
                                                    finalNumber:
                                                        snapshot.hasData
                                                            ? snapshot.data!
                                                            : 0,
                                                  ),
                                                );
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: TextFont(
                                                  text: convertToMoney(
                                                      Provider.of<AllWallets>(
                                                          context),
                                                      number,
                                                      finalNumber:
                                                          snapshot.hasData
                                                              ? snapshot.data!
                                                              : 0),
                                                  fontSize: 17.5,
                                                  textAlign: TextAlign.left,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      CustomPopupMenuButton(
                        colorScheme: colorScheme,
                        showButtons: enableDoubleColumn(context),
                        keepOutFirst: true,
                        // There is no header taking up space, we can always keep out the delete button
                        forceKeepOutFirst: true,
                        items: [
                          DropdownItemMenu(
                            id: "delete-transactions",
                            label: "delete-transactions".tr(),
                            icon: Icons.delete,
                            action: () async {
                              dynamic result = await deleteTransactionsPopup(
                                context,
                                transactionPks: value[pageID]!,
                                routesToPopAfterDelete:
                                    RoutesToPopAfterDelete.None,
                              );
                              if (result == DeletePopupAction.Delete) {
                                globalSelectedID.value[pageID] = [];
                                globalSelectedID.notifyListeners();
                              }
                            },
                          ),
                          if (value[pageID] != null &&
                              value[pageID]!.length <= 10)
                            DropdownItemMenu(
                              id: "create-copy",
                              label: "duplicate".tr(),
                              icon: appStateSettings["outlinedIcons"]
                                  ? Icons.file_copy_outlined
                                  : Icons.file_copy_rounded,
                              iconScale: 0.97,
                              action: () async {
                                bool showDetailedSnackbarMessage =
                                    value[pageID]!.length <= 1;
                                for (int i = 0;
                                    i < value[pageID]!.length;
                                    i++) {
                                  await duplicateTransaction(
                                    context,
                                    value[pageID]![i],
                                    showDuplicatedMessage:
                                        showDetailedSnackbarMessage,
                                  );
                                }
                                if (showDetailedSnackbarMessage == false) {
                                  openSnackbar(
                                    SnackbarMessage(
                                      icon: appStateSettings["outlinedIcons"]
                                          ? Icons.file_copy_outlined
                                          : Icons.file_copy_rounded,
                                      title: "created-copy".tr(),
                                      description:
                                          value[pageID]!.length.toString() +
                                              " " +
                                              "transactions".tr().toLowerCase(),
                                    ),
                                  );
                                }
                                globalSelectedID.value[pageID] = [];
                                globalSelectedID.notifyListeners();
                              },
                            ),
                          DropdownItemMenu(
                            id: "change-category",
                            label: "change-category".tr(),
                            icon: appStateSettings["outlinedIcons"]
                                ? Icons.category_outlined
                                : Icons.category_rounded,
                            action: () async {
                              MainAndSubcategory mainAndSubcategory =
                                  await selectCategorySequence(
                                context,
                                selectedCategory: null,
                                setSelectedCategory: (_) {},
                                selectedSubCategory: null,
                                setSelectedSubCategory: (_) {},
                                selectedIncomeInitial: null,
                              );
                              TransactionCategory? category =
                                  mainAndSubcategory.main;
                              print(mainAndSubcategory.sub);
                              if (category == null) return;
                              TransactionCategory? subCategory =
                                  mainAndSubcategory.sub;
                              List<Transaction> transactions = await database
                                  .getTransactionsFromPk(value[pageID]!);
                              await database.moveTransactionsToCategory(
                                transactions,
                                category.categoryPk,
                                subCategory?.categoryPk,
                                mainAndSubcategory
                                        .ignoredSubcategorySelection ==
                                    false,
                              );
                              openSnackbar(
                                SnackbarMessage(
                                  icon: appStateSettings["outlinedIcons"]
                                      ? Icons.account_balance_wallet_outlined
                                      : Icons.account_balance_wallet_rounded,
                                  title: "changed-category".tr(),
                                  description: "for".tr().capitalizeFirst +
                                      " " +
                                      transactions.length.toString() +
                                      " " +
                                      (transactions.length == 1
                                          ? "transaction".tr().toLowerCase()
                                          : "transactions".tr().toLowerCase()),
                                ),
                              );
                              globalSelectedID.value[pageID] = [];
                              globalSelectedID.notifyListeners();
                            },
                          ),
                          DropdownItemMenu(
                            id: "change-account",
                            label: "change-account".tr(),
                            icon: appStateSettings["outlinedIcons"]
                                ? Icons.account_balance_wallet_outlined
                                : Icons.account_balance_wallet_rounded,
                            action: () async {
                              TransactionWallet? wallet =
                                  await selectWalletPopup(
                                context,
                                allowEditWallet: true,
                              );
                              if (wallet == null) return;
                              List<Transaction> transactions = await database
                                  .getTransactionsFromPk(value[pageID]!);
                              await database.moveWalletTransactions(
                                Provider.of<AllWallets>(context, listen: false),
                                null,
                                wallet.walletPk,
                                transactionsToMove: transactions,
                              );
                              openSnackbar(
                                SnackbarMessage(
                                  icon: appStateSettings["outlinedIcons"]
                                      ? Icons.account_balance_wallet_outlined
                                      : Icons.account_balance_wallet_rounded,
                                  title: "changed-account".tr(),
                                  description: "for".tr().capitalizeFirst +
                                      " " +
                                      transactions.length.toString() +
                                      " " +
                                      (transactions.length == 1
                                          ? "transaction".tr().toLowerCase()
                                          : "transactions".tr().toLowerCase()),
                                ),
                              );
                              globalSelectedID.value[pageID] = [];
                              globalSelectedID.notifyListeners();
                            },
                          ),
                          DropdownItemMenu(
                            id: "add-to-budget",
                            label: "add-to-budget".tr(),
                            iconScale:
                                appStateSettings["outlinedIcons"] ? 1 : 0.85,
                            icon: appStateSettings["outlinedIcons"]
                                ? Icons.donut_small_outlined
                                : MoreIcons.chart_pie,
                            action: () async {
                              dynamic budget =
                                  await selectAddableBudgetPopup(context);
                              print(budget);
                              if (budget == null) return;

                              String? budgetPkToMoveTo;
                              if (budget == "none") {
                                budgetPkToMoveTo = null;
                              } else {
                                budgetPkToMoveTo = budget.budgetPk;
                              }
                              List<Transaction> transactions = await database
                                  .getTransactionsFromPk(value[pageID]!);
                              int numberMoved =
                                  await database.moveTransactionsToBudget(
                                      transactions, budgetPkToMoveTo);

                              // Some transactions weren't moved to a budget
                              // if (transactions.length != numberMoved) {
                              //   showIncomeCannotBeAddedToBudgetWarning();
                              // }

                              openSnackbar(
                                SnackbarMessage(
                                  icon: appStateSettings["outlinedIcons"]
                                      ? Icons.donut_small_outlined
                                      : MoreIcons.chart_pie,
                                  title: budget == "none"
                                      ? "removed-from-budget".tr()
                                      : "added-to-budget".tr(),
                                  description: "for".tr().capitalizeFirst +
                                      " " +
                                      numberMoved.toString() +
                                      " " +
                                      (numberMoved == 1
                                          ? "transaction".tr().toLowerCase()
                                          : "transactions".tr().toLowerCase()),
                                ),
                              );

                              globalSelectedID.value[pageID] = [];
                              globalSelectedID.notifyListeners();
                            },
                          ),
                          DropdownItemMenu(
                            id: "add-to-goal",
                            label: "add-to-goal".tr(),
                            iconScale: 0.85,
                            icon: appStateSettings["outlinedIcons"]
                                ? Icons.savings_outlined
                                : Icons.savings_rounded,
                            action: () async {
                              dynamic objective =
                                  await selectObjectivePopup(context);
                              if (objective == null) return;

                              String? objectivePkToMoveTo;
                              if (objective == "none") {
                                objectivePkToMoveTo = null;
                              } else {
                                objectivePkToMoveTo = objective.objectivePk;
                              }
                              List<Transaction> transactions = await database
                                  .getTransactionsFromPk(value[pageID]!);
                              int numberMoved =
                                  await database.moveTransactionsToObjective(
                                      transactions, objectivePkToMoveTo);

                              openSnackbar(
                                SnackbarMessage(
                                  icon: appStateSettings["outlinedIcons"]
                                      ? Icons.savings_outlined
                                      : Icons.savings_rounded,
                                  title: objective == "none"
                                      ? "removed-from-goal".tr()
                                      : "added-to-goal-action".tr(),
                                  description: "for".tr().capitalizeFirst +
                                      " " +
                                      numberMoved.toString() +
                                      " " +
                                      (numberMoved == 1
                                          ? "transaction".tr().toLowerCase()
                                          : "transactions".tr().toLowerCase()),
                                ),
                              );

                              globalSelectedID.value[pageID] = [];
                              globalSelectedID.notifyListeners();
                            },
                          ),
                        ],
                      ),
                      if (appStateSettings["massEditSelectedTransactions"] ==
                          true)
                        IconButton(
                          padding: EdgeInsets.all(15),
                          color: colorScheme.secondary,
                          icon: Icon(
                            Icons.edit,
                            color: colorScheme.secondary,
                          ),
                          onPressed: () {
                            openPopupCustom(
                              context,
                              title: "Edit " +
                                  (value)[pageID]!.length.toString() +
                                  " Selected",
                              child: EditSelectedTransactions(
                                transactionIDs: value[pageID]!,
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future duplicateTransaction(
  BuildContext context,
  String transactionPk, {
  bool showDuplicatedMessage = true,
  bool useCurrentDate = false,
  double? customAmount,
}) async {
  Transaction transaction = await database.getTransactionFromPk(transactionPk);
  if (useCurrentDate) {
    transaction = transaction.copyWith(dateCreated: DateTime.now());
  }
  if (customAmount != null) {
    transaction = transaction.copyWith(amount: customAmount);
  }
  await database.createOrUpdateTransaction(
    transaction,
    insert: true,
  );
  String transactionName = transaction.name;
  if (transactionName.trim() == "") {
    transactionName =
        (await database.getCategoryInstance(transaction.categoryFk)).name;
  }
  if (showDuplicatedMessage) {
    openSnackbar(
      SnackbarMessage(
        icon: appStateSettings["outlinedIcons"]
            ? Icons.file_copy_outlined
            : Icons.file_copy_rounded,
        title: "created-copy".tr(),
        description: "copied".tr() + " " + transactionName,
      ),
    );
  }
}

class EditSelectedTransactions extends StatefulWidget {
  const EditSelectedTransactions({super.key, required this.transactionIDs});
  final List<String> transactionIDs;

  @override
  State<EditSelectedTransactions> createState() =>
      _EditSelectedTransactionsState();
}

class _EditSelectedTransactionsState extends State<EditSelectedTransactions> {
  TransactionCategory? selectedCategory;

  double? selectedAmount;
  String? selectedAmountCalculation;

  String selectedOperation = "+";

  void setSelectedAmount(double amount, String amountCalculation) {
    if (amount == selectedAmount) {
      selectedAmountCalculation = amountCalculation;
    } else {
      setState(() {
        selectedAmount = amount;
        selectedAmountCalculation = amountCalculation;
      });
    }
    return;
  }

  Future<void> selectAmount(BuildContext context) async {
    openBottomSheet(
      context,
      fullSnap: true,
      PopupFramework(
        title: "enter-amount".tr(),
        underTitleSpace: false,
        child: SelectAmount(
          onlyShowCurrencyIcon: true,
          amountPassed: selectedAmountCalculation ?? "",
          setSelectedAmount: setSelectedAmount,
          next: () async {
            Navigator.pop(context);
          },
          nextLabel: "set-amount".tr(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFont(
          text: "Modify Amount",
          fontSize: 16,
        ),
        SizedBox(height: 5),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TappableTextEntry(
              title: selectedOperation,
              placeholder: "+/-",
              showPlaceHolderWhenTextEquals:
                  convertToMoney(Provider.of<AllWallets>(context), 0),
              onTap: () {
                if (selectedOperation == "-") {
                  setState(() {
                    selectedOperation = "+";
                  });
                } else if (selectedOperation == "+") {
                  setState(() {
                    selectedOperation = "-";
                  });
                }
              },
              fontSize: 35,
              fontWeight: FontWeight.bold,
              internalPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 3),
            ),
            TappableTextEntry(
              title: convertToMoney(
                  Provider.of<AllWallets>(context), selectedAmount ?? 0),
              placeholder: convertToMoney(Provider.of<AllWallets>(context), 0),
              showPlaceHolderWhenTextEquals:
                  convertToMoney(Provider.of<AllWallets>(context), 0),
              onTap: () {
                selectAmount(context);
              },
              fontSize: 35,
              fontWeight: FontWeight.bold,
              internalPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 3),
            ),
            SizedBox(width: 10),
            ButtonIcon(
              onTap: () {
                setState(() {
                  selectedAmount = null;
                  selectedAmountCalculation = null;
                  selectedOperation = "+";
                });
              },
              icon: Icons.clear,
            ),
          ],
        ),
        SizedBox(height: 10),
        TextFont(
          text: "Modify Category",
          fontSize: 16,
        ),
        SizedBox(height: 20),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CategoryIcon(
              onTap: () => openBottomSheet(
                context,
                PopupFramework(
                  title: "select-category".tr(),
                  child: SelectCategory(
                    setSelectedCategory: (category) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                  ),
                ),
              ),
              margin: EdgeInsets.zero,
              canEditByLongPress: false,
              categoryPk: selectedCategory == null
                  ? "-1"
                  : selectedCategory!.categoryPk,
              category: selectedCategory,
              size: 40,
              noBackground: false,
            ),
            SizedBox(width: 10),
            ButtonIcon(
              onTap: () {
                setState(() {
                  selectedCategory = null;
                });
              },
              icon: Icons.clear,
            ),
          ],
        ),
        SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Button(
              label: "cancel".tr(),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(width: 20),
            selectedAmount == null && selectedCategory == null
                ? Button(
                    label: "Apply",
                    onTap: () {
                      openSnackbar(
                        SnackbarMessage(
                          title: "No edits to apply!",
                          icon: appStateSettings["outlinedIcons"]
                              ? Icons.warning_outlined
                              : Icons.warning_rounded,
                          timeout: Duration(milliseconds: 1300),
                        ),
                        postIfQueue: false,
                      );
                    },
                    color: getColor(context, "lightDarkAccentHeavy"),
                  )
                : Button(
                    label: "Apply",
                    onTap: () {
                      openPopup(
                        context,
                        title: "Apply Edits?",
                        description: (selectedAmount != null
                                ? selectedOperation +
                                    convertToMoney(
                                        Provider.of<AllWallets>(context),
                                        selectedAmount ?? 0) +
                                    " to selected transactions."
                                : "") +
                            (selectedAmount != null && selectedCategory != null
                                ? "\n"
                                : "") +
                            (selectedCategory != null
                                ? "Set category to " +
                                    selectedCategory!.name +
                                    "."
                                : ""),
                        icon: appStateSettings["outlinedIcons"]
                            ? Icons.edit_outlined
                            : Icons.edit_rounded,
                        onCancel: () {
                          Navigator.pop(context);
                        },
                        onCancelLabel: "cancel".tr(),
                        onSubmit: () async {
                          if (selectedAmount != null) {
                            for (String transactionID
                                in widget.transactionIDs) {
                              Transaction transaction = await database
                                  .getTransactionFromPk(transactionID);
                              Transaction transactionEdited;
                              if (selectedOperation == "+") {
                                if (transaction.income) {
                                  transactionEdited = transaction.copyWith(
                                      amount: transaction.amount +
                                          (selectedAmount ?? 0).abs());
                                } else {
                                  transactionEdited = transaction.copyWith(
                                      amount: transaction.amount -
                                          (selectedAmount ?? 0).abs());
                                }
                              } else {
                                if (transaction.income) {
                                  // Income can't go below 0
                                  if (transaction.amount -
                                          (selectedAmount ?? 0).abs() <=
                                      0) {
                                    transactionEdited =
                                        transaction.copyWith(amount: 0);
                                  } else {
                                    transactionEdited = transaction.copyWith(
                                        amount: transaction.amount -
                                            (selectedAmount ?? 0).abs());
                                  }
                                } else {
                                  // Expenses can't go above 0
                                  if (transaction.amount +
                                          (selectedAmount ?? 0).abs() >=
                                      0) {
                                    transactionEdited =
                                        transaction.copyWith(amount: 0);
                                  } else {
                                    transactionEdited = transaction.copyWith(
                                        amount: transaction.amount +
                                            (selectedAmount ?? 0).abs());
                                  }
                                }
                              }

                              await database
                                  .createOrUpdateTransaction(transactionEdited);
                            }
                          }
                          if (selectedCategory != null) {
                            for (String transactionID
                                in widget.transactionIDs) {
                              Transaction transaction = await database
                                  .getTransactionFromPk(transactionID);
                              if (transaction.sharedKey != null) {
                                await database.deleteTransaction(
                                    transaction.transactionPk);
                                Transaction transactionEdited =
                                    transaction.copyWith(
                                  categoryFk: selectedCategory!.categoryPk,
                                  sharedKey: Value(null),
                                  transactionOwnerEmail: Value(null),
                                  transactionOriginalOwnerEmail: Value(null),
                                  sharedStatus: Value(null),
                                  sharedDateUpdated: Value(null),
                                );
                                await database.createOrUpdateTransaction(
                                    transactionEdited);
                              } else {
                                Transaction transactionEdited =
                                    transaction.copyWith(
                                        categoryFk:
                                            selectedCategory!.categoryPk);
                                await database.createOrUpdateTransaction(
                                    transactionEdited);
                              }
                            }
                          }

                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        onSubmitLabel: "Apply",
                      );
                    },
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    textColor:
                        Theme.of(context).colorScheme.onTertiaryContainer,
                  )
          ],
        )
      ],
    );
  }
}
