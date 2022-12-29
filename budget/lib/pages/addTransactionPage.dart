import 'dart:developer';
import 'dart:math';

import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/transactionsListPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/initializeNotifications.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/radioItems.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/selectCategory.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:budget/colors.dart';
import 'package:math_expressions/math_expressions.dart';

//TODO
//only show the tags that correspond to selected category
//put recent used tags at the top? when no category selected

dynamic transactionTypeDisplayToEnum = {
  "Default": null,
  "Upcoming": TransactionSpecialType.upcoming,
  "Subscription": TransactionSpecialType.subscription,
  "Repetitive": TransactionSpecialType.repetitive,
  null: "Default",
  TransactionSpecialType.upcoming: "Upcoming",
  TransactionSpecialType.subscription: "Subscription",
  TransactionSpecialType.repetitive: "Repetitive",
};

class AddTransactionPage extends StatefulWidget {
  AddTransactionPage({
    Key? key,
    required this.title,
    this.transaction,
    this.subscription,
  }) : super(key: key);
  final String title;

  //When a transaction is passed in, we are editing that transaction
  final Transaction? transaction;
  final bool? subscription;

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  TransactionCategory? selectedCategory;
  double? selectedAmount;
  String? selectedAmountCalculation;
  String? selectedTitle;
  String? selectedNote;
  String selectedTypeDisplay = "Default";
  TransactionSpecialType? selectedType = null;
  List<String> selectedTags = [];
  DateTime selectedDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  int selectedPeriodLength = 0;
  String selectedRecurrence = "Monthly";
  String selectedRecurrenceDisplay = "months";
  BudgetReoccurence selectedRecurrenceEnum = BudgetReoccurence.monthly;
  bool selectedIncome = false;
  String? selectedPayer;

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
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void setSelectedDate(DateTime dateTime) {
    setState(() {
      selectedDate = dateTime;
    });
  }

  void setSelectedCategory(TransactionCategory category) {
    setState(() {
      selectedCategory = category;
      selectedIncome = category.income;
      if (category.sharedKey != null) {
        selectedPayer = appStateSettings["currentUserEmail"];
      }
    });
    return;
  }

