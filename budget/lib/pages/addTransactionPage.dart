import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/sharedBudgetSettings.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/initializeNotifications.dart';
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
import 'package:budget/widgets/saveBottomButton.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:budget/colors.dart';

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
    this.selectedBudget,
  }) : super(key: key);
  final String title;

  //When a transaction is passed in, we are editing that transaction
  final Transaction? transaction;
  final bool? subscription;
  final Budget? selectedBudget;

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage>
    with SingleTickerProviderStateMixin {
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
  int selectedPeriodLength = 1;
  String selectedRecurrence = "Monthly";
  String selectedRecurrenceDisplay = "month";
  BudgetReoccurence selectedRecurrenceEnum = BudgetReoccurence.monthly;
  bool selectedIncome = false;
  String? selectedPayer;
  int? selectedBudgetPk;
  Budget? selectedBudget;
  bool selectedBudgetIsShared = false;
  int selectedWalletPk = appStateSettings["selectedWallet"];
  TransactionWallet? selectedWallet;
  late TabController _incomeTabController =
      TabController(length: 2, vsync: this);

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
    setSelectedIncome(category.income);
    setState(() {
      selectedCategory = category;
    });
    return;
  }

  void setSelectedAmount(double amount, String amountCalculation) {
    if (amount == double.infinity ||
        amount == double.negativeInfinity ||
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

  void setSelectedTitle(String title, {bool setInput = true}) {
    if (setInput) setTextInput(_titleInputController, title);
    selectedTitle = title.trim();
    return;
  }

  void setSelectedTitleController(String title, {bool setInput = true}) {
    if (setInput) setTextInput(_titleInputController, title);
    selectedTitle = title;
    return;
  }

  void setSelectedTags(List<String> tags) {
    setState(() {
      selectedTags = tags;
    });
  }

  void setSelectedNoteController(String note) {
    // setTextInput(_noteInputController, note);
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

  void setSelectedBudgetPk(Budget? selectedBudgetPassed,
      {bool isSharedBudget = false}) {
    setState(() {
      selectedBudgetPk =
          selectedBudgetPassed == null ? null : selectedBudgetPassed.budgetPk;
      selectedBudget = selectedBudgetPassed;
      selectedBudgetIsShared = isSharedBudget;
      if (selectedBudgetPk != null && selectedPayer == null)
        selectedPayer = appStateSettings["currentUserEmail"];
      if (isSharedBudget == false || selectedBudgetPassed?.sharedKey == null) {
        selectedPayer = null;
      }
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
    _incomeTabController.animateTo(value == true ? 1 : 0);
  }

  void setSelectedWalletPk(TransactionWallet selectedWalletPassed) {
    setState(() {
      selectedWalletPk = selectedWalletPassed.walletPk;
      selectedWallet = selectedWalletPassed;
    });
  }

  Future<bool> addTransaction() async {
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

    await database.createOrUpdateTransaction(
      await createTransaction(),
      originalTransaction: widget.transaction,
    );
    return true;
  }

  Future<Transaction> createTransaction(
      {bool removeShared = false, bool addInNewTime = true}) async {
    Transaction createdTransaction = Transaction(
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
      dateTimeModified: null,
      income: selectedIncome,
      walletFk: selectedWalletPk,
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
      dateTimeCreated: addInNewTime == false && widget.transaction != null
          ? widget.transaction!.dateTimeCreated
          : DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              DateTime.now().hour,
              DateTime.now().minute,
              DateTime.now().second,
              DateTime.now().millisecond,
              DateTime.now().microsecond,
            ),
      sharedKey: removeShared == false && widget.transaction != null
          ? widget.transaction!.sharedKey
          : null,
      sharedOldKey:
          widget.transaction != null ? widget.transaction!.sharedOldKey : null,
      transactionOwnerEmail: selectedPayer,
      transactionOriginalOwnerEmail:
          removeShared == false && widget.transaction != null
              ? widget.transaction!.transactionOriginalOwnerEmail
              : null,
      sharedStatus: removeShared == false && widget.transaction != null
          ? widget.transaction!.sharedStatus
          : null,
      sharedDateUpdated: removeShared == false && widget.transaction != null
          ? widget.transaction!.sharedDateUpdated
          : null,
      sharedReferenceBudgetPk: selectedBudgetPk,
      upcomingTransactionNotification: widget.transaction != null
          ? widget.transaction!.upcomingTransactionNotification
          : null,
    );

    if (widget.transaction != null &&
        widget.transaction!.type != null &&
        createdTransaction.type == null) {
      createdTransaction = createdTransaction.copyWith(paid: true);
    }

    return createdTransaction;
  }

  late TextEditingController _titleInputController;
  late TextEditingController _noteInputController;
  List<Budget> allSharedBudgets = [];
  List<Budget> allAddedTransactionBudgets = [];
  List<TransactionWallet> allWallets = [];

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
      selectedWalletPk = widget.transaction!.walletFk;
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
      _incomeTabController.animateTo(selectedIncome == true ? 1 : 0);
      selectedPayer = widget.transaction!.transactionOwnerEmail;
      selectedBudgetPk = widget.transaction!.sharedReferenceBudgetPk;
      // var amountString = widget.transaction!.amount.toStringAsFixed(2);
      // if (amountString.substring(amountString.length - 2) == "00") {
      //   selectedAmountCalculation =
      //       amountString.substring(0, amountString.length - 3);
      // } else {
      //   selectedAmountCalculation = amountString;
      // }
      textAddTransaction = "Save Changes";

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
    Future.delayed(Duration.zero, () async {
      allSharedBudgets = await database.getAllBudgets(sharedBudgetsOnly: true);
      allAddedTransactionBudgets =
          await database.getAllBudgetsAddedTransactionsOnly();
      allWallets = await database.getAllWallets();
      selectedWallet = await database.getWalletInstance(
          widget.transaction == null
              ? appStateSettings["selectedWallet"]
              : widget.transaction!.walletFk);
      setState(() {});
    });
    if (widget.selectedBudget != null) {
      selectedBudget = widget.selectedBudget;
      selectedBudgetPk = widget.selectedBudget!.budgetPk;
      selectedPayer = appStateSettings["currentUserEmail"];
      selectedBudgetIsShared = widget.selectedBudget!.sharedKey != null;
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
                  underTitleSpace: false,
                  padding: false,
                  child: SelectAmount(
                    allWallets: allWallets,
                    selectedWallet: selectedWallet,
                    setSelectedWallet: setSelectedWalletPk,
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    walletPkForCurrency: selectedWalletPk,
                    onlyShowCurrencyIcon:
                        appStateSettings["selectedWallet"] == selectedWalletPk,
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
      Budget? getBudget;
      try {
        getBudget = await database.getBudgetInstance(
            widget.transaction!.sharedReferenceBudgetPk ?? -1);
      } catch (e) {}

      setState(() {
        selectedCategory = getSelectedCategory;
        selectedBudget = getBudget;
        selectedBudgetIsShared =
            getBudget == null ? false : getBudget.sharedKey != null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Color categoryColor = dynamicPastel(
      context,
      HexColor(
        selectedCategory?.colour,
        defaultColor: dynamicPastel(
          context,
          Theme.of(context).colorScheme.primary,
          amount: appStateSettings["materialYou"] ? 0.55 : 0.2,
        ),
      ),
      amount: 0.35,
    );
    return WillPopScope(
      onWillPop: () async {
        if (widget.transaction != null) {
          discardChangesPopup(
            context,
            previousObject: widget.transaction,
            currentObject: await createTransaction(addInNewTime: false),
          );
        } else {
          return true;
        }
        return false;
      },
      child: GestureDetector(
        onTap: () {
          //Minimize keyboard when tap non interactive widget
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: PageFramework(
          resizeToAvoidBottomInset: true,
          title: widget.title,
          dragDownToDismiss: true,
          navbar: false,
          onBackButton: () async {
            if (widget.transaction != null) {
              discardChangesPopup(
                context,
                previousObject: widget.transaction,
                currentObject: await createTransaction(addInNewTime: false),
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
                currentObject: await createTransaction(addInNewTime: false),
              );
            } else {
              Navigator.pop(context);
            }
          },
          actions: [
            widget.transaction != null
                ? IconButton(
                    tooltip: "Delete transaction",
                    onPressed: () {
                      openPopup(
                        context,
                        title: "Delete transaction?",
                        description:
                            "Are you sure you want to delete this transaction?",
                        icon: Icons.delete_rounded,
                        onCancel: () {
                          Navigator.pop(context);
                        },
                        onCancelLabel: "Cancel",
                        onSubmit: () {
                          database.deleteTransaction(
                              widget.transaction!.transactionPk);
                          openSnackbar(
                            SnackbarMessage(
                              title: "Deleted transaction",
                              icon: Icons.delete_rounded,
                            ),
                          );
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        onSubmitLabel: "Delete",
                      );
                    },
                    icon: Icon(Icons.delete_rounded),
                  )
                : SizedBox.shrink()
          ],
          overlay: Align(
            alignment: Alignment.bottomCenter,
            child: selectedCategory == null
                ? SaveBottomButton(
                    label: "Select Category",
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
                              if (selectedAmount == null)
                                openBottomSheet(
                                  context,
                                  PopupFramework(
                                    title: "Enter Amount",
                                    padding: false,
                                    underTitleSpace: false,
                                    child: SelectAmount(
                                      allWallets: allWallets,
                                      selectedWallet: selectedWallet,
                                      setSelectedWallet: setSelectedWalletPk,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 18),
                                      walletPkForCurrency: selectedWalletPk,
                                      onlyShowCurrencyIcon:
                                          appStateSettings["selectedWallet"] ==
                                              selectedWalletPk,
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
                          ),
                        ),
                      );
                    },
                  )
                : selectedAmount == null
                    ? SaveBottomButton(
                        label: "Enter Amount",
                        onTap: () {
                          openBottomSheet(
                            context,
                            PopupFramework(
                              title: "Enter Amount",
                              padding: false,
                              underTitleSpace: false,
                              child: SelectAmount(
                                allWallets: allWallets,
                                selectedWallet: selectedWallet,
                                setSelectedWallet: setSelectedWalletPk,
                                padding: EdgeInsets.symmetric(horizontal: 18),
                                walletPkForCurrency: selectedWalletPk,
                                onlyShowCurrencyIcon:
                                    appStateSettings["selectedWallet"] ==
                                        selectedWalletPk,
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
                    : SaveBottomButton(
                        label: widget.transaction != null
                            ? "Save Changes"
                            : textAddTransaction ?? "",
                        onTap: () async {
                          bool result = await addTransaction();
                          if (result) Navigator.of(context).pop();
                        },
                      ),
          ),
          listWidgets: [
            AnimatedContainer(
              curve: Curves.easeInOut,
              duration: Duration(milliseconds: 300),
              color: categoryColor,
              child: Column(
                children: [
                  SizedBox(
                    height: 45,
                    child: Material(
                      color: Colors.black.withOpacity(0.2),
                      child: Theme(
                        data: ThemeData().copyWith(
                          splashColor: Theme.of(context).splashColor,
                        ),
                        child: TabBar(
                          splashFactory: Theme.of(context).splashFactory,
                          controller: _incomeTabController,
                          onTap: (value) {
                            if (value == 1)
                              setSelectedIncome(true);
                            else
                              setSelectedIncome(false);
                          },
                          dividerColor: Colors.transparent,
                          indicatorColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            color: categoryColor,
                          ),
                          labelColor: getColor(context, "black"),
                          unselectedLabelColor: Colors.white.withOpacity(0.3),
                          tabs: [
                            Tab(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Text(
                                  'Expense',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Avenir',
                                  ),
                                ),
                              ),
                            ),
                            Tab(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Text(
                                  'Income',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Avenir',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Tappable(
                        onLongPress: () {
                          pushRoute(
                            context,
                            AddCategoryPage(
                              title: selectedCategory == null
                                  ? "Add Category"
                                  : "Edit Category",
                              category: selectedCategory,
                            ),
                          );
                        },
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
                                  categoryPk: selectedCategory?.categoryPk ?? 0,
                                  size: 60,
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
                                padding: false,
                                title: "Enter Amount",
                                underTitleSpace: false,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: SelectAmount(
                                    allWallets: allWallets,
                                    selectedWallet: selectedWallet,
                                    setSelectedWallet: setSelectedWalletPk,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 18),
                                    walletPkForCurrency: selectedWalletPk,
                                    // onlyShowCurrencyIcon:
                                    //     appStateSettings[
                                    //             "selectedWallet"] ==
                                    //         selectedWalletPk,
                                    onlyShowCurrencyIcon: true,
                                    amountPassed: selectedAmountCalculation ??
                                        (selectedAmount ?? "0").toString(),
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
                                AnimatedSwitcher(
                                  duration: Duration(milliseconds: 350),
                                  child: CountNumber(
                                    key: ValueKey(selectedWalletPk),
                                    count: selectedAmount ?? 0,
                                    duration: Duration(milliseconds: 1000),
                                    dynamicDecimals: true,
                                    initialCount: selectedAmount ?? 0,
                                    textBuilder: (number) {
                                      return Align(
                                        alignment: Alignment.centerRight,
                                        child: TextFont(
                                          textAlign: TextAlign.right,
                                          text: convertToMoney(number,
                                              showCurrency: false,
                                              finalNumber: selectedAmount ?? 0),
                                          walletPkForCurrency: selectedWalletPk,
                                          onlyShowCurrencyIcon: appStateSettings[
                                                      "cachedWalletCurrencies"]
                                                  .keys
                                                  .length <=
                                              1,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          maxLines: 1,
                                        ),
                                      );
                                    },
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
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: AnimatedSwitcher(
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
                ),
                SizedBox(height: 10),
                SelectChips(
                  items: [
                    transactionTypeDisplayToEnum[null],
                    transactionTypeDisplayToEnum[
                        TransactionSpecialType.upcoming],
                    transactionTypeDisplayToEnum[
                        TransactionSpecialType.subscription],
                    transactionTypeDisplayToEnum[
                        TransactionSpecialType.repetitive]
                  ],
                  getLabel: (item) {
                    return item;
                  },
                  onSelected: (item) {
                    setSelectedType(item);
                  },
                  getSelected: (item) {
                    return selectedTypeDisplay == item;
                  },
                ),
                AnimatedSize(
                  duration: Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: selectedType == TransactionSpecialType.repetitive ||
                            selectedType == TransactionSpecialType.subscription
                        ? Wrap(
                            key: ValueKey(1),
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
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
                                    title: selectedPeriodLength.toString(),
                                    placeholder: "0",
                                    showPlaceHolderWhenTextEquals: "0",
                                    onTap: () {
                                      selectPeriodLength(context);
                                    },
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                    internalPadding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 4),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 3),
                                  ),
                                  TappableTextEntry(
                                    title: selectedRecurrenceDisplay,
                                    placeholder: "",
                                    onTap: () {
                                      selectRecurrence(context);
                                    },
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                    internalPadding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 4),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 3),
                                  ),
                                ],
                              )
                            ],
                          )
                        : Container(),
                  ),
                ),
                allSharedBudgets.length <= 0 &&
                        allAddedTransactionBudgets.length <= 0
                    ? SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: SelectChips(
                          extraWidget: AddButton(
                            onTap: () {},
                            width: 40,
                            padding: EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            openPage: AddBudgetPage(title: "Add Budget"),
                            borderRadius: 8,
                          ),
                          items: [
                            null,
                            ...[for (Budget budget in allSharedBudgets) budget],
                            ...[
                              for (Budget budget in allAddedTransactionBudgets)
                                budget
                            ]
                          ],
                          getLabel: (item) {
                            return item?.name ?? "No Budget";
                          },
                          onSelected: (item) {
                            setSelectedBudgetPk(
                              item,
                              isSharedBudget: item?.sharedKey != null,
                            );
                          },
                          getSelected: (item) {
                            return selectedBudgetPk == item?.budgetPk;
                          },
                          getCustomBorderColor: (item) {
                            return dynamicPastel(
                              context,
                              lightenPastel(
                                HexColor(
                                  item?.colour,
                                  defaultColor: Colors.transparent,
                                ),
                                amount: 0.3,
                              ),
                              amount: 0.4,
                            );
                          },
                        ),
                      ),
                AnimatedSize(
                  duration: Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: selectedBudgetPk != null &&
                            selectedBudgetIsShared == true
                        ? Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: SelectChips(
                                items: selectedBudget?.sharedMembers ?? [],
                                getLabel: (item) {
                                  return getMemberNickname(item);
                                },
                                onSelected: (item) {
                                  setSelectedPayer(item ?? "");
                                },
                                getSelected: (item) {
                                  return selectedPayer == item;
                                },
                                onLongPress: (item) {
                                  memberPopup(context, item ?? "");
                                }),
                          )
                        : Container(
                            key: ValueKey(1),
                          ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Tappable(
                    color: (appStateSettings["materialYou"]
                        ? Theme.of(context).colorScheme.secondaryContainer
                        : getColor(context, "canvasContainer")),
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
                    child: TextInput(
                      padding: EdgeInsets.zero,
                      labelText: "Title",
                      icon: Icons.title_rounded,
                      controller: _titleInputController,
                      onChanged: (text) async {
                        setSelectedTitle(text, setInput: false);
                      },
                    ),
                  ),
                ),
                Container(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Column(
                      children: [
                        Tappable(
                          color: (appStateSettings["materialYou"]
                              ? Theme.of(context).colorScheme.secondaryContainer
                              : getColor(context, "canvasContainer")),
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
                          child: TextInput(
                            borderRadius: BorderRadius.zero,
                            padding: EdgeInsets.zero,
                            labelText: "Notes",
                            icon: Icons.sticky_note_2_rounded,
                            controller: _noteInputController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            minLines: 3,
                            onChanged: (text) async {
                              setSelectedNoteController(text);
                            },
                          ),
                        ),
                        AnimatedSize(
                          duration: Duration(milliseconds: 1000),
                          curve: Curves.easeInOutCubicEmphasized,
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            child: extractLinks(selectedNote ?? "").length <= 0
                                ? Container(
                                    key: ValueKey(1),
                                  )
                                : Column(
                                    children: [
                                      for (String link
                                          in extractLinks(selectedNote ?? ""))
                                        Tappable(
                                          onTap: () {
                                            if (link.contains("http://"))
                                              link = "http://www." +
                                                  link
                                                      .replaceFirst("www.", "")
                                                      .replaceFirst(
                                                          "http://", "");
                                            else if (link.contains("https://"))
                                              link = "https://www." +
                                                  link
                                                      .replaceFirst("www.", "")
                                                      .replaceFirst(
                                                          "https://", "");
                                            else
                                              link = "http://www." +
                                                  link
                                                      .replaceFirst("www.", "")
                                                      .replaceFirst(
                                                          "https://", "")
                                                      .replaceFirst(
                                                          "http://", "");
                                            openUrl(link);
                                          },
                                          color: darkenPastel(
                                              (appStateSettings["materialYou"]
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .secondaryContainer
                                                  : getColor(context,
                                                      "canvasContainer")),
                                              amount: 0.2),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 10),
                                            child: Row(
                                              children: [
                                                Icon(Icons.link_rounded),
                                                SizedBox(width: 10),
                                                Expanded(
                                                  child: TextFont(
                                                    text: link
                                                        .replaceFirst(
                                                            "www.", "")
                                                        .replaceFirst(
                                                            "http://", "")
                                                        .replaceFirst(
                                                            "https://", ""),
                                                    fontSize: 16,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                          ),
                        )
                      ],
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
                          textColor: getColor(context, "textLight"),
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
                //             getColor(context, "canvasContainer"),
                //         padding: EdgeInsets.zero,
                //
                //         labelText: "Title",
                //         icon: Icons.title_rounded,
                //         controller: _titleInputController,
                //       ),
                //       Container(height: 14),
                //       TextInput(
                //         backgroundColor:
                //             getColor(context, "canvasContainer"),
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
          ],
        ),
      ),
    );
  }
}

class SelectedWalletButton extends StatelessWidget {
  const SelectedWalletButton({
    Key? key,
    required this.onTap,
    required this.selectedWalletName,
  }) : super(key: key);
  final VoidCallback onTap;
  final String selectedWalletName;
  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      borderRadius: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Row(
          children: [
            ButtonIcon(
              onTap: onTap,
              icon: Icons.account_balance_wallet_rounded,
              size: 41,
            ),
            SizedBox(width: 15),
            Expanded(
              child: TextFont(
                text: selectedWalletName,
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
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
            ButtonIcon(
              onTap: onTap,
              icon: Icons.calendar_month_rounded,
              size: 41,
            ),
            SizedBox(width: 15),
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
                          textColor: getColor(context, "textLight"),
                        ),
                      ),
                      onTap: () {
                        setSelectedDate(DateTime(DateTime.now().year,
                            DateTime.now().month, DateTime.now().day - 1));
                      },
                    ),
                  )
                : SizedBox(),
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
                  width: getWidthBottomSheet(context) - 36,
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
                  width: getWidthBottomSheet(context) - 36,
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

                      if (selectedTitleLocal == null) {
                        selectedTitleLocal = await getLikeAssociatedTitle(text);
                        categoryFk = selectedTitleLocal?.categoryFk ?? -1;
                        foundFromCategoryLocal = false;
                      }

                      if (categoryFk != -1 && categoryFk != 0) {
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
                            width: getWidthBottomSheet(context) - 36,
                          )
                        : Container(
                            key: ValueKey(selectedCategory!.categoryPk),
                            width: getWidthBottomSheet(context) - 36,
                            padding: EdgeInsets.only(top: 13),
                            child: Tappable(
                              borderRadius: 15,
                              color: Colors.transparent,
                              onTap: () {
                                widget.setSelectedCategory(selectedCategory!);
                                if (foundFromCategory == false)
                                  widget.setSelectedTitle(
                                      selectedAssociatedTitle!.title);
                                else
                                  widget.setSelectedTitle("");
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
                width: getWidthBottomSheet(context),
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
    this.icon,
    this.autoFocus = true,
    this.readOnly = false,
    this.textCapitalization = TextCapitalization.none,
    this.requestLateAutoFocus = false,
  }) : super(key: key);
  final Function(String) setSelectedText;
  final String? selectedText;
  final VoidCallback? next;
  final Function(String)? nextWithInput;
  final String labelText;
  final String? placeholder;
  final IconData? icon;
  final bool autoFocus;
  final bool readOnly;
  final TextCapitalization textCapitalization;
  final bool requestLateAutoFocus;

  @override
  _SelectTextState createState() => _SelectTextState();
}

class _SelectTextState extends State<SelectText> {
  String? input = "";
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    input = widget.selectedText;
    _focusNode = new FocusNode();
    if (widget.requestLateAutoFocus)
      Future.delayed(Duration(milliseconds: 250), () {
        _focusNode.requestFocus();
      });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: getWidthBottomSheet(context) - 36,
          child: TextInput(
            focusNode: _focusNode,
            textCapitalization: widget.textCapitalization,
            icon: widget.icon != null ? widget.icon : Icons.title_rounded,
            initialValue: widget.selectedText,
            autoFocus: widget.autoFocus,
            readOnly: widget.readOnly,
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
        color: getColor(context, "canvasContainer"),
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
      dateTimeModified: null,
      order: category.order,
      isExactMatch: false,
    );
    foundFromCategoryLocal = true;
  }
  return [selectedTitleLocal, categoryFk, foundFromCategoryLocal];
}

Future<TransactionAssociatedTitle?> getLikeAssociatedTitle(String text) async {
  if (text.trim() == "" || text.trim().length < 2) {
    return null;
  }
  List<TransactionAssociatedTitle> similarTitles =
      await database.getSimilarAssociatedTitles(title: text);
  return similarTitles.isEmpty ? null : similarTitles[0];
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
          dateTimeModified: null,
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

Future<bool> addAssociatedTitles(
    String selectedTitle, TransactionCategory selectedCategory) async {
  if (appStateSettings["autoAddAssociatedTitles"]) {
    List result = await getRelatingAssociatedTitle(selectedTitle);
    TransactionAssociatedTitle? foundTitle = result[0];
    int length = await database.getAmountOfAssociatedTitles();

    try {
      // Should this check be moved directly into createOrUpdateAssociatedTitle?
      TransactionAssociatedTitle checkIfAlreadyExists =
          await database.getRelatingAssociatedTitleWithCategory(
              selectedTitle, selectedCategory.categoryPk);
      // This is more efficient than shifting the associated title since this uses batching
      await database.deleteAssociatedTitle(
          checkIfAlreadyExists.associatedTitlePk, checkIfAlreadyExists.order);
      int length = await database.getAmountOfAssociatedTitles();
      await database.createOrUpdateAssociatedTitle(
          checkIfAlreadyExists.copyWith(order: length));
      print("already has this title, moved to top");
      return true;
    } catch (e) {
      print(e.toString());
    }

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

      await database.createOrUpdateAssociatedTitle(
        TransactionAssociatedTitle(
          associatedTitlePk: DateTime.now().millisecondsSinceEpoch,
          categoryFk: selectedCategory.categoryPk,
          isExactMatch: false,
          title: selectedTitle.trim(),
          dateCreated: DateTime.now(),
          dateTimeModified: null,
          order: length,
        ),
      );
    }
  }
  return true;
}

class SelectChips extends StatefulWidget {
  const SelectChips({
    super.key,
    required this.items,
    required this.getSelected,
    required this.onSelected,
    required this.getLabel,
    this.getCustomBorderColor,
    this.extraWidget,
    this.onLongPress,
    this.wrapped = false,
  });
  final List<dynamic> items;
  final bool Function(dynamic) getSelected;
  final Function(dynamic) onSelected;
  final String Function(dynamic) getLabel;
  final Color? Function(dynamic)? getCustomBorderColor;
  final Widget? extraWidget;
  final Function(dynamic)? onLongPress;
  final bool wrapped;

  @override
  State<SelectChips> createState() => _SelectChipsState();
}

class _SelectChipsState extends State<SelectChips> {
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      ...List<Widget>.generate(
        widget.items.length,
        (int index) {
          dynamic item = widget.items[index];
          bool selected = widget.getSelected(item);
          String label = widget.getLabel(item);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Tappable(
              onLongPress: () {
                if (widget.onLongPress != null) widget.onLongPress!(item);
              },
              color: Colors.transparent,
              child: ChoiceChip(
                selectedColor: appStateSettings["materialYou"]
                    ? null
                    : getColor(context, "lightDarkAccentHeavy"),
                side: widget.getCustomBorderColor == null ||
                        widget.getCustomBorderColor!(item) == null
                    ? null
                    : BorderSide(
                        color: widget.getCustomBorderColor!(item)!,
                      ),
                label: TextFont(
                  text: label,
                  fontSize: 15,
                ),
                selected: selected,
                onSelected: (bool selected) {
                  widget.onSelected(item);
                },
              ),
            ),
          );
        },
      ).toList(),
      widget.extraWidget ?? SizedBox.shrink()
    ];
    if (widget.wrapped)
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 18),
        child: Wrap(
          children: children,
        ),
      );
    return SizedBox(
      height: 40,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 18),
        scrollDirection: Axis.horizontal,
        children: children,
      ),
    );
  }
}
