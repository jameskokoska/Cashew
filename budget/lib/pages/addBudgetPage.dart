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
import 'package:budget/struct/transactionCategory.dart';
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

  List<TransactionCategory>? selectedCategories;
  double? selectedAmount;
  String? selectedAmountCalculation;
  String? selectedTitle;
  bool selectedAllCategories = true;
  String selectedCategoriesText = "All Categories";
  int selectedPeriodLength = 0;
  DateTime selectedStartDate = DateTime.now();
  DateTime? selectedEndDate;
  Color? selectedColor;
  String selectedRecurrence = "Monthly";
  String selectedRecurrenceDisplay = "months";

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

  Future<void> selectCategories(BuildContext context) async {
    openBottomSheet(
      context,
      PopupFramework(
        title: "Select Categories",
        child: SelectCategory(
          selectedCategories: selectedCategories,
          setSelectedCategories: setSelectedCategories,
          nextLabel: "Set Categories",
          next: () {
            Navigator.pop(context);
            setSelectedCategories(selectedCategories ?? []);
          },
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

  void setSelectedCategories(List<TransactionCategory> categories) {
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

  void setSelectedColor(Color color) {
    setState(() {
      selectedColor = color;
    });
    determineBottomButton();
    return;
  }

  Future addBudget() async {
    print("Added budget");
    await database.createOrUpdateBudget(await createBudget());
    print(await database.getAmountOfBudgets());
    Navigator.pop(context);
  }

  Future<Budget> createBudget() async {
    List<int> categoryFks = [];
    for (TransactionCategory category in selectedCategories ?? []) {
      categoryFks.add(category.categoryPk);
    }
    return await Budget(
      budgetPk: widget.budget != null
          ? widget.budget!.budgetPk
          : DateTime.now().millisecondsSinceEpoch,
      name: selectedTitle ?? "",
      amount: selectedAmount ?? 0,
      colour: toHexString(selectedColor ?? Colors.green),
      startDate: selectedStartDate,
      endDate: selectedEndDate ?? DateTime.now(),
      categoryFks: categoryFks,
      allCategoryFks: selectedAllCategories,
      periodLength: selectedPeriodLength,
      reoccurrence: mapRecurrence(selectedRecurrence),
      dateCreated:
          widget.budget != null ? widget.budget!.dateCreated : DateTime.now(),
      pinned: true,
      order: widget.budget != null
          ? widget.budget!.order
          : await database.getAmountOfBudgets(),
      walletFk: 0,
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      //We are editing a budget
      //Fill in the information from the passed in budget
      selectedTitle = widget.budget!.name;

      selectedAllCategories = widget.budget!.allCategoryFks;
      selectedAmount = widget.budget!.amount;
      setSelectedColor(HexColor(widget.budget!.colour));
      selectedPeriodLength = widget.budget!.periodLength;
      selectedRecurrence = enumRecurrence[widget.budget!.reoccurrence];
      if (selectedPeriodLength == 1) {
        selectedRecurrenceDisplay = nameRecurrence[selectedRecurrence];
      } else {
        selectedRecurrenceDisplay = namesRecurrence[selectedRecurrence];
      }
      selectedStartDate = widget.budget!.startDate;
      selectedEndDate = widget.budget!.endDate;

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
    if (widget.budget != null) {
      List<TransactionCategory> categories = [];
      for (int categoryPk in widget.budget!.categoryFks ?? []) {
        categories.add(await database.getCategoryInstance(categoryPk));
      }
      setSelectedCategories(categories);
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
        selectedColor != null &&
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.budget != null) {
          discardChangesPopup(
            context,
            previousObject: widget.budget,
            currentObject: await createBudget(),
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
                  if (widget.budget != null) {
                    discardChangesPopup(
                      context,
                      previousObject: widget.budget,
                      currentObject: await createBudget(),
                    );
                  } else {
                    discardChangesPopup(context);
                  }
                },
                onDragDownToDissmiss: () async {
                  if (widget.budget != null) {
                    discardChangesPopup(
                      context,
                      previousObject: widget.budget,
                      currentObject: await createBudget(),
                    );
                  } else {
                    discardChangesPopup(context);
                  }
                },
                listWidgets: [
                  Container(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TappableTextEntry(
                      title: selectedTitle,
                      placeholder: "Name",
                      onTap: () {
                        selectTitle();
                      },
                      autoSizeText: true,
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    ),
                  ),
                  Container(height: 17),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFont(
                      text: "Select Categories",
                      textColor: Theme.of(context).colorScheme.textLight,
                      fontSize: 16,
                    ),
                  ),
                  Container(height: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFont(
                      text: selectedCategoriesText + " Budget",
                      textColor:
                          Theme.of(context).colorScheme.secondaryContainer,
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
                      setSelectedCategories: setSelectedCategories,
                    ),
                  ),
                  Container(height: 23),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextFont(
                          text: "Amount and Period",
                          textColor: Theme.of(context).colorScheme.textLight,
                          fontSize: 16,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
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
                                  ? TappableTextEntry(
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
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                      )
                    : Button(
                        label: widget.budget == null
                            ? "Add Budget"
                            : "Save Changes",
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        onTap: () {},
                        color: Colors.grey,
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
