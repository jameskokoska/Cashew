import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/accountsPage.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/pages/editBudgetLimitsPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/pages/premiumPage.dart';
import 'package:budget/pages/sharedBudgetSettings.dart';
import 'package:budget/struct/currencyFunctions.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/struct/shareBudget.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/countNumber.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/incomeExpenseTabSelector.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/selectChips.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/radioItems.dart';
import 'package:budget/widgets/saveBottomButton.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/selectCategory.dart';
import 'package:budget/widgets/selectColor.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/util/showDatePicker.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:budget/colors.dart';
import 'package:provider/provider.dart';
import 'package:budget/widgets/animatedExpanded.dart';

import '../widgets/listItem.dart';
import '../widgets/outlinedButtonStacked.dart';
import '../widgets/sliverStickyLabelDivider.dart';
import '../widgets/tappableTextEntry.dart';

class AddBudgetPage extends StatefulWidget {
  AddBudgetPage({
    Key? key,
    this.budget,
    this.isAddedOnlyBudget = false,
    required this.routesToPopAfterDelete,
  }) : super(key: key);
  final bool isAddedOnlyBudget;

  //When a budget is passed in, we are editing that budget
  final Budget? budget;

  final RoutesToPopAfterDelete routesToPopAfterDelete;

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
  List<String>? selectedCategoryPks;
  List<String>? selectedCategoryPksExclude;
  double? selectedAmount;
  String? selectedAmountCalculation;
  String? selectedTitle;
  int selectedPeriodLength = 1;
  DateTime selectedStartDate =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? selectedEndDate;
  Color? selectedColor;
  String selectedRecurrence = "Monthly";
  bool selectedPin = true;
  bool selectedShared = false;
  bool selectedAddedTransactionsOnly = false;
  List<BudgetTransactionFilters> selectedBudgetTransactionFilters = [
    BudgetTransactionFilters.defaultBudgetTransactionFilters
  ];
  List<String> allMembersOfAllBudgets = [];
  List<String>? selectedMemberTransactionFilters;
  FocusNode _titleFocusNode = FocusNode();
  bool increaseBudgetWarningShown = false;
  List<String>? selectedWalletFks = null;
  String selectedWalletPk = appStateSettings["selectedWalletPk"];

  // BudgetsCompanion budget = BudgetsCompanion();

  Future<void> selectColor(BuildContext context) async {
    openBottomSheet(
      context,
      PopupFramework(
        title: "select-color".tr(),
        child: SelectColor(
          selectedColor: selectedColor,
          setSelectedColor: setSelectedColor,
        ),
      ),
    );
  }

  setSelectedShared(bool shared) {
    setState(() {
      selectedShared = shared;
      if (shared == true) selectedAddedTransactionsOnly = true;
      if (shared == false) selectedAddedTransactionsOnly = true;
    });
  }

  setSelectedWalletPk(String walletPkPassed) {
    selectedWalletPk = walletPkPassed;
  }

  setAddedTransactionsOnly(bool addedOnly) {
    setState(() {
      selectedAddedTransactionsOnly = addedOnly;
      if (selectedShared && !addedOnly) {
        selectedShared = false;
      }
      if (addedOnly) {
        selectedCategoryPks = null;
        selectedCategoryPksExclude = null;
      }
      setSelectedCategories(null);
      setSelectedCategoriesExclude(null);
    });
  }

  void setSelectedCategories(List<String>? categories) {
    setState(() {
      selectedCategoryPks = categories;
      selectedCategoryPksExclude = null;
    });
    determineBottomButton();
    return;
  }

  void setSelectedCategoriesExclude(List<String>? categories) {
    setState(() {
      selectedCategoryPksExclude = categories;
      selectedCategoryPks = null;
    });
    determineBottomButton();
    return;
  }

