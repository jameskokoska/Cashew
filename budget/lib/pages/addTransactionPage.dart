import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/accountsPage.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/addObjectivePage.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/pages/premiumPage.dart';
import 'package:budget/pages/sharedBudgetSettings.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/incomeExpenseTabSelector.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/timeDigits.dart';
import 'package:budget/struct/initializeNotifications.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/radioItems.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/selectCategory.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/selectChips.dart';
import 'package:budget/widgets/saveBottomButton.dart';
import 'package:budget/widgets/transactionEntry/incomeAmountArrow.dart';
import 'package:budget/widgets/transactionEntry/transactionEntry.dart';
import 'package:budget/widgets/transactionEntry/transactionEntryTypeButton.dart';
import 'package:budget/widgets/transactionEntry/transactionLabel.dart';
import 'package:budget/widgets/util/contextMenu.dart';
import 'package:budget/widgets/util/showDatePicker.dart';
import 'package:budget/widgets/util/widgetSize.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:budget/colors.dart';
import 'package:flutter/services.dart' hide TextInput;
import 'package:provider/provider.dart';
import 'package:budget/widgets/util/showTimePicker.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/struct/currencyFunctions.dart';
import 'package:budget/widgets/animatedExpanded.dart';

import '../widgets/listItem.dart';
import '../widgets/outlinedButtonStacked.dart';
import '../widgets/tappableTextEntry.dart';

//TODO
//only show the tags that correspond to selected category
//put recent used tags at the top? when no category selected

dynamic transactionTypeDisplayToEnum = {
  "Default": null,
  "Upcoming": TransactionSpecialType.upcoming,
  "Subscription": TransactionSpecialType.subscription,
  "Repetitive": TransactionSpecialType.repetitive,
  "Borrowed": TransactionSpecialType.debt,
  "Lent": TransactionSpecialType.credit,
  null: "Default",
  TransactionSpecialType.upcoming: "Upcoming",
  TransactionSpecialType.subscription: "Subscription",
  TransactionSpecialType.repetitive: "Repetitive",
  TransactionSpecialType.debt: "Borrowed",
  TransactionSpecialType.credit: "Lent",
};

class AddTransactionPage extends StatefulWidget {
  AddTransactionPage({
    Key? key,
    this.transaction,
    this.selectedBudget,
    this.selectedType,
    this.selectedObjective,
    this.selectedIncome,
    required this.routesToPopAfterDelete,
  }) : super(key: key);

