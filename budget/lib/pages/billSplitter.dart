import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/accountsPage.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/editRowEntry.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/radioItems.dart';
import 'package:budget/widgets/saveBottomButton.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:provider/provider.dart';
import 'package:budget/widgets/countNumber.dart';

class BillSplitterItem {
  BillSplitterItem(
    this.name,
    this.cost,
    this.userAmounts, {
    this.evenSplit = true,
  });
  String name;
  double cost;
  bool evenSplit;
  List<SplitPerson> userAmounts;
}

class SplitPerson {
  SplitPerson(
    this.name, {
    this.percent,
  });
  double? percent;
  String name;
}

class BillSplitter extends StatefulWidget {
  const BillSplitter({super.key});

  @override
  State<BillSplitter> createState() => _BillSplitterState();
}

class _BillSplitterState extends State<BillSplitter> {
  List<SplitPerson> splitPersons = [
    SplitPerson("James"),
    SplitPerson("Test"),
    SplitPerson("SplitPerson3"),
  ];

  List<BillSplitterItem> billSplitterItems = [
    BillSplitterItem(
      "Fries",
      50.5,
      [
        SplitPerson("James", percent: 1),
      ],
    ),
  ];

  addBillSplitterItem(BillSplitterItem billSplitterItem) {
    setState(() {
      billSplitterItems.add(billSplitterItem);
    });
  }

  updateBillSplitterItem(BillSplitterItem billSplitterItem, int? index) {
    if (index == null) return;
    setState(() {
      billSplitterItems[index] = billSplitterItem;
    });
  }

  Future<DeletePopupAction?> deleteBillSplitterItem(
      BillSplitterItem billSplitterItem) async {
    DeletePopupAction? action = await openDeletePopup(
      context,
      title: "Delete bill item?",
      subtitle: billSplitterItem.name,
    );
    if (action == DeletePopupAction.Delete) {
      setState(() {
        int index = billSplitterItems.indexOf(billSplitterItem);
        if (index != -1) {
          billSplitterItems.removeAt(index);
        }
      });
    }
    return action;
  }

  bool addPerson(SplitPerson person) {
    SplitPerson? searchPerson = getPerson(splitPersons, person.name);
    if (searchPerson == null) {
      setState(() {
        splitPersons.add(person);
      });
      return true;
    } else {
      openSnackbar(
        SnackbarMessage(
          title: "Duplicate name",
          icon: Icons.warning_amber_rounded,
          description: "Please choose another name",
        ),
      );
      return false;
    }
  }