  void setSelectedPin() {
    setState(() {
      selectedPin = !selectedPin;
    });
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

  void setSelectedColor(Color? color) {
    setState(() {
      selectedColor = color;
    });
    determineBottomButton();
    return;
  }

  void setSelectedAmount(double amount, String amountStringCalculation) {
    setState(() {
      selectedAmount = amount;
    });
  }

  Future addBudget() async {
    loadingIndeterminateKey.currentState!.setVisibility(true);
    Budget createdBudget = await createBudget();
    print("Added budget");
    int result = await database.createOrUpdateBudget(
        insert: widget.budget == null, createdBudget);
    if (selectedShared == true &&
        widget.budget == null &&
        appStateSettings["sharedBudgets"] == true) {
      openLoadingPopup(context);
      bool result2 = await shareBudget(createdBudget, context);
      Navigator.pop(context);
      if (result2 == false) {
        Future.delayed(Duration.zero, () {
          openPopup(
            context,
            title: "No Connection",
            icon: appStateSettings["outlinedIcons"]
                ? Icons.signal_wifi_connected_no_internet_4_outlined
                : Icons.signal_wifi_connected_no_internet_4_rounded,
            description:
                "You can only update the details of a shared budget online.",
            onSubmit: () {
              Navigator.pop(context);
            },
            onSubmitLabel: "ok".tr(),
          );
        });
        loadingIndeterminateKey.currentState!.setVisibility(false);
        return;
      }
    }
    loadingIndeterminateKey.currentState!.setVisibility(false);
    if (result == -1 && appStateSettings["sharedBudgets"] == true) {
      openPopup(
        context,
        title: "No Connection",
        icon: appStateSettings["outlinedIcons"]
            ? Icons.signal_wifi_connected_no_internet_4_outlined
            : Icons.signal_wifi_connected_no_internet_4_rounded,
        description:
            "You can only update the details of a shared category online.",
        onCancel: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
        onSubmit: () {
          Navigator.pop(context);
        },
        onSubmitLabel: "ok".tr(),
        onCancelLabel: "Exit Without Saving",
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<Budget> createBudget() async {
    Budget? currentInstance;
    if (widget.budget != null) {
      currentInstance =
          await database.getBudgetInstance(widget.budget!.budgetPk);
    }
    return await Budget(
      budgetPk: widget.budget != null ? widget.budget!.budgetPk : "-1",
      name: selectedTitle ?? "",
      amount: selectedAmount ?? 0,
      colour: toHexString(selectedColor),
      startDate: selectedStartDate,
      endDate: selectedEndDate ?? DateTime.now(),
      categoryFks: selectedCategoryPks,
      categoryFksExclude: selectedCategoryPksExclude,
      addedTransactionsOnly: selectedAddedTransactionsOnly,
      // TODO make this work excludeAddedTransactions
      periodLength: selectedPeriodLength,
      reoccurrence: mapRecurrence(selectedRecurrence),
      dateCreated:
          widget.budget != null ? widget.budget!.dateCreated : DateTime.now(),
      dateTimeModified: null,
      order: widget.budget != null
          ? widget.budget!.order
          : await database.getAmountOfBudgets(),
      walletFk: selectedWalletPk,
      pinned: selectedPin,
      sharedKey: widget.budget != null ? currentInstance!.sharedKey : null,
      sharedOwnerMember:
          widget.budget != null ? currentInstance!.sharedOwnerMember : null,
      sharedDateUpdated:
          widget.budget != null ? currentInstance!.sharedDateUpdated : null,
      sharedMembers:
          widget.budget != null ? currentInstance!.sharedMembers : null,
      sharedAllMembersEver:
          widget.budget != null ? currentInstance!.sharedAllMembersEver : null,
      budgetTransactionFilters: widget.budget?.addedTransactionsOnly == true ||
              selectedAddedTransactionsOnly
          ? null
          : currentInstance?.sharedKey != null
              ? null
              : selectedBudgetTransactionFilters,
      memberTransactionFilters: widget.budget?.addedTransactionsOnly == true ||
              selectedAddedTransactionsOnly
          ? null
          : currentInstance?.sharedKey != null
              ? null
              : selectedMemberTransactionFilters,
      isAbsoluteSpendingLimit:
          currentInstance?.isAbsoluteSpendingLimit ?? false,
      income: false,
      walletFks: selectedWalletFks,
    );
  }

  Budget? budgetInitial;

  void showDiscardChangesPopupIfNotEditing() async {
    Budget budgetCreated = await createBudget();
    budgetCreated = budgetCreated.copyWith(
        dateCreated: budgetInitial?.dateCreated,
        endDate: budgetInitial?.endDate);
    if (budgetCreated != budgetInitial && widget.budget == null) {
      discardChangesPopup(context, forceShow: true);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      if (widget.budget == null) {
        bool result = await premiumPopupBudgets(context);
        if (result == true && widget.isAddedOnlyBudget != true) {
          dynamic result = await openBottomSheet(
            context,
            fullSnap: false,
            SelectBudgetTypePopup(setBudgetType: setSelectedBudgetType),
          );
          if (result == "All Transactions") {
            await openBottomSheet(
              context,
              fullSnap: false,
              ViewBudgetTransactionFilterInfo(
                selectedBudgetFilters: selectedBudgetTransactionFilters,
                setSelectedBudgetFilters: setSelectedBudgetFilters,
                popOnDefault: true,
              ),
            );
          }
        }
      }

      allMembersOfAllBudgets = await database.getAllMembersOfBudgets();
      if (widget.isAddedOnlyBudget) {
        setAddedTransactionsOnly(true);
        setSelectedShared(false);
      }
      setState(() {});
    });

    if (widget.budget != null) {
      //We are editing a budget
      //Fill in the information from the passed in budget
      selectedTitle = widget.budget!.name;
      selectedPin = widget.budget!.pinned;
      selectedAmount = widget.budget!.amount;
      selectedAddedTransactionsOnly = widget.budget!.addedTransactionsOnly;
      selectedPeriodLength = widget.budget!.periodLength;
      selectedRecurrence = widget.budget!.reoccurrence == null
          ? "Monthly"
          : enumRecurrence[widget.budget!.reoccurrence];
      selectedStartDate = widget.budget!.startDate;
      selectedEndDate = widget.budget!.endDate;
      selectedColor = widget.budget!.colour == null
          ? null
          : HexColor(widget.budget!.colour);
      selectedWalletPk = widget.budget!.walletFk;
      selectedWalletFks = widget.budget!.walletFks;

      selectedBudgetTransactionFilters =
          widget.budget!.budgetTransactionFilters ??
              [BudgetTransactionFilters.defaultBudgetTransactionFilters];
      selectedMemberTransactionFilters =
          widget.budget!.memberTransactionFilters ?? null;

      var amountString = widget.budget!.amount.toStringAsFixed(2);
      if (amountString.substring(amountString.length - 2) == "00") {
        selectedAmountCalculation =
            amountString.substring(0, amountString.length - 3);
      } else {
        selectedAmountCalculation = amountString;
      }

      selectedCategoryPks = widget.budget!.categoryFks;
      selectedCategoryPksExclude = widget.budget!.categoryFksExclude;
      //Set to false because we can't save until we made some changes
      setState(() {
        canAddBudget = false;
      });
    }
    if (widget.budget == null) {
      Future.delayed(Duration.zero, () async {
        budgetInitial = await createBudget();
      });
    }
  }

  setSelectedBudgetFilters(List<BudgetTransactionFilters> filters) {
    setState(() {
      selectedBudgetTransactionFilters = filters;
    });
    determineBottomButton();
  }

  setSelectedBudgetType(String item) {
    if (item == "All Transactions") {
      setSelectedShared(false);
      setAddedTransactionsOnly(false);
    } else if (item == "Added Only") {
      setAddedTransactionsOnly(true);
      setSelectedShared(false);
    } else if (item == "Shared Group Budget") {
      if (kDebugMode) {
        setAddedTransactionsOnly(true);
        setSelectedShared(true);
      } else {
        openSnackbar(SnackbarMessage(title: "Only allowed in debug mode"));
      }
    }
  }

  @override
  void dispose() {
    _titleFocusNode.dispose();
    super.dispose();
  }

  determineBottomButton() {
    if (selectedTitle != null &&
        (selectedAmount ?? 0) >= 0 &&
        selectedAmount != null &&
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

  discardChangesPopupIfBudgetPassed() async {
    Budget? currentInstance;
    if (widget.budget != null) {
      currentInstance =
          await database.getBudgetInstance(widget.budget!.budgetPk);
    }
    discardChangesPopup(
      context,
      previousObject: widget.budget!.copyWith(
        sharedKey: Value(currentInstance!.sharedKey),
        sharedOwnerMember: Value(currentInstance.sharedOwnerMember),
        sharedDateUpdated: Value(currentInstance.sharedDateUpdated),
        sharedMembers: Value(currentInstance.sharedMembers),
        sharedAllMembersEver: Value(currentInstance.sharedAllMembersEver),
        isAbsoluteSpendingLimit: currentInstance.isAbsoluteSpendingLimit,
      ),
      currentObject: await createBudget(),
    );
  }

  void checkPopupBalanceCorrectionSelectedWarning(
      BuildContext context, List<String>? categories) {
    if (categories?.contains("0") == true) {
      openPopup(
        context,
        title: "balance-correction-selected".tr(),
        icon: appStateSettings["outlinedIcons"]
            ? Icons.bar_chart_outlined
            : Icons.bar_chart_rounded,
        description: "balance-correction-selected-info".tr(),
        onSubmit: () {
          Navigator.pop(context);
        },
        onSubmitLabel: "ok".tr(),
        onCancel: () {
          Navigator.pop(context);
          openBottomSheet(
            context,
            fullSnap: false,
            ViewBudgetTransactionFilterInfo(
                selectedBudgetFilters: selectedBudgetTransactionFilters,
                setSelectedBudgetFilters: setSelectedBudgetFilters),
          );
        },
        onCancelLabel: "info".tr(),
      );
    }
  }

  GlobalKey<_BudgetDetailsState> _budgetDetailsStateKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    double? budgetAmount = widget.budget == null
        ? null
        : budgetAmountToPrimaryCurrency(
            Provider.of<AllWallets>(context, listen: true), widget.budget!);

    return WillPopScope(
      onWillPop: () async {
        if (widget.budget != null) {
          discardChangesPopupIfBudgetPassed();
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
          resizeToAvoidBottomInset: true,
          dragDownToDismiss: true,
          title: widget.budget == null ? "add-budget".tr() : "edit-budget".tr(),
          onBackButton: () async {
            if (widget.budget != null) {
              discardChangesPopupIfBudgetPassed();
            } else {
              showDiscardChangesPopupIfNotEditing();
            }
          },
          onDragDownToDismiss: () async {
            if (widget.budget != null) {
              discardChangesPopupIfBudgetPassed();
            } else {
              showDiscardChangesPopupIfNotEditing();
            }
          },
          actions: [
            CustomPopupMenuButton(
              showButtons: widget.budget == null || enableDoubleColumn(context),
              keepOutFirst: true,
              items: [
                if (widget.budget != null &&
                    widget.routesToPopAfterDelete !=
                        RoutesToPopAfterDelete.PreventDelete)
                  DropdownItemMenu(
                    id: "delete-budget",
                    label: "delete-budget".tr(),
                    icon: appStateSettings["outlinedIcons"]
                        ? Icons.delete_outlined
                        : Icons.delete_rounded,
                    action: () {
                      deleteBudgetPopup(
                        context,
                        budget: widget.budget!,
                        routesToPopAfterDelete: widget.routesToPopAfterDelete,
                      );
                    },
                  ),
                // DropdownItemMenu(
                //   id: "pin-to-home",
                //   label: selectedPin
                //       ? "pinned-to-homepage".tr()
                //       : "unpinned-to-homepage".tr(),
                //   icon: selectedPin
                //       ? Icons.push_pin_rounded
                //       : Icons.push_pin_outlined,
                //   action: () {
                //     setSelectedPin();
                //   },
                // ),
                if (widget.budget != null)
                  DropdownItemMenu(
                    id: "spending-goals",
                    label: "spending-goals".tr(),
                    icon: appStateSettings["outlinedIcons"]
                        ? Icons.fact_check_outlined
                        : Icons.fact_check_rounded,
                    action: () async {
                      Budget budget = await createBudget();
                      pushRoute(
                        context,
                        StreamBuilder<Budget>(
                          stream: database.getBudget(widget.budget!.budgetPk),
                          builder: (context, snapshot) {
                            if (snapshot.data == null) return SizedBox.shrink();
                            return EditBudgetLimitsPage(
                              budget: budget,
                              currentIsAbsoluteSpendingLimit:
                                  snapshot.data!.isAbsoluteSpendingLimit,
                            );
                          },
                        ),
                      );
                    },
                  ),
              ],
            ),
          ],
          overlay: Align(
            alignment: Alignment.bottomCenter,
            child: selectedTitle == "" || selectedTitle == null
                ? SaveBottomButton(
                    label: "set-name".tr(),
                    onTap: () async {
                      FocusScope.of(context).unfocus();
                      Future.delayed(Duration(milliseconds: 100), () {
                        _titleFocusNode.requestFocus();
                      });
                    },
                    disabled: false,
                  )
                : selectedAmount == 0 || selectedAmount == null
                    ? SaveBottomButton(
                        label: "set-amount".tr(),
                        onTap: () async {
                          _budgetDetailsStateKey.currentState
                              ?.selectAmount(context);
                        },
                        disabled: false,
                      )
                    : SaveBottomButton(
                        label: widget.budget == null
                            ? "add-budget".tr()
                            : "save-changes".tr(),
                        onTap: () async {
                          await addBudget();
                        },
                        disabled: !(canAddBudget ?? false),
                      ),
          ),
          slivers: [
            ColumnSliver(
              centered: true,
              children: [
                SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: IntrinsicWidth(
                    child: TextInput(
                      textAlign: TextAlign.center,
                      autoFocus: kIsWeb && getIsFullScreen(context),
                      focusNode: _titleFocusNode,
                      labelText: "name-placeholder".tr(),
                      bubbly: false,
                      initialValue: selectedTitle,
                      onChanged: (text) {
                        setSelectedTitle(text);
                      },
                      padding: EdgeInsets.only(left: 7, right: 7),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      topContentPadding: 20,
                    ),
                  ),
                ),
                BudgetDetails(
                  showCurrentPeriod: true,
                  key: _budgetDetailsStateKey,
                  determineBottomButton: () {
                    determineBottomButton();
                  },
                  setSelectedAmount: setSelectedAmount,
                  initialSelectedAmount: selectedAmount,
                  setSelectedPeriodLength: (length) {
                    print("LENGTh");
                    print(selectedPeriodLength);
                    print(length);
                    setState(() {
                      selectedPeriodLength = length;
                    });
                  },
                  initialSelectedPeriodLength: selectedPeriodLength,
                  setSelectedRecurrence: (recurrence) {
                    setState(() {
                      selectedRecurrence = recurrence;
                    });
                  },
                  initialSelectedRecurrence: selectedRecurrence,
                  setSelectedStartDate: (date) {
                    setState(() {
                      selectedStartDate = date;
                    });
                  },
                  initialSelectedStartDate: selectedStartDate,
                  setSelectedEndDate: (date) {
                    setState(() {
                      selectedEndDate = date;
                    });
                  },
                  initialSelectedEndDate: selectedEndDate,
                  afterAmountEnteredDismissed: (amountEntered) {
                    if (widget.budget != null &&
                        amountEntered != null &&
                        budgetAmount != null) {
                      amountEntered = amountRatioToPrimaryCurrencyGivenPk(
                              Provider.of<AllWallets>(context, listen: false),
                              selectedWalletPk) *
                          amountEntered;
                      if (budgetAmount < amountEntered &&
                          increaseBudgetWarningShown == false) {
                        increaseBudgetWarningShown = true;
                        openPopup(
                          context,
                          title: "increase-budget-warning".tr(),
                          description:
                              "increase-budget-warning-description".tr(),
                          icon: appStateSettings["outlinedIcons"]
                              ? Icons.warning_outlined
                              : Icons.warning_rounded,
                          onSubmitLabel: "ok".tr(),
                          onSubmit: () {
                            Navigator.pop(context);
                          },
                        );
                      }
                    }
                  },
                  setSelectedWalletPk: setSelectedWalletPk,
                  initialSelectedWalletPk: selectedWalletPk,
                ),
                SizedBox(height: 10),
              ],
            ),
            SliverToBoxAdapter(
              child: widget.budget == null
                  ? SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 15,
                      ),
                      child: Button(
                        flexibleLayout: true,
                        icon: appStateSettings["outlinedIcons"]
                            ? Icons.fact_check_outlined
                            : Icons.fact_check_rounded,
                        label: "set-spending-goals".tr(),
                        onTap: () async {
                          Budget budget = await createBudget();
                          pushRoute(
                            context,
                            StreamBuilder<Budget>(
                              stream:
                                  database.getBudget(widget.budget!.budgetPk),
                              builder: (context, snapshot) {
                                if (snapshot.data == null)
                                  return SizedBox.shrink();
                                return EditBudgetLimitsPage(
                                  budget: budget,
                                  currentIsAbsoluteSpendingLimit:
                                      snapshot.data!.isAbsoluteSpendingLimit,
                                );
                              },
                            ),
                          );
                        },
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        textColor:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
            ),
            SliverStickyLabelDivider(
              info: "select-color".tr(),
              sliver: SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    height: 65,
                    child: SelectColor(
                      horizontalList: true,
                      selectedColor: selectedColor,
                      setSelectedColor: setSelectedColor,
                    ),
                  ),
                ),
              ),
            ),
            widget.budget != null
                ? SliverToBoxAdapter(child: SizedBox.shrink())
                : SliverStickyLabelDivider(
                    info: "budget-type".tr(),
                    sliver: ColumnSliver(
                      children: [
                        SizedBox(height: 5),
                        SelectChips(
                          allowMultipleSelected: false,
                          extraWidgetAtBeginning: true,
                          extraWidget: Transform.scale(
                            scale: 1.3,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              icon: Icon(
                                appStateSettings["outlinedIcons"]
                                    ? Icons.info_outlined
                                    : Icons.info_outline_rounded,
                                size: 19,
                              ),
                              onPressed: () {
                                openBottomSheet(
                                  context,
                                  fullSnap: false,
                                  SelectBudgetTypePopup(
                                    setBudgetType: setSelectedBudgetType,
                                    selectedBudgetTypeAdded:
                                        selectedAddedTransactionsOnly,
                                    selectedBudgetTypeAll:
                                        selectedAddedTransactionsOnly == false,
                                  ),
                                );
                              },
                            ),
                          ),
                          wrapped: true,
                          items: <String>[
                            "Added Only",
                            "All Transactions",
                            ...(appStateSettings["sharedBudgets"]
                                ? ["Shared Group Budget"]
                                : [])
                          ],
                          getLabel: (String item) {
                            if (item == "Shared Group Budget")
                              return item + " (Unsupported)";
                            else if (item == "All Transactions")
                              return "all-transactions".tr();
                            else if (item == "Added Only")
                              return "added-only".tr();
                            return item;
                          },
                          onSelected: (String item) {
                            setSelectedBudgetType(item);
                          },
                          getSelected: (String item) {
                            if (selectedShared == true &&
                                selectedAddedTransactionsOnly == true &&
                                item == "Shared Group Budget") {
                              return true;
                            } else if (selectedShared == false &&
                                selectedAddedTransactionsOnly == true &&
                                item == "Added Only") {
                              return true;
                            } else if (selectedShared == false &&
                                selectedAddedTransactionsOnly == false &&
                                item == "All Transactions") {
                              return true;
                            }
                            return false;
                          },
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
            SliverStickyLabelDivider(
              info: "transactions-to-include".tr(),
              visible:
                  !(selectedShared == true || selectedAddedTransactionsOnly) &&
                      ((widget.budget != null &&
                              widget.budget!.sharedKey == null &&
                              widget.budget!.addedTransactionsOnly == false) ||
                          widget.budget == null),
              sliver: SliverToBoxAdapter(
                child: FutureBuilder<TransactionCategory?>(
                    future: database.getCategory("0").$2,
                    builder: (context, snapshot) {
                      return AnimatedExpanded(
                        expand: !(selectedShared == true ||
                            selectedAddedTransactionsOnly),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5),
                            SelectChips(
                              extraWidget: Transform.scale(
                                scale: 1.3,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                  icon: Icon(
                                    appStateSettings["outlinedIcons"]
                                        ? Icons.info_outlined
                                        : Icons.info_outline_rounded,
                                    size: 19,
                                  ),
                                  onPressed: () {
                                    openBottomSheet(
                                      context,
                                      fullSnap: false,
                                      ViewBudgetTransactionFilterInfo(
                                          selectedBudgetFilters:
                                              selectedBudgetTransactionFilters,
                                          setSelectedBudgetFilters:
                                              setSelectedBudgetFilters),
                                    );
                                  },
                                ),
                              ),
                              extraWidgetAtBeginning: true,
                              items: [
                                BudgetTransactionFilters
                                    .defaultBudgetTransactionFilters,
                                BudgetTransactionFilters.includeIncome,
                                BudgetTransactionFilters.includeDebtAndCredit,
                                BudgetTransactionFilters.addedToOtherBudget,
                                BudgetTransactionFilters.addedToObjective,
                                ...(appStateSettings["sharedBudgets"]
                                    ? [
                                        BudgetTransactionFilters
                                            .sharedToOtherBudget
                                      ]
                                    : []),
                                if (snapshot.hasData)
                                  BudgetTransactionFilters
                                      .includeBalanceCorrection,
                              ],
                              getLabel: (dynamic item) {
                                return item ==
                                        BudgetTransactionFilters
                                            .defaultBudgetTransactionFilters
                                    ? "default".tr()
                                    : item ==
                                            BudgetTransactionFilters
                                                .includeIncome
                                        ? "include-income".tr()
                                        : item ==
                                                BudgetTransactionFilters
                                                    .addedToOtherBudget
                                            ? "added-to-other-budgets".tr()
                                            : item ==
                                                    BudgetTransactionFilters
                                                        .addedToObjective
                                                ? "added-to-goal".tr()
                                                : item ==
                                                        BudgetTransactionFilters
                                                            .sharedToOtherBudget
                                                    ? "shared-to-other-budgets"
                                                        .tr()
                                                    : item ==
                                                            BudgetTransactionFilters
                                                                .includeDebtAndCredit
                                                        ? "include-debt-and-credit"
                                                            .tr()
                                                        : item ==
                                                                BudgetTransactionFilters
                                                                    .includeBalanceCorrection
                                                            ? "balance-correction"
                                                                .tr()
                                                            : "";
                              },
                              onSelected: (dynamic item) {
                                if (item ==
                                    BudgetTransactionFilters
                                        .defaultBudgetTransactionFilters) {
                                  if (selectedBudgetTransactionFilters.contains(
                                      BudgetTransactionFilters
                                          .defaultBudgetTransactionFilters)) {
                                    selectedBudgetTransactionFilters = [];
                                  } else {
                                    selectedBudgetTransactionFilters = [
                                      BudgetTransactionFilters
                                          .defaultBudgetTransactionFilters
                                    ];
                                  }
                                } else {
                                  if (selectedBudgetTransactionFilters.contains(
                                      BudgetTransactionFilters
                                          .defaultBudgetTransactionFilters)) {
                                    selectedBudgetTransactionFilters = [];
                                  }
                                  if (selectedBudgetTransactionFilters
                                      .contains(item)) {
                                    selectedBudgetTransactionFilters
                                        .remove(item);
                                  } else {
                                    selectedBudgetTransactionFilters.add(item);
                                  }
                                }

                                setState(() {});
                                determineBottomButton();
                              },
                              getSelected: (dynamic item) {
                                if (selectedBudgetTransactionFilters.contains(
                                    BudgetTransactionFilters
                                        .defaultBudgetTransactionFilters))
                                  return isFilterSelectedWithDefaults(
                                      selectedBudgetTransactionFilters, item);
                                return selectedBudgetTransactionFilters
                                    .contains(item);
                              },
                            ),
                            AnimatedExpanded(
                              expand: appStateSettings["sharedBudgets"] ==
                                      true &&
                                  (selectedBudgetTransactionFilters.contains(
                                      BudgetTransactionFilters
                                          .sharedToOtherBudget)),
                              child: SelectChips(
                                items: ["All", ...allMembersOfAllBudgets],
                                getLabel: (String item) {
                                  return getMemberNickname(item);
                                },
                                onSelected: (String item) {
                                  if (item == "All" &&
                                      selectedMemberTransactionFilters ==
                                          null) {
                                    selectedMemberTransactionFilters = [];
                                    setState(() {});
                                    determineBottomButton();
                                    return;
                                  } else if (item == "All" &&
                                      selectedMemberTransactionFilters !=
                                          null) {
                                    selectedMemberTransactionFilters = null;
                                    setState(() {});
                                    determineBottomButton();
                                    return;
                                  }
                                  if (selectedMemberTransactionFilters ==
                                      null) {
                                    selectedMemberTransactionFilters = [];
                                  }
                                  if (selectedMemberTransactionFilters!
                                      .contains(item)) {
                                    selectedMemberTransactionFilters!
                                        .remove(item);
                                  } else {
                                    selectedMemberTransactionFilters!.add(item);
                                  }
                                  setState(() {});
                                  determineBottomButton();
                                },
                                getSelected: (String item) {
                                  if (item == "All" &&
                                      selectedMemberTransactionFilters == null)
                                    return true;
                                  if (item != "All" &&
                                      selectedMemberTransactionFilters == null)
                                    return true;
                                  return selectedMemberTransactionFilters!
                                      .contains(item);
                                },
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      );
                    }),
              ),
            ),
            if (widget.budget != null && widget.budget!.addedTransactionsOnly)
              SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 15, right: 15, top: 25),
                        child: TextFont(
                          text: "added-budget-description".tr(),
                          fontSize: 14,
                          textColor: getColor(context, "textLight"),
                          maxLines: 5,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SliverStickyLabelDivider(
              info: "select-accounts".tr(),
              visible:
                  !(selectedShared == true || selectedAddedTransactionsOnly) &&
                      ((widget.budget != null &&
                              widget.budget!.sharedKey == null &&
                              widget.budget!.addedTransactionsOnly == false) ||
                          widget.budget == null),
              sliver: SliverToBoxAdapter(
                child: StreamBuilder<List<TransactionWallet>>(
                  stream: database.watchAllWallets(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return AnimatedExpanded(
                        expand: !(selectedShared == true ||
                            selectedAddedTransactionsOnly),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5),
                            SelectChips(
                              items: [null, ...snapshot.data!],
                              onLongPress: (TransactionWallet? item) {
                                pushRoute(
                                  context,
                                  AddWalletPage(
                                    wallet: item,
                                    routesToPopAfterDelete:
                                        RoutesToPopAfterDelete.PreventDelete,
                                  ),
                                );
                              },
                              getLabel: (TransactionWallet? item) {
                                return item?.name ?? "all-accounts".tr();
                              },
                              onSelected: (TransactionWallet? item) {
                                // print(item);
                                // print(selectedWalletFks);
                                if (selectedWalletFks == null && item != null) {
                                  selectedWalletFks = [];
                                }
                                if (item != null) {
                                  if (selectedWalletFks!
                                      .contains(item.walletPk)) {
                                    selectedWalletFks!.remove(item.walletPk);
                                  } else {
                                    selectedWalletFks!.add(item.walletPk);
                                  }
                                }
                                if (item == null ||
                                    (selectedWalletFks ?? []).length <= 0) {
                                  selectedWalletFks = null;
                                }
                                setState(() {});
                                determineBottomButton();
                              },
                              getSelected: (TransactionWallet? item) {
                                return selectedWalletFks == null && item == null
                                    ? true
                                    : (selectedWalletFks ?? [])
                                        .contains(item?.walletPk);
                              },
                              getCustomBorderColor: (TransactionWallet? item) {
                                if (item == null) return null;
                                return dynamicPastel(
                                  context,
                                  lightenPastel(
                                    HexColor(
                                      item.colour,
                                      defaultColor:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    amount: 0.3,
                                  ),
                                  amount: 0.4,
                                );
                              },
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  },
                ),
              ),
            ),
            SliverStickyLabelDivider(
              info: "select-categories".tr(),
              extraInfo: getSelectedCategoriesText(selectedCategoryPks),
              visible:
                  !(selectedShared == true || selectedAddedTransactionsOnly) &&
                      ((widget.budget != null &&
                              widget.budget!.sharedKey == null &&
                              widget.budget!.addedTransactionsOnly == false) ||
                          widget.budget == null),
              sliver: SliverToBoxAdapter(
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 500),
                  opacity: (selectedCategoryPksExclude == null ||
                          selectedCategoryPksExclude?.isEmpty == true)
                      ? 1
                      : 0.3,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: AnimatedExpanded(
                      expand: !(selectedShared == true ||
                          selectedAddedTransactionsOnly),
                      child: SelectCategory(
                        horizontalList: true,
                        selectedCategories: selectedCategoryPks,
                        setSelectedCategories: (categories) {
                          checkPopupBalanceCorrectionSelectedWarning(
                              context, categories);
                          setSelectedCategories(categories);
                        },
                        showSelectedAllCategoriesIfNoneSelected: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverStickyLabelDivider(
              info: "select-exclude-categories".tr(),
              extraInfo: getSelectedCategoriesText(selectedCategoryPksExclude),
              visible:
                  !(selectedShared == true || selectedAddedTransactionsOnly) &&
                      ((widget.budget != null &&
                              widget.budget!.sharedKey == null &&
                              widget.budget!.addedTransactionsOnly == false) ||
                          widget.budget == null),
              sliver: SliverToBoxAdapter(
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 500),
                  opacity: (selectedCategoryPks == null ||
                          selectedCategoryPks?.isEmpty == true)
                      ? 1
                      : 0.3,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: AnimatedExpanded(
                      expand: !(selectedShared == true ||
                          selectedAddedTransactionsOnly),
                      child: SelectCategory(
                        horizontalList: true,
                        selectedCategories: selectedCategoryPksExclude,
                        setSelectedCategories: (categories) {
                          checkPopupBalanceCorrectionSelectedWarning(
                              context, categories);
                          setSelectedCategoriesExclude(categories);
                        },
                        showSelectedAllCategoriesIfNoneSelected: false,
                        fadeOutWhenSelected: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          listWidgets: [
            widget.budget != null && widget.budget!.sharedKey != null
                ? SharedBudgetSettings(
                    budget: widget.budget!,
                  )
                : SizedBox.shrink(),
            SizedBox(height: 13),
            Container(height: 70),
          ],
        ),
      ),
    );
  }
}

String getSelectedCategoriesText(List<String>? categoryFks) {
  if (categoryFks == null || categoryFks.isEmpty == true) {
    return "all-categories".tr();
  } else {
    if (categoryFks.length == 1) {
      return categoryFks.length.toString() +
          " " +
          "category".tr().toLowerCase();
    } else {
      return categoryFks.length.toString() +
          " " +
          "categories".tr().toLowerCase();
    }
  }
}

class ColumnSliver extends StatelessWidget {
  const ColumnSliver(
      {super.key, required this.children, this.centered = false});
  final List<Widget> children;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: children,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      ),
    );
  }
}

class BudgetDetails extends StatefulWidget {
  const BudgetDetails({
    super.key,
    required this.determineBottomButton,
    required this.setSelectedAmount,
    required this.setSelectedPeriodLength,
    required this.setSelectedRecurrence,
    required this.setSelectedStartDate,
    required this.setSelectedEndDate,
    this.setSelectedWalletPk,
    this.initialSelectedWalletPk,
    this.initialSelectedAmount,
    this.initialSelectedPeriodLength,
    this.initialSelectedStartDate,
    this.initialSelectedEndDate,
    this.initialSelectedRecurrence,
    this.afterAmountEnteredDismissed,
    this.showCurrentPeriod = false,
  });
  final Function determineBottomButton;
  final Function(double, String) setSelectedAmount;
  final Function(int) setSelectedPeriodLength;
  final Function(String) setSelectedRecurrence;
  final Function(DateTime) setSelectedStartDate;
  final Function(DateTime?) setSelectedEndDate;
  final Function(String)? setSelectedWalletPk;
  final String? initialSelectedWalletPk;
  final double? initialSelectedAmount;
  final int? initialSelectedPeriodLength;
  final DateTime? initialSelectedStartDate;
  final DateTime? initialSelectedEndDate;
  final String? initialSelectedRecurrence;
  final Function(double? amountEntered)? afterAmountEnteredDismissed;
  final bool showCurrentPeriod;
  @override
  State<BudgetDetails> createState() => _BudgetDetailsState();
}

class _BudgetDetailsState extends State<BudgetDetails> {
  late double? selectedAmount;
  late int selectedPeriodLength;
  late DateTime selectedStartDate;
  late DateTime? selectedEndDate;
  late String selectedRecurrence;
  String selectedRecurrenceDisplay = "month";
  late String selectedWalletPk;

  @override
  void initState() {
    selectedAmount = widget.initialSelectedAmount;
    selectedPeriodLength = widget.initialSelectedPeriodLength ?? 1;
    selectedStartDate = widget.initialSelectedStartDate ??
        DateTime(DateTime.now().year, DateTime.now().month, 1);
    selectedEndDate = widget.initialSelectedEndDate;
    selectedRecurrence = widget.initialSelectedRecurrence ?? "Monthly";
    selectedWalletPk =
        widget.initialSelectedWalletPk ?? appStateSettings["selectedWalletPk"];

    if (selectedPeriodLength == 1) {
      selectedRecurrenceDisplay = nameRecurrence[selectedRecurrence];
    } else {
      selectedRecurrenceDisplay = namesRecurrence[selectedRecurrence];
    }
    super.initState();
  }

  Future<void> selectAmount(BuildContext context) async {
    await openBottomSheet(
      context,
      fullSnap: true,
      PopupFramework(
        title: "enter-amount".tr(),
        hasPadding: false,
        underTitleSpace: false,
        child: SelectAmount(
          hideWalletPickerIfOneCurrency: true,
          onlyShowCurrencyIcon: true,
          amountPassed: selectedAmount.toString(),
          setSelectedAmount: (amount, calculation) {
            widget.setSelectedAmount(amount.abs(), calculation);
            setState(() {
              selectedAmount = amount.abs();
            });
            widget.determineBottomButton();
          },
          next: () async {
            Navigator.pop(context);
          },
          nextLabel: "set-amount".tr(),
          enableWalletPicker: true,
          padding: EdgeInsets.symmetric(horizontal: 18),
          setSelectedWalletPk: (walletPk) {
            setState(() {
              selectedWalletPk = walletPk;
            });
            if (widget.setSelectedWalletPk != null) {
              widget.setSelectedWalletPk!(walletPk);
            }
          },
          walletPkForCurrency: selectedWalletPk,
          selectedWalletPk: selectedWalletPk,
        ),
      ),
    );
    if (widget.afterAmountEnteredDismissed != null) {
      widget.afterAmountEnteredDismissed!(selectedAmount);
    }
  }

  Future<void> selectPeriodLength(BuildContext context) async {
    openBottomSheet(
      context,
      PopupFramework(
        title: "enter-period-length".tr(),
        child: SelectAmountValue(
          amountPassed: selectedPeriodLength.toString(),
          setSelectedAmount: (amount, _) {
            widget.determineBottomButton();
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
    widget.setSelectedPeriodLength(selectedPeriodLength);
    widget.determineBottomButton();
    return;
  }

  Future<void> selectRecurrence(BuildContext context) async {
    openBottomSheet(
      context,
      PopupFramework(
        title: "select-period".tr(),
        child: RadioItems(
          items: ["Custom", "Daily", "Weekly", "Monthly", "Yearly"],
          initial: selectedRecurrence,
          displayFilter: (item) {
            return item.toString().toLowerCase().tr();
          },
          onChanged: (value) {
            if (value == "Custom") {
              selectedEndDate = null;
              widget.setSelectedEndDate(null);
            }
            setState(() {
              selectedRecurrence = value;
              widget.setSelectedRecurrence(value);
              if (selectedPeriodLength == 1) {
                selectedRecurrenceDisplay = nameRecurrence[value];
              } else {
                selectedRecurrenceDisplay = namesRecurrence[value];
              }
            });
            Navigator.of(context).pop();
            widget.determineBottomButton();
          },
        ),
      ),
    );
  }

  Future<void> selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showCustomDateRangePicker(
      context,
      DateTimeRange(
        start: selectedStartDate,
        end: selectedEndDate ??
            DateTime(
              selectedStartDate.year,
              selectedStartDate.month,
              selectedStartDate.day + 7,
            ),
      ),
    );
    if (picked != null) {
      setState(() {
        selectedStartDate = picked.start;
        selectedEndDate = picked.end;
      });
      widget.setSelectedStartDate(picked.start);
      widget.setSelectedEndDate(picked.end);
    }
    widget.determineBottomButton();
  }

  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked =
        await showCustomDatePicker(context, selectedStartDate);
    setSelectedStartDate(picked);
  }

  setSelectedStartDate(DateTime? date) {
    if (date != null && date != selectedStartDate) {
      widget.setSelectedStartDate(date);
      setState(() {
        selectedStartDate = date;
      });
    }
    widget.determineBottomButton();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            alignment: WrapAlignment.center,
            children: [
              IntrinsicWidth(
                child: TappableTextEntry(
                  title: convertToMoney(
                    Provider.of<AllWallets>(context),
                    selectedAmount ?? 0,
                    currencyKey: Provider.of<AllWallets>(context, listen: true)
                        .indexedByPk[selectedWalletPk]
                        ?.currency,
                  ),
                  placeholder: convertToMoney(
                    Provider.of<AllWallets>(context),
                    0,
                    currencyKey: Provider.of<AllWallets>(context, listen: true)
                        .indexedByPk[selectedWalletPk]
                        ?.currency,
                  ),
                  showPlaceHolderWhenTextEquals: convertToMoney(
                    Provider.of<AllWallets>(context),
                    0,
                    currencyKey: Provider.of<AllWallets>(context, listen: true)
                        .indexedByPk[selectedWalletPk]
                        ?.currency,
                  ),
                  onTap: () {
                    selectAmount(context);
                  },
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  internalPadding:
                      EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 3),
                ),
              ),
              IntrinsicWidth(
                child: Row(
                  children: [
                    selectedRecurrence != "Custom"
                        ? TappableTextEntry(
                            title: "/ " + selectedPeriodLength.toString(),
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
                      title: selectedRecurrenceDisplay
                          .toString()
                          .toLowerCase()
                          .tr()
                          .toLowerCase(),
                      placeholder: "",
                      onTap: () {
                        selectRecurrence(context);
                      },
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      internalPadding:
                          EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 3),
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
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                      child: Center(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.end,
                          runAlignment: WrapAlignment.center,
                          alignment: WrapAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5.8),
                              child: TextFont(
                                text: "beginning".tr() + " ",
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IgnorePointer(
                              child: TappableTextEntry(
                                title:
                                    getWordedDateShortMore(selectedStartDate),
                                placeholder: "",
                                onTap: () {},
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                internalPadding: EdgeInsets.symmetric(
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
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                      child: Center(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IgnorePointer(
                              child: TappableTextEntry(
                                title: selectedEndDate == null
                                    ? null
                                    : getWordedDateShort(selectedStartDate) +
                                        " – " +
                                        getWordedDateShort(selectedEndDate!),
                                placeholder: "select-custom-period".tr(),
                                onTap: () {},
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                internalPadding: EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 4),
                                padding: EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        if (widget.showCurrentPeriod)
          AnimatedExpanded(
            expand:
                enumRecurrence[selectedRecurrence] != BudgetReoccurence.custom,
            child: Builder(builder: (context) {
              DateTimeRange budgetRange = getBudgetDate(
                Budget(
                  startDate: selectedStartDate,
                  periodLength: selectedPeriodLength,
                  reoccurrence: enumRecurrence[selectedRecurrence],
                  budgetPk: "-1",
                  name: "",
                  amount: 0,
                  endDate: DateTime.now(),
                  addedTransactionsOnly: false,
                  dateCreated: DateTime.now(),
                  pinned: false,
                  order: -1,
                  walletFk: "",
                  isAbsoluteSpendingLimit: false,
                  income: false,
                ),
                DateTime.now(),
              );
              String text = "current-period".tr() +
                  "\n" +
                  getWordedDateShortMore(budgetRange.start) +
                  " – " +
                  getWordedDateShortMore(budgetRange.end);
              return Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 10,
                        top: 5,
                      ),
                      child: AnimatedSizeSwitcher(
                        child: TextFont(
                          key: ValueKey(text),
                          text: text,
                          fontSize: 14.5,
                          maxLines: 4,
                          textColor: getColor(context, "textLight"),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
      ],
    );
  }
}

class SelectBudgetTypePopup extends StatelessWidget {
  const SelectBudgetTypePopup({
    required this.setBudgetType,
    this.selectedBudgetTypeAdded,
    this.selectedBudgetTypeAll,
    super.key,
  });
  final Function(String budgetTypeString) setBudgetType;
  final bool? selectedBudgetTypeAdded;
  final bool? selectedBudgetTypeAll;

  @override
  Widget build(BuildContext context) {
    return PopupFramework(
      title: "select-budget-type".tr(),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButtonStacked(
                  filled: selectedBudgetTypeAdded == true,
                  alignLeft: true,
                  alignBeside: true,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  text: "added-only".tr(),
                  iconData: appStateSettings["outlinedIcons"]
                      ? Icons.folder_outlined
                      : Icons.folder_rounded,
                  onTap: () {
                    setBudgetType("Added Only");
                    Navigator.pop(context, "Added Only");
                  },
                  afterWidget: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListItem(
                        "added-only-description-1".tr(),
                      ),
                      ListItem(
                        "added-only-description-2".tr(),
                      ),
                      Opacity(
                        opacity: 0.34,
                        child: ListItem(
                          "added-only-description-3".tr(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: OutlinedButtonStacked(
                  filled: selectedBudgetTypeAll == true,
                  alignLeft: true,
                  alignBeside: true,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  text: "all-transactions".tr(),
                  iconData: appStateSettings["outlinedIcons"]
                      ? Icons.category_outlined
                      : Icons.category_rounded,
                  onTap: () async {
                    setBudgetType("All Transactions");
                    Navigator.pop(context, "All Transactions");
                  },
                  afterWidget: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListItem(
                        "all-transactions-description-1".tr(),
                      ),
                      ListItem("all-transactions-description-2".tr()),
                      Opacity(
                        opacity: 0.34,
                        child: ListItem("all-transactions-description-3".tr()),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ViewBudgetTransactionFilterInfo extends StatefulWidget {
  const ViewBudgetTransactionFilterInfo({
    required this.selectedBudgetFilters,
    required this.setSelectedBudgetFilters,
    this.popOnDefault = false,
    super.key,
  });

  final List<BudgetTransactionFilters> selectedBudgetFilters;
  final void Function(List<BudgetTransactionFilters>) setSelectedBudgetFilters;
  final bool popOnDefault;

  @override
  State<ViewBudgetTransactionFilterInfo> createState() =>
      _ViewBudgetTransactionFilterInfoState();
}

class _ViewBudgetTransactionFilterInfoState
    extends State<ViewBudgetTransactionFilterInfo> {
  late List<BudgetTransactionFilters> selectedBudgetFilters =
      widget.selectedBudgetFilters;
  bool hasCorrectionCategory = false;

  onTap(BudgetTransactionFilters item) {
    if (item == BudgetTransactionFilters.defaultBudgetTransactionFilters) {
      if (selectedBudgetFilters
          .contains(BudgetTransactionFilters.defaultBudgetTransactionFilters)) {
        selectedBudgetFilters = [];
      } else {
        selectedBudgetFilters = [
          BudgetTransactionFilters.defaultBudgetTransactionFilters
        ];
      }
    } else {
      if (selectedBudgetFilters
          .contains(BudgetTransactionFilters.defaultBudgetTransactionFilters)) {
        selectedBudgetFilters = [];
      }
      if (selectedBudgetFilters.contains(item)) {
        selectedBudgetFilters.remove(item);
      } else {
        selectedBudgetFilters.add(item);
      }
    }
    widget.setSelectedBudgetFilters(selectedBudgetFilters);
    setState(() {});
  }

  @override
  void initState() {
    checkIfHasCorrectionCategory();
    super.initState();
  }

  void checkIfHasCorrectionCategory() {
    Future.delayed(Duration.zero, () async {
      try {
        await database.getCategory("0").$2;
        hasCorrectionCategory = true;
      } catch (e) {
        hasCorrectionCategory = false;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopupFramework(
      title: "select-transactions-to-include".tr(),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButtonStacked(
                  filled: selectedBudgetFilters.contains(
                      BudgetTransactionFilters.defaultBudgetTransactionFilters),
                  alignLeft: true,
                  alignBeside: true,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  text: "default".tr(),
                  iconData: appStateSettings["outlinedIcons"]
                      ? Icons.check_circle_outlined
                      : Icons.check_circle_rounded,
                  onTap: () {
                    if (widget.popOnDefault == true &&
                        selectedBudgetFilters.contains(BudgetTransactionFilters
                            .defaultBudgetTransactionFilters)) {
                      Navigator.pop(context);
                    } else {
                      onTap(BudgetTransactionFilters
                          .defaultBudgetTransactionFilters);
                    }
                  },
                ),
              ),
            ],
          ),
          FilterTypeInfoEntry(
            selectedBudgetFilters: selectedBudgetFilters,
            setSelectedBudgetFilters: widget.setSelectedBudgetFilters,
            budgetTransactionFilter: BudgetTransactionFilters.includeIncome,
            title: "include-income".tr(),
            childrenDescription: [
              ListItem(
                "include-income-description-1".tr(),
              ),
              ListItem(
                "include-income-description-2".tr(),
              ),
            ],
            icon: appStateSettings["outlinedIcons"]
                ? Icons.arrow_drop_up_outlined
                : Icons.arrow_drop_up_rounded,
            onTap: onTap,
          ),
          FilterTypeInfoEntry(
            selectedBudgetFilters: selectedBudgetFilters,
            setSelectedBudgetFilters: widget.setSelectedBudgetFilters,
            budgetTransactionFilter:
                BudgetTransactionFilters.includeDebtAndCredit,
            title: "include-debt-and-credit".tr(),
            childrenDescription: [
              ListItem(
                "include-debt-and-credit-description-1".tr(),
              ),
            ],
            icon: appStateSettings["outlinedIcons"]
                ? Icons.archive_outlined
                : Icons.archive_rounded,
            onTap: onTap,
          ),
          FilterTypeInfoEntry(
            selectedBudgetFilters: selectedBudgetFilters,
            setSelectedBudgetFilters: widget.setSelectedBudgetFilters,
            budgetTransactionFilter:
                BudgetTransactionFilters.addedToOtherBudget,
            title: "added-to-other-budgets".tr(),
            childrenDescription: [
              ListItem(
                "added-to-other-budgets-description-1".tr(),
              ),
            ],
            icon: appStateSettings["outlinedIcons"]
                ? Icons.add_outlined
                : Icons.add_rounded,
            onTap: onTap,
          ),
          FilterTypeInfoEntry(
            selectedBudgetFilters: selectedBudgetFilters,
            setSelectedBudgetFilters: widget.setSelectedBudgetFilters,
            budgetTransactionFilter: BudgetTransactionFilters.addedToObjective,
            title: "added-to-goal".tr(),
            childrenDescription: [
              ListItem(
                "added-to-goal-description-1".tr(),
              ),
            ],
            icon: appStateSettings["outlinedIcons"]
                ? Icons.savings_outlined
                : Icons.savings_rounded,
            onTap: onTap,
          ),
          if (hasCorrectionCategory == true)
            FilterTypeInfoEntry(
              selectedBudgetFilters: selectedBudgetFilters,
              setSelectedBudgetFilters: widget.setSelectedBudgetFilters,
              budgetTransactionFilter:
                  BudgetTransactionFilters.includeBalanceCorrection,
              title: "balance-correction".tr(),
              childrenDescription: [
                ListItem(
                  "balance-correction-description-1".tr(),
                ),
              ],
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.bar_chart_outlined
                  : Icons.bar_chart_rounded,
              onTap: onTap,
            ),
        ],
      ),
    );
  }
}

class FilterTypeInfoEntry extends StatelessWidget {
  final List<BudgetTransactionFilters> selectedBudgetFilters;
  final Function(List<BudgetTransactionFilters>) setSelectedBudgetFilters;
  final List<Widget> childrenDescription;
  final String title;
  final IconData icon;
  final Function(BudgetTransactionFilters filter) onTap;
  final BudgetTransactionFilters budgetTransactionFilter;

  FilterTypeInfoEntry({
    Key? key,
    required this.selectedBudgetFilters,
    required this.setSelectedBudgetFilters,
    required this.childrenDescription,
    required this.title,
    required this.icon,
    required this.onTap,
    required this.budgetTransactionFilter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 500),
      opacity: selectedBudgetFilters.contains(
              BudgetTransactionFilters.defaultBudgetTransactionFilters)
          ? 0.5
          : 1,
      child: Padding(
        padding: const EdgeInsets.only(top: 13),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButtonStacked(
                filled: isFilterSelectedWithDefaults(
                  selectedBudgetFilters,
                  budgetTransactionFilter,
                ),
                alignLeft: true,
                alignBeside: true,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                text: title,
                iconData: icon,
                onTap: () {
                  onTap(budgetTransactionFilter);
                },
                afterWidget: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: childrenDescription,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
