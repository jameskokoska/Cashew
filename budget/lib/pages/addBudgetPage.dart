import 'dart:developer';

import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/sharedBudgetSettings.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/shareBudget.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/categoryEntry.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/radioItems.dart';
import 'package:budget/widgets/categoryLimits.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/selectCategory.dart';
import 'package:budget/widgets/selectColor.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:budget/colors.dart';
import 'package:math_expressions/math_expressions.dart';

class AddBudgetPage extends StatefulWidget {
  AddBudgetPage({
    Key? key,
    required this.title,
    this.budget,
  }) : super(key: key);
  final String title;

  //When a transaction is passed in, we are editing that transaction
  final Budget? budget;

  @override
  _AddBudgetPageState createState() => _AddBudgetPageState();
}

dynamic namesRecurrence = {
  "Custom": "custom",
  "Daily": "days",
  "Weekly": "weeks",
  "Monthly": "months",
  "Yearly": "years",
  BudgetReoccurence.custom: "custom",
  BudgetReoccurence.daily: "days",
  BudgetReoccurence.weekly: "weeks",
  BudgetReoccurence.monthly: "months",
  BudgetReoccurence.yearly: "years",
};

dynamic nameRecurrence = {
  "Custom": "custom",
  "Daily": "day",
  "Weekly": "week",
  "Monthly": "month",
  "Yearly": "year",
  BudgetReoccurence.custom: "custom",
  BudgetReoccurence.daily: "day",
  BudgetReoccurence.weekly: "week",
  BudgetReoccurence.monthly: "month",
  BudgetReoccurence.yearly: "year",
};

dynamic enumRecurrence = {
  "Custom": BudgetReoccurence.custom,
  "Daily": BudgetReoccurence.daily,
  "Weekly": BudgetReoccurence.weekly,
  "Monthly": BudgetReoccurence.monthly,
  "Yearly": BudgetReoccurence.yearly,
  BudgetReoccurence.custom: "Custom",
  BudgetReoccurence.daily: "Daily",
  BudgetReoccurence.weekly: "Weekly",
  BudgetReoccurence.monthly: "Monthly",
  BudgetReoccurence.yearly: "Yearly",
};

class _AddBudgetPageState extends State<AddBudgetPage> {
  bool? canAddBudget;
  int setBudgetPk = DateTime.now().millisecondsSinceEpoch;
  List<int>? selectedCategories;
  double? selectedAmount;
  String? selectedAmountCalculation;
  String? selectedTitle;
  bool selectedAllCategories = true;
  String selectedCategoriesText = "All Categories";
  int selectedPeriodLength = 1;
  DateTime selectedStartDate = DateTime.now();
  DateTime? selectedEndDate;
  Color? selectedColor;
  String selectedRecurrence = "Monthly";
  String selectedRecurrenceDisplay = "month";
  bool selectedPin = true;
  bool selectedShared = false;
  bool selectedAddedTransactionsOnly = false;
  SharedTransactionsShow selectedSharedTransactionsShow =
      SharedTransactionsShow.fromEveryone;

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
        underTitleSpace: false,
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

  Future<void> selectColor(BuildContext context) async {
    openBottomSheet(
      context,
      PopupFramework(
        title: "Select Color",
        child: SelectColor(
          selectedColor: selectedColor,
          setSelectedColor: setSelectedColor,
        ),
      ),
    );
  }

