import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/button.dart';
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

class EditTransactionPage extends StatefulWidget {
  EditTransactionPage({
    Key? key,
    required this.transaction,
  }) : super(key: key);
  final Transaction transaction;

  @override
  _EditTransactionPageState createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends State<EditTransactionPage> {
  TransactionCategory? selectedCategory;
  double? selectedAmount;
  String? selectedAmountCalculation;
  String? selectedTitle;
  String? selectedNote;
  List<String> selectedTags = [];
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    _titleInputController =
        new TextEditingController(text: widget.transaction.name);
    _noteInputController =
        new TextEditingController(text: widget.transaction.note);
    _dateInputController = new TextEditingController(
        text: getWordedDate(widget.transaction.dateCreated));
    selectedTitle = widget.transaction.name;
    selectedNote = widget.transaction.note;
    selectedDate = widget.transaction.dateCreated;
    selectedAmount = widget.transaction.amount;

    Future.delayed(Duration(milliseconds: 0), () async {
      selectedCategory =
          await database.getCategoryInstance(widget.transaction.categoryFk);
    });
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

  void setSelectedCategory(TransactionCategory category) {
    setState(() {
      selectedCategory = category;
    });
    return;
  }

  void setSelectedAmount(double amount, String amountCalculation) {
    setState(() {
      selectedAmount = amount;
      selectedAmountCalculation = amountCalculation;
    });
    return;
  }

  void setSelectedTitle(String title) {
    _titleInputController.value = TextEditingValue(
      text: title,
      selection: TextSelection.fromPosition(
        TextPosition(offset: title.length),
      ),
    );
    setState(() {
      selectedTitle = title;
    });
    return;
  }

  void setSelectedTags(List<String> tags) {
    setState(() {
      selectedTags = tags;
    });
  }

  void setSelectedNote(String note) {
    _noteInputController.value = TextEditingValue(
      text: note,
      selection: TextSelection.fromPosition(
        TextPosition(offset: note.length),
      ),
    );
    setState(() {
      selectedNote = note;
    });
    return;
  }

  Future addTransaction() async {
    print("Added transaction");
    await database.createOrUpdateTransaction(Transaction(
        transactionPk: widget.transaction.transactionPk,
        name: selectedTitle ?? "",
        amount: selectedAmount ?? 10,
        note: selectedNote ?? "",
        budgetFk: 0,
        categoryFk: selectedCategory?.categoryPk ?? 0,
        dateCreated: DateTime.now()));
  }

  late TextEditingController _titleInputController;
  late TextEditingController _dateInputController;
  late TextEditingController _noteInputController;

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
                      text: "Edit Transaction",
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        color: HexColor(selectedCategory?.colour,
                                Theme.of(context).canvasColor)
                            .withOpacity(0.55),
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 17, right: 37, top: 20, bottom: 18),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AnimatedSwitcher(
                                duration: Duration(milliseconds: 300),
                                child: CategoryIcon(
                                  noBackground: true,
                                  key: ValueKey(
                                      selectedCategory?.categoryPk ?? ""),
                                  categoryPk: selectedCategory?.categoryPk ?? 0,
                                  size: 60,
                                  onTap: () {
                                    openBottomSheet(
                                      context,
                                      PopupFramework(
                                        title: "Select Category",
                                        child: SelectCategory(
                                          setSelectedCategory:
                                              setSelectedCategory,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Container(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(height: 8),
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        openBottomSheet(
                                          context,
                                          PopupFramework(
                                            title: "Enter Amount",
                                            child: SelectAmount(
                                              amountPassed:
                                                  selectedAmountCalculation ??
                                                      "",
                                              setSelectedAmount:
                                                  setSelectedAmount,
                                              next: () async {
                                                await addTransaction();
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              },
                                              nextLabel: "Save Transaction",
                                            ),
                                          ),
                                        );
                                      },
                                      child: AnimatedSwitcher(
                                        duration: Duration(milliseconds: 350),
                                        child: Container(
                                          key: ValueKey(selectedAmount),
                                          width: double.infinity,
                                          child: TextFont(
                                            textAlign: TextAlign.right,
                                            key: ValueKey(selectedAmount),
                                            text: convertToMoney(
                                                selectedAmount ?? 0),
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    AnimatedSwitcher(
                                      duration: Duration(milliseconds: 350),
                                      child: Container(
                                        key: ValueKey(
                                            selectedCategory?.name ?? ""),
                                        width: double.infinity,
                                        child: TextFont(
                                          textAlign: TextAlign.right,
                                          fontSize: 18,
                                          text: selectedCategory?.name ?? "",
                                        ),
                                      ),
                                    ),
                                    Container(height: 3),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            Container(height: 20),
                            TextInput(
                              labelText: "Title",
                              icon: Icons.title_rounded,
                              padding: EdgeInsets.zero,
                              controller: _titleInputController,
                              onChanged: (text) {
                                setSelectedTitle(text);
                              },
                            ),
                            Container(height: 14),
                            TextInput(
                              labelText: "Notes",
                              icon: Icons.edit,
                              padding: EdgeInsets.zero,
                              controller: _noteInputController,
                              onChanged: (text) {
                                setSelectedNote(text);
                              },
                            ),
                            Container(height: 14),
                            TextInput(
                              labelText: "Date",
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
                            SelectTag(),
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
              child: Button(
                label: "Save Transaction",
                width: MediaQuery.of(context).size.width,
                height: 50,
                fractionScaleHeight: 0.93,
                fractionScaleWidth: 0.98,
                onTap: () async {
                  await addTransaction();
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
