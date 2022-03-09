import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:budget/struct/transactionCategory.dart';
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
  List<String> selectedTags = [];
  DateTime selectedDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

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

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (picked != null && picked != selectedDate) {
      String dateString = getWordedDate(picked);
      _dateInputController.value = TextEditingValue(
        text: dateString,
        selection: TextSelection.fromPosition(
          TextPosition(offset: dateString.length),
        ),
      );
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void setSelectedCategories(List<TransactionCategory> categories) {
    setState(() {
      selectedCategories = categories;
    });
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

  Future addBudget() async {
    print("Added budget");
    await database.createOrUpdateBudget(
      Budget(
        budgetPk: widget.budget != null
            ? widget.budget!.budgetPk
            : DateTime.now().millisecondsSinceEpoch,
        name: selectedTitle ?? "",
        amount: selectedAmount ?? 10,
        colour: toHexString(Colors.blueGrey),
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        categoryFks: [0, 1, 2],
        periodLength: 30,
        reoccurrence: BudgetReoccurence.monthly,
        dateCreated: selectedDate,
        pinned: false,
      ),
    );
  }

  late TextEditingController _nameInputController;
  late TextEditingController _dateInputController;
  late TextEditingController _amountInputController;

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      //We are editing a budget
      //Fill in the information from the passed in budget
      _nameInputController =
          new TextEditingController(text: widget.budget!.name);

      // var amountString = widget.transaction!.amount.toStringAsFixed(2);
      // if (amountString.substring(amountString.length - 2) == "00") {
      //   selectedAmountCalculation =
      //       amountString.substring(0, amountString.length - 3);
      // } else {
      //   selectedAmountCalculation = amountString;
      // }
      textAddBudget = "Edit Transaction";

      WidgetsBinding.instance?.addPostFrameCallback((_) {
        updateInitial();
      });
    } else {
      _nameInputController = new TextEditingController();
      _dateInputController = new TextEditingController(text: "Today");
      _amountInputController =
          new TextEditingController(text: convertToMoney(0));
    }
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
                            TextInput(
                              labelText: "Select Categories",
                              icon: Icons.title_rounded,
                              padding: EdgeInsets.zero,
                              controller: _nameInputController,
                              onChanged: (text) {
                                setSelectedTitle(text);
                              },
                              onTap: () {
                                selectDate(context);
                              },
                            ),
                            TextInput(
                              labelText: "Recurrence",
                              icon: Icons.title_rounded,
                              padding: EdgeInsets.zero,
                              controller: _nameInputController,
                              onChanged: (text) {
                                setSelectedTitle(text);
                              },
                            ),
                            TextInput(
                              labelText: "Start Date",
                              icon: Icons.calendar_today_rounded,
                              padding: EdgeInsets.zero,
                              onTap: () {
                                selectDate(context);
                              },
                              readOnly: true,
                              showCursor: false,
                              controller: _dateInputController,
                            ),
                            TextInput(
                              labelText: "End Date",
                              icon: Icons.calendar_today_rounded,
                              padding: EdgeInsets.zero,
                              onTap: () {
                                selectDate(context);
                              },
                              readOnly: true,
                              showCursor: false,
                              controller: _dateInputController,
                            ),
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
