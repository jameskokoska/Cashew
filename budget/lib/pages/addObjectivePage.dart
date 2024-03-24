import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/accountsPage.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/pages/editObjectivesPage.dart';
import 'package:budget/pages/editWalletsPage.dart';
import 'package:budget/pages/objectivesListPage.dart';
import 'package:budget/pages/premiumPage.dart';
import 'package:budget/struct/currencyFunctions.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/extraInfoBoxes.dart';
import 'package:budget/widgets/globalSnackbar.dart';
import 'package:budget/widgets/iconButtonScaled.dart';
import 'package:budget/widgets/incomeExpenseTabSelector.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/periodCyclePicker.dart';
import 'package:budget/widgets/saveBottomButton.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/selectCategory.dart';
import 'package:budget/widgets/selectCategoryImage.dart';
import 'package:budget/widgets/selectColor.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/currencyPicker.dart';
import 'package:budget/widgets/transactionEntry/incomeAmountArrow.dart';
import 'package:budget/widgets/transactionEntry/transactionEntryAmount.dart';
import 'package:budget/widgets/util/showDatePicker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:budget/colors.dart';
import 'package:provider/provider.dart';

import '../widgets/listItem.dart';
import '../widgets/outlinedButtonStacked.dart';
import '../widgets/selectDateRange.dart';
import '../widgets/sliverStickyLabelDivider.dart';
import '../widgets/tappableTextEntry.dart';
import 'exchangeRatesPage.dart';

class AddObjectivePage extends StatefulWidget {
  AddObjectivePage({
    Key? key,
    this.objective,
    required this.routesToPopAfterDelete,
    this.objectiveType = ObjectiveType.goal,
    this.selectedIncome,
  }) : super(key: key);

  //When a wallet is passed in, we are editing that wallet
  final Objective? objective;
  final RoutesToPopAfterDelete routesToPopAfterDelete;
  final ObjectiveType objectiveType;
  final bool? selectedIncome;

  @override
  _AddObjectivePageState createState() => _AddObjectivePageState();
}