  Future<DeletePopupAction?> deletePerson(SplitPerson person) async {
    DeletePopupAction? action = await openDeletePopup(
      context,
      title: "Delete person?",
      subtitle: person.name,
    );
    if (action == DeletePopupAction.Delete) {
      setState(() {
        int index = splitPersons.indexOf(person);
        if (index != -1) {
          splitPersons.removeAt(index);
        }
      });
    }
    return action;
  }

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      dragDownToDismiss: true,
      title: "Bill Splitter".tr(),
      horizontalPadding: getHorizontalPaddingConstrained(context),
      floatingActionButton: AnimateFABDelayed(
        fab: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewPadding.bottom),
          child: FAB(
            openPage: AddBillItemPage(
              splitPersons: splitPersons,
              addBillSplitterItem: addBillSplitterItem,
              deleteBillSplitterItem: deleteBillSplitterItem,
              updateBillSplitterItem: updateBillSplitterItem,
              addPerson: addPerson,
              deletePerson: deletePerson,
            ),
          ),
        ),
      ),
      listWidgets: [
        Padding(
          padding:
              const EdgeInsets.only(top: 20, left: 20.0, right: 20, bottom: 20),
          child: Builder(
            builder: (context) {
              double totalAccountedFor = 0;
              double totalCost = 0;

              for (BillSplitterItem billSplitterItem in billSplitterItems) {
                totalCost += billSplitterItem.cost;

                for (SplitPerson splitPerson in billSplitterItem.userAmounts) {
                  double percentOfTotal = billSplitterItem.evenSplit
                      ? billSplitterItem.userAmounts.length == 0
                          ? 0
                          : 1 / billSplitterItem.userAmounts.length
                      : (splitPerson.percent ?? 0) / 100;
                  double amountSpent = billSplitterItem.cost * percentOfTotal;

                  totalAccountedFor += amountSpent;
                }
              }
              String totalAccountedForString = convertToMoney(
                Provider.of<AllWallets>(context),
                totalAccountedFor,
                finalNumber: totalAccountedFor.abs(),
              );
              String totalCostString = convertToMoney(
                Provider.of<AllWallets>(context),
                totalCost,
                finalNumber: totalCost.abs(),
              );
              Color? errorColor = totalCostString == totalAccountedForString
                  ? null
                  : totalCost > totalAccountedFor
                      ? getColor(context, "expenseAmount")
                      : totalCost < totalAccountedFor
                          ? getColor(context, "warningOrange")
                          : null;

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CountNumber(
                    count: totalAccountedFor,
                    duration: Duration(milliseconds: 700),
                    initialCount: (0),
                    textBuilder: (number) {
                      return TextFont(
                        textAlign: TextAlign.center,
                        text: convertToMoney(
                          Provider.of<AllWallets>(context),
                          number,
                          finalNumber: number.abs(),
                        ),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        textColor: errorColor,
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3.5),
                    child: CountNumber(
                      count: totalCost,
                      duration: Duration(milliseconds: 700),
                      initialCount: (0),
                      textBuilder: (number) {
                        return TextFont(
                          textAlign: TextAlign.center,
                          text: " / " +
                              convertToMoney(
                                Provider.of<AllWallets>(context),
                                number,
                                finalNumber: number.abs(),
                              ),
                          fontSize: 16,
                          textColor: getColor(context, "textLight"),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: getHorizontalPaddingConstrained(context) + 13,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: SettingsContainer(
                  isOutlinedColumn: true,
                  title: "New Bill".tr(),
                  icon: Icons.add_rounded,
                  isOutlined: true,
                  onTap: () {},
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: SettingsContainerOpenPage(
                  isOutlinedColumn: true,
                  title: "People".tr(),
                  icon: Icons.people_rounded,
                  isOutlined: true,
                  openPage: PeoplePage(
                    splitPersons: splitPersons,
                    addPerson: addPerson,
                    deletePerson: deletePerson,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: SettingsContainer(
                  isOutlinedColumn: true,
                  title: "Summary".tr(),
                  icon: Icons.summarize_rounded,
                  isOutlined: true,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        for (int i = 0; i < billSplitterItems.length; i++)
          BillSplitterItemEntry(
            splitPersons: splitPersons,
            billSplitterItem: billSplitterItems[i],
            billSplitterItemIndex: i,
            addBillSplitterItem: addBillSplitterItem,
            deleteBillSplitterItem: deleteBillSplitterItem,
            updateBillSplitterItem: updateBillSplitterItem,
            addPerson: addPerson,
            deletePerson: deletePerson,
          ),
        SizedBox(height: 55),
      ],
    );
  }
}

class BillSplitterItemEntry extends StatelessWidget {
  const BillSplitterItemEntry({
    required this.billSplitterItem,
    required this.billSplitterItemIndex,
    required this.splitPersons,
    required this.addBillSplitterItem,
    required this.deleteBillSplitterItem,
    required this.updateBillSplitterItem,
    required this.addPerson,
    required this.deletePerson,
    super.key,
  });
  final BillSplitterItem billSplitterItem;
  final int billSplitterItemIndex;
  final List<SplitPerson> splitPersons;
  final Function(BillSplitterItem) addBillSplitterItem;
  final Function(BillSplitterItem) deleteBillSplitterItem;
  final Function(BillSplitterItem, int? index) updateBillSplitterItem;
  final bool Function(SplitPerson) addPerson;
  final Function(SplitPerson) deletePerson;

  @override
  Widget build(BuildContext context) {
    double total = 0;
    for (SplitPerson splitPerson in billSplitterItem.userAmounts) {
      total += (splitPerson.percent ?? 0) / 100 * billSplitterItem.cost;
    }
    String totalString = convertToMoney(
      Provider.of<AllWallets>(context),
      total,
    );
    String originalCostString = convertToMoney(
      Provider.of<AllWallets>(context),
      billSplitterItem.cost,
    );
    if (billSplitterItem.evenSplit && billSplitterItem.userAmounts.length > 0) {
      totalString = originalCostString;
    }
    Color? errorColor = totalString == originalCostString
        ? null
        : total < billSplitterItem.cost
            ? getColor(context, "expenseAmount")
            : total > billSplitterItem.cost
                ? getColor(context, "warningOrange")
                : null;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        EditRowEntry(
          onDelete: () {
            deleteBillSplitterItem(billSplitterItem);
          },
          canDelete: getPlatform() == PlatformOS.isIOS ? true : false,
          accentColor: errorColor,
          openPage: AddBillItemPage(
            splitPersons: splitPersons,
            billSplitterItem: billSplitterItem,
            billSplitterItemIndex: billSplitterItemIndex,
            addBillSplitterItem: addBillSplitterItem,
            deleteBillSplitterItem: deleteBillSplitterItem,
            updateBillSplitterItem: updateBillSplitterItem,
            addPerson: addPerson,
            deletePerson: deletePerson,
          ),
          canReorder: false,
          hideReorder: true,
          padding: EdgeInsets.symmetric(
              vertical: 7,
              horizontal: getPlatform() == PlatformOS.isIOS ? 17 : 7),
          currentReorder: false,
          index: 0,
          content: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFont(
                        text: billSplitterItem.name,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        maxLines: 1,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextFont(
                          text: totalString,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          textColor: errorColor,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: TextFont(
                            text: " / " +
                                convertToMoney(
                                  Provider.of<AllWallets>(context),
                                  billSplitterItem.cost,
                                ),
                            fontSize: 15,
                            textColor: getColor(context, "textLight"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                billSplitterItem.userAmounts.length <= 0
                    ? SizedBox.shrink()
                    : SizedBox(height: 7),
                for (SplitPerson splitPerson in billSplitterItem.userAmounts)
                  Builder(
                    builder: (context) {
                      double percentOfTotal = billSplitterItem.evenSplit
                          ? billSplitterItem.userAmounts.length == 0
                              ? 0
                              : 1 / billSplitterItem.userAmounts.length
                          : (splitPerson.percent ?? 0) / 100;
                      double amountSpent =
                          billSplitterItem.cost * percentOfTotal;
                      if (amountSpent == 0) percentOfTotal = 0;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 7),
                          Row(
                            children: [
                              Expanded(
                                child: TextFont(
                                  text: splitPerson.name,
                                  fontSize: 18,
                                ),
                              ),
                              TextFont(
                                text: convertToMoney(
                                  Provider.of<AllWallets>(context),
                                  amountSpent,
                                ),
                                fontSize: 18,
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Stack(
                              children: [
                                Container(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                                  height: 5,
                                ),
                                AnimatedFractionallySizedBox(
                                  duration: Duration(milliseconds: 1000),
                                  curve: Curves.easeInOutCubicEmphasized,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Container(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      height: 5,
                                    ),
                                  ),
                                  widthFactor: percentOfTotal,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          top: -11,
          right: -2,
          child: IconButton(
            onPressed: () {
              deleteBillSplitterItem(billSplitterItem);
            },
            icon: AnimatedContainer(
              duration: Duration(milliseconds: 500),
              decoration: BoxDecoration(
                color:
                    dynamicPastel(context, Theme.of(context).colorScheme.error),
                borderRadius: BorderRadius.circular(100),
              ),
              padding: EdgeInsets.all(5),
              child: Icon(
                Icons.delete_rounded,
                color: Theme.of(context).colorScheme.onError,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AddBillItemPage extends StatefulWidget {
  const AddBillItemPage({
    required this.splitPersons,
    this.billSplitterItem,
    this.billSplitterItemIndex,
    required this.addBillSplitterItem,
    required this.deleteBillSplitterItem,
    required this.updateBillSplitterItem,
    required this.addPerson,
    required this.deletePerson,
    super.key,
  });
  final List<SplitPerson> splitPersons;
  final BillSplitterItem? billSplitterItem;
  final int? billSplitterItemIndex;
  final Function(BillSplitterItem) addBillSplitterItem;
  final Function(BillSplitterItem) deleteBillSplitterItem;
  final bool Function(SplitPerson) addPerson;
  final Function(SplitPerson) deletePerson;
  final Function(BillSplitterItem, int? index) updateBillSplitterItem;

  @override
  State<AddBillItemPage> createState() => _AddBillItemPageState();
}

class _AddBillItemPageState extends State<AddBillItemPage> {
  late BillSplitterItem billSplitterItem =
      widget.billSplitterItem ?? BillSplitterItem("", 0, []);
  late List<SplitPerson> splitPersons = widget.splitPersons;
  List<SplitPerson> selectedSplitPersons = [];
  late TextEditingController _titleInputController =
      TextEditingController(text: billSplitterItem.name);

  @override
  void initState() {
    super.initState();
    if (widget.billSplitterItem == null) {
      Future.delayed(Duration.zero, () async {
        openBottomSheet(
          context,
          PopupFramework(
            title: "set-title".tr(),
            child: SelectText(
              setSelectedText: (value) {
                _titleInputController.text = value;
                billSplitterItem.name = value;
              },
              labelText: "set-title".tr(),
              placeholder: "title-placeholder".tr(),
              nextWithInput: (text) async {
                openEnterAmountBottomSheet();
              },
            ),
          ),
        );
        // Fix over-scroll stretch when keyboard pops up quickly
        Future.delayed(Duration(milliseconds: 100), () {
          bottomSheetControllerGlobal.scrollTo(0,
              duration: Duration(milliseconds: 100));
        });
      });
    }
  }

  Future openEnterAmountBottomSheet() async {
    await openBottomSheet(
      context,
      fullSnap: true,
      PopupFramework(
        title: "enter-amount".tr(),
        hasPadding: false,
        underTitleSpace: false,
        child: SelectAmount(
          enableWalletPicker: true,
          padding: EdgeInsets.symmetric(horizontal: 18),
          onlyShowCurrencyIcon: true,
          selectedWallet: Provider.of<AllWallets>(context, listen: false)
              .indexedByPk[appStateSettings["selectedWalletPk"]],
          amountPassed: billSplitterItem.cost.toString(),
          setSelectedAmount: (amount, _) {
            setState(() {
              billSplitterItem.cost = amount;
            });
          },
          next: () async {
            Navigator.pop(context);
          },
          nextLabel: "set-amount".tr(),
          allowZero: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        discardChangesPopup(context, forceShow: true);
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
          title: widget.billSplitterItem == null ? "Add Item" : "Edit Item",
          dragDownToDismiss: true,
          horizontalPadding: 13,
          actions: [
            widget.billSplitterItem != null
                ? IconButton(
                    padding: EdgeInsets.all(15),
                    tooltip: "Delete Item",
                    onPressed: () async {
                      if (await widget
                              .deleteBillSplitterItem(billSplitterItem) ==
                          DeletePopupAction.Delete) {
                        Navigator.pop(context);
                      }
                    },
                    icon: Icon(Icons.delete_rounded),
                  )
                : SizedBox.shrink(),
          ],
          listWidgets: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 7.5),
                  child: TappableTextEntry(
                    title: convertToMoney(
                      Provider.of<AllWallets>(context),
                      billSplitterItem.cost,
                    ),
                    placeholder: convertToPercent(0),
                    showPlaceHolderWhenTextEquals: convertToPercent(0),
                    onTap: () {
                      openEnterAmountBottomSheet();
                    },
                    fontSize: 27,
                    padding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: TextInput(
                    controller: _titleInputController,
                    labelText: "Item Name",
                    bubbly: false,
                    onChanged: (text) {
                      billSplitterItem.name = text;
                    },
                    padding: EdgeInsets.only(left: 7, right: 7),
                    fontSize: getIsFullScreen(context) ? 25 : 24,
                    fontWeight: FontWeight.bold,
                    topContentPadding: 0,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: getPlatform() == PlatformOS.isIOS
                    ? BorderRadius.circular(10)
                    : BorderRadius.circular(20),
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
              child: SettingsContainerSwitch(
                title: "Split Evenly",
                onSwitched: (value) {
                  setState(() {
                    billSplitterItem.evenSplit = value;
                  });
                },
                enableBorderRadius: true,
                initialValue: billSplitterItem.evenSplit,
              ),
            ),
            SizedBox(height: 10),
            CheckItems(
              minVerticalPadding: 0,
              initial: billSplitterItem.userAmounts
                  .map((item) => item.name)
                  .toList(),
              items: [
                ...splitPersons
                    .map((SplitPerson splitPerson) => splitPerson.name)
                    .toList(),
                ...billSplitterItem.userAmounts
                    .map((item) => item.name)
                    .toList(),
              ].toSet().toList(),
              onChanged: (currentValues) {
                selectedSplitPersons = [];
                for (String name in currentValues) {
                  selectedSplitPersons.add(
                    SplitPerson(
                      name,
                      percent: getPerson(splitPersons, name)?.percent,
                    ),
                  );
                }
              },
              buildSuffix:
                  (currentValues, item, selected, addEntry, removeEntry) {
                double percent = selected == true && billSplitterItem.evenSplit
                    ? 1 / currentValues.length * 100
                    : selected == false && billSplitterItem.evenSplit
                        ? 0
                        : (getPerson(splitPersons, item)?.percent ?? 0);
                return TappableTextEntry(
                  title: convertToPercent(percent),
                  placeholder: convertToPercent(0),
                  showPlaceHolderWhenTextEquals: convertToPercent(0),
                  disabled: billSplitterItem.evenSplit,
                  customTitleBuilder: (titleBuilder) {
                    return CountNumber(
                      count: percent,
                      textBuilder: (amount) {
                        return titleBuilder(convertToPercent(amount));
                      },
                      duration: Duration(milliseconds: 400),
                    );
                  },
                  onTap: () {
                    openBottomSheet(
                      context,
                      PopupFramework(
                        title: "Enter Period Length",
                        child: SelectAmountValue(
                          amountPassed:
                              removeTrailingZeroes(percent.toString()),
                          setSelectedAmount: (amount, _) {
                            for (int i = 0; i < splitPersons.length; i++) {
                              if (splitPersons[i].name == item) {
                                setState(() {
                                  splitPersons[i].percent = amount;
                                });
                                break;
                              }
                            }
                            if (amount != 0) {
                              addEntry(item);
                            } else {
                              removeEntry(item);
                            }
                          },
                          next: () async {
                            Navigator.pop(context);
                          },
                          nextLabel: "set-amount".tr(),
                          allowZero: true,
                          suffix: "%",
                        ),
                      ),
                    );
                  },
                  fontSize: 22,
                  padding: EdgeInsets.zero,
                );
              },
            ),
            SizedBox(height: 10),
            AddButton(
              onTap: () {
                openAddPersonPopup(
                  context: context,
                  setState: setState,
                  addPerson: widget.addPerson,
                );
              },
            ),
          ],
          overlay: Align(
            alignment: Alignment.bottomCenter,
            child: SaveBottomButton(
              label:
                  widget.billSplitterItem == null ? "Add Item" : "Update Item",
              onTap: () {
                // for (SplitPerson splitPerson in selectedSplitPersons) {
                //   print(splitPerson.name);
                //   print(splitPerson.percent);
                // }
                billSplitterItem.userAmounts = [...selectedSplitPersons];
                if (widget.billSplitterItem == null) {
                  widget.addBillSplitterItem(billSplitterItem);
                } else {
                  widget.updateBillSplitterItem(
                      billSplitterItem, widget.billSplitterItemIndex);
                }
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }
}

SplitPerson? getPerson(List<SplitPerson> splitPersons, String personName) {
  for (SplitPerson splitPerson in splitPersons) {
    if (splitPerson.name == personName) {
      return splitPerson;
    }
  }
  return null;
}

void openAddPersonPopup({
  required BuildContext context,
  required void setState(void Function() fn),
  required bool Function(SplitPerson) addPerson,
}) {
  openBottomSheet(
    context,
    PopupFramework(
      title: "Add Person",
      child: SelectText(
        popContext: false,
        setSelectedText: (_) {},
        placeholder: "name-placeholder".tr(),
        nextWithInput: (text) async {
          bool result = addPerson(SplitPerson(text));
          if (result == true) {
            setState(() {});
            Navigator.pop(context);
          }
        },
      ),
    ),
  );
  // Fix over-scroll stretch when keyboard pops up quickly
  Future.delayed(Duration(milliseconds: 100), () {
    bottomSheetControllerGlobal.scrollTo(0,
        duration: Duration(milliseconds: 100));
  });
}

class PeoplePage extends StatefulWidget {
  const PeoplePage({
    required this.splitPersons,
    required this.addPerson,
    required this.deletePerson,
    super.key,
  });
  final List<SplitPerson> splitPersons;
  final bool Function(SplitPerson) addPerson;
  final Function(SplitPerson) deletePerson;

  @override
  State<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {
  @override
  Widget build(BuildContext context) {
    return PageFramework(
      title: "People",
      dragDownToDismiss: true,
      listWidgets: [
        widget.splitPersons.length <= 0
            ? NoResults(
                message: "No people found.",
              )
            : SizedBox.shrink(),
        for (SplitPerson person in widget.splitPersons)
          EditRowEntry(
            onDelete: () async {
              await widget.deletePerson(person);
              setState(() {});
            },
            openPage: SizedBox.shrink(),
            onTap: () {
              openAddPersonPopup(
                context: context,
                setState: setState,
                addPerson: (person) {
                  person.name = "hello";
                  return true;
                },
              );
            },
            canReorder: false,
            hideReorder: true,
            currentReorder: false,
            index: 0,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFont(
                  text: person.name,
                  fontSize: 19,
                )
              ],
            ),
          ),
      ],
      floatingActionButton: AnimateFABDelayed(
        fab: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewPadding.bottom),
          child: FAB(
            openPage: SizedBox.shrink(),
            onTap: () {
              openAddPersonPopup(
                context: context,
                setState: setState,
                addPerson: widget.addPerson,
              );
            },
          ),
        ),
      ),
    );
  }
}