  Future<void> selectRecurrence(BuildContext context) async {
    openBottomSheet(
      context,
      PopupFramework(
        title: "Select Period",
        child: RadioItems(
          items: ["Custom", "Daily", "Weekly", "Monthly", "Yearly"],
          initial: selectedRecurrence,
          onChanged: (value) {
            if (value == "Custom") {
              selectedEndDate = null;
            }
            setState(() {
              selectedRecurrence = value;
              if (selectedPeriodLength == 1) {
                selectedRecurrenceDisplay = nameRecurrence[value];
              } else {
                selectedRecurrenceDisplay = namesRecurrence[value];
              }
            });
            Navigator.of(context).pop();
            determineBottomButton();
          },
        ),
      ),
    );
  }

  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedStartDate,
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime(DateTime.now().year + 2),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).brightness == Brightness.light
              ? ThemeData.light().copyWith(
                  primaryColor: Theme.of(context).colorScheme.primary,
                  colorScheme: ColorScheme.light(
                      primary: Theme.of(context).colorScheme.primary),
                  buttonTheme:
                      ButtonThemeData(textTheme: ButtonTextTheme.primary),
                )
              : ThemeData.dark().copyWith(
                  primaryColor: Theme.of(context).colorScheme.secondary,
                  colorScheme: ColorScheme.dark(
                      primary: Theme.of(context).colorScheme.secondary),
                  buttonTheme:
                      ButtonThemeData(textTheme: ButtonTextTheme.primary),
                ),
          child: child ?? Container(),
        );
      },
    );
    setSelectedStartDate(picked);
  }

  setSelectedStartDate(DateTime? date) {
    if (date != null && date != selectedStartDate) {
      setState(() {
        selectedStartDate = date;
      });
    }
    determineBottomButton();
  }

  setSelectedShared(bool shared) {
    setState(() {
      selectedShared = shared;
      selectedAddedTransactionsOnly = true;
      selectedSharedTransactionsShow = SharedTransactionsShow.fromEveryone;
    });
  }

  setAddedTransactionsOnly(bool addedOnly) {
    setState(() {
      selectedAddedTransactionsOnly = addedOnly;
      if (selectedShared && !addedOnly) {
        selectedShared = false;
      }
      if (addedOnly) {
        selectedSharedTransactionsShow = SharedTransactionsShow.fromEveryone;
      }
    });
  }

  Future<void> selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime(DateTime.now().year + 2),
      initialDateRange: DateTimeRange(
        start: selectedStartDate,
        end: selectedEndDate ??
            DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day, DateTime.now().hour + 5),
      ),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).brightness == Brightness.light
              ? ThemeData.light().copyWith(
                  primaryColor: Theme.of(context).colorScheme.primary,
                  colorScheme: ColorScheme.light(
                      primary: Theme.of(context).colorScheme.primary),
                  buttonTheme:
                      ButtonThemeData(textTheme: ButtonTextTheme.primary),
                )
              : ThemeData.dark().copyWith(
                  primaryColor: Theme.of(context).colorScheme.secondary,
                  colorScheme: ColorScheme.dark(
                      primary: Theme.of(context).colorScheme.secondary),
                  buttonTheme:
                      ButtonThemeData(textTheme: ButtonTextTheme.primary),
                ),
          child: child ?? Container(),
        );
      },
    );
    if (picked != null) {
      determineBottomButton();
      setState(() {
        selectedStartDate = picked.start;
        selectedEndDate = picked.end;
      });
    }
  }

  Future<void> selectPeriodLength(BuildContext context) async {
    openBottomSheet(
      context,
      PopupFramework(
        title: "Enter Period Length",
        child: SelectAmountValue(
          amountPassed: selectedPeriodLength.toString(),
          setSelectedAmount: (amount, _) {
            setSelectedPeriodLength(amount);
          },
          next: () async {
            Navigator.pop(context);
          },
          nextLabel: "Set Amount",
        ),
      ),
    );
  }

  void setSelectedCategories(List<int> categories) {
    if (categories.length <= 0) {
      setState(() {
        selectedCategories = categories;
        selectedAllCategories = true;
      });
      setState(() {
        selectedCategoriesText = "All Categories";
      });
    } else {
      setState(() {
        selectedCategories = categories;
        selectedAllCategories = false;
      });
      if (categories.length == 1) {
        setState(() {
          selectedCategoriesText =
              categories.length.toString() + " " + "Category";
        });
      } else {
        setState(() {
          selectedCategoriesText =
              categories.length.toString() + " " + "Categories";
        });
      }
    }
    determineBottomButton();
    return;
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

  void setSelectedPin() {
    setState(() {
      selectedPin = !selectedPin;
    });
    determineBottomButton();
    return;
  }

  void setSelectedSharedTransactionsShow() {
    if (selectedSharedTransactionsShow ==
        SharedTransactionsShow.excludeOtherIfNotShared)
      setState(() {
        selectedSharedTransactionsShow = SharedTransactionsShow.onlyIfOwner;
      });
    else if (selectedSharedTransactionsShow ==
        SharedTransactionsShow.onlyIfOwner)
      setState(() {
        selectedSharedTransactionsShow =
            SharedTransactionsShow.onlyIfOwnerIfShared;
      });
    else if (selectedSharedTransactionsShow ==
        SharedTransactionsShow.onlyIfOwnerIfShared)
      setState(() {
        selectedSharedTransactionsShow = SharedTransactionsShow.fromEveryone;
      });
    else if (selectedSharedTransactionsShow ==
        SharedTransactionsShow.fromEveryone)
      setState(() {
        selectedSharedTransactionsShow = SharedTransactionsShow.onlyIfShared;
      });
    else if (selectedSharedTransactionsShow ==
        SharedTransactionsShow.onlyIfShared)
      setState(() {
        selectedSharedTransactionsShow = SharedTransactionsShow.onlyIfNotShared;
      });
    else if (selectedSharedTransactionsShow ==
        SharedTransactionsShow.onlyIfNotShared)
      setState(() {
        selectedSharedTransactionsShow = SharedTransactionsShow.excludeOther;
      });
    else if (selectedSharedTransactionsShow ==
        SharedTransactionsShow.excludeOther)
      setState(() {
        selectedSharedTransactionsShow =
            SharedTransactionsShow.excludeOtherIfShared;
      });
    else if (selectedSharedTransactionsShow ==
        SharedTransactionsShow.excludeOtherIfShared)
      setState(() {
        selectedSharedTransactionsShow =
            SharedTransactionsShow.excludeOtherIfNotShared;
      });

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

  void setSelectedPeriodLength(double period) {
    try {
      setState(() {
        selectedPeriodLength = period.toInt();
        if (selectedPeriodLength == 1) {
          selectedRecurrenceDisplay = nameRecurrence[selectedRecurrence];
        } else {
          selectedRecurrenceDisplay = namesRecurrence[selectedRecurrence];
        }
      });
    } catch (e) {
      setState(() {
        selectedPeriodLength = 0;
        if (selectedPeriodLength == 1) {
          selectedRecurrenceDisplay = nameRecurrence[selectedRecurrence];
        } else {
          selectedRecurrenceDisplay = namesRecurrence[selectedRecurrence];
        }
      });
    }
    determineBottomButton();
    return;
  }

  void setSelectedColor(Color? color) {
    setState(() {
      selectedColor = color;
    });
    determineBottomButton();
    return;
  }

  Future addBudget() async {
    loadingIndeterminateKey.currentState!.setVisibility(true);
    Budget createdBudget = await createBudget();
    print("Added budget");
    int result = await database.createOrUpdateBudget(createdBudget);
    if (selectedShared == true && widget.budget == null) {
      openLoadingPopup(context);
      bool result2 = await shareBudget(createdBudget, context);
      Navigator.pop(context);
      if (result2 == false) {
        Future.delayed(Duration.zero, () {
          openPopup(
            context,
            title: "No Connection",
            icon: Icons.signal_wifi_connected_no_internet_4_rounded,
            description:
                "You can only update the details of a shared budget online.",
            onSubmit: () {
              Navigator.pop(context);
            },
            onSubmitLabel: "OK",
          );
        });
        loadingIndeterminateKey.currentState!.setVisibility(false);
        return;
      }
    }
    loadingIndeterminateKey.currentState!.setVisibility(false);
    if (result == -1) {
      openPopup(
        context,
        title: "No Connection",
        icon: Icons.signal_wifi_connected_no_internet_4_rounded,
        description:
            "You can only update the details of a shared category online.",
        onCancel: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
        onSubmit: () {
          Navigator.pop(context);
        },
        onSubmitLabel: "OK",
        onCancelLabel: "Exit Without Saving",
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<Budget> createBudget() async {
    Budget? currentInstance;
    if (widget.budget != null) {
      currentInstance =
          await database.getBudgetInstance(widget.budget!.budgetPk);
    }
    return await Budget(
      budgetPk: widget.budget != null ? widget.budget!.budgetPk : setBudgetPk,
      name: selectedTitle ?? "",
      amount: selectedAmount ?? 0,
      colour: toHexString(selectedColor),
      startDate: selectedStartDate,
      endDate: selectedEndDate ?? DateTime.now(),
      categoryFks: selectedCategories,
      allCategoryFks: selectedAllCategories,
      addedTransactionsOnly: selectedAddedTransactionsOnly,
      // TODO make this work excludeAddedTransactions
      periodLength: selectedPeriodLength,
      reoccurrence: mapRecurrence(selectedRecurrence),
      dateCreated:
          widget.budget != null ? widget.budget!.dateCreated : DateTime.now(),
      order: widget.budget != null
          ? widget.budget!.order
          : await database.getAmountOfBudgets(),
      walletFk: 0,
      pinned: selectedPin,
      sharedTransactionsShow: selectedSharedTransactionsShow,
      sharedKey: widget.budget != null ? currentInstance!.sharedKey : null,
      sharedOwnerMember:
          widget.budget != null ? currentInstance!.sharedOwnerMember : null,
      sharedDateUpdated:
          widget.budget != null ? currentInstance!.sharedDateUpdated : null,
      sharedMembers:
          widget.budget != null ? currentInstance!.sharedMembers : null,
      sharedAllMembersEver:
          widget.budget != null ? currentInstance!.sharedAllMembersEver : null,
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      //We are editing a budget
      //Fill in the information from the passed in budget
      selectedTitle = widget.budget!.name;
      selectedPin = widget.budget!.pinned;
      selectedSharedTransactionsShow = widget.budget!.sharedTransactionsShow;
      selectedAllCategories = widget.budget!.allCategoryFks;
      selectedAmount = widget.budget!.amount;
      selectedAddedTransactionsOnly = widget.budget!.addedTransactionsOnly;
      selectedPeriodLength = widget.budget!.periodLength;
      selectedRecurrence = enumRecurrence[widget.budget!.reoccurrence];
      if (selectedPeriodLength == 1) {
        selectedRecurrenceDisplay = nameRecurrence[selectedRecurrence];
      } else {
        selectedRecurrenceDisplay = namesRecurrence[selectedRecurrence];
      }
      selectedStartDate = widget.budget!.startDate;
      selectedEndDate = widget.budget!.endDate;
      selectedColor = widget.budget!.colour == null
          ? null
          : HexColor(widget.budget!.colour);

      var amountString = widget.budget!.amount.toStringAsFixed(2);
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
    if (widget.budget != null && widget.budget!.categoryFks != null) {
      setSelectedCategories(widget.budget!.categoryFks!);
    }
    //Set to false because we can't save until we made some changes
    setState(() {
      canAddBudget = false;
    });
  }

  determineBottomButton() {
    if (selectedTitle != null &&
        (selectedAmount ?? 0) >= 0 &&
        selectedAmount != null &&
        selectedStartDate != null &&
        ((selectedRecurrence == "Custom" && selectedEndDate != null) ||
            (selectedRecurrence != "Custom" && selectedPeriodLength != 0))) {
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

  discardChangesPopupIfBudgetPassed() async {
    Budget? currentInstance;
    if (widget.budget != null) {
      currentInstance =
          await database.getBudgetInstance(widget.budget!.budgetPk);
    }
    discardChangesPopup(
      context,
      previousObject: widget.budget!.copyWith(
          sharedKey: Value(currentInstance!.sharedKey),
          sharedOwnerMember: Value(currentInstance.sharedOwnerMember),
          sharedDateUpdated: Value(currentInstance.sharedDateUpdated),
          sharedMembers: Value(currentInstance.sharedMembers),
          sharedAllMembersEver: Value(currentInstance.sharedAllMembersEver)),
      currentObject: await createBudget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.budget != null) {
          discardChangesPopupIfBudgetPassed();
        } else {
          // remove budget category limits created for a budget that has not been made yet
          discardChangesPopup(context, onDiscard: () {
            database.deleteCategoryBudgetLimitsInBudget(setBudgetPk);
          });
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
                syncKeyboardHeight: true,
                dragDownToDismiss: true,
                title: widget.title,
                navbar: false,
                onBackButton: () async {
                  if (widget.budget != null) {
                    discardChangesPopupIfBudgetPassed();
                  } else {
                    discardChangesPopup(context, onDiscard: () {
                      database.deleteCategoryBudgetLimitsInBudget(setBudgetPk);
                    });
                  }
                },
                onDragDownToDissmiss: () async {
                  if (widget.budget != null) {
                    discardChangesPopupIfBudgetPassed();
                  } else {
                    discardChangesPopup(context, onDiscard: () {
                      database.deleteCategoryBudgetLimitsInBudget(setBudgetPk);
                    });
                  }
                },
                actions: [
                  widget.budget != null
                      ? Container(
                          padding: EdgeInsets.only(top: 12.5, right: 5),
                          child: IconButton(
                            onPressed: () {
                              deleteBudgetPopup(context, widget.budget!,
                                  afterDelete: () {
                                Navigator.pop(context);
                              });
                            },
                            icon: Icon(Icons.delete_rounded),
                          ),
                        )
                      : SizedBox.shrink(),
                ],
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
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
                      alignment: WrapAlignment.center,
                      children: [
                        IntrinsicWidth(
                          child: TappableTextEntry(
                            title: convertToMoney(selectedAmount ?? 0),
                            placeholder: convertToMoney(0),
                            showPlaceHolderWhenTextEquals: convertToMoney(0),
                            onTap: () {
                              selectAmount(context);
                            },
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            internalPadding: EdgeInsets.symmetric(
                                vertical: 2, horizontal: 4),
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 3),
                          ),
                        ),
                        IntrinsicWidth(
                          child: Row(
                            children: [
                              selectedRecurrence != "Custom"
                                  ?
                                  // TextFont(
                                  //     text: " /",
                                  //     fontSize: 25,
                                  //     fontWeight: FontWeight.bold,
                                  //   )
                                  // Disable the custom period length for now...
                                  TappableTextEntry(
                                      title: "/ " +
                                          selectedPeriodLength.toString(),
                                      placeholder: "/ 0",
                                      showPlaceHolderWhenTextEquals: "/ 0",
                                      onTap: () {
                                        selectPeriodLength(context);
                                      },
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      internalPadding: EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 4),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 3),
                                    )
                                  : TextFont(
                                      text: " /",
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                              TappableTextEntry(
                                title: selectedRecurrenceDisplay,
                                placeholder: "",
                                onTap: () {
                                  selectRecurrence(context);
                                },
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                internalPadding: EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 4),
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(
                        0,
                        selectedEndDate == null &&
                                selectedRecurrence == "Custom"
                            ? 0
                            : -5),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: selectedRecurrence != "Custom"
                            ? Tappable(
                                onTap: () {
                                  selectStartDate(context);
                                },
                                color: Colors.transparent,
                                borderRadius: 15,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 8),
                                  child: Center(
                                    child: Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.end,
                                      runAlignment: WrapAlignment.center,
                                      alignment: WrapAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 5.8),
                                          child: TextFont(
                                            text: "beginning ",
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IgnorePointer(
                                          child: TappableTextEntry(
                                            title: getWordedDate(
                                                selectedStartDate),
                                            placeholder: "",
                                            onTap: () {
                                              selectAmount(context);
                                            },
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                            internalPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 2, horizontal: 4),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 0, horizontal: 5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Tappable(
                                onTap: () {
                                  selectDateRange(context);
                                },
                                color: Colors.transparent,
                                borderRadius: 15,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 8),
                                  child: Center(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IgnorePointer(
                                          child: TappableTextEntry(
                                            title: selectedEndDate == null
                                                ? null
                                                : getWordedDateShort(
                                                        selectedStartDate) +
                                                    " - " +
                                                    getWordedDateShort(
                                                        selectedEndDate!),
                                            placeholder: "Select Custom Period",
                                            onTap: () {},
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                            internalPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 2, horizontal: 4),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 0, horizontal: 5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                  ),
                  SizedBox(height: 17),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFont(
                      text: "Select Color",
                      textColor: Theme.of(context).colorScheme.textLight,
                      fontSize: 16,
                    ),
                  ),
                  Container(height: 10),
                  Container(
                    height: 65,
                    child: SelectColor(
                      horizontalList: true,
                      selectedColor: selectedColor,
                      setSelectedColor: setSelectedColor,
                    ),
                  ),
                  Container(height: 17),
                  widget.budget != null && widget.budget!.sharedKey != null
                      ? SharedBudgetSettings(
                          budget: widget.budget!,
                        )
                      : widget.budget == null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: TextFont(
                                    text: "Share Group Budget",
                                    textColor:
                                        Theme.of(context).colorScheme.textLight,
                                    fontSize: 16,
                                  ),
                                ),
                                Container(height: 2),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Tappable(
                                    onTap: () {
                                      setSelectedShared(!selectedShared);
                                    },
                                    borderRadius: 10,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 6),
                                      child: Row(
                                        children: [
                                          ButtonIcon(
                                            onTap: () {
                                              setSelectedShared(
                                                  !selectedShared);
                                            },
                                            icon: selectedPin
                                                ? Icons.share_rounded
                                                : Icons.share_rounded,
                                            size: 41,
                                          ),
                                          SizedBox(width: 15),
                                          Expanded(
                                            child: TextFont(
                                              text: selectedShared == false
                                                  ? "Personal"
                                                  : "Shared",
                                              fontWeight: FontWeight.bold,
                                              fontSize: 26,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(height: 10),
                              ],
                            )
                          : SizedBox.shrink(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextFont(
                          text: "Pin to Homepage",
                          textColor: Theme.of(context).colorScheme.textLight,
                          fontSize: 16,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Tappable(
                      onTap: () {
                        setSelectedPin();
                      },
                      borderRadius: 10,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 6),
                        child: Row(
                          children: [
                            ButtonIcon(
                              onTap: () {
                                setSelectedPin();
                              },
                              icon: selectedPin
                                  ? Icons.push_pin_rounded
                                  : Icons.push_pin_outlined,
                              size: 41,
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: TextFont(
                                text:
                                    selectedPin == true ? "Pinned" : "Unpinned",
                                fontWeight: FontWeight.bold,
                                fontSize: 26,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 13),
                  (widget.budget != null &&
                              widget.budget!.sharedKey == null &&
                              widget.budget!.addedTransactionsOnly == false) ||
                          widget.budget == null
                      ? AnimatedOpacity(
                          duration: Duration(milliseconds: 250),
                          opacity: selectedShared == true ||
                                  selectedAddedTransactionsOnly
                              ? 0.2
                              : 1,
                          child: IgnorePointer(
                            ignoring: selectedShared == true ||
                                selectedAddedTransactionsOnly,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextFont(
                                        text:
                                            "Transactions To Include From Other Budgets",
                                        textColor: Theme.of(context)
                                            .colorScheme
                                            .textLight,
                                        fontSize: 16,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Tappable(
                                    onTap: () {
                                      setSelectedSharedTransactionsShow();
                                    },
                                    borderRadius: 10,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 6),
                                      child: Row(
                                        children: [
                                          ButtonIcon(
                                            onTap: () {
                                              setSelectedSharedTransactionsShow();
                                            },
                                            icon: Icons.import_export_rounded,
                                            size: 41,
                                          ),
                                          SizedBox(width: 15),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 4,
                                              ),
                                              child: TextFont(
                                                autoSizeText: true,
                                                maxLines: 1,
                                                text: selectedSharedTransactionsShow ==
                                                        SharedTransactionsShow
                                                            .fromEveryone
                                                    ? "All"
                                                    : selectedSharedTransactionsShow ==
                                                            SharedTransactionsShow
                                                                .onlyIfOwner
                                                        ? "From Me"
                                                        : selectedSharedTransactionsShow ==
                                                                SharedTransactionsShow
                                                                    .onlyIfShared
                                                            ? "All If Shared"
                                                            : selectedSharedTransactionsShow ==
                                                                    SharedTransactionsShow
                                                                        .onlyIfNotShared
                                                                ? "All If Not Shared"
                                                                : selectedSharedTransactionsShow ==
                                                                        SharedTransactionsShow
                                                                            .onlyIfOwnerIfShared
                                                                    ? "From Me If Shared"
                                                                    : selectedSharedTransactionsShow ==
                                                                            SharedTransactionsShow
                                                                                .excludeOther
                                                                        ? "Exclude Others"
                                                                        : selectedSharedTransactionsShow ==
                                                                                SharedTransactionsShow.excludeOtherIfNotShared
                                                                            ? "Exclude If Not Shared"
                                                                            : selectedSharedTransactionsShow == SharedTransactionsShow.excludeOtherIfShared
                                                                                ? "Exclude If Shared"
                                                                                : "",
                                                fontWeight: FontWeight.bold,
                                                fontSize: 26,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                  SizedBox(height: 13),
                  (widget.budget != null &&
                              widget.budget!.sharedKey == null &&
                              widget.budget!.addedTransactionsOnly == true) ||
                          widget.budget == null
                      ? AnimatedOpacity(
                          duration: Duration(milliseconds: 250),
                          opacity: selectedShared == true ||
                                  (widget.budget != null &&
                                      widget.budget!.addedTransactionsOnly ==
                                          true)
                              ? 0.2
                              : 1,
                          child: IgnorePointer(
                            ignoring: selectedShared == true ||
                                (widget.budget != null &&
                                    widget.budget!.addedTransactionsOnly ==
                                        true),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: TextFont(
                                    text: "Added transactions only",
                                    textColor:
                                        Theme.of(context).colorScheme.textLight,
                                    fontSize: 16,
                                  ),
                                ),
                                Container(height: 2),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Tappable(
                                    onTap: () {
                                      setAddedTransactionsOnly(
                                          !selectedAddedTransactionsOnly);
                                    },
                                    borderRadius: 10,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 6),
                                      child: Row(
                                        children: [
                                          ButtonIcon(
                                            onTap: () {
                                              setAddedTransactionsOnly(
                                                  !selectedAddedTransactionsOnly);
                                            },
                                            icon: Icons.select_all,
                                            size: 41,
                                          ),
                                          SizedBox(width: 15),
                                          Expanded(
                                            child: TextFont(
                                              text:
                                                  selectedAddedTransactionsOnly ==
                                                          false
                                                      ? "All"
                                                      : "Added Only",
                                              fontWeight: FontWeight.bold,
                                              fontSize: 26,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(height: 10),
                              ],
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                  (widget.budget != null &&
                              widget.budget!.sharedKey == null &&
                              widget.budget!.addedTransactionsOnly == false) ||
                          widget.budget == null
                      ? AnimatedOpacity(
                          duration: Duration(milliseconds: 250),
                          opacity: selectedShared == true ||
                                  selectedAddedTransactionsOnly
                              ? 0.2
                              : 1,
                          child: IgnorePointer(
                            ignoring: selectedShared == true ||
                                selectedAddedTransactionsOnly,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: TextFont(
                                    text: "Select Categories",
                                    textColor:
                                        Theme.of(context).colorScheme.textLight,
                                    fontSize: 16,
                                  ),
                                ),
                                Container(height: 2),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: TextFont(
                                    text: selectedCategoriesText + " Budget",
                                    textColor: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(height: 10),
                                Container(
                                  height: 100,
                                  child: SelectCategory(
                                    horizontalList: true,
                                    selectedCategories: selectedCategories,
                                    setSelectedCategories:
                                        setSelectedCategories,
                                    showSelectedAllCategoriesIfNoneSelected:
                                        true,
                                  ),
                                ),
                                Container(height: 13),
                              ],
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextFont(
                          text: "Category Spending Goals",
                          textColor: Theme.of(context).colorScheme.textLight,
                          fontSize: 16,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  CategoryLimits(
                    selectedCategories: selectedCategories ?? [],
                    budgetPk: widget.budget == null
                        ? setBudgetPk
                        : widget.budget!.budgetPk,
                    budgetLimit: selectedAmount ?? 1,
                  ),
                  Container(height: 70),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: canAddBudget ?? false
                    ? Button(
                        label: widget.budget == null
                            ? "Add Budget"
                            : "Save Changes",
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        onTap: () {
                          addBudget();
                        },
                        hasBottomExtraSafeArea: true,
                      )
                    : Button(
                        label: widget.budget == null
                            ? "Add Budget"
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
                    color: appStateSettings["materialYou"]
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                        : Theme.of(context).colorScheme.lightDarkAccentHeavy)),
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
