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

class _AddBudgetPageState extends State<AddBudgetPage> {
  dynamic namesRecurrence = {
    "Custom": "custom",
    "Weekly": "weeks",
    "Monthly": "months",
    "Yearly": "years",
  };

  dynamic nameRecurrence = {
    "Custom": "custom",
    "Weekly": "week",
    "Monthly": "month",
    "Yearly": "year",
  };

  bool? canAddBudget;

  List<TransactionCategory>? selectedCategories;
  double? selectedAmount;
  String? selectedAmountCalculation;
  String? selectedTitle;
  String? selectedNote;
  bool selectedAllCategories = true;
  String selectedCategoriesText = "All Categories";
  int selectedPeriodLength = 0;
  List<String> selectedTags = [];
  DateTime selectedStartDate = DateTime.now();
  DateTime? selectedEndDate;
  Color? selectedColor;
  String selectedRecurrence = "Weekly";
  String selectedRecurrenceDisplay = "weeks";

  late TextEditingController _nameInputController;

  String? textAddBudget = "Add Transaction";

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
          items: ["Custom", "Weekly", "Monthly", "Yearly"],
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
            determineBottomButton();
          },
        ),
      ),
    );
  }

  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedStartDate ?? DateTime.now(),
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
        start: selectedStartDate ?? DateTime.now(),
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
    List<int> categoryFks = [];
    for (TransactionCategory category in selectedCategories ?? []) {
      categoryFks.add(category.categoryPk);
    }
    await database.createOrUpdateBudget(
      Budget(
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
        dateCreated: DateTime.now(),
        pinned: true,
        order: await database.getAmountOfBudgets(),
        walletFk: 0,
      ),
    );
    print(await database.getAmountOfBudgets());
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      //We are editing a budget
      //Fill in the information from the passed in budget
      _nameInputController =
          new TextEditingController(text: widget.budget!.name);
      selectedTitle = widget.budget!.name;

      selectedAllCategories = widget.budget!.allCategoryFks;
      var amountString = widget.budget!.amount.toStringAsFixed(2);
      if (amountString.substring(amountString.length - 2) == "00") {
        selectedAmountCalculation =
            amountString.substring(0, amountString.length - 3);
      } else {
        selectedAmountCalculation = amountString;
      }
      textAddBudget = "Edit Transaction";

      WidgetsBinding.instance.addPostFrameCallback((_) {
        updateInitial();
      });
    } else {
      _nameInputController = new TextEditingController();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  updateInitial() async {
    if (widget.budget != null) {
      // TransactionCategory? getSelectedCategory =
      //     await database.getCategoryInstance(widget.budget!.categoryFk);
      // setState(() {
      //   selectedCategory = getSelectedCategory;
      // });
    }
  }

  determineBottomButton() {
    if (selectedTitle != null &&
        (selectedAmount ?? 0) >= 0 &&
        selectedAmount != null &&
        selectedColor != null &&
        selectedStartDate != null &&
        ((selectedRecurrence == "Custom" && selectedEndDate != null) ||
            (selectedRecurrence != "Custom" && selectedPeriodLength != 0))) {
      if (canAddBudget != true)
        this.setState(() {
          canAddBudget = true;
        });
    } else {
      if (canAddBudget != false)
        this.setState(() {
          canAddBudget = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              listWidgets: [
                Container(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 1000),
                        child: Tappable(
                          key: ValueKey(selectedColor),
                          color: lightenPastel(
                              selectedColor ??
                                  Theme.of(context)
                                      .colorScheme
                                      .lightDarkAccentHeavy,
                              amount: 0.3),
                          borderRadius: 15,
                          child: Container(
                            width: 55,
                            height: 55,
                          ),
                          onTap: () {
                            selectColor(context);
                          },
                        ),
                      ),
                      Container(width: 15),
                      Expanded(
                        child: Tappable(
                          onTap: () {
                            selectTitle();
                          },
                          color: Colors.transparent,
                          borderRadius: 15,
                          child: Container(
                            height: 55,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 1.5,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightDarkAccentHeavy)),
                            ),
                            child: IntrinsicWidth(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: TextFont(
                                  autoSizeText: true,
                                  maxLines: 1,
                                  minFontSize: 16,
                                  textAlign: TextAlign.left,
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  text: selectedTitle == null ||
                                          selectedTitle == ""
                                      ? "Name"
                                      : selectedTitle ?? "",
                                  textColor: selectedTitle == null ||
                                          selectedTitle == ""
                                      ? Theme.of(context).colorScheme.textLight
                                      : Theme.of(context).colorScheme.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 35),
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
                Container(height: 25),
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
                    textColor: Theme.of(context).colorScheme.secondaryContainer,
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
                Container(height: 30),
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
                        child: Tappable(
                          onTap: () {
                            selectAmount(context);
                          },
                          color: Colors.transparent,
                          borderRadius: 15,
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: CountNumber(
                                count: selectedAmount ?? 0,
                                duration: Duration(milliseconds: 1000),
                                dynamicDecimals: true,
                                initialCount: selectedAmount ?? 0,
                                textBuilder: (number) {
                                  return TextFont(
                                    textAlign: TextAlign.right,
                                    text: convertToMoney(number),
                                    fontSize: 35,
                                    fontWeight: FontWeight.bold,
                                    maxLines: 1,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      IntrinsicWidth(
                        child: Row(
                          children: [
                            selectedRecurrence != "Custom"
                                ? Tappable(
                                    onTap: () {
                                      selectPeriodLength(context);
                                    },
                                    color: Colors.transparent,
                                    borderRadius: 15,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 13),
                                      child: Center(
                                        child: TextFont(
                                          text: "/ " +
                                              selectedPeriodLength.toString(),
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )
                                : TextFont(
                                    text: "/ ",
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                            Tappable(
                              onTap: () {
                                selectRecurrence(context);
                              },
                              color: Colors.transparent,
                              borderRadius: 15,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 13),
                                child: Center(
                                  child: TextFont(
                                    text: selectedRecurrenceDisplay,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
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
                      selectedEndDate == null && selectedRecurrence == "Custom"
                          ? 0
                          : -15),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: selectedRecurrence != "Custom"
                        ? Column(
                            children: [
                              Tappable(
                                onTap: () {
                                  selectStartDate(context);
                                },
                                color: Colors.transparent,
                                borderRadius: 15,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 13),
                                  child: Center(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 2.8),
                                          child: TextFont(
                                            text: "beginning  ",
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextFont(
                                          text:
                                              getWordedDate(selectedStartDate),
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Tappable(
                            onTap: () {
                              selectDateRange(context);
                            },
                            color: selectedEndDate == null
                                ? Theme.of(context).colorScheme.lightDarkAccent
                                : Colors.transparent,
                            borderRadius: 15,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 13),
                              child: Center(
                                child: selectedEndDate == null
                                    ? TextFont(
                                        text: "Select Custom Period",
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        textColor: Theme.of(context)
                                            .colorScheme
                                            .textLight,
                                      )
                                    : TextFont(
                                        text: getWordedDateShort(
                                                selectedStartDate) +
                                            " - " +
                                            getWordedDateShort(
                                                selectedEndDate!),
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                              ),
                            ),
                          ),
                  ),
                ),
                Container(height: 15),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: canAddBudget ?? false
                  ? Button(
                      label: "Add Budget",
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      onTap: () {
                        addBudget();
                      },
                    )
                  : Button(
                      label: "Add Budget",
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      onTap: () {},
                      color: Colors.grey,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