class _AddObjectivePageState extends State<AddObjectivePage>
    with SingleTickerProviderStateMixin {
  bool? canAddObjective;

  String? selectedTitle;
  Color? selectedColor;
  late String? selectedImage = widget.objective == null ? "image.png" : null;
  String? selectedEmoji;
  double selectedAmount = 0;
  DateTime selectedStartDate = DateTime.now();
  DateTime? selectedEndDate = null;
  late bool selectedIncome = widget.selectedIncome ?? true;
  bool selectedPin = true;
  String selectedWalletPk = appStateSettings["selectedWalletPk"];
  bool isDifferenceOnlyLoan = false;

  FocusNode _titleFocusNode = FocusNode();
  late TabController _incomeTabController =
      TabController(length: 2, vsync: this);

  late ObjectiveType objectiveType =
      widget.objective?.type ?? widget.objectiveType;

  setSelectedWalletPk(String walletPkPassed) {
    setState(() {
      selectedWalletPk = walletPkPassed;
    });
  }

  void setSelectedTitle(String title) {
    setState(() {
      selectedTitle = title;
    });
    determineBottomButton();
    return;
  }

  void setSelectedImage(String? image) {
    setState(() {
      selectedImage = (image ?? "").replaceFirst("assets/categories/", "");
      selectedEmoji = null;
    });
    determineBottomButton();
    return;
  }

  void setSelectedEmoji(String? emoji) {
    setState(() {
      selectedEmoji = emoji;
      selectedImage = null;
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

  void setSelectedAmount(double amount) {
    setState(() {
      selectedAmount = amount;
    });
    determineBottomButton();
    return;
  }

  void setSelectedIncome(bool income) {
    setState(() {
      selectedIncome = income;
      if (isDifferenceOnlyLoan) {
        selectedAmount = 0;
      }
      isDifferenceOnlyLoan = false;
    });
    determineBottomButton();
    return;
  }

  Future<void> selectAmount(BuildContext context,
      {bool allowZero = false}) async {
    openBottomSheet(
      context,
      fullSnap: true,
      PopupFramework(
        title: "enter-amount".tr(),
        underTitleSpace: false,
        hasPadding: false,
        child: SelectAmount(
          allowZero: allowZero,
          hideWalletPickerIfOneCurrency: true,
          onlyShowCurrencyIcon: true,
          amountPassed: selectedAmount.toString(),
          setSelectedAmount: (amount, calculation) {
            setSelectedAmount(amount.abs());
            setState(() {
              selectedAmount = amount.abs();
            });
            determineBottomButton();
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
          },
          walletPkForCurrency: selectedWalletPk,
          selectedWalletPk: selectedWalletPk,
        ),
      ),
    );
  }

  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked =
        await showCustomDatePicker(context, selectedStartDate);
    setSelectedStartDate(picked);
  }

  Future<void> selectEndDate(BuildContext context) async {
    final DateTime? picked =
        await showCustomDatePicker(context, selectedEndDate ?? DateTime.now());
    if (picked != null) setSelectedEndDate(picked);
  }

  setSelectedStartDate(DateTime? date) {
    if (date != null && date != selectedStartDate) {
      setState(() {
        selectedStartDate = date;
      });
    }
    determineBottomButton();
  }

  setSelectedEndDate(DateTime? date) {
    if (date != selectedEndDate) {
      setState(() {
        selectedEndDate = date;
      });
    }
    determineBottomButton();
  }

  Future addObjective() async {
    MainAndSubcategory? mainAndSubcategory;
    if (widget.objective == null &&
        widget.objectiveType == ObjectiveType.loan &&
        isDifferenceOnlyLoan == false) {
      mainAndSubcategory = await selectCategorySequence(
        context,
        selectedCategory: null,
        setSelectedCategory: (_) {},
        selectedSubCategory: null,
        setSelectedSubCategory: (_) {},
        selectedIncomeInitial: null,
        subtitle: "select-first-transaction-category".tr(),
      );
      if (mainAndSubcategory.main == null) {
        return;
      }
    }

    print("Added objective");
    int rowId = await database.createOrUpdateObjective(
        insert: widget.objective == null, await createObjective());

    // Create the initial transaction if it is a loan
    if (widget.objective == null &&
        widget.objectiveType == ObjectiveType.loan &&
        isDifferenceOnlyLoan == false) {
      final Objective objectiveJustAdded =
          await database.getObjectiveFromRowId(rowId);
      if (mainAndSubcategory?.main != null) {
        await database.createOrUpdateTransaction(
          insert: true,
          Transaction(
            transactionPk: "-1",
            name: "initial-record".tr(),
            note: "",
            amount: selectedAmount.abs() * (!selectedIncome ? 1 : -1),
            categoryFk: mainAndSubcategory!.main!.categoryPk,
            subCategoryFk: mainAndSubcategory.sub?.categoryPk,
            walletFk: selectedWalletPk,
            dateCreated: DateTime.now(),
            income: !selectedIncome,
            paid: true,
            skipPaid: false,
            type: null,
            objectiveLoanFk: objectiveJustAdded.objectivePk,
          ),
        );
      }
    }
    Navigator.pop(context);
  }

  Future<Objective> createObjective() async {
    int numberOfObjectives = (await database.getTotalCountOfObjectives(
            objectiveType: objectiveType))[0] ??
        0;
    if (selectedEndDate != null &&
        selectedStartDate.isAfter(selectedEndDate!)) {
      selectedEndDate = null;
    }
    return Objective(
      objectivePk:
          widget.objective != null ? widget.objective!.objectivePk : "-1",
      name: selectedTitle ?? "",
      colour: toHexString(selectedColor),
      dateCreated: selectedStartDate,
      endDate: selectedEndDate,
      dateTimeModified: null,
      order: widget.objective != null
          ? widget.objective!.order
          : numberOfObjectives,
      emojiIconName: selectedEmoji,
      iconName: selectedImage,
      amount: isDifferenceOnlyLoan == true &&
              appStateSettings["longTermLoansDifferenceFeature"] == true
          // This defines what a difference only loan can be
          ? -1
          // Set to zero if adding a new long term loan, otherwise keep its amount because of the total offset
          : objectiveType == ObjectiveType.loan && widget.objective == null
              ? 0
              : selectedAmount,
      income: selectedIncome,
      pinned: selectedPin,
      walletFk: selectedWalletPk,
      archived: widget.objective?.archived ?? false,
      type: objectiveType,
    );
  }

  Objective? objectiveInitial;

  void showDiscardChangesPopupIfNotEditing() async {
    Objective objectiveCreated = await createObjective();
    objectiveCreated =
        objectiveCreated.copyWith(dateCreated: objectiveInitial?.dateCreated);
    if (objectiveCreated != objectiveInitial && widget.objective == null) {
      discardChangesPopup(context, forceShow: true);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.objective != null) {
      //We are editing an objective
      //Fill in the information from the passed in objective
      //Outside of future.delayed because of textinput when in web mode initial value
      selectedTitle = widget.objective!.name;

      selectedColor = widget.objective!.colour == null
          ? null
          : HexColor(widget.objective!.colour);
      selectedImage = widget.objective!.iconName;
      selectedEmoji = widget.objective!.emojiIconName;
      selectedStartDate = widget.objective!.dateCreated;
      selectedEndDate = widget.objective!.endDate;
      selectedAmount = widget.objective!.amount;
      selectedPin = widget.objective!.pinned;
      selectedWalletPk = widget.objective!.walletFk;
      isDifferenceOnlyLoan = getIsDifferenceOnlyLoan(widget.objective!);

      selectedIncome = widget.objective!.income;
      if (widget.objective?.income == false) {
        _incomeTabController.animateTo(1);
      } else {
        _incomeTabController.animateTo(0);
      }
    } else {
      Future.delayed(Duration.zero, () async {
        if (widget.objective == null) {
          bool result = await premiumPopupObjectives(context,
              objectiveType: objectiveType);
          if (result == true && objectiveType != ObjectiveType.loan) {
            openBottomSheet(
              context,
              fullSnap: false,
              SelectObjectiveTypePopup(
                setObjectiveIncome: setSelectedIncome,
              ),
            );
          }
        }
      });
    }
    if (widget.objective == null) {
      Future.delayed(Duration.zero, () async {
        objectiveInitial = await createObjective();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  determineBottomButton() {
    if (selectedTitle != null) {
      if (canAddObjective != true)
        this.setState(() {
          canAddObjective = true;
        });
    } else {
      if (canAddObjective != false)
        this.setState(() {
          canAddObjective = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.objective != null) {
          discardChangesPopup(
            context,
            previousObject: widget.objective,
            currentObject: await createObjective(),
          );
        } else {
          showDiscardChangesPopupIfNotEditing();
        }
        return false;
      },
      child: GestureDetector(
        onTap: () {
          minimizeKeyboard(context);
        },
        child: PageFramework(
          horizontalPadding: getHorizontalPaddingConstrained(context),
          resizeToAvoidBottomInset: true,
          dragDownToDismiss: true,
          title: objectiveType == ObjectiveType.goal
              ? (widget.objective == null ? "add-goal".tr() : "edit-goal".tr())
              : objectiveType == ObjectiveType.loan
                  ? (widget.objective == null
                      ? "add-loan".tr()
                      : "edit-loan".tr())
                  : "",
          onBackButton: () async {
            if (widget.objective != null) {
              discardChangesPopup(
                context,
                previousObject: widget.objective,
                currentObject: await createObjective(),
              );
            } else {
              showDiscardChangesPopupIfNotEditing();
            }
          },
          onDragDownToDismiss: () async {
            if (widget.objective != null) {
              discardChangesPopup(
                context,
                previousObject: widget.objective,
                currentObject: await createObjective(),
              );
            } else {
              showDiscardChangesPopupIfNotEditing();
            }
          },
          actions: [
            CustomPopupMenuButton(
              showButtons:
                  widget.objective == null || enableDoubleColumn(context),
              keepOutFirst: true,
              items: [
                if (widget.objective != null &&
                    widget.routesToPopAfterDelete !=
                        RoutesToPopAfterDelete.PreventDelete)
                  DropdownItemMenu(
                    id: "delete-goal",
                    label: widget.objective?.type == ObjectiveType.loan
                        ? "delete-loan".tr()
                        : "delete-goal".tr(),
                    icon: appStateSettings["outlinedIcons"]
                        ? Icons.delete_outlined
                        : Icons.delete_rounded,
                    action: () {
                      deleteObjectivePopup(
                        context,
                        objective: widget.objective!,
                        routesToPopAfterDelete: widget.routesToPopAfterDelete,
                      );
                    },
                  ),
              ],
            ),
          ],
          staticOverlay: Align(
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
                : selectedAmount == 0 &&
                        widget.objective == null &&
                        isDifferenceOnlyLoan == false
                    ? SaveBottomButton(
                        label: "set-amount".tr(),
                        onTap: () async {
                          selectAmount(context);
                        },
                        disabled: false,
                      )
                    : SaveBottomButton(
                        label: widget.objective == null
                            ? objectiveType == ObjectiveType.loan
                                ? "add-loan".tr()
                                : "add-goal".tr()
                            : "save-changes".tr(),
                        onTap: () async {
                          await addObjective();
                        },
                        disabled: !(canAddObjective ?? false),
                      ),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                // Flip the order if ObjectiveType.loan
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 500),
                        opacity: isDifferenceOnlyLoan ? 0.5 : 1,
                        child: IncomeExpenseTabSelector(
                          hasBorderRadius: true,
                          onTabChanged: (isIncome) {
                            if (objectiveType == ObjectiveType.loan) {
                              setSelectedIncome(!isIncome);
                            } else {
                              setSelectedIncome(isIncome);
                            }
                          },
                          initialTabIsIncome:
                              objectiveType == ObjectiveType.loan
                                  ? !selectedIncome
                                  : selectedIncome,
                          syncWithInitial: true,
                          expenseLabel: objectiveType == ObjectiveType.goal
                              ? "expense-goal".tr()
                              : objectiveType == ObjectiveType.loan
                                  ? "lent".tr()
                                  : "",
                          incomeLabel: objectiveType == ObjectiveType.goal
                              ? "savings-goal".tr()
                              : objectiveType == ObjectiveType.loan
                                  ? "borrowed".tr()
                                  : "",
                          showIcons: objectiveType != ObjectiveType.loan,
                          expenseCustomIcon: objectiveType == ObjectiveType.goal
                              ? null
                              : Icon(
                                  getTransactionTypeIcon(
                                      TransactionSpecialType.credit),
                                ),
                          incomeCustomIcon: objectiveType == ObjectiveType.goal
                              ? null
                              : Icon(
                                  getTransactionTypeIcon(
                                      TransactionSpecialType.debt),
                                ),
                        ),
                      ),
                    ),
                    if (appStateSettings["longTermLoansDifferenceFeature"] ==
                            true &&
                        (widget.objectiveType == ObjectiveType.loan ||
                            widget.objective?.type == ObjectiveType.loan))
                      Padding(
                        padding: const EdgeInsets.only(left: 7),
                        child: ButtonIcon(
                          onTap: () {
                            setState(() {
                              if (isDifferenceOnlyLoan) {
                                selectedAmount = 0;
                              }
                              isDifferenceOnlyLoan = !isDifferenceOnlyLoan;
                            });
                            determineBottomButton();
                          },
                          icon: appStateSettings["outlinedIcons"]
                              ? Icons.hourglass_empty_outlined
                              : Icons.hourglass_empty_rounded,
                          color: isDifferenceOnlyLoan == false
                              ? null
                              : Theme.of(context).colorScheme.tertiaryContainer,
                          iconColor: isDifferenceOnlyLoan == false
                              ? null
                              : Theme.of(context)
                                  .colorScheme
                                  .onTertiaryContainer,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Tappable(
                    onTap: () {
                      openBottomSheet(
                        context,
                        PopupFramework(
                          title: "select-icon".tr(),
                          child: SelectCategoryImage(
                            setSelectedImage: setSelectedImage,
                            setSelectedEmoji: setSelectedEmoji,
                            selectedImage:
                                "assets/categories/" + selectedImage.toString(),
                            setSelectedTitle: (String? titleRecommendation) {},
                          ),
                        ),
                        showScrollbar: true,
                      );
                    },
                    color: Colors.transparent,
                    child: Container(
                      height: 126,
                      padding: const EdgeInsets.only(left: 13, right: 18),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            child: CategoryIcon(
                              key: ValueKey((selectedImage ?? "") +
                                  selectedColor.toString()),
                              categoryPk: "-1",
                              category: TransactionCategory(
                                categoryPk: "-1",
                                name: "",
                                dateCreated: DateTime.now(),
                                dateTimeModified: null,
                                order: 0,
                                income: false,
                                iconName: selectedImage,
                                colour: toHexString(selectedColor),
                                emojiIconName: selectedEmoji,
                              ),
                              size: 50,
                              sizePadding: 30,
                              canEditByLongPress: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: IntrinsicWidth(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20, bottom: 40),
                        child: TextInput(
                          autoFocus: kIsWeb && getIsFullScreen(context),
                          focusNode: _titleFocusNode,
                          labelText: "name-placeholder".tr(),
                          bubbly: false,
                          onChanged: (text) {
                            setSelectedTitle(text);
                          },
                          padding: EdgeInsets.zero,
                          fontSize: getIsFullScreen(context) ? 34 : 27,
                          fontWeight: FontWeight.bold,
                          topContentPadding: 40,
                          initialValue: selectedTitle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 65,
                child: SelectColor(
                  horizontalList: true,
                  selectedColor: selectedColor,
                  setSelectedColor: setSelectedColor,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 25,
              ),
            ),
            if (widget.objective != null || isDifferenceOnlyLoan == false)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: OutlinedContainer(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        children: [
                          widget.objective != null &&
                                  objectiveType == ObjectiveType.loan
                              ? TipBox(
                                  borderRadius: 0,
                                  onTap: () {
                                    pushRoute(
                                      context,
                                      AddTransactionPage(
                                        routesToPopAfterDelete:
                                            RoutesToPopAfterDelete.None,
                                        selectedObjective: widget.objective,
                                        selectedIncome: !selectedIncome,
                                      ),
                                    );
                                  },
                                  text: selectedIncome
                                      ? "change-loan-amount-tip-lent".tr()
                                      : "change-loan-amount-tip-borrowed".tr(),
                                  settingsString: null,
                                )
                              : isDifferenceOnlyLoan
                                  ? SizedBox.shrink()
                                  : Wrap(
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.end,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 14),
                                          child: AnimatedSizeSwitcher(
                                            child: TextFont(
                                              key: ValueKey(
                                                  selectedIncome.toString()),
                                              text: objectiveType ==
                                                      ObjectiveType.loan
                                                  ? selectedIncome
                                                      ? "lent".tr()
                                                      : "borrowed".tr()
                                                  : "goal".tr() + " ",
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        TappableTextEntry(
                                          title: convertToMoney(
                                            Provider.of<AllWallets>(context),
                                            selectedAmount,
                                            currencyKey: Provider.of<
                                                        AllWallets>(context,
                                                    listen: true)
                                                .indexedByPk[selectedWalletPk]
                                                ?.currency,
                                          ),
                                          placeholder: convertToMoney(
                                            Provider.of<AllWallets>(context),
                                            0,
                                            currencyKey: Provider.of<
                                                        AllWallets>(context,
                                                    listen: true)
                                                .indexedByPk[selectedWalletPk]
                                                ?.currency,
                                          ),
                                          showPlaceHolderWhenTextEquals:
                                              convertToMoney(
                                            Provider.of<AllWallets>(context),
                                            0,
                                            currencyKey: Provider.of<
                                                        AllWallets>(context,
                                                    listen: true)
                                                .indexedByPk[selectedWalletPk]
                                                ?.currency,
                                          ),
                                          onTap: () {
                                            selectAmount(context);
                                          },
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          internalPadding: EdgeInsets.symmetric(
                                              vertical: 2, horizontal: 4),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 5),
                                        ),
                                      ],
                                    ),
                          if (isDifferenceOnlyLoan != true)
                            HorizontalBreakAbove(
                              child: Center(
                                child: SelectDateRange(
                                  padding: EdgeInsets.only(bottom: 8),
                                  initialStartDate: selectedStartDate,
                                  initialEndDate: selectedEndDate,
                                  onSelectedStartDate: setSelectedStartDate,
                                  onSelectedEndDate: setSelectedEndDate,
                                ),
                              ),
                            ),
                          if (widget.objective != null &&
                              objectiveType == ObjectiveType.loan &&
                              isDifferenceOnlyLoan == false)
                            HorizontalBreakAbove(
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
                                  children: [
                                    HeaderWithIconAndInfo(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20 - 5.0),
                                      iconData:
                                          appStateSettings["outlinedIcons"]
                                              ? Icons.exposure_outlined
                                              : Icons.exposure_rounded,
                                      iconScale: 1,
                                      text: "total-offset".tr(),
                                      infoButton: IconButtonScaled(
                                        iconData:
                                            appStateSettings["outlinedIcons"]
                                                ? Icons.info_outlined
                                                : Icons.info_outline_rounded,
                                        iconSize: 16,
                                        scale: 1.6,
                                        onTap: () {
                                          openPopup(
                                            context,
                                            title: "total-offset".tr(),
                                            description:
                                                "total-offset-description".tr(),
                                            icon: appStateSettings[
                                                    "outlinedIcons"]
                                                ? Icons.exposure_outlined
                                                : Icons.exposure_rounded,
                                            onSubmit: () {
                                              Navigator.pop(context);
                                            },
                                            onSubmitLabel: "ok".tr(),
                                          );
                                        },
                                      ),
                                    ),
                                    TappableTextEntry(
                                      title: convertToMoney(
                                        Provider.of<AllWallets>(context),
                                        selectedAmount,
                                        currencyKey: Provider.of<AllWallets>(
                                                context,
                                                listen: true)
                                            .indexedByPk[selectedWalletPk]
                                            ?.currency,
                                      ),
                                      placeholder: convertToMoney(
                                        Provider.of<AllWallets>(context),
                                        0,
                                        currencyKey: Provider.of<AllWallets>(
                                                context,
                                                listen: true)
                                            .indexedByPk[selectedWalletPk]
                                            ?.currency,
                                      ),
                                      showPlaceHolderWhenTextEquals:
                                          convertToMoney(
                                        Provider.of<AllWallets>(context),
                                        0,
                                        currencyKey: Provider.of<AllWallets>(
                                                context,
                                                listen: true)
                                            .indexedByPk[selectedWalletPk]
                                            ?.currency,
                                      ),
                                      onTap: () {
                                        selectAmount(context, allowZero: true);
                                      },
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      internalPadding: EdgeInsets.symmetric(
                                          vertical: 2, horizontal: 4),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 5),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, right: 8, bottom: 8, top: 2),
                                      child: StreamBuilder<Objective>(
                                        stream: database.getObjective(
                                            widget.objective?.objectivePk ??
                                                "0"),
                                        builder: (context, snapshot) {
                                          if (snapshot.data == null)
                                            return SizedBox.shrink();
                                          Objective objective =
                                              snapshot.data!.copyWith(
                                            income: selectedIncome,
                                            amount: 0,
                                            walletFk: selectedWalletPk,
                                          );
                                          return WatchTotalAndAmountOfObjective(
                                            objective: objective,
                                            builder: (double objectiveAmount,
                                                double totalAmount,
                                                double percentageTowardsGoal) {
                                              double selectedAmountConverted =
                                                  selectedAmount *
                                                      amountRatioToPrimaryCurrency(
                                                        Provider.of<AllWallets>(
                                                            context),
                                                        Provider.of<AllWallets>(
                                                                context)
                                                            .indexedByPk[
                                                                objective
                                                                    .walletFk]
                                                            ?.currency,
                                                      );
                                              return TextFont(
                                                text: (selectedIncome
                                                        ? "lent".tr()
                                                        : "borrowed".tr()) +
                                                    " " +
                                                    "total".tr() +
                                                    ": " +
                                                    convertToMoney(
                                                      Provider.of<AllWallets>(
                                                          context),
                                                      selectedAmountConverted,
                                                    ) +
                                                    " + " +
                                                    convertToMoney(
                                                      Provider.of<AllWallets>(
                                                          context),
                                                      objectiveAmount,
                                                    ) +
                                                    " = " +
                                                    convertToMoney(
                                                      Provider.of<AllWallets>(
                                                          context),
                                                      objectiveAmount +
                                                          selectedAmountConverted,
                                                    ),
                                                fontSize: 14.5,
                                                textAlign: TextAlign.center,
                                                textColor: getColor(
                                                    context, "textLight"),
                                                maxLines: 4,
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            SliverToBoxAdapter(child: SizedBox(height: 65)),
            // SliverToBoxAdapter(
            //   child: KeyboardHeightAreaAnimated(),
            // ),
          ],
        ),
      ),
    );
  }
}

class SelectObjectiveTypePopup extends StatelessWidget {
  const SelectObjectiveTypePopup({required this.setObjectiveIncome, super.key});
  final Function(bool isIncome) setObjectiveIncome;

  @override
  Widget build(BuildContext context) {
    return PopupFramework(
      title: "select-goal-type".tr(),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButtonStacked(
                  alignLeft: true,
                  alignBeside: true,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  text: "savings-goal".tr(),
                  iconData: appStateSettings["outlinedIcons"]
                      ? Icons.savings_outlined
                      : Icons.savings_rounded,
                  onTap: () {
                    setObjectiveIncome(true);
                    Navigator.pop(context);
                  },
                  afterWidget: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListItem(
                        "savings-goal-description-1".tr(),
                      ),
                      ListItem(
                        "savings-goal-description-2".tr(),
                      ),
                      Opacity(
                        opacity: 0.34,
                        child: ListItem(
                          "savings-goal-description-3".tr(),
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
                  alignLeft: true,
                  alignBeside: true,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  text: "expense-goal".tr(),
                  iconData: appStateSettings["outlinedIcons"]
                      ? Icons.request_quote_outlined
                      : Icons.request_quote_rounded,
                  onTap: () async {
                    setObjectiveIncome(false);
                    Navigator.pop(context);
                  },
                  afterWidget: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListItem(
                        "expense-goal-description-1".tr(),
                      ),
                      ListItem(
                        "expense-goal-description-2".tr(),
                      ),
                      Opacity(
                        opacity: 0.34,
                        child: ListItem("expense-goal-description-3".tr()),
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

Future<bool> startCreatingInstallment(
    {required BuildContext context, Objective? initialObjective}) async {
  dynamic objective = initialObjective ??
      await selectObjectivePopup(context,
          canSelectNoGoal: false, includeAmount: true, showAddButton: true);
  if (objective is Objective) {
    dynamic result = await openBottomSheet(
      context,
      fullSnap: true,
      InstallmentObjectivePopup(objective: objective),
    );
    if (result == true) return true;
  }
  return false;
}

class InstallmentObjectivePopup extends StatefulWidget {
  const InstallmentObjectivePopup({required this.objective, super.key});
  final Objective objective;

  @override
  State<InstallmentObjectivePopup> createState() =>
      _InstallmentObjectivePopupState();
}

class _InstallmentObjectivePopupState extends State<InstallmentObjectivePopup> {
  bool isNegative = false;
  TimeOfDay? selectedTime = null;
  DateTime? selectedDateTime = null;
  String selectedTitle = "";
  String selectedWalletPk = appStateSettings["selectedWalletPk"];
  TransactionCategory? selectedCategory;
  TransactionCategory? selectedSubCategory;

  int selectedPeriodLength = 1;
  String selectedRecurrence = "Monthly";
  String selectedRecurrenceDisplay = "month";
  BudgetReoccurence selectedRecurrenceEnum = BudgetReoccurence.monthly;

  int? numberOfInstallmentPayments = null;
  double? amountPerInstallmentPayment = null;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      selectedCategory = (await database.getAllCategories()).firstOrNull;
      setState(() {});
    });
  }

  Future<void> selectAmountPerInstallment(BuildContext context) async {
    openBottomSheet(
      context,
      PopupFramework(
        title: "enter-payment-amount".tr(),
        hasPadding: false,
        underTitleSpace: false,
        child: SelectAmount(
          enableWalletPicker: true,
          hideWalletPickerIfOneCurrency: true,
          padding: EdgeInsets.symmetric(horizontal: 18),
          onlyShowCurrencyIcon: true,
          amountPassed: (amountPerInstallmentPayment ?? 0).toString(),
          setSelectedAmount: (amount, _) {
            setState(() {
              numberOfInstallmentPayments = null;
              amountPerInstallmentPayment = amount == 0 ? null : amount;
            });
          },
          selectedWalletPk: selectedWalletPk,
          setSelectedWalletPk: (walletPk) {
            setState(() {
              selectedWalletPk = walletPk;
            });
          },
          next: () {
            Navigator.pop(context);
          },
          nextLabel: "set-amount".tr(),
        ),
      ),
    );
  }

  Future<void> selectInstallmentLength(BuildContext context) async {
    openBottomSheet(
      context,
      PopupFramework(
        title: "enter-payment-period".tr(),
        child: SelectAmountValue(
          enableDecimal: false,
          amountPassed: (numberOfInstallmentPayments ?? 0).toString(),
          setSelectedAmount: (amount, _) {
            setState(() {
              amountPerInstallmentPayment = null;
              selectedWalletPk = appStateSettings["selectedWalletPk"];
              numberOfInstallmentPayments =
                  amount.toInt() == 0 ? null : amount.toInt();
            });
          },
          next: () async {
            Navigator.pop(context);
          },
          nextLabel: "set-amount".tr(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget editTransferDetails = Column(
      children: [
        TextInput(
          icon: appStateSettings["outlinedIcons"]
              ? Icons.title_outlined
              : Icons.title_rounded,
          autoFocus: false,
          onChanged: (text) async {
            selectedTitle = text;
          },
          initialValue: selectedTitle,
          labelText: "title-placeholder".tr(),
          padding: EdgeInsets.only(bottom: 13),
        ),
        DateButton(
          internalPadding: EdgeInsets.only(right: 5),
          initialSelectedDate: selectedDateTime ?? DateTime.now(),
          initialSelectedTime: TimeOfDay(
              hour: selectedDateTime?.hour ?? TimeOfDay.now().hour,
              minute: selectedDateTime?.minute ?? TimeOfDay.now().minute),
          setSelectedDate: (date) {
            selectedDateTime = date;
          },
          setSelectedTime: (time) {
            selectedDateTime = (selectedDateTime ?? DateTime.now())
                .copyWith(hour: time.hour, minute: time.minute);
          },
        ),
      ],
    );

    return PopupFramework(
      title: "installment".tr(),
      subtitle: widget.objective.name +
          " (" +
          convertToMoney(
              Provider.of<AllWallets>(context),
              objectiveAmountToPrimaryCurrency(
                      Provider.of<AllWallets>(context), widget.objective) *
                  ((widget.objective.income) ? 1 : -1)) +
          ")",
      underTitleSpace: false,
      hasPadding: false,
      child: Column(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Builder(
                  builder: (context) {
                    List<double> results = getInstallmentPaymentCalculations(
                      allWallets: Provider.of<AllWallets>(context),
                      objective: widget.objective,
                      numberOfInstallmentPayments: numberOfInstallmentPayments,
                      amountPerInstallmentPayment: amountPerInstallmentPayment,
                      amountPerInstallmentPaymentWalletPk: selectedWalletPk,
                    );
                    double numberOfInstallmentPaymentsDisplay = results[0];
                    double amountPerInstallmentPaymentDisplay = results[1];

                    String displayNumberOfInstallmentPaymentsDisplay =
                        numberOfInstallmentPaymentsDisplay == double.infinity
                            ? "0"
                            : removeTrailingZeroes(
                                numberOfInstallmentPaymentsDisplay
                                    .toStringAsFixed(3));
                    String displayAmountPerInstallmentPaymentDisplay =
                        convertToMoney(
                      Provider.of<AllWallets>(context),
                      amountPerInstallmentPaymentDisplay == double.infinity
                          ? 0
                          : amountPerInstallmentPaymentDisplay,
                      currencyKey: Provider.of<AllWallets>(context)
                          .indexedByPk[selectedWalletPk]
                          ?.currency,
                    );
                    return Column(
                      children: [
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            TappableTextEntry(
                              title: displayNumberOfInstallmentPaymentsDisplay,
                              placeholder: numberOfInstallmentPayments == null
                                  ? displayNumberOfInstallmentPaymentsDisplay
                                  : "",
                              showPlaceHolderWhenTextEquals:
                                  numberOfInstallmentPayments == null
                                      ? displayNumberOfInstallmentPaymentsDisplay
                                      : "",
                              onTap: () {
                                selectInstallmentLength(context);
                              },
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              internalPadding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 4),
                              padding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 3),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 3),
                              child: TextFont(
                                text: numberOfInstallmentPayments == 1
                                    ? "payment-of".tr()
                                    : "payments-of".tr(),
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TappableTextEntry(
                              title: displayAmountPerInstallmentPaymentDisplay,
                              placeholder: amountPerInstallmentPayment == null
                                  ? displayAmountPerInstallmentPaymentDisplay
                                  : "",
                              showPlaceHolderWhenTextEquals:
                                  amountPerInstallmentPayment == null
                                      ? displayAmountPerInstallmentPaymentDisplay
                                      : "",
                              onTap: () {
                                selectAmountPerInstallment(context);
                              },
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              internalPadding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 4),
                              padding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 3),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: TextFont(
                            text: "until-goal-reached".tr().toLowerCase(),
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
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
                          title: selectedPeriodLength.toString(),
                          placeholder: "0",
                          showPlaceHolderWhenTextEquals: "0",
                          onTap: () {
                            selectPeriodLength(
                              context: context,
                              selectedPeriodLength: selectedPeriodLength,
                              setSelectedPeriodLength: (period) =>
                                  setSelectedPeriodLength(
                                period: period,
                                selectedRecurrence: selectedRecurrence,
                                setPeriodLength: (selectedPeriodLength,
                                    selectedRecurrenceDisplay) {
                                  this.selectedPeriodLength =
                                      selectedPeriodLength;
                                  this.selectedRecurrenceDisplay =
                                      selectedRecurrenceDisplay;
                                  setState(() {});
                                },
                              ),
                            );
                          },
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          internalPadding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                          padding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 3),
                        ),
                        TappableTextEntry(
                          title: selectedRecurrenceDisplay
                              .toString()
                              .toLowerCase()
                              .tr()
                              .toLowerCase(),
                          placeholder: "",
                          onTap: () {
                            selectRecurrence(
                              context: context,
                              selectedRecurrence: selectedRecurrence,
                              selectedPeriodLength: selectedPeriodLength,
                              onChanged: (selectedRecurrence,
                                  selectedRecurrenceEnum,
                                  selectedRecurrenceDisplay) {
                                this.selectedRecurrence = selectedRecurrence;
                                this.selectedRecurrenceEnum =
                                    selectedRecurrenceEnum;
                                this.selectedRecurrenceDisplay =
                                    selectedRecurrenceDisplay;
                                setState(() {});
                              },
                            );
                          },
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          internalPadding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                          padding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 3),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 10),
              HorizontalBreak(
                color: Theme.of(context)
                    .colorScheme
                    .secondaryContainer
                    .withOpacity(0.5),
              ),
              SizedBox(height: 4),
              if (selectedCategory != null)
                SelectCategory(
                  horizontalList: true,
                  listPadding: EdgeInsets.symmetric(horizontal: 10),
                  addButton: false,
                  setSelectedCategory: (category) {
                    // Clear the subcategory
                    if (category.categoryPk != selectedCategory?.categoryPk) {
                      setState(() {
                        selectedSubCategory = null;
                      });
                    }

                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  popRoute: false,
                  selectedCategory: selectedCategory,
                ),
              SizedBox(height: 6),
              if (selectedCategory != null)
                SelectSubcategoryChips(
                  setSelectedSubCategory: (category) {
                    if (selectedSubCategory?.categoryPk ==
                        category.categoryPk) {
                      selectedSubCategory = null;
                    } else {
                      selectedSubCategory = category;
                    }
                    setState(
                      () {},
                    );
                  },
                  selectedCategoryPk: selectedCategory!.categoryPk,
                  selectedSubCategoryPk: selectedSubCategory?.categoryPk,
                ),
              SizedBox(height: 9),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: editTransferDetails,
              ),
              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Button(
                  disabled: selectedCategory == null ||
                      (amountPerInstallmentPayment == null &&
                          numberOfInstallmentPayments == null),
                  onDisabled: () {
                    openSnackbar(
                      SnackbarMessage(
                        title: "cannot-create-installment".tr(),
                        description:
                            "missing-installment-period-and-amount".tr(),
                        icon: appStateSettings["outlinedIcons"]
                            ? Icons.warning_amber_outlined
                            : Icons.warning_amber_rounded,
                      ),
                    );
                  },
                  label: "add-transaction".tr(),
                  width: MediaQuery.sizeOf(context).width,
                  onTap: () async {
                    Transaction transaction = Transaction(
                      transactionPk: "-1",
                      name: selectedTitle,
                      amount: getInstallmentPaymentCalculations(
                        allWallets:
                            Provider.of<AllWallets>(context, listen: false),
                        objective: widget.objective,
                        numberOfInstallmentPayments:
                            numberOfInstallmentPayments,
                        amountPerInstallmentPayment:
                            amountPerInstallmentPayment,
                        amountPerInstallmentPaymentWalletPk: selectedWalletPk,
                      )[1],
                      note: "",
                      categoryFk: selectedCategory?.categoryPk ?? "-1",
                      subCategoryFk: selectedSubCategory?.categoryPk,
                      walletFk: selectedWalletPk,
                      dateCreated: selectedDateTime ?? DateTime.now(),
                      income: widget.objective.income,
                      paid: false,
                      skipPaid: false,
                      createdAnotherFutureTransaction: false,
                      type: TransactionSpecialType.repetitive,
                      periodLength: selectedPeriodLength,
                      reoccurrence: selectedRecurrenceEnum,
                      objectiveFk: widget.objective.objectivePk,
                    );
                    await database.createOrUpdateTransaction(transaction,
                        insert: true);
                    Navigator.maybePop(context, true);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
