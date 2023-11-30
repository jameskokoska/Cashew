import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/accountsPage.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/editObjectivesPage.dart';
import 'package:budget/pages/editWalletsPage.dart';
import 'package:budget/pages/premiumPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/globalSnackBar.dart';
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
  }) : super(key: key);

  //When a wallet is passed in, we are editing that wallet
  final Objective? objective;
  final RoutesToPopAfterDelete routesToPopAfterDelete;

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
  bool selectedIncome = true;
  bool selectedPin = true;
  String selectedWalletPk = appStateSettings["selectedWalletPk"];

  FocusNode _titleFocusNode = FocusNode();
  late TabController _incomeTabController =
      TabController(length: 2, vsync: this);

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
    });
    determineBottomButton();
    return;
  }

  void setSelectedEmoji(String? emoji) {
    setState(() {
      selectedEmoji = emoji;
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

  Future<void> selectAmount(BuildContext context) async {
    openBottomSheet(
      context,
      fullSnap: true,
      PopupFramework(
        title: "enter-amount".tr(),
        underTitleSpace: false,
        hasPadding: false,
        child: SelectAmount(
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
    print("Added objective");
    await database.createOrUpdateObjective(
        insert: widget.objective == null, await createObjective());
    Navigator.pop(context);
  }

  Future<Objective> createObjective() async {
    int numberOfObjectives =
        (await database.getTotalCountOfObjectives())[0] ?? 0;
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
      amount: selectedAmount,
      income: selectedIncome,
      pinned: selectedPin,
      walletFk: selectedWalletPk,
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

      selectedIncome = widget.objective!.income;
      if (widget.objective?.income == false) {
        _incomeTabController.animateTo(1);
      } else {
        _incomeTabController.animateTo(0);
      }
    } else {
      Future.delayed(Duration.zero, () async {
        if (widget.objective == null) {
          bool result = await premiumPopupObjectives(context);
          if (result == true) {
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
          //Minimize keyboard when tap non interactive widget
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: PageFramework(
          horizontalPadding: getHorizontalPaddingConstrained(context),
          resizeToAvoidBottomInset: true,
          dragDownToDismiss: true,
          title: widget.objective == null ? "add-goal".tr() : "edit-goal".tr(),
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
                    label: "delete-goal".tr(),
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
                : selectedAmount == 0
                    ? SaveBottomButton(
                        label: "set-amount".tr(),
                        onTap: () async {
                          selectAmount(context);
                        },
                        disabled: false,
                      )
                    : SaveBottomButton(
                        label: widget.objective == null
                            ? "add-goal".tr()
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
                child: ClipRRect(
                  borderRadius: getPlatform() == PlatformOS.isIOS
                      ? BorderRadius.circular(10)
                      : BorderRadius.circular(15),
                  child: IncomeExpenseTabSelector(
                    onTabChanged: setSelectedIncome,
                    initialTabIsIncome: selectedIncome,
                    syncWithInitial: true,
                    expenseLabel: "expense-goal".tr(),
                    incomeLabel: "savings-goal".tr(),
                  ),
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
                height: 10,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: TextFont(
                        text: "goal".tr() + " ",
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Flexible(
                      child: TappableTextEntry(
                        title: convertToMoney(
                          Provider.of<AllWallets>(context),
                          selectedAmount,
                          currencyKey:
                              Provider.of<AllWallets>(context, listen: true)
                                  .indexedByPk[selectedWalletPk]
                                  ?.currency,
                        ),
                        placeholder: convertToMoney(
                          Provider.of<AllWallets>(context),
                          0,
                          currencyKey:
                              Provider.of<AllWallets>(context, listen: true)
                                  .indexedByPk[selectedWalletPk]
                                  ?.currency,
                        ),
                        showPlaceHolderWhenTextEquals: convertToMoney(
                          Provider.of<AllWallets>(context),
                          0,
                          currencyKey:
                              Provider.of<AllWallets>(context, listen: true)
                                  .indexedByPk[selectedWalletPk]
                                  ?.currency,
                        ),
                        onTap: () {
                          selectAmount(context);
                        },
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        internalPadding:
                            EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: SelectDateRange(
                  initialStartDate: selectedStartDate,
                  initialEndDate: selectedEndDate,
                  onSelectedStartDate: setSelectedStartDate,
                  onSelectedEndDate: setSelectedEndDate,
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