  void setSelectedAmount(double amount, String amountCalculation) {
    if (amount == double.infinity ||
        amount == double.negativeInfinity ||
        amount == double.nan ||
        amount.isNaN) {
      return;
    }
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
    setTextInput(_titleInputController, title);
    selectedTitle = title.trim();
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

  void setSelectedNoteController(String note) {
    setTextInput(_noteInputController, note);
    selectedNote = note;
    return;
  }

  void setSelectedType(String type) {
    setState(() {
      selectedType = transactionTypeDisplayToEnum[type];
      selectedTypeDisplay = type;
    });
    return;
  }

  void setSelectedPayer(String payer) {
    setState(() {
      selectedPayer = payer;
    });
    return;
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
    return;
  }

  Future<void> selectRecurrence(BuildContext context) async {
    openBottomSheet(
      context,
      PopupFramework(
        title: "Select Period",
        child: RadioItems(
          items: ["Daily", "Weekly", "Monthly", "Yearly"],
          initial: selectedRecurrence,
          onChanged: (value) {
            setState(() {
              selectedRecurrence = value;
              selectedRecurrenceEnum = enumRecurrence[value];
              if (selectedPeriodLength == 1) {
                selectedRecurrenceDisplay = nameRecurrence[value];
              } else {
                selectedRecurrenceDisplay = namesRecurrence[value];
              }
            });
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void setSelectedIncome(bool value) {
    setState(() {
      selectedIncome = value;
    });
  }

  Future addTransaction() async {
    print("Added transaction");
    if (selectedTitle != null &&
        selectedCategory != null &&
        selectedTitle != "")
      await addAssociatedTitles(selectedTitle!, selectedCategory!);
    Transaction createdTransaction = await createTransaction();
    if ([
      TransactionSpecialType.repetitive,
      TransactionSpecialType.subscription,
      TransactionSpecialType.upcoming
    ].contains(createdTransaction.type)) {
      await setUpcomingNotifications(context);
    }
    await database.createOrUpdateTransaction(await createTransaction());
  }

  Future<Transaction> createTransaction() async {
    return Transaction(
      transactionPk: widget.transaction != null
          ? widget.transaction!.transactionPk
          : DateTime.now().millisecondsSinceEpoch,
      name: (selectedTitle ?? "").trim(),
      amount: (selectedIncome
          ? (selectedAmount ?? 0).abs()
          : (selectedAmount ?? 0).abs() * -1),
      note: selectedNote ?? "",
      categoryFk: selectedCategory?.categoryPk ?? 0,
      dateCreated: selectedDate,
      income: selectedIncome,
      walletFk: appStateSettings["selectedWallet"],
      paid: widget.transaction != null
          ? widget.transaction!.paid
          : selectedType == null,
      skipPaid: widget.transaction != null
          ? widget.transaction!.skipPaid
          : selectedType == null,
      type: selectedType,
      reoccurrence: widget.transaction != null
          ? widget.transaction!.reoccurrence
          : selectedRecurrenceEnum,
      periodLength: widget.transaction != null
          ? widget.transaction!.periodLength
          : selectedPeriodLength,
      methodAdded:
          widget.transaction != null ? widget.transaction!.methodAdded : null,
      createdAnotherFutureTransaction: widget.transaction != null
          ? widget.transaction!.createdAnotherFutureTransaction
          : null,
      dateTimeCreated: widget.transaction != null
          ? widget.transaction!.dateTimeCreated
          : DateTime.now(),
      sharedKey:
          widget.transaction != null ? widget.transaction!.sharedKey : null,
      transactionOwnerEmail: widget.transaction != null
          ? selectedPayer
          : selectedCategory?.sharedKey != null
              ? selectedPayer
              : null,
      transactionOriginalOwnerEmail: widget.transaction != null
          ? widget.transaction!.transactionOriginalOwnerEmail
          : null,
      sharedStatus:
          widget.transaction != null ? widget.transaction!.sharedStatus : null,
      sharedDateUpdated: widget.transaction != null
          ? widget.transaction!.sharedDateUpdated
          : null,
    );
  }

  late TextEditingController _titleInputController;
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
      selectedTitle = widget.transaction!.name;
      selectedNote = widget.transaction!.note;
      selectedDate = widget.transaction!.dateCreated;
      selectedAmount = widget.transaction!.amount.abs();
      selectedType = widget.transaction!.type;
      selectedTypeDisplay =
          transactionTypeDisplayToEnum[widget.transaction!.type] ?? "Default";
      selectedPeriodLength = widget.transaction!.periodLength ?? 0;
      selectedRecurrenceEnum =
          widget.transaction!.reoccurrence ?? BudgetReoccurence.monthly;
      selectedRecurrence = enumRecurrence[selectedRecurrenceEnum];
      if (selectedPeriodLength == 1) {
        selectedRecurrenceDisplay = nameRecurrence[selectedRecurrence];
      } else {
        selectedRecurrenceDisplay = namesRecurrence[selectedRecurrence];
      }
      selectedIncome = widget.transaction!.income;
      selectedPayer = widget.transaction!.transactionOwnerEmail;
      // var amountString = widget.transaction!.amount.toStringAsFixed(2);
      // if (amountString.substring(amountString.length - 2) == "00") {
      //   selectedAmountCalculation =
      //       amountString.substring(0, amountString.length - 3);
      // } else {
      //   selectedAmountCalculation = amountString;
      // }
      textAddTransaction = "Edit Transaction";

      WidgetsBinding.instance.addPostFrameCallback((_) {
        updateInitial();
      });
    } else {
      if (widget.subscription != null) {
        selectedTypeDisplay = "Subscription";
        selectedType = TransactionSpecialType.subscription;
      }

      _titleInputController = new TextEditingController();
      _noteInputController = new TextEditingController();

      Future.delayed(Duration(milliseconds: 0), () {
        openBottomSheet(
            context,
            appStateSettings["askForTransactionTitle"]
                ? PopupFramework(
                    child: SelectTitle(
                      selectedTitle: selectedTitle,
                      setSelectedTitle: setSelectedTitleController,
                      setSelectedTags: setSelectedTags,
                      selectedCategory: selectedCategory,
                      setSelectedCategory: setSelectedCategory,
                      next: () {
                        openBottomSheet(context, afterSetTitle());
                      },
                    ),
                  )
                : afterSetTitle(),
            snap: appStateSettings["askForTransactionTitle"] != true);
      });
    }
  }

  Widget afterSetTitle() {
    return PopupFramework(
      title: "Select Category",
      child: Column(
        children: [
          SelectCategory(
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
          selectedCategory != null
              ? CategoryIcon(
                  categoryPk: 0,
                  size: 50,
                  category: selectedCategory,
                )
              : Container()
        ],
      ),
    );
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
    return WillPopScope(
      onWillPop: () async {
        if (widget.transaction != null) {
          discardChangesPopup(
            context,
            previousObject: widget.transaction,
            currentObject: await createTransaction(),
          );
        } else {
          return true;
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
                dragDownToDismiss: true,
                navbar: false,
                onBackButton: () async {
                  if (widget.transaction != null) {
                    discardChangesPopup(
                      context,
                      previousObject: widget.transaction,
                      currentObject: await createTransaction(),
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
                onDragDownToDissmiss: () async {
                  if (widget.transaction != null) {
                    discardChangesPopup(
                      context,
                      previousObject: widget.transaction,
                      currentObject: await createTransaction(),
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
                listWidgets: [
                  AnimatedContainer(
                    curve: Curves.easeInOut,
                    duration: Duration(milliseconds: 300),
                    color: HexColor(
                      selectedCategory?.colour,
                      defaultColor: dynamicPastel(
                        context,
                        Theme.of(context).colorScheme.primary,
                        amount: appStateSettings["materialYou"] ? 0.55 : 0.2,
                      ),
                    ).withOpacity(0.55),
                    child: Row(
                      children: [
                        Tappable(
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
                          color: Colors.transparent,
                          child: Container(
                            height: 136,
                            padding: const EdgeInsets.only(left: 17, right: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedSwitcher(
                                  duration: Duration(milliseconds: 300),
                                  child: CategoryIcon(
                                    canEditByLongPress: false,
                                    noBackground: true,
                                    key: ValueKey(
                                        selectedCategory?.categoryPk ?? ""),
                                    categoryPk:
                                        selectedCategory?.categoryPk ?? 0,
                                    size: 60,
                                    sharedIconOffset: -7,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Tappable(
                            color: Colors.transparent,
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
                                                // await addTransaction();
                                                // Navigator.pop(context);
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
                            child: Container(
                              padding: const EdgeInsets.only(right: 37),
                              height: 136,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(height: 5),
                                  CountNumber(
                                    count: selectedAmount ?? 0,
                                    duration: Duration(milliseconds: 1000),
                                    dynamicDecimals: true,
                                    initialCount: selectedAmount ?? 0,
                                    textBuilder: (number) {
                                      return TextFont(
                                        textAlign: TextAlign.right,
                                        text: convertToMoney(number),
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        maxLines: 1,
                                      );
                                    },
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
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        Container(height: 20),
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          child: DateButton(
                            key: ValueKey(selectedDate.toString()),
                            onTap: () {
                              selectDate(context);
                            },
                            selectedDate: selectedDate,
                            setSelectedDate: setSelectedDate,
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          child: TypeButton(
                            key: ValueKey(selectedTypeDisplay.toString()),
                            onTap: () => openBottomSheet(
                              context,
                              PopupFramework(
                                title: "Select Type",
                                child: RadioItems(
                                  items: [
                                    transactionTypeDisplayToEnum[null],
                                    transactionTypeDisplayToEnum[
                                        TransactionSpecialType.upcoming],
                                    transactionTypeDisplayToEnum[
                                        TransactionSpecialType.subscription],
                                    transactionTypeDisplayToEnum[
                                        TransactionSpecialType.repetitive]
                                  ],
                                  initial: selectedTypeDisplay,
                                  onChanged: (value) {
                                    setSelectedType(value);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            ),
                            selectedType: selectedType,
                            selectedTypeDisplay: selectedTypeDisplay,
                          ),
                        ),
                        AnimatedSize(
                          duration: Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            child: selectedType ==
                                        TransactionSpecialType.repetitive ||
                                    selectedType ==
                                        TransactionSpecialType.subscription
                                ? Wrap(
                                    key: ValueKey(1),
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      TextFont(
                                        text: "Repeat every",
                                        fontSize: 23,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TappableTextEntry(
                                            title:
                                                selectedPeriodLength.toString(),
                                            placeholder: "0",
                                            showPlaceHolderWhenTextEquals: "0",
                                            onTap: () {
                                              selectPeriodLength(context);
                                            },
                                            fontSize: 23,
                                            fontWeight: FontWeight.bold,
                                            internalPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 4, horizontal: 4),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 3),
                                          ),
                                          TappableTextEntry(
                                            title: selectedRecurrenceDisplay,
                                            placeholder: "",
                                            onTap: () {
                                              selectRecurrence(context);
                                            },
                                            fontSize: 23,
                                            fontWeight: FontWeight.bold,
                                            internalPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 4, horizontal: 4),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 3),
                                          ),
                                        ],
                                      )
                                    ],
                                  )
                                : Container(),
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 400),
                          child: IncomeTypeButton(
                            key: ValueKey(selectedIncome),
                            onTap: () {
                              setSelectedIncome(!selectedIncome);
                            },
                            selectedIncome: selectedIncome,
                          ),
                        ),
                        AnimatedSize(
                          duration: Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            child: selectedCategory != null &&
                                    selectedCategory!.sharedKey != null
                                ? AnimatedSwitcher(
                                    duration: Duration(milliseconds: 400),
                                    child: TransactionOwnerButton(
                                      key: ValueKey(selectedPayer),
                                      onTap: () => openBottomSheet(
                                        context,
                                        PopupFramework(
                                          title: "Select Payer",
                                          child: RadioItems(
                                            items: selectedCategory!
                                                    .sharedMembers ??
                                                [],
                                            initial: selectedPayer ?? "",
                                            onChanged: (value) {
                                              setSelectedPayer(value);
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ),
                                      ),
                                      selectedOwner: selectedPayer ?? "",
                                    ),
                                  )
                                : Container(),
                          ),
                        ),

                        Container(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: Tappable(
                            color:
                                Theme.of(context).colorScheme.canvasContainer,
                            onTap: () {
                              openBottomSheet(
                                context,
                                PopupFramework(
                                  child: SelectTitle(
                                    setSelectedTitle: setSelectedTitle,
                                    setSelectedCategory: setSelectedCategory,
                                    setSelectedTags: setSelectedTags,
                                    selectedTitle: selectedTitle,
                                  ),
                                ),
                              );
                            },
                            borderRadius: 15,
                            child: kIsWeb
                                ? TextInput(
                                    padding: EdgeInsets.zero,
                                    labelText: "Title",
                                    icon: Icons.title_rounded,
                                    controller: _titleInputController,
                                    onChanged: (text) async {
                                      setSelectedTitle(text);
                                    },
                                  )
                                : IgnorePointer(
                                    child: TextInput(
                                      padding: EdgeInsets.zero,
                                      readOnly: true,
                                      labelText: "Title",
                                      icon: Icons.title_rounded,
                                      controller: _titleInputController,
                                    ),
                                  ),
                          ),
                        ),
                        Container(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: Tappable(
                            color:
                                Theme.of(context).colorScheme.canvasContainer,
                            onTap: () {
                              openBottomSheet(
                                context,
                                PopupFramework(
                                  child: SelectNotes(
                                    setSelectedNote: setSelectedNoteController,
                                    selectedNote: selectedNote,
                                  ),
                                ),
                                snap: false,
                              );
                            },
                            borderRadius: 15,
                            child: kIsWeb
                                ? TextInput(
                                    padding: EdgeInsets.zero,
                                    labelText: "Notes",
                                    icon: Icons.edit,
                                    controller: _noteInputController,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    minLines: 3,
                                    onChanged: (text) async {
                                      setSelectedNoteController(text);
                                    },
                                  )
                                : IgnorePointer(
                                    child: TextInput(
                                      padding: EdgeInsets.zero,
                                      readOnly: true,
                                      labelText: "Notes",
                                      icon: Icons.edit,
                                      controller: _noteInputController,
                                      keyboardType: TextInputType.multiline,
                                      maxLines: null,
                                      minLines: 3,
                                    ),
                                  ),
                          ),
                        ),
                        widget.transaction == null ||
                                widget.transaction!.sharedDateUpdated == null
                            ? SizedBox.shrink()
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 28),
                                child: TextFont(
                                  text: "Synced " +
                                      getTimeAgo(
                                        widget.transaction!.sharedDateUpdated!,
                                      ).toLowerCase() +
                                      "\n Created by " +
                                      (widget.transaction!
                                              .transactionOriginalOwnerEmail ??
                                          ""),
                                  fontSize: 13,
                                  textColor:
                                      Theme.of(context).colorScheme.textLight,
                                  textAlign: TextAlign.center,
                                  maxLines: 4,
                                ),
                              ),

                        // Padding(
                        //   padding: EdgeInsets.symmetric(horizontal: 24),
                        //   child: Column(
                        //     children: [
                        //       Container(height: 20),
                        //       TextInput(
                        //         backgroundColor:
                        //             Theme.of(context).colorScheme.canvasContainer,
                        //         padding: EdgeInsets.zero,
                        //
                        //         labelText: "Title",
                        //         icon: Icons.title_rounded,
                        //         controller: _titleInputController,
                        //       ),
                        //       Container(height: 14),
                        //       TextInput(
                        //         backgroundColor:
                        //             Theme.of(context).colorScheme.canvasContainer,
                        //         padding: EdgeInsets.zero,
                        //
                        //         labelText: "Notes",
                        //         icon: Icons.edit,
                        //         controller: _noteInputController,
                        //         keyboardType: TextInputType.multiline,
                        //         maxLines: null,
                        //         minLines: 3,
                        //       ),
                        //       Container(height: 20),
                        //     ],
                        //   ),
                        // ),
                        Container(height: 20),
                        Container(height: 100),
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
                                          print("HELLO");
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
                        },
                        hasBottomExtraSafeArea: true,
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
                                  title: "Enter Amount",
                                  child: SelectAmount(
                                    amountPassed:
                                        selectedAmountCalculation ?? "",
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
                            hasBottomExtraSafeArea: true,
                          )
                        : Button(
                            label: widget.transaction != null
                                ? "Save Changes"
                                : textAddTransaction ?? "",
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            onTap: () async {
                              await addTransaction();
                              Navigator.of(context).pop();
                            },
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

class TransactionOwnerButton extends StatelessWidget {
  const TransactionOwnerButton({
    Key? key,
    required this.onTap,
    required this.selectedOwner,
  }) : super(key: key);
  final VoidCallback onTap;
  final String selectedOwner;
  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      borderRadius: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: TextFont(
                text: selectedOwner,
                fontWeight: FontWeight.bold,
                fontSize: 26,
                textColor: Theme.of(context).colorScheme.black,
              ),
            ),
            ButtonIcon(
              onTap: onTap,
              icon: Icons.person_rounded,
              size: 41,
            ),
          ],
        ),
      ),
    );
  }
}

class TypeButton extends StatelessWidget {
  const TypeButton(
      {Key? key,
      required this.onTap,
      required this.selectedType,
      required this.selectedTypeDisplay})
      : super(key: key);
  final VoidCallback onTap;
  final TransactionSpecialType? selectedType;
  final String selectedTypeDisplay;
  @override
  Widget build(BuildContext context) {
    IconData iconData = getTransactionTypeIcon(selectedType);
    return Tappable(
      onTap: onTap,
      borderRadius: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: TextFont(
                text: selectedType == null
                    ? "Default transaction"
                    : selectedTypeDisplay,
                fontWeight: FontWeight.bold,
                fontSize: 26,
                textColor: selectedType == null
                    ? Theme.of(context).colorScheme.textLight
                    : null,
              ),
            ),
            ButtonIcon(
              onTap: onTap,
              icon: iconData,
              size: 41,
            ),
          ],
        ),
      ),
    );
  }
}

class DateButton extends StatelessWidget {
  const DateButton(
      {Key? key,
      required this.onTap,
      required this.selectedDate,
      required this.setSelectedDate})
      : super(key: key);
  final VoidCallback onTap;
  final DateTime selectedDate;
  final Function(DateTime) setSelectedDate;
  @override
  Widget build(BuildContext context) {
    String wordedDate = getWordedDateShortMore(selectedDate);

    return Tappable(
      onTap: onTap,
      borderRadius: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: TextFont(
                text: wordedDate,
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
            wordedDate == "Today"
                ? Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Tappable(
                      borderRadius: 10,
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10),
                        child: TextFont(
                          text: "Yesterday?",
                          fontSize: 15,
                          textColor: Theme.of(context).colorScheme.textLight,
                        ),
                      ),
                      onTap: () {
                        setSelectedDate(DateTime(DateTime.now().year,
                            DateTime.now().month, DateTime.now().day - 1));
                      },
                    ),
                  )
                : SizedBox(),
            ButtonIcon(
              onTap: onTap,
              icon: Icons.calendar_month_rounded,
              size: 41,
            ),
          ],
        ),
      ),
    );
  }
}

class SelectNotes extends StatefulWidget {
  SelectNotes({
    Key? key,
    required this.setSelectedNote,
    this.selectedNote,
    this.next,
  }) : super(key: key);
  final Function(String) setSelectedNote;
  final String? selectedNote;
  final VoidCallback? next;

  @override
  _SelectNotesState createState() => _SelectNotesState();
}

class _SelectNotesState extends State<SelectNotes> {
  String? input = "";

  @override
  void initState() {
    super.initState();
    input = widget.selectedNote;
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
                  text: "Enter Notes",
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
                Container(height: 14),
                Container(
                  width: MediaQuery.of(context).size.width - 36,
                  child: TextInput(
                    // icon: Icons.title_rounded,
                    initialValue: widget.selectedNote,
                    autoFocus: true,
                    onEditingComplete: () {
                      //if selected a tag and a category is set, then go to enter amount
                      //else enter amount
                      widget.setSelectedNote(input ?? "");
                      Navigator.pop(context);
                      if (widget.next != null) {
                        widget.next!();
                      }
                    },
                    onChanged: (text) {
                      input = text;
                      widget.setSelectedNote(input!);
                    },
                    labelText: "Notes",
                    padding: EdgeInsets.zero,
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    minLines: 5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
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
  bool foundFromCategory = false;
  TransactionCategory? selectedCategory;
  TransactionAssociatedTitle? selectedAssociatedTitle;

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
                Container(height: 14),
                Container(
                  width: MediaQuery.of(context).size.width - 36,
                  child: TextInput(
                    icon: Icons.title_rounded,
                    initialValue: widget.selectedTitle,
                    autoFocus: true,
                    onEditingComplete: () {
                      //if selected a tag and a category is set, then go to enter amount
                      //else enter amount
                      widget.setSelectedTitle(input ?? "");
                      if (selectedCategory != null) {
                        widget.setSelectedCategory(selectedCategory!);
                      }
                      Navigator.pop(context);
                      if (widget.next != null) {
                        widget.next!();
                      }
                    },
                    onChanged: (text) async {
                      input = text;
                      widget.setSelectedTitle(input!);

                      List result = await getRelatingAssociatedTitle(text);
                      TransactionAssociatedTitle? selectedTitleLocal =
                          result[0];
                      int categoryFk = result[1];
                      bool foundFromCategoryLocal = result[2];

                      if (categoryFk != -1 &&
                          categoryFk != 0 &&
                          selectedTitleLocal != null) {
                        TransactionCategory? foundCategory =
                            await database.getCategoryInstance(categoryFk);
                        // Update the size of the bottom sheet
                        Future.delayed(Duration(milliseconds: 100), () {
                          bottomSheetControllerGlobal.snapToExtent(0);
                        });
                        setState(() {
                          selectedCategory = foundCategory;
                          selectedAssociatedTitle = selectedTitleLocal;
                          foundFromCategory = foundFromCategoryLocal;
                        });
                      } else {
                        setState(() {
                          selectedCategory = null;
                          selectedAssociatedTitle = null;
                          foundFromCategory = foundFromCategoryLocal;
                        });
                        // Update the size of the bottom sheet
                        Future.delayed(Duration(milliseconds: 300), () {
                          bottomSheetControllerGlobal.snapToExtent(0);
                        });
                      }
                    },
                    labelText: "Title",
                    padding: EdgeInsets.zero,
                  ),
                ),
                AnimatedSize(
                  duration: Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 250),
                    child: selectedCategory == null
                        ? Container(
                            key: ValueKey(0),
                            width: MediaQuery.of(context).size.width - 36,
                          )
                        : Container(
                            key: ValueKey(selectedCategory!.categoryPk),
                            width: MediaQuery.of(context).size.width - 36,
                            padding: EdgeInsets.only(top: 13),
                            child: Tappable(
                              borderRadius: 15,
                              color: Colors.transparent,
                              onTap: () {
                                widget.setSelectedCategory(selectedCategory!);
                                Navigator.pop(context);
                                if (widget.next != null) {
                                  widget.next!();
                                }
                              },
                              child: Row(
                                children: [
                                  CategoryIcon(
                                    categoryPk: 0,
                                    size: 40,
                                    category: selectedCategory,
                                    margin: EdgeInsets.zero,
                                    sharedIconOffset: 4,
                                  ),
                                  SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextFont(
                                        text: selectedCategory!.name,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      !foundFromCategory
                                          ? TextFont(
                                              text: selectedAssociatedTitle!
                                                  .title,
                                              fontSize: 16,
                                            )
                                          : Container(),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                  ),
                )
              ],
            ),
          ],
        ),
        // AnimatedSwitcher(
        //   duration: Duration(milliseconds: 300),
        //   child: CategoryIcon(
        //     key: ValueKey(selectedCategory?.categoryPk ?? ""),
        //     margin: EdgeInsets.zero,
        //     categoryPk: selectedCategory?.categoryPk ?? 0,
        //     size: 55,
        //     onTap: () {
        //       openBottomSheet(
        //         context,
        //         PopupFramework(
        //           title: "Select Category",
        //           child: SelectCategory(
        //             setSelectedCategory: (TransactionCategory category) {
        //               widget.setSelectedCategory(category);
        //               setState(() {
        //                 selectedCategory = category;
        //               });
        //             },
        //           ),
        //         ),
        //       );
        //     },
        //   ),
        // ),
        Container(height: 20),
        widget.next != null
            ? Button(
                label: "Select Category",
                width: MediaQuery.of(context).size.width,
                height: 50,
                onTap: () {
                  Navigator.pop(context);
                  if (widget.next != null) {
                    widget.next!();
                  }
                },
              )
            : SizedBox.shrink()
      ],
    );
  }
}

// class SelectTag extends StatefulWidget {
//   SelectTag({Key? key, this.setSelectedCategory}) : super(key: key);
//   final Function(TransactionCategoryOld)? setSelectedCategory;

//   @override
//   _SelectTagState createState() => _SelectTagState();
// }

// class _SelectTagState extends State<SelectTag> {
//   int selectedIndex = 0;
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: Center(
//         child: Wrap(
//           alignment: WrapAlignment.center,
//           spacing: 10,
//           children: listTag()
//               .asMap()
//               .map(
//                 (index, tag) => MapEntry(
//                   index,
//                   TagIcon(
//                     tag: tag,
//                     size: 17,
//                     onTap: () {},
//                   ),
//                 ),
//               )
//               .values
//               .toList(),
//         ),
//       ),
//     );
//   }
// }

class SelectText extends StatefulWidget {
  SelectText({
    Key? key,
    required this.setSelectedText,
    this.selectedText,
    this.labelText = "",
    this.next,
    this.nextWithInput,
    this.placeholder,
  }) : super(key: key);
  final Function(String) setSelectedText;
  final String? selectedText;
  final VoidCallback? next;
  final Function(String)? nextWithInput;
  final String labelText;
  final String? placeholder;

  @override
  _SelectTextState createState() => _SelectTextState();
}

class _SelectTextState extends State<SelectText> {
  String? input = "";

  @override
  void initState() {
    super.initState();
    input = widget.selectedText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width - 36,
          child: TextInput(
            icon: Icons.title_rounded,
            initialValue: widget.selectedText,
            autoFocus: true,
            onEditingComplete: () {
              widget.setSelectedText(input ?? "");
              Navigator.pop(context);
              if (widget.next != null) {
                widget.next!();
              }
              if (widget.nextWithInput != null) {
                widget.nextWithInput!(input ?? "");
              }
            },
            onChanged: (text) {
              input = text;
              widget.setSelectedText(input!);
            },
            labelText: widget.placeholder ?? widget.labelText,
            padding: EdgeInsets.zero,
          ),
        ),
        Container(height: 14),
      ],
    );
  }
}

class EnterTextButton extends StatefulWidget {
  const EnterTextButton({
    Key? key,
    required this.title,
    required this.placeholder,
    this.defaultValue,
    required this.setSelectedText,
    this.icon,
  }) : super(key: key);

  final String title;
  final String placeholder;
  final String? defaultValue;
  final Function(String) setSelectedText;
  final IconData? icon;

  @override
  State<EnterTextButton> createState() => _EnterTextButtonState();
}

class _EnterTextButtonState extends State<EnterTextButton> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    if (widget.defaultValue != null) {
      _textController = new TextEditingController(text: widget.defaultValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 19),
      child: Tappable(
        color: Theme.of(context).colorScheme.canvasContainer,
        onTap: () {
          openBottomSheet(
            context,
            PopupFramework(
              title: widget.title,
              child: SelectText(
                setSelectedText: (text) {
                  setTextInput(_textController, text);
                  widget.setSelectedText(text);
                },
                labelText: widget.title,
                selectedText: _textController.text,
                placeholder: widget.placeholder,
              ),
            ),
          );
        },
        borderRadius: 15,
        child: IgnorePointer(
          child: TextInput(
            padding: EdgeInsets.zero,
            readOnly: true,
            labelText: widget.placeholder,
            icon: widget.icon,
            controller: _textController,
          ),
        ),
      ),
    );
  }
}

getRelatingAssociatedTitleLimited(String text) async {
  int categoryFk = -1;
  bool foundFromCategoryLocal = false;
  TransactionAssociatedTitle? selectedTitleLocal;

  TransactionAssociatedTitle relatingTitle;
  try {
    relatingTitle = await database.getRelatingAssociatedTitle(text);
    categoryFk = relatingTitle.categoryFk;
    selectedTitleLocal = relatingTitle;
  } catch (e) {
    print("No relating titles found!");
  }

  if (categoryFk == -1) {
    TransactionCategory relatingCategory;
    try {
      relatingCategory = await database.getRelatingCategory(text);
    } catch (e) {
      print("No category names found!");
      return [selectedTitleLocal, categoryFk, foundFromCategoryLocal];
    }

    TransactionCategory category = relatingCategory;
    categoryFk = category.categoryPk;
    selectedTitleLocal = TransactionAssociatedTitle(
      associatedTitlePk: 0,
      title: category.name,
      categoryFk: category.categoryPk,
      dateCreated: category.dateCreated,
      order: category.order,
      isExactMatch: false,
    );
    foundFromCategoryLocal = true;
  }
  return [selectedTitleLocal, categoryFk, foundFromCategoryLocal];
}

getRelatingAssociatedTitle(String text) async {
  List<TransactionAssociatedTitle> allTitles =
      (await database.getAllAssociatedTitles());

  int categoryFk = -1;
  TransactionAssociatedTitle? selectedTitleLocal;
  for (TransactionAssociatedTitle title in allTitles) {
    if (text.toLowerCase().contains(title.title.toLowerCase())) {
      categoryFk = title.categoryFk;
      selectedTitleLocal = title;
      break;
    }
  }

  bool foundFromCategoryLocal = false;
  if (categoryFk == -1) {
    List<TransactionCategory> allCategories =
        (await database.getAllCategories());
    for (TransactionCategory category in allCategories) {
      if (text.toLowerCase().contains(category.name.toLowerCase())) {
        categoryFk = category.categoryPk;
        selectedTitleLocal = TransactionAssociatedTitle(
          associatedTitlePk: 0,
          title: category.name,
          categoryFk: category.categoryPk,
          dateCreated: category.dateCreated,
          order: category.order,
          isExactMatch: false,
        );
        foundFromCategoryLocal = true;

        break;
      }
    }
  }
  return [selectedTitleLocal, categoryFk, foundFromCategoryLocal];
}

addAssociatedTitles(
    String selectedTitle, TransactionCategory selectedCategory) async {
  if (appStateSettings["autoAddAssociatedTitles"]) {
    List result = await getRelatingAssociatedTitle(selectedTitle);

    TransactionAssociatedTitle? foundTitle = result[0];

    if (foundTitle == null ||
        (foundTitle.categoryFk != selectedCategory.categoryPk ||
                foundTitle.title.trim() != selectedTitle.trim()) &&
            !(foundTitle.categoryFk == selectedCategory.categoryPk &&
                foundTitle.title.trim() == selectedTitle.trim())) {
      //Should just add to the end but be sorted in opposite direction on edit titles page
      //Also when it loops through getRelatingAssociatedTitle it should reverse the order
      // It's way faster to avoid pushing elements all down by 1 spot
      // I think it also fixes race conditions when writing quickly to the db
      // print("successfully added title " + selectedTitle);
      //it makes sense to add a new title if the exisitng one is from a different category, it will bump this one down and take priority
      int length = await database.getAmountOfAssociatedTitles();

      await database.createOrUpdateAssociatedTitle(
        TransactionAssociatedTitle(
          associatedTitlePk: DateTime.now().millisecondsSinceEpoch,
          categoryFk: selectedCategory.categoryPk,
          isExactMatch: false,
          title: selectedTitle.trim(),
          dateCreated: DateTime.now(),
          order: length,
        ),
      );
    }
  }
}
