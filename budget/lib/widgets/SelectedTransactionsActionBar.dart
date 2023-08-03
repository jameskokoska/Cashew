import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/globalSnackBar.dart';
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

class SelectedTransactionsActionBar extends StatelessWidget {
  const SelectedTransactionsActionBar({Key? key, required this.pageID})
      : super(key: key);

  final String pageID;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: globalSelectedID,
      builder: (context, value, widget) {
        List<int> listOfIDs = (value)[pageID] ?? [];
        bool animateIn = (value)[pageID] != null && (value)[pageID]!.length > 0;
        return AnimatedPositioned(
          left: 0,
          right: 0,
          duration: Duration(milliseconds: 500),
          top: animateIn ? 0 : -(MediaQuery.of(context).padding.top + 80),
          curve: Curves.easeInOutCubic,
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Container(
                  padding:
                      EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  decoration: BoxDecoration(
                    // borderRadius: BorderRadius.only(
                    //   bottomLeft: Radius.circular(
                    //       getIsFullScreen(context) ? 20 : 10),
                    //   bottomRight: Radius.circular(
                    //       getIsFullScreen(context) ? 20 : 10),
                    // ),
                    boxShadow: boxShadowCheck(boxShadowSharp(context)),
                    color: Theme.of(context).colorScheme.secondaryContainer,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            IconButton(
                              padding: EdgeInsets.all(15),
                              color: Theme.of(context).colorScheme.secondary,
                              icon: Icon(
                                Icons.arrow_back_rounded,
                                color: Theme.of(context).colorScheme.secondary,
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
                                    dynamicDecimals: true,
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
                                            offset: Offset(5, 0),
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
                                                    showCurrency: false,
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
                      Row(
                        children: [
                          appStateSettings["massEditSelectedTransactions"] ==
                                  false
                              ? SizedBox.shrink()
                              : IconButton(
                                  padding: EdgeInsets.all(15),
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  icon: Icon(
                                    Icons.edit,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
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
                          IconButton(
                            padding: EdgeInsets.all(15),
                            color: Theme.of(context).colorScheme.secondary,
                            icon: Icon(
                              Icons.delete,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            onPressed: () {
                              openPopup(
                                context,
                                title: "delete-selected-transactions".tr(),
                                description:
                                    "delete-selected-transactions-description"
                                            .tr() +
                                        (value)[pageID]!.length.toString() +
                                        " " +
                                        ((value)[pageID]!.length == 1
                                            ? "transaction".tr().toLowerCase()
                                            : "transactions"
                                                .tr()
                                                .toLowerCase()) +
                                        "?",
                                icon: Icons.delete_rounded,
                                onCancel: () {
                                  Navigator.pop(context);
                                },
                                onCancelLabel: "cancel".tr(),
                                onSubmit: () async {
                                  await database
                                      .deleteTransactions(value[pageID]!);
                                  openSnackbar(
                                    SnackbarMessage(
                                      title: "deleted".tr() +
                                          " " +
                                          value[pageID]!.length.toString() +
                                          " " +
                                          ((value)[pageID]!.length == 1
                                              ? "transaction".tr().toLowerCase()
                                              : "transactions"
                                                  .tr()
                                                  .toLowerCase()),
                                      icon: Icons.delete_rounded,
                                    ),
                                  );
                                  globalSelectedID.value[pageID] = [];
                                  globalSelectedID.notifyListeners();
                                  Navigator.pop(context);
                                },
                                onSubmitLabel: "delete".tr(),
                              );
                            },
                          ),
                        ],
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

class EditSelectedTransactions extends StatefulWidget {
  const EditSelectedTransactions({super.key, required this.transactionIDs});
  final List<int> transactionIDs;

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
              categoryPk:
                  selectedCategory == null ? -1 : selectedCategory!.categoryPk,
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
                          icon: Icons.warning_rounded,
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
                        icon: Icons.edit_rounded,
                        onCancel: () {
                          Navigator.pop(context);
                        },
                        onCancelLabel: "cancel".tr(),
                        onSubmit: () async {
                          if (selectedAmount != null) {
                            for (int transactionID in widget.transactionIDs) {
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
                            for (int transactionID in widget.transactionIDs) {
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
