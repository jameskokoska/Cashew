import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/editBudgetLimitsPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/premiumPage.dart';
import 'package:budget/pages/sharedBudgetSettings.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/struct/shareBudget.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/globalSnackBar.dart';
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

import '../widgets/sliverStickyLabelDivider.dart';

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
  double? selectedAmount;
  String? selectedAmountCalculation;
  String? selectedTitle;
  bool selectedAllCategories = true;
  String selectedCategoriesText = "all-categories";
  int selectedPeriodLength = 1;
  DateTime selectedStartDate =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? selectedEndDate;
  Color? selectedColor;
  String selectedRecurrence = "Monthly";
  bool selectedPin = true;
  bool selectedShared = false;
  bool selectedAddedTransactionsOnly = false;
  List<BudgetTransactionFilters>? selectedBudgetTransactionFilters = null;
  List<String> allMembersOfAllBudgets = [];
  List<String>? selectedMemberTransactionFilters;
  FocusNode _titleFocusNode = FocusNode();
  bool selectedIsAbsoluteSpendingLimit = false;

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

  setAddedTransactionsOnly(bool addedOnly) {
    setState(() {
      selectedAddedTransactionsOnly = addedOnly;
      if (selectedShared && !addedOnly) {
        selectedShared = false;
      }
      if (addedOnly) {
        selectedCategoryPks = [];
        selectedAllCategories = true;
      }
      setSelectedCategories([]);
    });
  }

  void setSelectedCategories(List<String> categories) {
    if (categories.length <= 0) {
      setState(() {
        selectedCategoryPks = categories;
        selectedAllCategories = true;
      });
      setState(() {
        selectedCategoriesText = "all-categories";
      });
    } else {
      setState(() {
        selectedCategoryPks = categories;
        selectedAllCategories = false;
      });
      if (categories.length == 1) {
        setState(() {
          selectedCategoriesText = categories.length.toString() +
              " " +
              "category".tr().toLowerCase();
        });
      } else {
        setState(() {
          selectedCategoriesText = categories.length.toString() +
              " " +
              "categories".tr().toLowerCase();
        });
      }
    }
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
            icon: Icons.signal_wifi_connected_no_internet_4_rounded,
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
        icon: Icons.signal_wifi_connected_no_internet_4_rounded,
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
      allCategoryFks: selectedAllCategories,
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
      walletFk: "0",
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
      budgetTransactionFilters: widget.budget?.addedTransactionsOnly == true
          ? null
          : currentInstance?.sharedKey != null
              ? null
              : selectedBudgetTransactionFilters,
      memberTransactionFilters: widget.budget?.addedTransactionsOnly == true
          ? null
          : currentInstance?.sharedKey != null
              ? null
              : selectedMemberTransactionFilters,
      isAbsoluteSpendingLimit: selectedIsAbsoluteSpendingLimit,
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      if (widget.budget == null) premiumPopupBudgets(context);

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
      selectedAllCategories = widget.budget!.allCategoryFks;
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

      selectedBudgetTransactionFilters =
          widget.budget!.budgetTransactionFilters ?? null;
      selectedMemberTransactionFilters =
          widget.budget!.memberTransactionFilters ?? null;
      selectedIsAbsoluteSpendingLimit =
          widget.budget?.isAbsoluteSpendingLimit ?? false;

      var amountString = widget.budget!.amount.toStringAsFixed(2);
      if (amountString.substring(amountString.length - 2) == "00") {
        selectedAmountCalculation =
            amountString.substring(0, amountString.length - 3);
      } else {
        selectedAmountCalculation = amountString;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        updateInitial();
      });
    }
  }

  @override
  void dispose() {
    _titleFocusNode.dispose();
    super.dispose();
  }

  updateInitial() async {
    if (widget.budget != null && widget.budget!.categoryFks != null) {
      setSelectedCategories(widget.budget!.categoryFks!);
    }
    //Set to false because we can't save until we made some changes
    setState(() {
      canAddBudget = false;
    });
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
          sharedAllMembersEver: Value(currentInstance.sharedAllMembersEver)),
      currentObject: await createBudget(),
    );
  }

  GlobalKey<_BudgetDetailsState> _budgetDetailsStateKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.budget != null) {
          discardChangesPopupIfBudgetPassed();
        } else {
          discardChangesPopup(context, forceShow: true);
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
              discardChangesPopup(context, forceShow: true);
            }
          },
          onDragDownToDissmiss: () async {
            if (widget.budget != null) {
              discardChangesPopupIfBudgetPassed();
            } else {
              discardChangesPopup(context, forceShow: true);
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
                    icon: Icons.delete_rounded,
                    action: () {
                      deleteBudgetPopup(
                        context,
                        budget: widget.budget!,
                        routesToPopAfterDelete: widget.routesToPopAfterDelete,
                      );
                    },
                  ),
                DropdownItemMenu(
                  id: "pin-to-home",
                  label: selectedPin
                      ? "pinned-to-homepage".tr()
                      : "unpinned-to-homepage".tr(),
                  icon: selectedPin
                      ? Icons.push_pin_rounded
                      : Icons.push_pin_outlined,
                  action: () {
                    setSelectedPin();
                  },
                ),
                if (widget.budget != null)
                  DropdownItemMenu(
                    id: "spending-goals",
                    label: "spending-goals".tr(),
                    icon: Icons.fact_check_rounded,
                    action: () {
                      pushRoute(
                        context,
                        EditBudgetLimitsPage(
                          budget: widget.budget!,
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
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextInput(
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
                BudgetDetails(
                  key: _budgetDetailsStateKey,
                  determineBottomButton: () {
                    determineBottomButton();
                  },
                  setSelectedAmount: (amount, _) {
                    setState(() {
                      selectedAmount = amount;
                    });
                  },
                  initialSelectedAmount: selectedAmount,
                  setSelectedPeriodLength: (length) {
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
                ),
                SizedBox(height: 17),
              ],
            ),
            SliverStickyLabelDivider(
              info: "select-color".tr(),
              sliver: ColumnSliver(children: [
                Container(
                  height: 65,
                  child: SelectColor(
                    horizontalList: true,
                    selectedColor: selectedColor,
                    setSelectedColor: setSelectedColor,
                  ),
                ),
              ]),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 8)),
            widget.budget != null
                ? SliverToBoxAdapter(child: SizedBox.shrink())
                : SliverStickyLabelDivider(
                    info: "budget-type".tr(),
                    sliver: ColumnSliver(
                      children: [
                        AnimatedSize(
                          duration: Duration(milliseconds: 500),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextFont(
                              text: selectedAddedTransactionsOnly == false &&
                                      selectedShared == false
                                  ? "budget-type-all-description".tr()
                                  : selectedShared == true &&
                                          selectedAddedTransactionsOnly == true
                                      ? "budget-type-shared-description".tr()
                                      : "budget-type-added-description".tr(),
                              textColor: getColor(context, "textLight"),
                              fontSize: 13,
                              maxLines: 3,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        SelectChips(
                          wrapped: true,
                          items: <String>[
                            "All Transactions",
                            "Added Only",
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
                                openSnackbar(SnackbarMessage(
                                    title: "Only allowed in debug mode"));
                              }
                            }
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
                      ],
                    ),
                  ),
            widget.budget != null
                ? SliverToBoxAdapter(child: SizedBox.shrink())
                : SliverToBoxAdapter(child: SizedBox(height: 5)),
            SliverStickyLabelDivider(
              info: "select-categories".tr(),
              extraInfo: selectedCategoriesText.tr() +
                  " " +
                  "budget".tr().toLowerCase(),
              visible:
                  !(selectedShared == true || selectedAddedTransactionsOnly) &&
                      ((widget.budget != null &&
                              widget.budget!.sharedKey == null &&
                              widget.budget!.addedTransactionsOnly == false) ||
                          widget.budget == null),
              sliver: SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: AnimatedExpanded(
                    expand: !(selectedShared == true ||
                        selectedAddedTransactionsOnly),
                    child: Container(
                      height: 100,
                      child: SelectCategory(
                        horizontalList: true,
                        selectedCategories: selectedCategoryPks,
                        setSelectedCategories: setSelectedCategories,
                        showSelectedAllCategoriesIfNoneSelected: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverStickyLabelDivider(
              info: "transaction-filters".tr(),
              visible:
                  !(selectedShared == true || selectedAddedTransactionsOnly) &&
                      ((widget.budget != null &&
                              widget.budget!.sharedKey == null &&
                              widget.budget!.addedTransactionsOnly == false) ||
                          widget.budget == null),
              sliver: ColumnSliver(
                children: [
                  AnimatedExpanded(
                    expand: !(selectedShared == true ||
                        selectedAddedTransactionsOnly),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 5),
                        SelectChips(
                          items: [
                            "All",
                            BudgetTransactionFilters.addedToOtherBudget,
                            ...(appStateSettings["sharedBudgets"]
                                ? [BudgetTransactionFilters.sharedToOtherBudget]
                                : []),
                          ],
                          getLabel: (dynamic item) {
                            if (item == "All") return "all".tr();
                            return item ==
                                    BudgetTransactionFilters.addedToOtherBudget
                                ? "added-to-other-budgets".tr()
                                : item ==
                                        BudgetTransactionFilters
                                            .sharedToOtherBudget
                                    ? "shared-to-other-budgets".tr()
                                    : "";
                          },
                          onSelected: (dynamic item) {
                            if (item == "All" &&
                                selectedBudgetTransactionFilters == null) {
                              selectedBudgetTransactionFilters = [];
                              setState(() {});
                              determineBottomButton();
                              return;
                            } else if (item == "All" &&
                                selectedBudgetTransactionFilters != null) {
                              selectedBudgetTransactionFilters = null;
                              setState(() {});
                              determineBottomButton();
                              return;
                            }
                            if (selectedBudgetTransactionFilters == null)
                              selectedBudgetTransactionFilters = [];
                            if (selectedBudgetTransactionFilters!
                                .contains(item))
                              selectedBudgetTransactionFilters!.remove(item);
                            else
                              selectedBudgetTransactionFilters!.add(item);
                            setState(() {});
                            determineBottomButton();
                          },
                          getSelected: (dynamic item) {
                            if (item == "All" &&
                                selectedBudgetTransactionFilters == null)
                              return true;
                            if (selectedBudgetTransactionFilters == null)
                              return true;
                            return selectedBudgetTransactionFilters!
                                .contains(item);
                          },
                        ),
                        AnimatedExpanded(
                          expand: appStateSettings["sharedBudgets"] == true &&
                              (selectedBudgetTransactionFilters == null ||
                                  selectedBudgetTransactionFilters!.contains(
                                      BudgetTransactionFilters
                                          .sharedToOtherBudget)),
                          child: SelectChips(
                            items: ["All", ...allMembersOfAllBudgets],
                            getLabel: (String item) {
                              return getMemberNickname(item);
                            },
                            onSelected: (String item) {
                              if (item == "All" &&
                                  selectedMemberTransactionFilters == null) {
                                selectedMemberTransactionFilters = [];
                                setState(() {});
                                determineBottomButton();
                                return;
                              } else if (item == "All" &&
                                  selectedMemberTransactionFilters != null) {
                                selectedMemberTransactionFilters = null;
                                setState(() {});
                                determineBottomButton();
                                return;
                              }
                              if (selectedMemberTransactionFilters == null) {
                                selectedMemberTransactionFilters = [];
                              }
                              if (selectedMemberTransactionFilters!
                                  .contains(item)) {
                                selectedMemberTransactionFilters!.remove(item);
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
                      ],
                    ),
                  ),
                  widget.budget != null && widget.budget!.addedTransactionsOnly
                      ? Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 15, right: 15, top: 25),
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
                        )
                      : SizedBox.shrink(),
                ],
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

class TappableTextEntry extends StatelessWidget {
  const TappableTextEntry({
    Key? key,
    required this.title,
    required this.placeholder,
    required this.onTap,
    this.fontSize,
    this.fontWeight,
    this.padding = const EdgeInsets.symmetric(vertical: 0),
    this.internalPadding =
        const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
    this.autoSizeText = false,
    this.showPlaceHolderWhenTextEquals,
  }) : super(key: key);

  final String? title;
  final String placeholder;
  final VoidCallback onTap;
  final EdgeInsets padding;
  final EdgeInsets internalPadding;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool autoSizeText;
  final String? showPlaceHolderWhenTextEquals;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      color: Colors.transparent,
      borderRadius: 15,
      child: Padding(
        padding: padding,
        child: Container(
          padding: internalPadding,
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    width: 1.5,
                    color: appStateSettings["materialYou"]
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                        : getColor(context, "lightDarkAccentHeavy"))),
          ),
          child: IntrinsicWidth(
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextFont(
                autoSizeText: autoSizeText,
                maxLines: 1,
                minFontSize: 16,
                textAlign: TextAlign.left,
                fontSize: fontSize ?? 35,
                fontWeight: fontWeight ?? FontWeight.bold,
                text: title == null ||
                        title == "" ||
                        title == showPlaceHolderWhenTextEquals
                    ? placeholder
                    : title ?? "",
                textColor: title == null ||
                        title == "" ||
                        title == showPlaceHolderWhenTextEquals
                    ? getColor(context, "textLight")
                    : getColor(context, "black"),
              ),
            ),
          ),
        ),
      ),
    );
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
    this.initialSelectedAmount,
    this.initialSelectedPeriodLength,
    this.initialSelectedStartDate,
    this.initialSelectedEndDate,
    this.initialSelectedRecurrence,
  });
  final Function determineBottomButton;
  final Function(double, String) setSelectedAmount;
  final Function(int) setSelectedPeriodLength;
  final Function(String) setSelectedRecurrence;
  final Function(DateTime) setSelectedStartDate;
  final Function(DateTime?) setSelectedEndDate;
  final double? initialSelectedAmount;
  final int? initialSelectedPeriodLength;
  final DateTime? initialSelectedStartDate;
  final DateTime? initialSelectedEndDate;
  final String? initialSelectedRecurrence;
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
  @override
  void initState() {
    selectedAmount = widget.initialSelectedAmount;
    selectedPeriodLength = widget.initialSelectedPeriodLength ?? 1;
    selectedStartDate = widget.initialSelectedStartDate ??
        DateTime(DateTime.now().year, DateTime.now().month, 1);
    selectedEndDate = widget.initialSelectedEndDate;
    selectedRecurrence = widget.initialSelectedRecurrence ?? "Monthly";

    if (selectedPeriodLength == 1) {
      selectedRecurrenceDisplay = nameRecurrence[selectedRecurrence];
    } else {
      selectedRecurrenceDisplay = namesRecurrence[selectedRecurrence];
    }
    super.initState();
  }

  Future<void> selectAmount(BuildContext context) async {
    openBottomSheet(
      context,
      fullSnap: true,
      PopupFramework(
        title: "enter-amount".tr(),
        underTitleSpace: false,
        child: SelectAmount(
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
        ),
      ),
    );
  }

  Future<void> selectPeriodLength(BuildContext context) async {
    openBottomSheet(
      context,
      PopupFramework(
        title: "Enter Period Length",
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
                      Provider.of<AllWallets>(context), selectedAmount ?? 0),
                  placeholder:
                      convertToMoney(Provider.of<AllWallets>(context), 0),
                  showPlaceHolderWhenTextEquals:
                      convertToMoney(Provider.of<AllWallets>(context), 0),
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
                                onTap: () {
                                  selectAmount(context);
                                },
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
                                        " - " +
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
      ],
    );
  }
}
