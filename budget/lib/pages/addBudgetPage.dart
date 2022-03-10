import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/categoryEntry.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/popupFramework.dart';
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
  List<TransactionCategory>? selectedCategories;
  double? selectedAmount;
  String? selectedAmountCalculation;
  String? selectedTitle;
  String? selectedNote;
  bool selectedAllCategories = true;
  int selectedPeriodLength = 1;
  List<String> selectedTags = [];
  DateTime selectedStartDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime selectedEndDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  Color? selectedColor;

  late TextEditingController _nameInputController;
  late TextEditingController _startDateInputController;
  late TextEditingController _customDateInputController;
  late TextEditingController _amountInputController;
  late TextEditingController _selectCategoriesInputController;
  late TextEditingController _periodLengthInputController;
  late TextEditingController _colorInputController;
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

  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedStartDate,
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (picked != null && picked != selectedStartDate) {
      String dateString = getWordedDate(picked);
      _startDateInputController.value = TextEditingValue(
        text: dateString,
        selection: TextSelection.fromPosition(
          TextPosition(offset: dateString.length),
        ),
      );
      selectedStartDate = picked;
    }
  }

  Future<void> selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (picked != null) {
      String dateString =
          getWordedDate(picked.start) + " - " + getWordedDate(picked.end);
      _customDateInputController.value = TextEditingValue(
        text: dateString,
        selection: TextSelection.fromPosition(
          TextPosition(offset: dateString.length),
        ),
      );
      selectedStartDate = picked.start;
      selectedEndDate = picked.end;
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

    return;
  }

  void setSelectedAmount(double amount, String amountCalculation) {
    selectedAmount = amount;
    selectedAmountCalculation = amountCalculation;
    setTextInput(_amountInputController, convertToMoney(amount));
    return;
  }

  void setSelectedTitle(String title) {
    selectedTitle = title;
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
    return;
  }

  void setSelectedColor(Color color) {
    selectedColor = color;
    setTextInput(_colorInputController, toHexString(color));
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
      _customDateInputController =
          new TextEditingController(text: "Date Range");

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

      WidgetsBinding.instance?.addPostFrameCallback((_) {
        updateInitial();
      });
    } else {
      _nameInputController = new TextEditingController();
      _startDateInputController = new TextEditingController(text: "Today");
      _customDateInputController =
          new TextEditingController(text: "Date Range");

      _amountInputController =
          new TextEditingController(text: convertToMoney(0));
      _selectCategoriesInputController =
          new TextEditingController(text: "All categories");
      _periodLengthInputController = new TextEditingController(text: "0");
      _colorInputController = new TextEditingController();
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
                              controller: _nameInputController,
                              onChanged: (text) {
                                setSelectedTitle(text);
                              },
                            ),
                            Container(height: 14),
                            DropdownSelect(
                                initial: "Custom",
                                items: [
                                  "Custom",
                                  "Weekly",
                                  "Monthly",
                                  "Yearly"
                                ],
                                onChanged: (_) {}),
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
                                      focusNode: _periodLengthFocusNode,
                                      labelText: "",
                                      padding: EdgeInsets.zero,
                                      onChanged: (text) {
                                        setSelectedPeriodLength(text);
                                      },
                                      numbersOnly: true,
                                      controller: _periodLengthInputController,
                                      paddingRight: 8,
                                    ),
                                  ),
                                  TextFont(text: " weeks.")
                                ],
                              ),
                            ),
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
          ],
        ),
      ),
    );
  }
}