  //When a transaction is passed in, we are editing that transaction
  final Transaction? transaction;
  final Budget? selectedBudget;
  final TransactionSpecialType? selectedType;
  final Objective? selectedObjective;
  final RoutesToPopAfterDelete routesToPopAfterDelete;
  final bool? selectedIncome;

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage>
    with SingleTickerProviderStateMixin {
  TransactionCategory? selectedCategory;
  String? selectedSubCategoryPk;
  double? selectedAmount;
  String? selectedAmountCalculation;
  String? selectedTitle;
  String? selectedNote;
  TransactionSpecialType? selectedType = null;
  List<String> selectedTags = [];
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  int selectedPeriodLength = 1;
  String selectedRecurrence = "Monthly";
  String selectedRecurrenceDisplay = "month";
  BudgetReoccurence selectedRecurrenceEnum = BudgetReoccurence.monthly;
  bool selectedIncome = false;
  String? selectedPayer;
  String? selectedObjectivePk;
  String? selectedBudgetPk;
  Budget? selectedBudget;
  bool selectedBudgetIsShared = false;
  String selectedWalletPk = appStateSettings["selectedWalletPk"];
  TransactionWallet? selectedWallet;
  bool notesInputFocused = false;

  String? textAddTransaction = "add-transaction".tr();

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showCustomDatePicker(context, selectedDate);
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = selectedDate.copyWith(
          year: picked.year,
          month: picked.month,
          day: picked.day,
        );
      });
    }
  }

  void setSelectedDate(DateTime dateTime) {
    setState(() {
      selectedDate = dateTime;
    });
  }

  void setSelectedTime(TimeOfDay time) {
    setState(() {
      selectedTime = time;
      selectedDate =
          selectedDate.copyWith(hour: time.hour, minute: time.minute);
    });
  }

  void setSelectedCategory(TransactionCategory category) {
    setSelectedIncome(category.income);
    setState(() {
      if (selectedCategory != category) selectedSubCategoryPk = null;
      selectedCategory = category;
    });
    return;
  }

  void setSelectedSubCategory(TransactionCategory category) {
    setState(() {
      if (selectedSubCategoryPk == category.categoryPk) {
        selectedSubCategoryPk = null;
      } else {
        selectedSubCategoryPk = category.categoryPk;
      }
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

  void setSelectedNoteController(String note, {bool setInput = true}) {
    if (setInput) setTextInput(_noteInputController, note);
    selectedNote = note;
    return;
  }

  void setSelectedType(String type) {
    if (selectedType == TransactionSpecialType.credit ||
        selectedType == TransactionSpecialType.debt) {
      setSelectedIncome(selectedCategory?.income ?? false);
    }
    setState(() {
      selectedType = transactionTypeDisplayToEnum[type];
    });
    if (selectedType == TransactionSpecialType.credit) {
      setSelectedIncome(false);
    } else if (selectedType == TransactionSpecialType.debt) {
      setSelectedIncome(true);
    }
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
        selectedPayer = appStateSettings["currentUserEmail"] ?? "";
      if (isSharedBudget == false || selectedBudgetPassed?.sharedKey == null) {
        selectedPayer = null;
      }
    });
    return;
  }

  void setSelectedObjectivePk(String? selectedObjectivePkPassed) {
    setState(() {
      selectedObjectivePk = selectedObjectivePkPassed;
    });
    return;
  }

  Future<void> selectPeriodLength(BuildContext context) async {
    openBottomSheet(
      context,
      PopupFramework(
        title: "enter-period-length".tr(),
        child: SelectAmountValue(
          amountPassed: selectedPeriodLength.toString(),
          setSelectedAmount: (amount, _) {
            setSelectedPeriodLength(amount);
          },
          next: () async {
            Navigator.pop(context);
          },
          nextLabel: "set-amount".tr(),
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
        title: "select-period".tr(),
        child: RadioItems(
          items: ["Daily", "Weekly", "Monthly", "Yearly"],
          initial: selectedRecurrence,
          displayFilter: (item) {
            return item.toString().toLowerCase().tr();
          },
          onChanged: (value) {
            setState(() {
              selectedRecurrence = value;
              selectedRecurrenceEnum = enumRecurrence[value];
              if (selectedPeriodLength == 1) {
                selectedRecurrenceDisplay =
                    nameRecurrence[value].toString().tr();
              } else {
                selectedRecurrenceDisplay =
                    namesRecurrence[value].toString().tr();
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

  void setSelectedWalletPk(TransactionWallet selectedWalletPassed) {
    setState(() {
      selectedWalletPk = selectedWalletPassed.walletPk;
      selectedWallet = selectedWalletPassed;
    });
  }

  Transaction addDefaultMissingValues(Transaction transaction) {
    return transaction.copyWith(
      reoccurrence:
          Value(transaction.reoccurrence ?? BudgetReoccurence.monthly),
      periodLength: Value(transaction.periodLength ?? 1),
    );
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

    final int? rowId = await database.createOrUpdateTransaction(
      insert: widget.transaction == null,
      await createTransaction(),
      originalTransaction: widget.transaction,
    );

    if (rowId != null) {
      final Transaction transactionJustAdded =
          await database.getTransactionFromRowId(rowId);
      print("Transaction just added:");
      print(transactionJustAdded);

      // Do the flash animation only if the date was changed
      if (transactionJustAdded.dateCreated != widget.transaction?.dateCreated) {
        recentlyAddedTransactionInfo.value.shouldAnimate = true;
        recentlyAddedTransactionInfo.value.transactionPk =
            transactionJustAdded.transactionPk;
        recentlyAddedTransactionInfo.value.loopCount = 5;
        // If a new transaction with an added date of 5 minutes of less before, flash only a bit
        if (widget.transaction == null &&
            transactionJustAdded.dateCreated.isAfter(
              DateTime.now().subtract(
                Duration(minutes: 5),
              ),
            )) {
          recentlyAddedTransactionInfo.value.loopCount = 2;
        }
        recentlyAddedTransactionInfo.notifyListeners();
      }
    }

    // recentlyAddedTransactionID.value =

    if (widget.transaction == null && appStateSettings["purchaseID"] == null) {
      updateSettings("premiumPopupAddTransactionCount",
          appStateSettings["premiumPopupAddTransactionCount"] + 1,
          updateGlobalState: false);
    }

    return true;
  }

  Transaction createTransaction({bool removeShared = false}) {
    bool? createdAnotherFutureTransaction = widget.transaction != null
        ? widget.transaction!.createdAnotherFutureTransaction
        : null;
    bool paid = widget.transaction != null
        ? widget.transaction!.paid
        : selectedType == null;
    bool skipPaid = widget.transaction != null
        ? widget.transaction!.skipPaid
        : selectedType == null;

    if (selectedType != null &&
        widget.transaction != null &&
        widget.transaction!.type != selectedType) {
      createdAnotherFutureTransaction = false;

      if ([TransactionSpecialType.credit, TransactionSpecialType.debt]
          .contains(selectedType)) {
        paid = true;
        skipPaid = false;
      } else {
        paid = false;
        skipPaid = false;
      }
    }

    Transaction createdTransaction = Transaction(
      transactionPk:
          widget.transaction != null ? widget.transaction!.transactionPk : "-1",
      name: (selectedTitle ?? "").trim(),
      amount: (selectedIncome
          ? (selectedAmount ?? 0).abs()
          : (selectedAmount ?? 0).abs() * -1),
      note: selectedNote ?? "",
      categoryFk: selectedCategory?.categoryPk ?? "-1",
      subCategoryFk: selectedSubCategoryPk,
      dateCreated: selectedDate,
      dateTimeModified: null,
      income: selectedIncome,
      walletFk: selectedWalletPk,
      paid: paid,
      skipPaid: skipPaid,
      type: selectedType,
      reoccurrence: selectedRecurrenceEnum,
      periodLength: selectedPeriodLength,
      methodAdded:
          widget.transaction != null ? widget.transaction!.methodAdded : null,
      createdAnotherFutureTransaction: createdAnotherFutureTransaction,
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
      originalDateDue: widget.transaction != null
          ? widget.transaction!.originalDateDue
          : null,
      objectiveFk: selectedObjectivePk,
    );

    if (widget.transaction != null &&
        widget.transaction!.type != null &&
        createdTransaction.type == null) {
      createdTransaction = createdTransaction.copyWith(paid: true);
    }

    if ((createdTransaction.type == TransactionSpecialType.credit ||
            createdTransaction.type == TransactionSpecialType.debt) &&
        (widget.transaction == null)) {
      createdTransaction = createdTransaction.copyWith(paid: true);
    }

    return createdTransaction;
  }

  Transaction? transactionInitial;

  // If a change was made, show the discard changes popup
  // When creating a new entry only
  void showDiscardChangesPopupIfNotEditing() {
    Transaction transactionCreated = createTransaction();
    if (transactionCreated != transactionInitial &&
        widget.transaction == null) {
      discardChangesPopup(context, forceShow: true);
    } else {
      Navigator.pop(context);
    }
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
      selectedTime = TimeOfDay(
        hour: widget.transaction!.dateCreated.hour,
        minute: widget.transaction!.dateCreated.minute,
      );
      selectedWalletPk = widget.transaction!.walletFk;
      selectedAmount = widget.transaction!.amount.abs();
      selectedType = widget.transaction!.type;
      selectedPeriodLength = widget.transaction!.periodLength ?? 1;
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
      selectedBudgetPk = widget.transaction!.sharedReferenceBudgetPk;
      selectedObjectivePk = widget.transaction!.objectiveFk;
      selectedSubCategoryPk = widget.transaction!.subCategoryFk;
      // var amountString = widget.transaction!.amount.toStringAsFixed(2);
      // if (amountString.substring(amountString.length - 2) == "00") {
      //   selectedAmountCalculation =
      //       amountString.substring(0, amountString.length - 3);
      // } else {
      //   selectedAmountCalculation = amountString;
      // }
      textAddTransaction = "save-changes".tr();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        updateInitial();
      });
    } else {
      if (widget.selectedType != null) {
        selectedType = widget.selectedType;
      }

      _titleInputController = new TextEditingController();
      _noteInputController = new TextEditingController();

      Future.delayed(Duration(milliseconds: 0), () async {
        await premiumPopupAddTransaction(context);
        openBottomSheet(
          context,
          // Only allow full snap when entering a title
          fullSnap: appStateSettings["askForTransactionTitle"] == true,
          appStateSettings["askForTransactionTitle"]
              ? SelectTitle(
                  selectedTitle: selectedTitle,
                  setSelectedNote: setSelectedNoteController,
                  setSelectedTitle: setSelectedTitleController,
                  setSelectedTags: setSelectedTags,
                  selectedCategory: selectedCategory,
                  setSelectedCategory: setSelectedCategory,
                  next: () {
                    openBottomSheet(context, afterSetTitle());
                  },
                )
              : afterSetTitle(),
        );
        if (appStateSettings["askForTransactionTitle"]) {
          // Fix over-scroll stretch when keyboard pops up quickly
          Future.delayed(Duration(milliseconds: 100), () {
            bottomSheetControllerGlobal.scrollTo(0,
                duration: Duration(milliseconds: 100));
          });
        }
      });
    }
    Future.delayed(Duration.zero, () async {
      selectedWallet = await database.getWalletInstance(
          widget.transaction == null
              ? appStateSettings["selectedWalletPk"]
              : widget.transaction!.walletFk);
    });
    if (widget.selectedBudget != null) {
      selectedBudget = widget.selectedBudget;
      selectedBudgetPk = widget.selectedBudget!.budgetPk;
      selectedPayer = appStateSettings["currentUserEmail"];
      selectedBudgetIsShared = widget.selectedBudget!.sharedKey != null;
    }
    if (widget.selectedObjective != null) {
      selectedObjectivePk = widget.selectedObjective!.objectivePk;
    }
    if (widget.selectedIncome != null) {
      selectedIncome = widget.selectedIncome!;
    }
    if (widget.transaction == null) {
      Future.delayed(Duration.zero, () {
        transactionInitial = createTransaction();
      });
    }

    setState(() {});
  }

  Widget afterSetTitle() {
    return PopupFramework(
      title: "select-category".tr(),
      hasPadding: false,
      child: Column(
        children: [
          SelectAddedBudget(
            setSelectedBudget: setSelectedBudgetPk,
            selectedBudgetPk: selectedBudgetPk,
            extraHorizontalPadding: 13,
            wrapped: false,
          ),
          SelectObjective(
            setSelectedObjective: setSelectedObjectivePk,
            selectedObjectivePk: selectedObjectivePk,
            extraHorizontalPadding: 13,
            wrapped: false,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 18, right: 18, bottom: 10),
            child: SelectCategory(
              selectedCategory: selectedCategory,
              setSelectedCategory: setSelectedCategory,
              skipIfSet: true,
              next: () {
                openBottomSheet(
                  context,
                  fullSnap: true,
                  PopupFramework(
                    title: "enter-amount".tr(),
                    underTitleSpace: false,
                    hasPadding: false,
                    child: SelectAmount(
                      enableWalletPicker: true,
                      selectedWallet: selectedWallet,
                      setSelectedWallet: setSelectedWalletPk,
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      walletPkForCurrency: selectedWalletPk,
                      onlyShowCurrencyIcon:
                          appStateSettings["selectedWalletPk"] ==
                              selectedWalletPk,
                      amountPassed: (selectedAmount ?? "0").toString(),
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
          selectedCategory != null
              ? CategoryIcon(
                  categoryPk: "-1",
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
            widget.transaction!.sharedReferenceBudgetPk ?? "-1");
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

    Widget transactionAmountAndCategoryHeader = AnimatedContainer(
      curve: Curves.easeInOut,
      duration: Duration(milliseconds: 300),
      color: categoryColor,
      child: Column(
        children: [
          AnimatedExpanded(
            expand: !(selectedType == TransactionSpecialType.credit ||
                selectedType == TransactionSpecialType.debt),
            child: IncomeExpenseTabSelector(
              onTabChanged: setSelectedIncome,
              initialTabIsIncome: selectedIncome,
              syncWithInitial: true,
              color: categoryColor,
              unselectedColor: Colors.black.withOpacity(0.2),
              unselectedLabelColor: Colors.white.withOpacity(0.3),
            ),
          ),
          Row(
            children: [
              Tappable(
                onLongPress: () async {
                  await pushRoute(
                    context,
                    AddCategoryPage(
                      category: selectedCategory,
                      routesToPopAfterDelete:
                          RoutesToPopAfterDelete.PreventDelete,
                    ),
                  );
                  if (selectedCategory != null) {
                    TransactionCategory category = await database
                        .getCategory(selectedCategory!.categoryPk)
                        .$2;
                    setSelectedCategory(category);
                  }
                },
                onTap: () async {
                  await openBottomSheet(
                    context,
                    PopupFramework(
                      title: "select-category".tr(),
                      child: SelectCategory(
                        selectedCategory: selectedCategory,
                        setSelectedCategory: setSelectedCategory,
                      ),
                    ),
                  );
                  if (selectedCategory?.categoryPk != null) {
                    int subCategoriesOfMain = await database
                        .getAmountOfSubCategories(selectedCategory!.categoryPk);
                    if (subCategoriesOfMain > 0) {
                      await openBottomSheet(
                        context,
                        PopupFramework(
                          title: "select-category".tr(),
                          child: SelectCategory(
                            selectedCategory: selectedCategory,
                            setSelectedCategory: setSelectedSubCategory,
                            mainCategoryPk: selectedCategory!.categoryPk,
                          ),
                        ),
                      );
                    }
                  }
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
                          tintEnabled: false,
                          canEditByLongPress: false,
                          noBackground: true,
                          key: ValueKey(selectedCategory?.categoryPk ?? ""),
                          category: selectedCategory,
                          size: 60,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: CustomContextMenu(
                  buttonItems: [
                    ContextMenuButtonItem(
                      type: ContextMenuButtonType.copy,
                      onPressed: () {
                        ContextMenuController.removeAny();
                        copyToClipboard(
                          convertToMoney(
                            Provider.of<AllWallets>(context, listen: false),
                            selectedAmount ?? 0,
                            finalNumber: selectedAmount ?? 0,
                            decimals: selectedWallet?.decimals,
                          ),
                        );
                      },
                    ),
                    ContextMenuButtonItem(
                      type: ContextMenuButtonType.paste,
                      onPressed: () async {
                        ContextMenuController.removeAny();
                        String? clipboardText =
                            await readClipboard(showSnackbar: false);
                        double? amount =
                            getAmountFromString(clipboardText ?? "");
                        if (amount != null) {
                          setSelectedAmount(amount, amount.toString());
                          openSnackbar(
                            SnackbarMessage(
                              title: "pasted-from-clipboard".tr(),
                              icon: appStateSettings["outlinedIcons"]
                                  ? Icons.paste_outlined
                                  : Icons.paste_rounded,
                              timeout: Duration(milliseconds: 2500),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                  tappableBuilder: (onLongPress) {
                    return Tappable(
                      color: Colors.transparent,
                      onLongPress: onLongPress,
                      onTap: () {
                        openBottomSheet(
                          context,
                          fullSnap: true,
                          PopupFramework(
                            title: "enter-amount".tr(),
                            hasPadding: false,
                            underTitleSpace: false,
                            child: SelectAmount(
                              enableWalletPicker: true,
                              selectedWallet: selectedWallet,
                              setSelectedWallet: setSelectedWalletPk,
                              padding: EdgeInsets.symmetric(horizontal: 18),
                              walletPkForCurrency: selectedWalletPk,
                              // onlyShowCurrencyIcon:
                              //     appStateSettings[
                              //             "selectedWalletPk"] ==
                              //         selectedWalletPk,
                              onlyShowCurrencyIcon: true,
                              amountPassed: (selectedAmount ?? "0").toString(),
                              setSelectedAmount: setSelectedAmount,
                              next: () async {
                                if (selectedCategory == null) {
                                  Navigator.pop(context);
                                  openBottomSheet(
                                    context,
                                    PopupFramework(
                                      title: "select-category".tr(),
                                      child: SelectCategory(
                                        selectedCategory: selectedCategory,
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
                                  Navigator.pop(context);
                                }
                              },
                              nextLabel: selectedCategory == null
                                  ? "select-category".tr()
                                  : "set-amount".tr(),
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
                              child: Align(
                                key: ValueKey(selectedWalletPk.toString() +
                                    selectedAmount.toString()),
                                alignment: Alignment.centerRight,
                                child: TextFont(
                                  textAlign: TextAlign.right,
                                  text: convertToMoney(
                                    Provider.of<AllWallets>(context),
                                    selectedAmount ?? 0,
                                    decimals: selectedWallet?.decimals,
                                    currencyKey: selectedWallet?.currency,
                                    addCurrencyName:
                                        ((Provider.of<AllWallets>(context)
                                                .indexedByPk[
                                                    selectedWallet?.walletPk]
                                                ?.currency) !=
                                            Provider.of<AllWallets>(context)
                                                .indexedByPk[appStateSettings[
                                                    "selectedWalletPk"]]
                                                ?.currency),
                                  ),
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  maxLines: 1,
                                  autoSizeText: true,
                                ),
                              ),
                            ),
                            Provider.of<AllWallets>(context).list.length <= 1 ||
                                    selectedWallet?.walletPk ==
                                        appStateSettings["selectedWalletPk"] ||
                                    ((Provider.of<AllWallets>(context)
                                            .indexedByPk[
                                                selectedWallet?.walletPk]
                                            ?.currency) ==
                                        Provider.of<AllWallets>(context)
                                            .indexedByPk[appStateSettings[
                                                "selectedWalletPk"]]
                                            ?.currency)
                                ? AnimatedSizeSwitcher(
                                    switcherDuration:
                                        Duration(milliseconds: 350),
                                    child: Container(
                                      key: ValueKey(
                                          selectedCategory?.name ?? ""),
                                      width: double.infinity,
                                      child: TextFont(
                                        textAlign: TextAlign.right,
                                        fontSize: 18,
                                        text: selectedCategory?.name ?? "",
                                        maxLines: 2,
                                      ),
                                    ),
                                  )
                                : AnimatedSwitcher(
                                    duration: Duration(milliseconds: 350),
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: TextFont(
                                        textAlign: TextAlign.right,
                                        text: convertToMoney(
                                          Provider.of<AllWallets>(context),
                                          (selectedAmount ?? 0) *
                                              (amountRatioToPrimaryCurrencyGivenPk(
                                                      Provider.of<AllWallets>(
                                                          context),
                                                      selectedWalletPk) ??
                                                  1),
                                        ),
                                        fontSize: 18,
                                        maxLines: 1,
                                        autoSizeText: true,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          if (selectedCategory != null)
            StreamBuilder<List<TransactionCategory>>(
              stream: database.watchAllSubCategoriesOfMainCategory(
                  selectedCategory!.categoryPk),
              builder: (context, snapshot) {
                List<TransactionCategory> subCategories = snapshot.data ?? [];
                return AnimatedSizeSwitcher(
                  child: (subCategories.length <= 0)
                      ? Container()
                      : Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: SelectChips(
                                selectedColor: Theme.of(context)
                                    .canvasColor
                                    .withOpacity(0.6),
                                onLongPress: (category) {
                                  pushRoute(
                                    context,
                                    AddCategoryPage(
                                      category: category,
                                      routesToPopAfterDelete:
                                          RoutesToPopAfterDelete.PreventDelete,
                                    ),
                                  );
                                },
                                items: subCategories,
                                getSelected: (TransactionCategory category) {
                                  return selectedSubCategoryPk ==
                                      category.categoryPk;
                                },
                                onSelected: (TransactionCategory category) {
                                  setSelectedSubCategory(category);
                                },
                                getCustomBorderColor:
                                    (TransactionCategory category) {
                                  return dynamicPastel(
                                    context,
                                    lightenPastel(
                                      HexColor(
                                        category.colour,
                                        defaultColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      amount: 0.3,
                                    ),
                                    amount: 0.4,
                                  );
                                },
                                getLabel: (TransactionCategory category) {
                                  return category.name;
                                },
                                extraWidget: AddButton(
                                  onTap: () {},
                                  width: 40,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 1),
                                  openPage: AddCategoryPage(
                                    routesToPopAfterDelete:
                                        RoutesToPopAfterDelete.None,
                                    mainCategoryPkWhenSubCategory:
                                        selectedCategory?.categoryPk,
                                  ),
                                  borderRadius: 8,
                                ),
                                getAvatar: (TransactionCategory category) {
                                  return LayoutBuilder(
                                      builder: (context, constraints) {
                                    return CategoryIcon(
                                      categoryPk: "-1",
                                      category: category,
                                      size: constraints.maxWidth,
                                      sizePadding: 0,
                                      noBackground: true,
                                      canEditByLongPress: false,
                                      margin: EdgeInsets.zero,
                                    );
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                );
              },
            ),
        ],
      ),
    );

    Widget transactionTextInput = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        enableDoubleColumn(context)
            ? Container(height: 20)
            : Container(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: TextInput(
            padding: EdgeInsets.zero,
            labelText: "title-placeholder".tr(),
            icon: appStateSettings["outlinedIcons"]
                ? Icons.title_outlined
                : Icons.title_rounded,
            controller: _titleInputController,
            onChanged: (text) async {
              setSelectedTitle(text, setInput: false);
            },
            autoFocus: kIsWeb && getIsFullScreen(context),
          ),
        ),
        Container(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
                getPlatform() == PlatformOS.isIOS ? 8 : 15),
            child: Column(
              children: [
                Focus(
                  child: TextInput(
                    borderRadius: BorderRadius.zero,
                    padding: EdgeInsets.zero,
                    labelText: "notes-placeholder".tr(),
                    icon: appStateSettings["outlinedIcons"]
                        ? Icons.sticky_note_2_outlined
                        : Icons.sticky_note_2_rounded,
                    controller: _noteInputController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    minLines: 3,
                    onChanged: (text) async {
                      setSelectedNoteController(text, setInput: false);
                    },
                  ),
                  onFocusChange: (hasFocus) {
                    if (hasFocus == false && notesInputFocused == true) {
                      setState(() {
                        notesInputFocused = false;
                      });
                    } else if (hasFocus == true && notesInputFocused == false) {
                      setState(() {
                        notesInputFocused = true;
                      });
                    }
                  },
                ),
                AnimatedSizeSwitcher(
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
                                            .replaceFirst("http://", "");
                                  else if (link.contains("https://"))
                                    link = "https://www." +
                                        link
                                            .replaceFirst("www.", "")
                                            .replaceFirst("https://", "");
                                  else
                                    link = "http://www." +
                                        link
                                            .replaceFirst("www.", "")
                                            .replaceFirst("https://", "")
                                            .replaceFirst("http://", "");
                                  openUrl(link);
                                },
                                color: darkenPastel(
                                    (appStateSettings["materialYou"]
                                        ? Theme.of(context)
                                            .colorScheme
                                            .secondaryContainer
                                        : getColor(context, "canvasContainer")),
                                    amount: 0.2),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  child: Row(
                                    children: [
                                      Icon(appStateSettings["outlinedIcons"]
                                          ? Icons.link_outlined
                                          : Icons.link_rounded),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: TextFont(
                                          text: link
                                              .replaceFirst("www.", "")
                                              .replaceFirst("http://", "")
                                              .replaceFirst("https://", ""),
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
                )
              ],
            ),
          ),
        ),
      ],
    );

    return WillPopScope(
      onWillPop: () async {
        if (widget.transaction != null) {
          discardChangesPopup(
            context,
            previousObject: addDefaultMissingValues(widget.transaction!),
            currentObject: await createTransaction(),
          );
        } else {
          showDiscardChangesPopupIfNotEditing();
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
          belowAppBarPaddingWhenCenteredTitleSmall: 0,
          resizeToAvoidBottomInset: true,
          title: widget.transaction == null
              ? "add-transaction".tr()
              : "edit-transaction".tr(),
          dragDownToDismiss: true,
          onBackButton: () async {
            if (widget.transaction != null) {
              discardChangesPopup(
                context,
                previousObject: addDefaultMissingValues(widget.transaction!),
                currentObject: await createTransaction(),
              );
            } else {
              showDiscardChangesPopupIfNotEditing();
            }
          },
          onDragDownToDismiss: () async {
            if (widget.transaction != null) {
              discardChangesPopup(
                context,
                previousObject: addDefaultMissingValues(widget.transaction!),
                currentObject: await createTransaction(),
              );
            } else {
              showDiscardChangesPopupIfNotEditing();
            }
          },
          actions: [
            widget.transaction != null
                ? IconButton(
                    padding: EdgeInsets.all(15),
                    tooltip: "delete-transaction".tr(),
                    onPressed: () {
                      deleteTransactionPopup(
                        context,
                        transaction: widget.transaction!,
                        category: selectedCategory,
                        routesToPopAfterDelete: widget.routesToPopAfterDelete,
                      );
                    },
                    icon: Icon(appStateSettings["outlinedIcons"]
                        ? Icons.delete_outlined
                        : Icons.delete_rounded),
                  )
                : SizedBox.shrink()
          ],
          overlay: Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                Expanded(
                  child: selectedCategory == null
                      ? SaveBottomButton(
                          label: "select-category".tr(),
                          onTap: () {
                            openBottomSheet(
                              context,
                              PopupFramework(
                                title: "select-category".tr(),
                                child: SelectCategory(
                                  selectedCategory: selectedCategory,
                                  setSelectedCategory: setSelectedCategory,
                                  skipIfSet: true,
                                  next: () {
                                    if (selectedAmount == null)
                                      openBottomSheet(
                                        context,
                                        fullSnap: true,
                                        PopupFramework(
                                          title: "enter-amount".tr(),
                                          hasPadding: false,
                                          underTitleSpace: false,
                                          child: SelectAmount(
                                            enableWalletPicker: true,
                                            selectedWallet: selectedWallet,
                                            setSelectedWallet:
                                                setSelectedWalletPk,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 18),
                                            walletPkForCurrency:
                                                selectedWalletPk,
                                            onlyShowCurrencyIcon:
                                                appStateSettings[
                                                        "selectedWalletPk"] ==
                                                    selectedWalletPk,
                                            amountPassed:
                                                (selectedAmount ?? "0")
                                                    .toString(),
                                            setSelectedAmount:
                                                setSelectedAmount,
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
                              label: "enter-amount".tr(),
                              onTap: () {
                                openBottomSheet(
                                  context,
                                  fullSnap: true,
                                  PopupFramework(
                                    title: "enter-amount".tr(),
                                    hasPadding: false,
                                    underTitleSpace: false,
                                    child: SelectAmount(
                                      enableWalletPicker: true,
                                      selectedWallet: selectedWallet,
                                      setSelectedWallet: setSelectedWalletPk,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 18),
                                      walletPkForCurrency: selectedWalletPk,
                                      onlyShowCurrencyIcon: appStateSettings[
                                              "selectedWalletPk"] ==
                                          selectedWalletPk,
                                      amountPassed:
                                          (selectedAmount ?? "0").toString(),
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
                                  ? "save-changes".tr()
                                  : textAddTransaction ?? "",
                              onTap: () async {
                                bool result = await addTransaction();
                                if (result) Navigator.of(context).pop();
                              },
                            ),
                ),
                AnimatedSizeSwitcher(
                  child: widget.transaction != null && selectedType != null
                      ? WidgetSizeBuilder(
                          // Change the key to re-render the widget when transaction type changed
                          key: ValueKey(widget.transaction != null
                              ? getTransactionActionNameFromType(
                                      createTransaction())
                                  .tr()
                              : ""),
                          widgetBuilder: (Size? size) {
                            return Container(
                              key: ValueKey(1),
                              width: size?.width,
                              child: SaveBottomButton(
                                margin: EdgeInsets.only(left: 5),
                                color: isTransactionActionDealtWith(
                                        createTransaction())
                                    ? Theme.of(context)
                                        .colorScheme
                                        .tertiaryContainer
                                    : null,
                                labelColor: isTransactionActionDealtWith(
                                        createTransaction())
                                    ? Theme.of(context)
                                        .colorScheme
                                        .onTertiaryContainer
                                    : null,
                                label: widget.transaction != null
                                    ? getTransactionActionNameFromType(
                                            createTransaction())
                                        .tr()
                                    : "",
                                onTap: () async {
                                  if (widget.transaction != null &&
                                      selectedType != null) {
                                    dynamic result =
                                        await openTransactionActionFromType(
                                      context,
                                      createTransaction(),
                                      runBefore: () async {
                                        await addTransaction();
                                      },
                                    );
                                    if (result == true) {
                                      Navigator.of(context).pop();
                                    }
                                  }
                                },
                              ),
                            );
                          },
                        )
                      : Container(
                          key: ValueKey(2),
                        ),
                ),
                AnimatedSizeSwitcher(
                  child: notesInputFocused && getPlatform() == PlatformOS.isIOS
                      ? WidgetSizeBuilder(
                          widgetBuilder: (Size? size) {
                            return Container(
                              key: ValueKey(1),
                              width: size?.width,
                              child: SaveBottomButton(
                                margin: EdgeInsets.only(left: 5),
                                color: isTransactionActionDealtWith(
                                        createTransaction())
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                                labelColor: isTransactionActionDealtWith(
                                        createTransaction())
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : null,
                                label: "done".tr(),
                                onTap: () async {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                              ),
                            );
                          },
                        )
                      : Container(
                          key: ValueKey(2),
                        ),
                ),
              ],
            ),
          ),
          listWidgets: [
            enableDoubleColumn(context) == false
                ? transactionAmountAndCategoryHeader
                : SizedBox.shrink(),
            enableDoubleColumn(context)
                ? SizedBox(height: 50)
                : SizedBox.shrink(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                enableDoubleColumn(context) == false
                    ? SizedBox.shrink()
                    : Flexible(
                        child: Container(
                          constraints: BoxConstraints(maxWidth: 900),
                          child: FractionallySizedBox(
                            widthFactor: 0.95,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 23),
                                  child: ClipRRect(
                                    child: transactionAmountAndCategoryHeader,
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                ),
                                transactionTextInput,
                              ],
                            ),
                          ),
                        ),
                      ),
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 900),
                    child: FractionallySizedBox(
                      widthFactor:
                          enableDoubleColumn(context) == false ? 1 : 0.95,
                      child: Column(
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
                                setSelectedTime: setSelectedTime,
                                selectedTime: selectedTime,
                              ),
                            ),
                          ),
                          enableDoubleColumn(context) == false
                              ? SizedBox(height: 5)
                              : SizedBox.shrink(),
                          HorizontalBreakAbove(
                            enabled: enableDoubleColumn(context),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: SelectChips(
                                wrapped: enableDoubleColumn(context),
                                extraWidgetAtBeginning: true,
                                extraWidget: Transform.scale(
                                  scale: 1.3,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                    icon: Icon(
                                      Icons.info_outlined,
                                      size: 19,
                                    ),
                                    onPressed: () {
                                      openBottomSheet(
                                        context,
                                        fullSnap: false,
                                        SelectTransactionTypePopup(
                                          setTransactionType: (type) {
                                            setSelectedType(
                                              transactionTypeDisplayToEnum[
                                                  type],
                                            );
                                          },
                                          selectedTransactionType: selectedType,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                items: <TransactionSpecialType?>[
                                  null,
                                  ...TransactionSpecialType.values
                                ],
                                getLabel: (TransactionSpecialType? item) {
                                  return transactionTypeDisplayToEnum[item]
                                          ?.toString()
                                          .toLowerCase()
                                          .tr() ??
                                      "";
                                },
                                onSelected: (TransactionSpecialType? item) {
                                  setSelectedType(
                                      transactionTypeDisplayToEnum[item]);
                                },
                                getSelected: (TransactionSpecialType? item) {
                                  return selectedType == item;
                                },
                              ),
                            ),
                          ),
                          AnimatedExpanded(
                            expand: selectedType ==
                                    TransactionSpecialType.repetitive ||
                                selectedType ==
                                    TransactionSpecialType.subscription,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Wrap(
                                      key: ValueKey(1),
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        TextFont(
                                          text: "repeat-every".tr(),
                                          fontSize: 23,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TappableTextEntry(
                                              title: selectedPeriodLength
                                                  .toString(),
                                              placeholder: "0",
                                              showPlaceHolderWhenTextEquals:
                                                  "0",
                                              onTap: () {
                                                selectPeriodLength(context);
                                              },
                                              fontSize: 23,
                                              fontWeight: FontWeight.bold,
                                              internalPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 4,
                                                      horizontal: 4),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 5, horizontal: 3),
                                            ),
                                            TappableTextEntry(
                                              title: selectedRecurrenceDisplay
                                                  .toString()
                                                  .toLowerCase()
                                                  .tr()
                                                  .toLowerCase(),
                                              placeholder: "",
                                              onTap: () {
                                                selectRecurrence(context);
                                              },
                                              fontSize: 23,
                                              fontWeight: FontWeight.bold,
                                              internalPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 4,
                                                      horizontal: 4),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 5, horizontal: 3),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Wallet picker is in Select Amount... consider removing?
                          Provider.of<AllWallets>(context).list.length <= 1
                              ? SizedBox.shrink()
                              : HorizontalBreakAbove(
                                  enabled: enableDoubleColumn(context),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: SelectChips(
                                      onLongPress: (TransactionWallet wallet) {
                                        pushRoute(
                                          context,
                                          AddWalletPage(
                                            wallet: wallet,
                                            routesToPopAfterDelete:
                                                RoutesToPopAfterDelete
                                                    .PreventDelete,
                                          ),
                                        );
                                      },
                                      items:
                                          Provider.of<AllWallets>(context).list,
                                      getSelected: (TransactionWallet wallet) {
                                        return selectedWallet == wallet;
                                      },
                                      onSelected: (TransactionWallet wallet) {
                                        setSelectedWalletPk(wallet);
                                      },
                                      getCustomBorderColor:
                                          (TransactionWallet item) {
                                        return dynamicPastel(
                                          context,
                                          lightenPastel(
                                            HexColor(
                                              item.colour,
                                              defaultColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                            amount: 0.3,
                                          ),
                                          amount: 0.4,
                                        );
                                      },
                                      getLabel: (TransactionWallet wallet) {
                                        return wallet.name ==
                                                wallet.currency
                                                    .toString()
                                                    .toUpperCase()
                                            ? wallet.currency
                                                .toString()
                                                .toUpperCase()
                                            : wallet.name +
                                                " (" +
                                                wallet.currency
                                                    .toString()
                                                    .toUpperCase() +
                                                ")";
                                      },
                                      extraWidget: AddButton(
                                        onTap: () {},
                                        width: 40,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 1),
                                        openPage: AddWalletPage(
                                          routesToPopAfterDelete:
                                              RoutesToPopAfterDelete.None,
                                        ),
                                        borderRadius: 8,
                                      ),
                                    ),
                                  ),
                                ),
                          SelectAddedBudget(
                            selectedBudgetPk: selectedBudgetPk,
                            setSelectedBudget: setSelectedBudgetPk,
                            horizontalBreak: true,
                          ),
                          SelectObjective(
                            setSelectedObjective: setSelectedObjectivePk,
                            selectedObjectivePk: selectedObjectivePk,
                            horizontalBreak: true,
                          ),
                          AnimatedExpanded(
                            expand: selectedBudgetPk != null &&
                                selectedBudgetIsShared == true,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: SelectChips(
                                wrapped: enableDoubleColumn(context),
                                items: <String>[
                                  ...(selectedBudget?.sharedMembers ?? [])
                                ],
                                getLabel: (String item) {
                                  return getMemberNickname(item);
                                },
                                onSelected: (String item) {
                                  setSelectedPayer(item);
                                },
                                getSelected: (String item) {
                                  return selectedPayer == item;
                                },
                                onLongPress: (String item) {
                                  memberPopup(context, item);
                                },
                              ),
                            ),
                          ),
                          enableDoubleColumn(context)
                              ? SizedBox.shrink()
                              : transactionTextInput,
                          widget.transaction == null ||
                                  widget.transaction!.sharedDateUpdated == null
                              ? SizedBox.shrink()
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 28),
                                  child: TextFont(
                                    text: "synced".tr() +
                                        " " +
                                        getTimeAgo(
                                          widget
                                              .transaction!.sharedDateUpdated!,
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
                          Container(height: 100),
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
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.account_balance_wallet_outlined
                  : Icons.account_balance_wallet_rounded,
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
  const DateButton({
    Key? key,
    required this.onTap,
    required this.selectedDate,
    required this.selectedTime,
    required this.setSelectedDate,
    required this.setSelectedTime,
  }) : super(key: key);
  final VoidCallback onTap;
  final DateTime selectedDate;
  final Function(DateTime) setSelectedDate;
  final Function(TimeOfDay) setSelectedTime;
  final TimeOfDay selectedTime;
  @override
  Widget build(BuildContext context) {
    String wordedDate = getWordedDateShortMore(selectedDate);
    String wordedDateShort = getWordedDateShort(selectedDate);

    return Tappable(
      onTap: onTap,
      borderRadius: 10,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 6, bottom: 6, right: 4),
        child: Row(
          children: [
            ButtonIcon(
              onTap: onTap,
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.calendar_month_outlined
                  : Icons.calendar_month_rounded,
              size: 41,
            ),
            SizedBox(width: 15),
            Expanded(
              child: TextFont(
                text: wordedDate,
                fontWeight: FontWeight.bold,
                fontSize: 23,
                minFontSize: 15,
                maxLines: 1,
                autoSizeText: true,
                overflowReplacement: TextFont(
                  text: wordedDateShort,
                  fontWeight: FontWeight.bold,
                  fontSize: 23,
                  minFontSize: 15,
                  maxLines: 1,
                  autoSizeText: true,
                ),
              ),
            ),
            SizedBox(width: 10),
            Tappable(
              onTap: () async {
                TimeOfDay? newTime = await showCustomTimePicker(
                  context,
                  selectedTime,
                );
                setSelectedTime(newTime ?? selectedTime);
              },
              borderRadius: 5,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: TimeDigits(
                  timeOfDay: TimeOfDay(
                    hour: selectedTime.hour,
                    minute: selectedTime.minute,
                  ),
                ),
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
    required this.setSelectedNote,
    this.selectedCategory,
    required this.setSelectedCategory,
    this.selectedTitle,
    required this.setSelectedTags,
    this.next,
  }) : super(key: key);
  final Function(String) setSelectedTitle;
  final Function(String) setSelectedNote;
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

  void selectTitle() {
    widget.setSelectedCategory(selectedCategory!);
    if (foundFromCategory == false)
      widget.setSelectedTitle(selectedAssociatedTitle?.title ?? "");
    else
      widget.setSelectedTitle("");
    Navigator.pop(context);
    if (widget.next != null) {
      widget.next!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupFramework(
      title: "enter-title".tr(),
      hasBottomSafeArea: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: getWidthBottomSheet(context) - 36,
            child: TextInput(
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.title_outlined
                  : Icons.title_rounded,
              initialValue: widget.selectedTitle,
              autoFocus: true,
              onEditingComplete: () {
                //if selected a tag and a category is set, then go to enter amount
                //else enter amount
                if (selectedCategory?.name.toString().trim().toLowerCase() ==
                    input?.toString().trim().toLowerCase()) {
                  widget.setSelectedTitle("");
                } else {
                  widget.setSelectedTitle(
                      selectedAssociatedTitle?.title ?? input ?? "");
                }

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
                TransactionAssociatedTitle? selectedTitleLocal = result[0];
                String? categoryFk = result[1];
                bool foundFromCategoryLocal = result[2];

                if (selectedTitleLocal == null) {
                  selectedTitleLocal = await getLikeAssociatedTitle(text);
                  categoryFk = selectedTitleLocal?.categoryFk;
                  foundFromCategoryLocal = false;
                }

                if (categoryFk != null) {
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
              labelText: "title-placeholder".tr(),
              padding: EdgeInsets.zero,
            ),
          ),
          AnimatedSizeSwitcher(
            sizeDuration: Duration(milliseconds: 400),
            sizeCurve: Curves.easeInOut,
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
                        selectTitle();
                      },
                      child: Row(
                        children: [
                          CategoryIcon(
                            categoryPk: "-1",
                            size: 40,
                            category: selectedCategory,
                            margin: EdgeInsets.zero,
                            onTap: () {
                              selectTitle();
                            },
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFont(
                                text: selectedCategory?.name ?? "",
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              !foundFromCategory
                                  ? TextFont(
                                      text: selectedAssociatedTitle!.title,
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
          getIsFullScreen(context) ||
                  appStateSettings["askForTransactionNoteWithTitle"]
              ? Padding(
                  padding: const EdgeInsets.only(top: 13),
                  child: Container(
                    width: getWidthBottomSheet(context) - 36,
                    child: TextInput(
                      autoFocus: false,
                      onChanged: (text) {
                        widget.setSelectedNote(text);
                      },
                      labelText: "notes-placeholder".tr(),
                      icon: appStateSettings["outlinedIcons"]
                          ? Icons.sticky_note_2_outlined
                          : Icons.sticky_note_2_rounded,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      minLines: 3,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                )
              : SizedBox.shrink(),
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
          //           title: "select-category".tr(),
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
                  label: "select-category".tr(),
                  width: getWidthBottomSheet(context),
                  onTap: () {
                    Navigator.pop(context);
                    if (widget.next != null) {
                      widget.next!();
                    }
                  },
                )
              : SizedBox.shrink(),
          SizedBox(height: 10),
        ],
      ),
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
    this.popContext = true,
    this.popContextWhenSet = false,
    this.inputFormatters,
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
  final bool popContext;
  final bool popContextWhenSet;
  final List<TextInputFormatter>? inputFormatters;

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
            inputFormatters: widget.inputFormatters,
            focusNode: _focusNode,
            textCapitalization: widget.textCapitalization,
            icon: widget.icon != null
                ? widget.icon
                : appStateSettings["outlinedIcons"]
                    ? Icons.title_outlined
                    : Icons.title_rounded,
            initialValue: widget.selectedText,
            autoFocus: widget.autoFocus,
            readOnly: widget.readOnly,
            onEditingComplete: () {
              widget.setSelectedText(input ?? "");
              if (widget.popContext) {
                Navigator.pop(context);
              }
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
              if (widget.popContextWhenSet) {
                Navigator.pop(context);
              }
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
  String? categoryFk;
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

  if (categoryFk == null) {
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
      associatedTitlePk: "-1",
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
  String? categoryFk = null;
  TransactionAssociatedTitle? selectedTitleLocal;

  // getLikeAssociatedTitle is more efficient since it uses queries
  //
  // Alternative:
  // be more efficient when finding
  // lookup if title matches exactly category name in database
  // then get list of all associated titles that contain that title in database
  // then loop through those to see which match
  // instead of getting all then looping

  // List<TransactionAssociatedTitle> allTitles =
  //     (await database.getAllAssociatedTitles());

  // for (TransactionAssociatedTitle title in allTitles) {
  //   if (text.toLowerCase().contains(title.title.toLowerCase())) {
  //     categoryFk = title.categoryFk;
  //     selectedTitleLocal = title;
  //     break;
  //   }
  // }

  bool foundFromCategoryLocal = false;
  // if (categoryFk != null) {
  print("SEARCHING");
  List<TransactionCategory> allCategories = (await database.getAllCategories());
  print(allCategories);
  for (TransactionCategory category in allCategories) {
    if (text.toLowerCase().contains(category.name.toLowerCase())) {
      categoryFk = category.categoryPk;
      selectedTitleLocal = TransactionAssociatedTitle(
        associatedTitlePk: "-1",
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
  // }

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
        insert: true,
        TransactionAssociatedTitle(
          associatedTitlePk: "-1",
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

class SelectAddedBudget extends StatefulWidget {
  const SelectAddedBudget({
    required this.setSelectedBudget,
    this.selectedBudgetPk,
    this.extraHorizontalPadding,
    this.wrapped,
    this.horizontalBreak,
    super.key,
  });
  final Function(Budget?, {bool isSharedBudget}) setSelectedBudget;
  final String? selectedBudgetPk;
  final double? extraHorizontalPadding;
  final bool? wrapped;
  final bool? horizontalBreak;

  @override
  State<SelectAddedBudget> createState() => _SelectAddedBudgetState();
}

class _SelectAddedBudgetState extends State<SelectAddedBudget> {
  late String? selectedBudgetPk = widget.selectedBudgetPk;

  @override
  void didUpdateWidget(covariant SelectAddedBudget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (selectedBudgetPk != widget.selectedBudgetPk) {
      setState(() {
        selectedBudgetPk = widget.selectedBudgetPk;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Budget>>(
      stream: database.watchAllAddableBudgets(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.length <= 0) return Container();
          return HorizontalBreakAbove(
            enabled:
                enableDoubleColumn(context) && widget.horizontalBreak == true,
            child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: SelectChips(
                  wrapped: widget.wrapped ?? enableDoubleColumn(context),
                  extraHorizontalPadding: widget.extraHorizontalPadding,
                  onLongPress: (Budget? item) {
                    pushRoute(
                      context,
                      AddBudgetPage(
                        budget: item,
                        routesToPopAfterDelete:
                            RoutesToPopAfterDelete.PreventDelete,
                      ),
                    );
                  },
                  extraWidget: AddButton(
                    onTap: () {},
                    width: 40,
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    openPage: AddBudgetPage(
                      isAddedOnlyBudget: true,
                      routesToPopAfterDelete: RoutesToPopAfterDelete.One,
                    ),
                    borderRadius: 8,
                  ),
                  items: [null, ...snapshot.data!],
                  getLabel: (Budget? item) {
                    return item?.name ?? "no-budget".tr();
                  },
                  onSelected: (Budget? item) {
                    widget.setSelectedBudget(
                      item,
                      isSharedBudget: item?.sharedKey != null,
                    );
                    setState(() {
                      selectedBudgetPk = item?.budgetPk;
                    });
                  },
                  getSelected: (Budget? item) {
                    return selectedBudgetPk == item?.budgetPk;
                  },
                  getCustomBorderColor: (Budget? item) {
                    return dynamicPastel(
                      context,
                      lightenPastel(
                        HexColor(
                          item?.colour,
                          defaultColor: Theme.of(context).colorScheme.primary,
                        ),
                        amount: 0.3,
                      ),
                      amount: 0.4,
                    );
                  },
                )),
          );
        } else {
          return Container();
        }
      },
    );
  }
}

class SelectObjective extends StatefulWidget {
  const SelectObjective({
    required this.setSelectedObjective,
    this.selectedObjectivePk,
    this.extraHorizontalPadding,
    this.wrapped,
    this.horizontalBreak = false,
    super.key,
  });
  final Function(String?) setSelectedObjective;
  final String? selectedObjectivePk;
  final double? extraHorizontalPadding;
  final bool? wrapped;
  final bool horizontalBreak;

  @override
  State<SelectObjective> createState() => _SelectObjectiveState();
}

class _SelectObjectiveState extends State<SelectObjective> {
  late String? selectedObjectivePk = widget.selectedObjectivePk;

  @override
  void didUpdateWidget(covariant SelectObjective oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (selectedObjectivePk != widget.selectedObjectivePk) {
      setState(() {
        selectedObjectivePk = widget.selectedObjectivePk;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Objective>>(
      stream: database.watchAllObjectives(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.length <= 0) return Container();
          return HorizontalBreakAbove(
            enabled:
                enableDoubleColumn(context) && widget.horizontalBreak == true,
            child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: SelectChips(
                  wrapped: widget.wrapped ?? enableDoubleColumn(context),
                  extraHorizontalPadding: widget.extraHorizontalPadding,
                  onLongPress: (Objective? item) {
                    pushRoute(
                      context,
                      AddObjectivePage(
                        objective: item,
                        routesToPopAfterDelete:
                            RoutesToPopAfterDelete.PreventDelete,
                      ),
                    );
                  },
                  extraWidget: AddButton(
                    onTap: () {},
                    width: 40,
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    openPage: AddObjectivePage(
                      routesToPopAfterDelete: RoutesToPopAfterDelete.One,
                    ),
                    borderRadius: 8,
                  ),
                  items: [null, ...snapshot.data!],
                  getLabel: (Objective? item) {
                    return item?.name ?? "no-goal".tr();
                  },
                  onSelected: (Objective? item) {
                    widget.setSelectedObjective(
                      item?.objectivePk,
                    );
                    setState(() {
                      selectedObjectivePk = item?.objectivePk;
                    });
                  },
                  getSelected: (Objective? item) {
                    return selectedObjectivePk == item?.objectivePk;
                  },
                  getCustomBorderColor: (Objective? item) {
                    return dynamicPastel(
                      context,
                      lightenPastel(
                        HexColor(
                          item?.colour,
                          defaultColor: Theme.of(context).colorScheme.primary,
                        ),
                        amount: 0.3,
                      ),
                      amount: 0.4,
                    );
                  },
                )),
          );
        } else {
          return Container();
        }
      },
    );
  }
}

class HorizontalBreakAbove extends StatelessWidget {
  const HorizontalBreakAbove({
    required this.child,
    this.enabled = true,
    super.key,
  });
  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (enabled == false) return child;
    return Column(
      children: [
        // Divider(indent: 10, endIndent: 10),
        HorizontalBreak(),
        child,
      ],
    );
  }
}

class HorizontalBreak extends StatelessWidget {
  const HorizontalBreak(
      {this.padding = const EdgeInsets.symmetric(vertical: 10), super.key});
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: padding,
      height: 2,
      decoration: BoxDecoration(
        color: getColor(context, "dividerColor"),
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
    );
  }
}

void deleteTransactionPopup(
  BuildContext context, {
  required Transaction transaction,
  required TransactionCategory? category,
  required RoutesToPopAfterDelete routesToPopAfterDelete,
}) async {
  String? transactionName =
      await getTransactionLabel(transaction, category: category);
  DeletePopupAction? action = await openDeletePopup(
    context,
    title: "delete-transaction-question".tr(),
    subtitle: transactionName,
  );
  if (action == DeletePopupAction.Delete) {
    if (routesToPopAfterDelete == RoutesToPopAfterDelete.All) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (routesToPopAfterDelete == RoutesToPopAfterDelete.One) {
      Navigator.of(context).pop();
    }
    openLoadingPopupTryCatch(() async {
      await database.deleteTransaction(transaction.transactionPk);
      openSnackbar(
        SnackbarMessage(
          title: "deleted-transaction".tr(),
          icon: Icons.delete,
          description: transactionName,
        ),
      );
    });
  }
}

Future deleteTransactionsPopup(
  BuildContext context, {
  required List<String> transactionPks,
  required RoutesToPopAfterDelete routesToPopAfterDelete,
}) async {
  DeletePopupAction? action = await openDeletePopup(
    context,
    title: "delete-selected-transactions".tr(),
    subtitle: transactionPks.length.toString() +
        " " +
        (transactionPks.length == 1
            ? "transaction".tr().toLowerCase()
            : "transactions".tr().toLowerCase()),
  );
  if (action == DeletePopupAction.Delete) {
    if (routesToPopAfterDelete == RoutesToPopAfterDelete.All) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (routesToPopAfterDelete == RoutesToPopAfterDelete.One) {
      Navigator.of(context).pop();
    }
    openLoadingPopupTryCatch(() async {
      await database.deleteTransactions(transactionPks);
      openSnackbar(
        SnackbarMessage(
          title: "deleted-transactions".tr(),
          icon: Icons.delete,
          description: transactionPks.length.toString() +
              " " +
              (transactionPks.length == 1
                  ? "transaction".tr().toLowerCase()
                  : "transactions".tr().toLowerCase()),
        ),
      );
    });
  }
  return action;
}

class SelectTransactionTypePopup extends StatelessWidget {
  const SelectTransactionTypePopup({
    required this.setTransactionType,
    this.selectedTransactionType,
    super.key,
  });
  final Function(TransactionSpecialType? transactionType) setTransactionType;
  final TransactionSpecialType? selectedTransactionType;

  @override
  Widget build(BuildContext context) {
    return PopupFramework(
      title: "select-transaction-type".tr(),
      child: Column(
        children: [
          TransactionTypeInfoEntry(
            selectedTransactionType: selectedTransactionType,
            setTransactionType: setTransactionType,
            transactionType: null,
            title: "default".tr(),
            onTap: () {
              setTransactionType(null);
              Navigator.pop(context);
            },
            icon: appStateSettings["outlinedIcons"]
                ? Icons.check_circle_outlined
                : Icons.check_circle_rounded,
          ),
          TransactionTypeInfoEntry(
            selectedTransactionType: selectedTransactionType,
            setTransactionType: setTransactionType,
            transactionType: TransactionSpecialType.upcoming,
            title: "upcoming".tr(),
            childrenDescription: [
              ListItem(
                "upcoming-transaction-type-description-1".tr(),
              ),
              ListItem(
                "upcoming-transaction-type-description-2".tr(),
              ),
            ],
          ),
          TransactionTypeInfoEntry(
            selectedTransactionType: selectedTransactionType,
            setTransactionType: setTransactionType,
            transactionType: TransactionSpecialType.subscription,
            title: "subscription".tr(),
            childrenDescription: [
              ListItem(
                "subscription-transaction-type-description-1".tr(),
              ),
              ListItem(
                "subscription-transaction-type-description-2".tr(),
              ),
            ],
          ),
          TransactionTypeInfoEntry(
            selectedTransactionType: selectedTransactionType,
            setTransactionType: setTransactionType,
            transactionType: TransactionSpecialType.repetitive,
            title: "repetitive".tr(),
            childrenDescription: [
              ListItem(
                "repetitive-transaction-type-description-1".tr(),
              ),
              ListItem(
                "repetitive-transaction-type-description-2".tr(),
              ),
            ],
          ),
          TransactionTypeInfoEntry(
            selectedTransactionType: selectedTransactionType,
            setTransactionType: setTransactionType,
            transactionType: TransactionSpecialType.credit,
            title: "lent".tr(),
            childrenDescription: [
              ListItem(
                "lent-transaction-type-description-1".tr(),
              ),
              ListItem(
                "lent-transaction-type-description-2".tr(),
              ),
              ListItem(
                "lent-transaction-type-description-3".tr(),
              ),
            ],
          ),
          TransactionTypeInfoEntry(
            selectedTransactionType: selectedTransactionType,
            setTransactionType: setTransactionType,
            transactionType: TransactionSpecialType.debt,
            title: "borrowed".tr(),
            childrenDescription: [
              ListItem(
                "borrowed-transaction-type-description-1".tr(),
              ),
              ListItem(
                "borrowed-transaction-type-description-2".tr(),
              ),
              ListItem(
                "borrowed-transaction-type-description-3".tr(),
              ),
            ],
          ),
          SizedBox(height: 13),
          Tappable(
            color: dynamicPastel(
              context,
              Theme.of(context).colorScheme.secondaryContainer,
              amount: 0.5,
            ),
            borderRadius: 20,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Column(
                children: [
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFont(
                      maxLines: 5,
                      fontSize: 16,
                      textAlign: TextAlign.center,
                      text: "mark-transaction-help-description".tr(),
                    ),
                  ),
                  SizedBox(height: 18),
                  IgnorePointer(
                    child: TransactionEntry(
                      highlightActionButton: true,
                      useHorizontalPaddingConstrained: false,
                      openPage: Container(),
                      transaction: Transaction(
                        transactionPk: "-1",
                        name: "",
                        amount: 100,
                        note: "",
                        categoryFk: "-1",
                        walletFk: appStateSettings["selectedWalletPk"],
                        dateCreated: DateTime.now(),
                        income: false,
                        paid: false,
                        skipPaid: false,
                        type: TransactionSpecialType.upcoming,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (TransactionSpecialType type
                          in TransactionSpecialType.values)
                        IgnorePointer(
                          child: TransactionEntryActionButton(
                            transaction: Transaction(
                              transactionPk: "-1",
                              name: "",
                              amount: 0,
                              note: "",
                              categoryFk: "-1",
                              subCategoryFk: null,
                              walletFk: "",
                              dateCreated: DateTime.now(),
                              income: false,
                              paid: [
                                TransactionSpecialType.credit,
                                TransactionSpecialType.debt
                              ].contains(type)
                                  ? true
                                  : false,
                              skipPaid: false,
                              type: type,
                            ),
                            iconColor: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionTypeInfoEntry extends StatelessWidget {
  final Function(TransactionSpecialType? transactionType) setTransactionType;
  final TransactionSpecialType? selectedTransactionType;
  final List<Widget>? childrenDescription;
  final String title;
  final IconData? icon;
  final TransactionSpecialType? transactionType;
  final VoidCallback? onTap;

  TransactionTypeInfoEntry({
    Key? key,
    required this.setTransactionType,
    required this.selectedTransactionType,
    this.childrenDescription,
    required this.title,
    this.icon,
    required this.transactionType,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 13),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButtonStacked(
              filled: selectedTransactionType == transactionType,
              alignLeft: true,
              alignBeside: true,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              text: title,
              iconData: icon ?? getTransactionTypeIcon(transactionType),
              onTap: onTap ??
                  () {
                    setTransactionType(transactionType);
                    Navigator.pop(context);
                  },
              afterWidget: childrenDescription == null
                  ? null
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: childrenDescription ?? [],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
