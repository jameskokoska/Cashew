import 'dart:developer';

import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/categoryEntry.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/radioItems.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/selectCategory.dart';
import 'package:budget/widgets/selectColor.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:budget/colors.dart';
import 'package:math_expressions/math_expressions.dart';

class AddBillSplitterTransaction extends StatefulWidget {
  AddBillSplitterTransaction({
    Key? key,
    required this.title,
    this.billSplitterTransaction,
  }) : super(key: key);
  final String title;

  //When a transaction is passed in, we are editing that transaction
  final BillSplitterTransaction? billSplitterTransaction;

  @override
  _AddBillSplitterTransactionState createState() =>
      _AddBillSplitterTransactionState();
}

class _AddBillSplitterTransactionState
    extends State<AddBillSplitterTransaction> {
  bool? canAddBudget;

  double? selectedAmount;
  String? selectedAmountCalculation;
  String? selectedTitle;

  Future<void> selectTitle() async {
    openBottomSheet(
      context,
      PopupFramework(
        title: "Enter Name",
        child: SelectText(
          setSelectedText: setSelectedTitle,
          labelText: "Name",
          selectedText: selectedTitle,
        ),
      ),
      snap: false,
    );
  }

  Future<void> selectAmount(BuildContext context) async {
    openBottomSheet(
      context,
      PopupFramework(
        title: "Enter Amount",
        child: SelectAmount(
          amountPassed: selectedAmountCalculation ?? "",
          setSelectedAmount: setSelectedAmount,
          next: () async {
            Navigator.pop(context);
          },
          nextLabel: "Set Amount",
        ),
      ),
    );
  }

  void setSelectedAmount(double amount, String amountCalculation) {
    if (amount == selectedAmount) {
      selectedAmountCalculation = amountCalculation;
    } else {
      setState(() {
        selectedAmount = amount;
        selectedAmountCalculation = amountCalculation;
      });
    }
    determineBottomButton();
    return;
  }

  void setSelectedTitle(String title) {
    setState(() {
      selectedTitle = title;
    });
    determineBottomButton();
    return;
  }

  // Future addBudget() async {
  //   print("Added budget");
  //   await database.createOrUpdateBudget(await createBudget());
  //   print(await database.getAmountOfBudgets());
  //   Navigator.pop(context);
  // }

  // Future<Budget> createBudget() async {
  //   List<int> categoryFks = [];
  //   for (TransactionCategory category in selectedCategories ?? []) {
  //     categoryFks.add(category.categoryPk);
  //   }
  //   return await Budget(
  //     budgetPk: widget.budget != null
  //         ? widget.budget!.budgetPk
  //         : DateTime.now().millisecondsSinceEpoch,
  //     name: selectedTitle ?? "",
  //     amount: selectedAmount ?? 0,
  //     colour: toHexString(selectedColor),
  //     startDate: selectedStartDate,
  //     endDate: selectedEndDate ?? DateTime.now(),
  //     categoryFks: categoryFks,
  //     allCategoryFks: selectedAllCategories,
  //     periodLength: selectedPeriodLength,
  //     reoccurrence: mapRecurrence(selectedRecurrence),
  //     dateCreated:
  //         widget.budget != null ? widget.budget!.dateCreated : DateTime.now(),
  //     pinned: true,
  //     order: widget.budget != null
  //         ? widget.budget!.order
  //         : await database.getAmountOfBudgets(),
  //     walletFk: 0,
  //   );
  // }

  @override
  void initState() {
    super.initState();
    if (widget.billSplitterTransaction != null) {
      //We are editing a budget
      //Fill in the information from the passed in budget
      selectedTitle = widget.billSplitterTransaction!.name;

      selectedAmount = widget.billSplitterTransaction!.cost;
      var amountString =
          widget.billSplitterTransaction!.cost.toStringAsFixed(2);
      if (amountString.substring(amountString.length - 2) == "00") {
        selectedAmountCalculation =
            amountString.substring(0, amountString.length - 3);
      } else {
        selectedAmountCalculation = amountString;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        updateInitial();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  updateInitial() async {
    //Set to false because we can't save until we made some changes
    setState(() {
      canAddBudget = false;
    });
  }

  determineBottomButton() {
    if (selectedTitle != null &&
        (selectedAmount ?? 0) >= 0 &&
        selectedAmount != null) {
      if (canAddBudget != true) {
        this.setState(() {
          canAddBudget = true;
        });
        return true;
      }
    } else {
      if (canAddBudget != false) {
        this.setState(() {
          canAddBudget = false;
        });
        return false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.billSplitterTransaction != null) {
          discardChangesPopup(
            context,
            previousObject: widget.billSplitterTransaction,
            currentObject: "await createBudget()",
          );
        } else {
          discardChangesPopup(context);
        }
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          onTap: () {
            //Minimize keyboard when tap non interactive widget
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Stack(
            children: [
              PageFramework(
                title: widget.title,
                navbar: false,
                onBackButton: () async {
                  if (widget.billSplitterTransaction != null) {
                    discardChangesPopup(
                      context,
                      previousObject: widget.billSplitterTransaction,
                      currentObject: "await createBudget()",
                    );
                  } else {
                    discardChangesPopup(context);
                  }
                },
                onDragDownToDissmiss: () async {
                  if (widget.billSplitterTransaction != null) {
                    discardChangesPopup(
                      context,
                      previousObject: widget.billSplitterTransaction,
                      currentObject: "await createBudget()",
                    );
                  } else {
                    discardChangesPopup(context);
                  }
                },
                listWidgets: [
                  Container(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: kIsWeb
                        ? TextInput(
                            labelText: "Name",
                            bubbly: false,
                            initialValue: selectedTitle,
                            onChanged: (text) {
                              setSelectedTitle(text);
                            },
                            padding: EdgeInsets.only(left: 7, right: 7),
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            topContentPadding: 20,
                          )
                        : TappableTextEntry(
                            title: selectedTitle,
                            placeholder: "Name",
                            onTap: () {
                              selectTitle();
                            },
                            autoSizeText: true,
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                          ),
                  ),
                  TappableTextEntry(
                    title: convertToMoney(selectedAmount ?? 0),
                    placeholder: convertToMoney(0),
                    showPlaceHolderWhenTextEquals: convertToMoney(0),
                    onTap: () {
                      selectAmount(context);
                    },
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    internalPadding:
                        EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 3),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: canAddBudget ?? false
                        ? Button(
                            label: widget.billSplitterTransaction == null
                                ? "Add Budget"
                                : "Save Changes",
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            onTap: () {
                              // addBudget();
                            },
                            hasBottomExtraSafeArea: true,
                          )
                        : Button(
                            label: widget.billSplitterTransaction == null
                                ? "Add Transaction"
                                : "Save Changes",
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            onTap: () {},
                            color: Colors.grey,
                            hasBottomExtraSafeArea: true,
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TappableTextEntry extends StatelessWidget {
  const TappableTextEntry({
    Key? key,
    required this.title,
    required this.placeholder,
    required this.onTap,
    this.fontSize,
    this.fontWeight,
    this.padding = const EdgeInsets.symmetric(vertical: 0),
    this.internalPadding =
        const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
    this.autoSizeText = false,
    this.showPlaceHolderWhenTextEquals,
  }) : super(key: key);

  final String? title;
  final String placeholder;
  final VoidCallback onTap;
  final EdgeInsets padding;
  final EdgeInsets internalPadding;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool autoSizeText;
  final String? showPlaceHolderWhenTextEquals;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      color: Colors.transparent,
      borderRadius: 15,
      child: Padding(
        padding: padding,
        child: Container(
          padding: internalPadding,
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    width: 1.5,
                    color: Theme.of(context).colorScheme.lightDarkAccentHeavy)),
          ),
          child: IntrinsicWidth(
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextFont(
                autoSizeText: autoSizeText,
                maxLines: 1,
                minFontSize: 16,
                textAlign: TextAlign.left,
                fontSize: fontSize ?? 35,
                fontWeight: fontWeight ?? FontWeight.bold,
                text: title == null ||
                        title == "" ||
                        title == showPlaceHolderWhenTextEquals
                    ? placeholder
                    : title ?? "",
                textColor: title == null ||
                        title == "" ||
                        title == showPlaceHolderWhenTextEquals
                    ? Theme.of(context).colorScheme.textLight
                    : Theme.of(context).colorScheme.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
