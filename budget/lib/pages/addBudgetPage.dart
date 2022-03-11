import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/categoryEntry.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/radioItems.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/selectCategory.dart';
import 'package:budget/widgets/selectColor.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:budget/struct/transactionCategory.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
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
  bool? canAddBudget;

  List<TransactionCategory>? selectedCategories;
  double? selectedAmount;
  String? selectedAmountCalculation;
  String? selectedTitle;
  String? selectedNote;
  bool selectedAllCategories = true;
  int selectedPeriodLength = 0;
  List<String> selectedTags = [];
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  Color? selectedColor;
  String? selectedRecurrence;

  late TextEditingController _nameInputController;
  late TextEditingController _startDateInputController;
  late TextEditingController _customDateInputController;
  late TextEditingController _amountInputController;
  late TextEditingController _selectCategoriesInputController;
  late TextEditingController _periodLengthInputController;
  late TextEditingController _colorInputController;
  late TextEditingController _recurrenceInputController;
  late FocusNode _periodLengthFocusNode;

  String? textAddBudget = "Add Transaction";

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
          initial: selectedRecurrence ?? "",
          onChanged: (value) {
            if (value == "Custom") {
              selectedStartDate = null;
              selectedEndDate = null;
            }
            setState(() {
              selectedRecurrence = value;
            });
            determineBottomButton();
            setTextInput(_recurrenceInputController, value);
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
                  primaryColor: Theme.of(context).colorScheme.accentColor,
                  colorScheme: ColorScheme.light(
                      primary: Theme.of(context).colorScheme.accentColor),
                  buttonTheme:
                      ButtonThemeData(textTheme: ButtonTextTheme.primary),
                )
              : ThemeData.dark().copyWith(
                  primaryColor: Theme.of(context).colorScheme.accentColorHeavy,
                  colorScheme: ColorScheme.dark(
                      primary: Theme.of(context).colorScheme.accentColorHeavy),
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
      String dateString = getWordedDate(date);
      setTextInput(_startDateInputController, dateString);
      selectedStartDate = date;
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
                  primaryColor: Theme.of(context).colorScheme.accentColor,
                  colorScheme: ColorScheme.light(
                      primary: Theme.of(context).colorScheme.accentColor),
                  buttonTheme:
                      ButtonThemeData(textTheme: ButtonTextTheme.primary),
                )
              : ThemeData.dark().copyWith(
                  primaryColor: Theme.of(context).colorScheme.accentColorHeavy,
                  colorScheme: ColorScheme.dark(
                      primary: Theme.of(context).colorScheme.accentColorHeavy),
                  buttonTheme:
                      ButtonThemeData(textTheme: ButtonTextTheme.primary),
                ),
          child: child ?? Container(),
        );
      },
    );
    if (picked != null) {
      String dateString =
          getWordedDate(picked.start) + " - " + getWordedDate(picked.end);
      setTextInput(_customDateInputController, dateString);
      setTextInput(_startDateInputController, getWordedDate(picked.start));
      selectedStartDate = picked.start;
      selectedEndDate = picked.end;
      determineBottomButton();
    }
  }

  void setSelectedCategories(List<TransactionCategory> categories) {
    if (categories.length <= 0) {
      setState(() {
        selectedCategories = categories;
        selectedAllCategories = true;
      });
      _selectCategoriesInputController.text = "All categories";
    } else {
      setState(() {
        selectedCategories = categories;
        selectedAllCategories = false;
      });
      if (categories.length == 1) {
        _selectCategoriesInputController.text =
            categories.length.toString() + " " + "category";
      } else {
        _selectCategoriesInputController.text =
            categories.length.toString() + " " + "categories";
      }
    }
    determineBottomButton();
    return;
  }

  void setSelectedAmount(double amount, String amountCalculation) {
    selectedAmount = amount;
    selectedAmountCalculation = amountCalculation;
    setTextInput(_amountInputController, convertToMoney(amount));
    determineBottomButton();
    return;
  }

  void setSelectedTitle(String title) {
    selectedTitle = title;
    determineBottomButton();
    return;
  }

  void setSelectedPeriodLength(String period) {
    try {
      selectedPeriodLength = int.parse(period);
      setTextInput(
          _periodLengthInputController, selectedPeriodLength.toString());
    } catch (e) {
      selectedPeriodLength = 0;
      setTextInput(_periodLengthInputController, "0");
    }
    determineBottomButton();
    return;
  }

  void setSelectedColor(Color color) {
    selectedColor = color;
    setTextInput(_colorInputController, toHexString(color));
    determineBottomButton();
    return;
  }

  Future addBudget() async {
    print("Added budget");
    await database.createOrUpdateBudget(
      Budget(
        budgetPk: widget.budget != null
            ? widget.budget!.budgetPk
            : DateTime.now().millisecondsSinceEpoch,
        name: selectedTitle ?? "",
        amount: selectedAmount ?? 10,
        colour: toHexString(selectedColor ?? Colors.green),
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        categoryFks: [0, 1, 2],
        allCategoryFks: false,
        periodLength: 30,
        reoccurrence: BudgetReoccurence.monthly,
        dateCreated: DateTime.now(),
        pinned: false,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _periodLengthFocusNode = FocusNode();

    if (widget.budget != null) {
      //We are editing a budget
      //Fill in the information from the passed in budget
      _nameInputController =
          new TextEditingController(text: widget.budget!.name);
      _startDateInputController = new TextEditingController(text: "Today");
      _customDateInputController = new TextEditingController();

      _amountInputController = new TextEditingController(
          text: convertToMoney(widget.budget!.amount));
      selectedAllCategories = widget.budget!.allCategoryFks;
      _periodLengthInputController = new TextEditingController(text: "0");
      // var amountString = widget.transaction!.amount.toStringAsFixed(2);
      // if (amountString.substring(amountString.length - 2) == "00") {
      //   selectedAmountCalculation =
      //       amountString.substring(0, amountString.length - 3);
      // } else {
      //   selectedAmountCalculation = amountString;
      // }
      textAddBudget = "Edit Transaction";
      _colorInputController = new TextEditingController();
      _recurrenceInputController = new TextEditingController();

      WidgetsBinding.instance?.addPostFrameCallback((_) {
        updateInitial();
      });
    } else {
      _nameInputController = new TextEditingController();
      _startDateInputController = new TextEditingController();
      _customDateInputController = new TextEditingController();

      _amountInputController =
          new TextEditingController(text: convertToMoney(0));
      _selectCategoriesInputController =
          new TextEditingController(text: "All categories");
      _periodLengthInputController = new TextEditingController(text: "0");
      _colorInputController = new TextEditingController();
      _recurrenceInputController = new TextEditingController();
    }
  }

  @override
  void dispose() {
    _periodLengthFocusNode.dispose();
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
      print(selectedPeriodLength);
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
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  leading: Container(),
                  backgroundColor: Theme.of(context).canvasColor,
                  floating: false,
                  pinned: true,
                  expandedHeight: 200.0,
                  collapsedHeight: 65,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                    title: TextFont(
                      text: widget.title,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            Container(height: 20),
                            TextInput(
                              labelText: "Budget Name",
                              icon: Icons.title_rounded,
                              padding: EdgeInsets.zero,
                              controller: _nameInputController,
                              onChanged: (text) {
                                setSelectedTitle(text);
                              },
                            ),
                            Container(height: 14),
                            TextInput(
                              labelText: "Amount",
                              icon: Icons.attach_money_rounded,
                              padding: EdgeInsets.zero,
                              controller: _amountInputController,
                              onTap: () {
                                selectAmount(context);
                              },
                              readOnly: true,
                              showCursor: false,
                            ),
                            Container(height: 14),
                            TextInput(
                              labelText: "Select color",
                              icon: Icons.color_lens_rounded,
                              padding: EdgeInsets.zero,
                              onTap: () {
                                selectColor(context);
                              },
                              readOnly: true,
                              showCursor: false,
                              controller: _colorInputController,
                            ),
                            Container(height: 14),
                            Row(
                              children: [
                                Flexible(
                                  child: TextInput(
                                    labelText: "Select Categories",
                                    icon: Icons.category_rounded,
                                    padding: EdgeInsets.zero,
                                    controller:
                                        _selectCategoriesInputController,
                                    onChanged: (text) {
                                      setSelectedTitle(text);
                                    },
                                    onTap: () {
                                      selectCategories(context);
                                    },
                                    readOnly: true,
                                    showCursor: false,
                                  ),
                                ),
                                Column(
                                  children: [
                                    CupertinoSwitch(
                                      value: selectedAllCategories,
                                      onChanged: (value) {
                                        if (value == false) {
                                          selectCategories(context);
                                        } else {
                                          setState(() {
                                            selectedAllCategories = value;
                                            _selectCategoriesInputController
                                                .text = "All categories";
                                          });
                                        }
                                      },
                                    ),
                                    Container(
                                      child: TextFont(
                                        text: "All Categories",
                                        maxLines: 2,
                                        fontSize: 8,
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            Container(height: 14),
                            TextInput(
                              labelText: "Recurrence",
                              icon: Icons.loop_rounded,
                              padding: EdgeInsets.zero,
                              controller: _recurrenceInputController,
                              readOnly: true,
                              showCursor: false,
                              onTap: () {
                                selectRecurrence(context);
                              },
                            ),
                            selectedRecurrence != "Custom"
                                ? Column(
                                    children: [
                                      Container(height: 14),
                                      TextInput(
                                        labelText: "Start Date",
                                        icon: Icons.calendar_today_rounded,
                                        padding: EdgeInsets.zero,
                                        onTap: () {
                                          selectStartDate(context);
                                        },
                                        readOnly: true,
                                        showCursor: false,
                                        controller: _startDateInputController,
                                      ),
                                      Container(height: 14),
                                      GestureDetector(
                                        onTap: () {
                                          _periodLengthFocusNode.requestFocus();
                                        },
                                        child: Row(
                                          children: [
                                            Container(width: 55),
                                            TextFont(text: "Repeat every "),
                                            IntrinsicWidth(
                                              child: TextInput(
                                                focusNode:
                                                    _periodLengthFocusNode,
                                                labelText: "",
                                                padding: EdgeInsets.zero,
                                                onChanged: (text) {
                                                  setSelectedPeriodLength(text);
                                                },
                                                numbersOnly: true,
                                                controller:
                                                    _periodLengthInputController,
                                                paddingRight: 8,
                                              ),
                                            ),
                                            TextFont(text: " weeks.")
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      Container(height: 14),
                                      TextInput(
                                        labelText: "Custom Date Range",
                                        icon: Icons.calendar_today_rounded,
                                        padding: EdgeInsets.zero,
                                        onTap: () {
                                          selectDateRange(context);
                                        },
                                        readOnly: true,
                                        showCursor: false,
                                        controller: _customDateInputController,
                                        maxLines: 3,
                                      ),
                                    ],
                                  ),
                            Container(height: 14),
                            Container(height: 20),
                            Container(height: 10),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SliverFillRemaining()
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: canAddBudget ?? false
                  ? Button(
                      label: "Add Budget",
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      fractionScaleHeight: 0.93,
                      fractionScaleWidth: 0.98,
                      onTap: () {},
                    )
                  : Button(
                      label: "Add Budget",
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      fractionScaleHeight: 0.93,
                      fractionScaleWidth: 0.98,
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
