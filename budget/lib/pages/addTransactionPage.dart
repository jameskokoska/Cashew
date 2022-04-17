import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/selectCategory.dart';
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

//TODO
//only show the tags that correspond to selected category
//put recent used tags at the top? when no category selected

class AddTransactionPage extends StatefulWidget {
  AddTransactionPage({
    Key? key,
    required this.title,
    this.transaction,
  }) : super(key: key);
  final String title;

  //When a transaction is passed in, we are editing that transaction
  final Transaction? transaction;

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  TransactionCategory? selectedCategory;
  double? selectedAmount;
  String? selectedAmountCalculation;
  String? selectedTitle;
  String? selectedNote;
  List<String> selectedTags = [];
  DateTime selectedDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  String? textAddTransaction = "Add Transaction";

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
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
    if (picked != null && picked != selectedDate) {
      String dateString = getWordedDate(picked);
      _dateInputController.value = TextEditingValue(
        text: dateString,
        selection: TextSelection.fromPosition(
          TextPosition(offset: dateString.length),
        ),
      );
      selectedDate = picked;
    }
  }

  void setSelectedCategory(TransactionCategory category) {
    setState(() {
      selectedCategory = category;
    });
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
    return;
  }

  void setSelectedTitle(String title) {
    selectedTitle = title;
    return;
  }

  void setSelectedTitleController(String title) {
    setTextInput(_titleInputController, title);
    selectedTitle = title;
    return;
  }

  void setSelectedTags(List<String> tags) {
    setState(() {
      selectedTags = tags;
    });
  }

  void setSelectedNote(String note) {
    selectedNote = note;
    return;
  }

  Future addTransaction() async {
    print("Added transaction");
    print(selectedDate);
    await database.createOrUpdateTransaction(
      Transaction(
        transactionPk: widget.transaction != null
            ? widget.transaction!.transactionPk
            : DateTime.now().millisecondsSinceEpoch,
        name: selectedTitle ?? "",
        amount: selectedAmount ?? 10,
        note: selectedNote ?? "",
        categoryFk: selectedCategory?.categoryPk ?? 0,
        dateCreated: selectedDate,
        income: false,
        walletFk: 0,
      ),
    );
  }

  late TextEditingController _titleInputController;
  late TextEditingController _dateInputController;
  late TextEditingController _noteInputController;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      //We are editing a transaction
      //Fill in the information from the passed in transaction
      _titleInputController =
          new TextEditingController(text: widget.transaction!.name);
      _noteInputController =
          new TextEditingController(text: widget.transaction!.note);
      _dateInputController = new TextEditingController(
          text: getWordedDate(widget.transaction!.dateCreated));
      selectedTitle = widget.transaction!.name;
      selectedNote = widget.transaction!.note;
      selectedDate = widget.transaction!.dateCreated;
      selectedAmount = widget.transaction!.amount;
      // var amountString = widget.transaction!.amount.toStringAsFixed(2);
      // if (amountString.substring(amountString.length - 2) == "00") {
      //   selectedAmountCalculation =
      //       amountString.substring(0, amountString.length - 3);
      // } else {
      //   selectedAmountCalculation = amountString;
      // }
      textAddTransaction = "Edit Transaction";

      WidgetsBinding.instance?.addPostFrameCallback((_) {
        updateInitial();
      });
    } else {
      _titleInputController = new TextEditingController();
      _dateInputController = new TextEditingController(text: "Today");
      _noteInputController = new TextEditingController();

      Future.delayed(Duration(milliseconds: 0), () {
        openBottomSheet(
          context,
          PopupFramework(
            child: SelectTitle(
                setSelectedTitle: setSelectedTitleController,
                setSelectedTags: setSelectedTags,
                selectedCategory: selectedCategory,
                setSelectedCategory: setSelectedCategory,
                next: () {
                  openBottomSheet(
                    context,
                    PopupFramework(
                      title: "Select Category",
                      child: SelectCategory(
                        selectedCategory: selectedCategory,
                        setSelectedCategory: setSelectedCategory,
                        skipIfSet: true,
                        next: () {
                          openBottomSheet(
                            context,
                            PopupFramework(
                              title: "Enter Amount",
                              child: SelectAmount(
                                amountPassed: selectedAmountCalculation ?? "",
                                setSelectedAmount: setSelectedAmount,
                                next: () async {
                                  await addTransaction();
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                nextLabel: textAddTransaction,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }),
          ),
        );
      });
    }
  }

  updateInitial() async {
    if (widget.transaction != null) {
      TransactionCategory? getSelectedCategory =
          await database.getCategoryInstance(widget.transaction!.categoryFk);
      setState(() {
        selectedCategory = getSelectedCategory;
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
            PageFramework(
              title: widget.title,
              navbar: false,
              listWidgets: [
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
                            key: ValueKey(selectedCategory?.categoryPk ?? ""),
                            categoryPk: selectedCategory?.categoryPk ?? 0,
                            size: 60,
                            onTap: () {
                              openBottomSheet(
                                context,
                                PopupFramework(
                                  title: "Select Category",
                                  child: SelectCategory(
                                    selectedCategory: selectedCategory,
                                    setSelectedCategory: setSelectedCategory,
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
                                            selectedAmountCalculation ?? "",
                                        setSelectedAmount: setSelectedAmount,
                                        next: () async {
                                          if (selectedCategory == null) {
                                            Navigator.pop(context);
                                            openBottomSheet(
                                              context,
                                              PopupFramework(
                                                title: "Select Category",
                                                child: SelectCategory(
                                                  selectedCategory:
                                                      selectedCategory,
                                                  setSelectedCategory:
                                                      setSelectedCategory,
                                                  next: () async {
                                                    await addTransaction();
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ),
                                            );
                                          } else {
                                            await addTransaction();
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          }
                                        },
                                        nextLabel: selectedCategory == null
                                            ? "Select Category"
                                            : textAddTransaction,
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
                                      text: convertToMoney(selectedAmount ?? 0),
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
                                  key: ValueKey(selectedCategory?.name ?? ""),
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
                ),
              ],
            ),
            //This align causes a state update when keyboard pushes it up... optimize in the future?
            Align(
              alignment: Alignment.bottomCenter,
              child: selectedCategory == null
                  ? Button(
                      label: "Select Category",
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      onTap: () {
                        openBottomSheet(
                          context,
                          PopupFramework(
                            title: "Select Category",
                            child: SelectCategory(
                              selectedCategory: selectedCategory,
                              setSelectedCategory: setSelectedCategory,
                              skipIfSet: true,
                              next: () {
                                openBottomSheet(
                                  context,
                                  PopupFramework(
                                    title: "Enter Amount",
                                    child: SelectAmount(
                                      amountPassed:
                                          selectedAmountCalculation ?? "",
                                      setSelectedAmount: setSelectedAmount,
                                      next: () async {
                                        await addTransaction;
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      nextLabel: textAddTransaction,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    )
                  : selectedAmount == null
                      ? Button(
                          label: "Enter Amount",
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          onTap: () {
                            openBottomSheet(
                              context,
                              PopupFramework(
                                child: SelectAmount(
                                  amountPassed: selectedAmountCalculation ?? "",
                                  setSelectedAmount: setSelectedAmount,
                                  next: () async {
                                    await addTransaction();
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  nextLabel: textAddTransaction,
                                ),
                              ),
                            );
                          },
                        )
                      : Button(
                          label: textAddTransaction ?? "",
                          width: MediaQuery.of(context).size.width,
                          height: 50,
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

class SelectTitle extends StatefulWidget {
  SelectTitle({
    Key? key,
    required this.setSelectedTitle,
    this.selectedCategory,
    required this.setSelectedCategory,
    this.selectedTitle,
    required this.setSelectedTags,
    this.next,
  }) : super(key: key);
  final Function(String) setSelectedTitle;
  final TransactionCategory? selectedCategory;
  final Function(TransactionCategory) setSelectedCategory;
  final Function(List<String>) setSelectedTags;
  final String? selectedTitle;
  final VoidCallback? next;

  @override
  _SelectTitleState createState() => _SelectTitleState();
}

class _SelectTitleState extends State<SelectTitle> {
  int selectedIndex = 0;
  String? input = "";
  TransactionCategory? selectedCategory;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.selectedCategory;
    input = widget.selectedTitle;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFont(
                  text: "Enter Title",
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
                Container(height: 2),
                Container(
                  width: MediaQuery.of(context).size.width - 130,
                  child: TextInput(
                    initialValue: widget.selectedTitle,
                    autoFocus: true,
                    onEditingComplete: () {
                      //if selected a tag and a category is set, then go to enter amount
                      //else enter amount
                      widget.setSelectedTitle(input ?? "");
                      Navigator.pop(context);
                      if (widget.next != null) {
                        widget.next!();
                      }
                    },
                    onChanged: (text) {
                      input = text;
                      widget.setSelectedTitle(input!);
                    },
                    labelText: "Title",
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: CategoryIcon(
                key: ValueKey(selectedCategory?.categoryPk ?? ""),
                margin: EdgeInsets.zero,
                categoryPk: selectedCategory?.categoryPk ?? 0,
                size: 55,
                onTap: () {
                  openBottomSheet(
                    context,
                    PopupFramework(
                      title: "Select Category",
                      child: SelectCategory(
                        setSelectedCategory: (TransactionCategory category) {
                          widget.setSelectedCategory(category);
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
        Container(height: 20),
        SelectTag(),
        Container(height: 20),
        Button(
          label: selectedCategory == null ? "Select Category" : "Enter Amount",
          width: MediaQuery.of(context).size.width,
          height: 50,
          onTap: () {
            Navigator.pop(context);
            if (widget.next != null) {
              widget.next!();
            }
          },
        )
      ],
    );
  }
}

class SelectTag extends StatefulWidget {
  SelectTag({Key? key, this.setSelectedCategory}) : super(key: key);
  final Function(TransactionCategoryOld)? setSelectedCategory;

  @override
  _SelectTagState createState() => _SelectTagState();
}

class _SelectTagState extends State<SelectTag> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          children: listTag()
              .asMap()
              .map(
                (index, tag) => MapEntry(
                  index,
                  TagIcon(
                    tag: tag,
                    size: 17,
                    onTap: () {},
                  ),
                ),
              )
              .values
              .toList(),
        ),
      ),
    );
  }
}
