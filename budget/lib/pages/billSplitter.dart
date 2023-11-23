import 'dart:convert';

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
import 'package:budget/widgets/selectCategory.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/sliverStickyLabelDivider.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:provider/provider.dart';
import 'package:budget/widgets/countNumber.dart';
import 'package:budget/struct/databaseGlobal.dart';

import '../widgets/tappableTextEntry.dart';

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

  // Convert a BillSplitterItem object to a JSON Map
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = this.name;
    data['cost'] = this.cost;
    data['evenSplit'] = this.evenSplit;
    data['userAmounts'] =
        this.userAmounts.map((person) => person.toJson()).toList();
    return data;
  }

  // Create a BillSplitterItem object from a JSON Map
  factory BillSplitterItem.fromJson(Map<String, dynamic> json) {
    return BillSplitterItem(
      json['name'] as String,
      json['cost'] as double,
      (json['userAmounts'] as List<dynamic>)
          .map((personJson) => SplitPerson.fromJson(personJson))
          .toList(),
      evenSplit: json['evenSplit'] as bool,
    );
  }
}

class SplitPerson {
  SplitPerson(
    this.name, {
    this.percent,
  });
  double? percent;
  String name;

  // Convert a SplitPerson object to a JSON Map
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = this.name;
    data['percent'] = this.percent;
    return data;
  }

  // Create a SplitPerson object from a JSON Map
  factory SplitPerson.fromJson(Map<String, dynamic> json) {
    return SplitPerson(
      json['name'] as String,
      percent: json['percent'] as double?,
    );
  }
}

class BillSplitter extends StatefulWidget {
  const BillSplitter({super.key});

  @override
  State<BillSplitter> createState() => _BillSplitterState();
}

class _BillSplitterState extends State<BillSplitter> {
  List<SplitPerson> splitPersons = [];
  List<BillSplitterItem> billSplitterItems = [];
  double multiplierAmount = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      splitPersons = await getBillSplitterPersonList();
      billSplitterItems = await getBillSplitterItemList();
      multiplierAmount = await getMultiplierAmount();
      setState(() {});
    });
  }

  addBillSplitterItem(BillSplitterItem billSplitterItem) {
    billSplitterAddItem(billSplitterItem);
    setState(() {
      billSplitterItems.add(billSplitterItem);
    });
  }

  updateBillSplitterItem(BillSplitterItem billSplitterItem, int? index) {
    if (index == null) return;
    billSplitterUpdateItem(billSplitterItem, index);
    setState(() {
      billSplitterItems[index] = billSplitterItem;
    });
  }

  Future<DeletePopupAction?> deleteBillSplitterItem(
      BillSplitterItem billSplitterItem) async {
    DeletePopupAction? action = await openDeletePopup(
      context,
      title: "delete-bill-item-question".tr(),
      subtitle: billSplitterItem.name,
    );
    if (action == DeletePopupAction.Delete) {
      billSplitterDeleteItem(billSplitterItem);
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
      billSplitterAddPerson(person);
      setState(() {
        splitPersons.add(person);
      });
      return true;
    } else {
      openSnackbar(
        SnackbarMessage(
          title: "duplicate-name-warning".tr(),
          icon: appStateSettings["outlinedIcons"]
              ? Icons.warning_outlined
              : Icons.warning_rounded,
          description: "duplicate-name-warning-description".tr(),
        ),
      );
      return false;
    }
  }

  Future<DeletePopupAction?> deletePerson(SplitPerson person) async {
    DeletePopupAction? action = await openDeletePopup(
      context,
      title: "delete-name-question".tr(),
      subtitle: person.name,
    );
    if (action == DeletePopupAction.Delete) {
      billSplitterDeletePerson(person);
      setState(() {
        int index = splitPersons.indexOf(person);
        if (index != -1) {
          splitPersons.removeAt(index);
        }
      });
    }
    return action;
  }

  Future<DeletePopupAction?> resetBill() async {
    DeletePopupAction? action = await openDeletePopup(context,
        title: "reset-bill-question".tr(),
        description: "reset-bill-description".tr());
    if (action == DeletePopupAction.Delete) {
      resetBillSplitterItemList();
      setState(() {
        billSplitterItems = [];
      });
    }
    return action;
  }

  Future setMultiplierAmount(double amount) async {
    setState(() {
      multiplierAmount = amount;
    });
    saveMultiplierAmount(amount);
  }

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      dragDownToDismiss: true,
      title: "bill-splitter".tr(),
      actions: [
        IconButton(
          padding: EdgeInsets.all(15),
          tooltip: "info".tr(),
          onPressed: () {
            openPopup(
              context,
              title: "bill-splitter".tr(),
              description: "bill-splitter-info".tr(),
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.info_outlined
                  : Icons.info_outline_rounded,
              onCancel: () {
                Navigator.pop(context);
              },
              onCancelLabel: "ok".tr(),
            );
          },
          icon: Icon(
            appStateSettings["outlinedIcons"]
                ? Icons.info_outlined
                : Icons.info_outline_rounded,
          ),
        ),
      ],
      horizontalPadding: getHorizontalPaddingConstrained(context),
      floatingActionButton: AnimateFABDelayed(
        fab: FAB(
          onLongPressAddAllPopup: false,
          openPage: AddBillItemPage(
            splitPersons: splitPersons,
            addBillSplitterItem: addBillSplitterItem,
            deleteBillSplitterItem: deleteBillSplitterItem,
            updateBillSplitterItem: updateBillSplitterItem,
            addPerson: addPerson,
            deletePerson: deletePerson,
            multiplierAmount: multiplierAmount,
            setMultiplierAmount: setMultiplierAmount,
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
                totalCost += billSplitterItem.cost * multiplierAmount;

                for (SplitPerson splitPerson in billSplitterItem.userAmounts) {
                  double percentOfTotal = billSplitterItem.evenSplit
                      ? billSplitterItem.userAmounts.length == 0
                          ? 0
                          : 1 / billSplitterItem.userAmounts.length
                      : (splitPerson.percent ?? 0) / 100;
                  double amountSpent =
                      billSplitterItem.cost * multiplierAmount * percentOfTotal;

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
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: IgnorePointer(
                  ignoring: billSplitterItems.length <= 0,
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 500),
                    opacity: billSplitterItems.length <= 0 ? 0.5 : 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: SettingsContainer(
                        isOutlinedColumn: true,
                        title: "new-bill".tr(),
                        icon: appStateSettings["outlinedIcons"]
                            ? Icons.add_outlined
                            : Icons.add_rounded,
                        isOutlined: true,
                        onTap: () {
                          resetBill();
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: SettingsContainerOpenPage(
                  isOutlinedColumn: true,
                  title: "names".tr(),
                  icon: appStateSettings["outlinedIcons"]
                      ? Icons.people_outlined
                      : Icons.people_rounded,
                  isOutlined: true,
                  openPage: PeoplePage(
                    splitPersons: splitPersons,
                    addPerson: addPerson,
                    deletePerson: deletePerson,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: IgnorePointer(
                  ignoring: billSplitterItems.length <= 0,
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 500),
                    opacity: billSplitterItems.length <= 0 ? 0.5 : 1,
                    child: SettingsContainerOpenPage(
                      isOutlinedColumn: true,
                      title: "summary".tr(),
                      icon: appStateSettings["outlinedIcons"]
                          ? Icons.summarize_outlined
                          : Icons.summarize_rounded,
                      isOutlined: true,
                      openPage: SummaryPage(
                        billSplitterItems: billSplitterItems,
                        resetBill: resetBill,
                        multiplierAmount: multiplierAmount,
                      ),
                    ),
                  ),
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
            multiplierAmount: multiplierAmount,
            setMultiplierAmount: setMultiplierAmount,
          ),
        SizedBox(height: 55),
      ],
    );
  }
}

Future<bool> billSplitterAddPerson(SplitPerson person) async {
  List<SplitPerson> billSplitterPersonList = await getBillSplitterPersonList();
  billSplitterPersonList.add(person);

  String jsonList = jsonEncode(billSplitterPersonList);

  await sharedPreferences.setString("billSplitterPersonList", jsonList);
  return true;
}

Future<bool> billSplitterDeletePerson(SplitPerson person) async {
  List<SplitPerson> billSplitterPersonList = await getBillSplitterPersonList();
  for (int index = 0; index < billSplitterPersonList.length; index++) {
    if (billSplitterPersonList[index].toJson().toString() ==
        person.toJson().toString()) {
      billSplitterPersonList.removeAt(index);
      break;
    }
  }

  String jsonList = jsonEncode(billSplitterPersonList);

  await sharedPreferences.setString("billSplitterPersonList", jsonList);
  return true;
}

Future<List<SplitPerson>> getBillSplitterPersonList() async {
  String? jsonString = sharedPreferences.getString("billSplitterPersonList");
  List<SplitPerson> billSplitterPersonList = [];
  if (jsonString != null && jsonString.isNotEmpty) {
    List<dynamic> jsonList = json.decode(jsonString);
    billSplitterPersonList =
        jsonList.map((json) => SplitPerson.fromJson(json)).toList();
  }
  return billSplitterPersonList;
}

Future<bool> billSplitterAddItem(BillSplitterItem item) async {
  List<BillSplitterItem> billSplitterItemList = await getBillSplitterItemList();
  billSplitterItemList.add(item);

  String jsonList = jsonEncode(billSplitterItemList);

  await sharedPreferences.setString("billSplitterItemList", jsonList);
  return true;
}

Future<bool> billSplitterDeleteItem(BillSplitterItem item) async {
  List<BillSplitterItem> billSplitterItemList = await getBillSplitterItemList();
  for (int index = 0; index < billSplitterItemList.length; index++) {
    if (billSplitterItemList[index].toJson().toString() ==
        item.toJson().toString()) {
      billSplitterItemList.removeAt(index);
      break;
    }
  }

  String jsonList = jsonEncode(billSplitterItemList);

  await sharedPreferences.setString("billSplitterItemList", jsonList);
  return true;
}

Future<bool> billSplitterUpdateItem(BillSplitterItem newItem, int index) async {
  List<BillSplitterItem> billSplitterItemList = await getBillSplitterItemList();
  billSplitterItemList[index] = newItem;

  String jsonList = jsonEncode(billSplitterItemList);

  await sharedPreferences.setString("billSplitterItemList", jsonList);
  return true;
}

Future<List<BillSplitterItem>> getBillSplitterItemList() async {
  String? jsonString = sharedPreferences.getString("billSplitterItemList");
  List<BillSplitterItem> billSplitterItemList = [];
  if (jsonString != null && jsonString.isNotEmpty) {
    List<dynamic> jsonList = json.decode(jsonString);
    billSplitterItemList =
        jsonList.map((json) => BillSplitterItem.fromJson(json)).toList();
  }
  return billSplitterItemList;
}

Future<bool> resetBillSplitterItemList() async {
  await sharedPreferences.setString("billSplitterItemList", "[]");
  return true;
}

Future<double> getMultiplierAmount() async {
  double? multiplierAmount =
      sharedPreferences.getDouble("billSplitterMultiplierAmount");
  return multiplierAmount ?? 1;
}

Future saveMultiplierAmount(double amount) async {
  await sharedPreferences.setDouble("billSplitterMultiplierAmount", amount);
  return;
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
    required this.setMultiplierAmount,
    required this.multiplierAmount,
    super.key,
  });
  final BillSplitterItem billSplitterItem;
  final int billSplitterItemIndex;
  final List<SplitPerson> splitPersons;
  final Function(BillSplitterItem) addBillSplitterItem;
  final Future<DeletePopupAction?> Function(BillSplitterItem)
      deleteBillSplitterItem;
  final Function(BillSplitterItem, int? index) updateBillSplitterItem;
  final bool Function(SplitPerson) addPerson;
  final Function(SplitPerson) deletePerson;
  final Function(double amount) setMultiplierAmount;
  final double multiplierAmount;

  @override
  Widget build(BuildContext context) {
    double total = 0;
    for (SplitPerson splitPerson in billSplitterItem.userAmounts) {
      total += (splitPerson.percent ?? 0) /
          100 *
          billSplitterItem.cost *
          multiplierAmount;
    }
    String totalString = convertToMoney(
      Provider.of<AllWallets>(context),
      total,
    );
    String originalCostString = convertToMoney(
      Provider.of<AllWallets>(context),
      billSplitterItem.cost * multiplierAmount,
    );
    if (billSplitterItem.evenSplit && billSplitterItem.userAmounts.length > 0) {
      totalString = originalCostString;
    }
    Color? errorColor = totalString == originalCostString
        ? null
        : total < billSplitterItem.cost * multiplierAmount
            ? getColor(context, "expenseAmount")
            : total > billSplitterItem.cost * multiplierAmount
                ? getColor(context, "warningOrange")
                : null;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedSize(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: EditRowEntry(
              onDelete: () async {
                return (await deleteBillSplitterItem(billSplitterItem)) ==
                    DeletePopupAction.Delete;
              },
              key: ValueKey(uuid.v4()),
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
                multiplierAmount: multiplierAmount,
                setMultiplierAmount: setMultiplierAmount,
              ),
              canReorder: false,
              hideReorder: true,
              iconAlignment: Alignment.bottomCenter,
              padding: getPlatform() == PlatformOS.isIOS
                  ? EdgeInsets.only(
                      top: 17,
                      bottom: 0,
                      left: 25,
                      right: 5,
                    )
                  : EdgeInsets.only(
                      top: 17,
                      bottom: 0,
                      left: 25,
                      right: 25,
                    ),
              currentReorder: false,
              index: billSplitterItemIndex,
              content: Column(
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
                                    billSplitterItem.cost * multiplierAmount,
                                  ),
                              fontSize: 15,
                              textColor: getColor(context, "textLight"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              extraWidgetsBelow: [
                AnimatedSize(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 17, left: 25, right: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        billSplitterItem.userAmounts.length <= 0
                            ? SizedBox.shrink()
                            : SizedBox(height: 7),
                        for (SplitPerson splitPerson
                            in billSplitterItem.userAmounts)
                          Builder(
                            builder: (context) {
                              double percentOfTotal = billSplitterItem.evenSplit
                                  ? billSplitterItem.userAmounts.length == 0
                                      ? 0
                                      : 1 / billSplitterItem.userAmounts.length
                                  : (splitPerson.percent ?? 0) / 100;
                              double amountSpent = billSplitterItem.cost *
                                  multiplierAmount *
                                  percentOfTotal;
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
                                          duration:
                                              Duration(milliseconds: 1500),
                                          curve:
                                              Curves.easeInOutCubicEmphasized,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            child: Container(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
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
              ]),
        ),
        getPlatform() == PlatformOS.isIOS
            ? SizedBox.shrink()
            : Positioned(
                top: -11,
                right: -2,
                child: IconButton(
                  onPressed: () {
                    deleteBillSplitterItem(billSplitterItem);
                  },
                  icon: AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    decoration: BoxDecoration(
                      color: dynamicPastel(
                          context, Theme.of(context).colorScheme.error),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    padding: EdgeInsets.all(5),
                    child: Icon(
                      appStateSettings["outlinedIcons"]
                          ? Icons.delete_outlined
                          : Icons.delete_rounded,
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
    required this.setMultiplierAmount,
    required this.multiplierAmount,
    super.key,
  });
  final List<SplitPerson> splitPersons;
  final BillSplitterItem? billSplitterItem;
  final int? billSplitterItemIndex;
  final Function(BillSplitterItem) addBillSplitterItem;
  final Future<DeletePopupAction?> Function(BillSplitterItem)
      deleteBillSplitterItem;
  final bool Function(SplitPerson) addPerson;
  final Function(SplitPerson) deletePerson;
  final Function(BillSplitterItem, int? index) updateBillSplitterItem;
  final Function(double amount) setMultiplierAmount;
  final double multiplierAmount;

  @override
  State<AddBillItemPage> createState() => _AddBillItemPageState();
}

class _AddBillItemPageState extends State<AddBillItemPage> {
  late BillSplitterItem billSplitterItem = widget.billSplitterItem != null
      ? BillSplitterItem(
          widget.billSplitterItem!.name,
          widget.billSplitterItem!.cost,
          widget.billSplitterItem!.userAmounts,
          evenSplit: widget.billSplitterItem!.evenSplit,
        )
      : BillSplitterItem(
          "",
          0,
          [],
        );
  late List<SplitPerson> splitPersons = widget.splitPersons;
  List<SplitPerson> selectedSplitPersons = [];
  late TextEditingController _titleInputController =
      TextEditingController(text: billSplitterItem.name);
  late double multiplierAmount = widget.multiplierAmount;

  @override
  void initState() {
    super.initState();
    if (widget.billSplitterItem == null) {
      Future.delayed(Duration.zero, () async {
        openBottomSheet(
          context,
          fullSnap: true,
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
          enableWalletPicker: false,
          padding: EdgeInsets.symmetric(horizontal: 18),
          onlyShowCurrencyIcon: true,
          selectedWalletPk: appStateSettings["selectedWalletPk"],
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
        if (widget.billSplitterItem == null ||
            billSplitterItem.toJson().toString() !=
                widget.billSplitterItem!.toJson().toString() ||
            jsonEncode(selectedSplitPersons) !=
                jsonEncode(billSplitterItem.userAmounts)) {
          discardChangesPopup(context, forceShow: true);
          return false;
        }
        return true;
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
          title: widget.billSplitterItem == null
              ? "add-item".tr()
              : "edit-item".tr(),
          dragDownToDismiss: true,
          horizontalPadding: getHorizontalPaddingConstrained(context) + 13,
          actions: [
            widget.billSplitterItem != null
                ? IconButton(
                    padding: EdgeInsets.all(15),
                    tooltip: "delete-item",
                    onPressed: () async {
                      if (await widget
                              .deleteBillSplitterItem(billSplitterItem) ==
                          DeletePopupAction.Delete) {
                        Navigator.pop(context);
                      }
                    },
                    icon: Icon(appStateSettings["outlinedIcons"]
                        ? Icons.delete_outlined
                        : Icons.delete_rounded),
                  )
                : SizedBox.shrink(),
          ],
          listWidgets: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: IntrinsicWidth(
                    child: TextInput(
                      controller: _titleInputController,
                      labelText: "item-name-placeholder".tr(),
                      bubbly: false,
                      onChanged: (text) {
                        billSplitterItem.name = text;
                      },
                      textAlign: TextAlign.center,
                      padding: EdgeInsets.only(left: 7, right: 7),
                      fontSize: getIsFullScreen(context) ? 26 : 25,
                      fontWeight: FontWeight.bold,
                      topContentPadding: kIsWeb ? 6.8 : 0,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Padding(
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
                ),
                TextFont(text: "×"),
                Padding(
                  padding: const EdgeInsets.only(bottom: 7.5),
                  child: TappableTextEntry(
                    title: multiplierAmount.toStringAsFixed(2),
                    placeholder: "1",
                    showPlaceHolderWhenTextEquals: "1.00",
                    onTap: () {
                      openBottomSheet(
                        context,
                        fullSnap: true,
                        PopupFramework(
                          title: "enter-amount".tr(),
                          subtitle: "bill-splitter-multiplier-description".tr(),
                          child: SelectAmount(
                            allowZero: true,
                            allDecimals: true,
                            convertToMoney: false,
                            amountPassed: multiplierAmount.toString(),
                            setSelectedAmount: (amount, __) {
                              if (amount == 0) {
                                widget.setMultiplierAmount(1);
                                setState(() {
                                  multiplierAmount = 1;
                                });
                              } else {
                                widget.setMultiplierAmount(amount);
                                setState(() {
                                  multiplierAmount = amount;
                                });
                              }
                            },
                            next: () {
                              print(multiplierAmount);
                              Navigator.pop(context);
                            },
                            nextLabel: "set-amount".tr(),
                            currencyKey: null,
                            onlyShowCurrencyIcon: false,
                            enableWalletPicker: false,
                          ),
                        ),
                      );
                    },
                    fontSize: 27,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                borderRadius: getPlatform() == PlatformOS.isIOS
                    ? BorderRadius.circular(10)
                    : BorderRadius.circular(20),
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
              child: SettingsContainerSwitch(
                title: "split-evenly".tr(),
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
                  enableAnimatedSwitcher: false,
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
                        title: "enter-amount".tr(),
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
              label: widget.billSplitterItem == null
                  ? "add-item".tr()
                  : "update-item".tr(),
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
      title: "add-name".tr(),
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
      title: "names".tr(),
      dragDownToDismiss: true,
      horizontalPadding: getHorizontalPaddingConstrained(context),
      listWidgets: [
        widget.splitPersons.length <= 0
            ? NoResults(
                message: "no-names-found".tr(),
              )
            : SizedBox.shrink(),
        for (int i = 0; i < widget.splitPersons.length; i++)
          EditRowEntry(
            key: ValueKey(uuid.v4()),
            onDelete: () async {
              bool result =
                  (await widget.deletePerson(widget.splitPersons[i])) ==
                      DeletePopupAction.Delete;
              setState(() {});
              return result;
            },
            openPage: SizedBox.shrink(),
            onTap: () {},
            canReorder: false,
            hideReorder: true,
            currentReorder: false,
            index: i,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFont(
                  text: widget.splitPersons[i].name,
                  fontSize: 19,
                )
              ],
            ),
          ),
      ],
      floatingActionButton: AnimateFABDelayed(
        fab: FAB(
          onLongPressAddAllPopup: false,
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
    );
  }
}

class SplitPersonSummary {
  SplitPersonSummary(
    this.splitPerson,
    this.billSplitterItems,
    this.total,
  );
  SplitPerson splitPerson;
  List<BillSplitterItem> billSplitterItems;
  double total;
}

class SummaryPage extends StatelessWidget {
  const SummaryPage(
      {required this.billSplitterItems,
      required this.resetBill,
      required this.multiplierAmount,
      super.key});

  final List<BillSplitterItem> billSplitterItems;
  final Future<DeletePopupAction?> Function() resetBill;
  final double multiplierAmount;

  @override
  Widget build(BuildContext context) {
    // Get all the users who participated
    // We have to loop through the items, because if a user was deleted
    // and they were enetered as paying for something their total wouldn't be there if we just checked the saved people!
    Set<String> splitPersonsNames = {};
    for (BillSplitterItem billSplitterItem in billSplitterItems) {
      for (SplitPerson splitPerson in billSplitterItem.userAmounts) {
        splitPersonsNames.add(splitPerson.name);
      }
    }

    List<SplitPersonSummary> splitPersonSummaries = [];
    for (String splitPersonName in splitPersonsNames) {
      double total = 0;
      for (BillSplitterItem billSplitterItem in billSplitterItems) {
        SplitPerson? splitPerson;
        for (SplitPerson splitPersonCheck in billSplitterItem.userAmounts) {
          if (splitPersonCheck.name == splitPersonName) {
            splitPerson = splitPersonCheck;
            break;
          }
        }
        if (splitPerson == null) continue;

        double percentOfTotal = billSplitterItem.evenSplit
            ? billSplitterItem.userAmounts.length == 0
                ? 0
                : 1 / billSplitterItem.userAmounts.length
            : (splitPerson.percent ?? 0) / 100;
        double amountSpent =
            billSplitterItem.cost * multiplierAmount * percentOfTotal;
        if (amountSpent == 0) percentOfTotal = 0;
        total += amountSpent;
      }
      splitPersonSummaries.add(
        SplitPersonSummary(
          SplitPerson(splitPersonName),
          billSplitterItems,
          total,
        ),
      );
    }

    return PageFramework(
      title: "summary".tr(),
      dragDownToDismiss: true,
      overlay: Align(
        alignment: Alignment.bottomCenter,
        child: SaveBottomButton(
          label: "generate-loan-transactions".tr(),
          onTap: () async {
            generateLoanTransactionsFromBillSummary(
              context,
              splitPersonSummaries,
              resetBill,
              multiplierAmount,
            );
          },
          disabled: false,
        ),
      ),
      slivers: [
        SliverStickyLabelDivider(
          info: "name".tr(),
          extraInfo: "owed-to-you".tr(),
          sliver: ColumnSliver(
            children: splitPersonSummaries.length <= 0
                ? [NoResults(message: "missing-data".tr())]
                : [
                    for (int i = 0; i < splitPersonSummaries.length; i++)
                      SummaryPersonRowEntry(
                        splitPersonName:
                            splitPersonSummaries[i].splitPerson.name,
                        total: splitPersonSummaries[i].total,
                        billSplitterItems:
                            splitPersonSummaries[i].billSplitterItems,
                        index: i,
                        multiplierAmount: multiplierAmount,
                      ),
                    SizedBox(height: 50),
                  ],
          ),
        ),
      ],
      horizontalPadding: getHorizontalPaddingConstrained(context),
    );
  }
}

Future<bool> generateLoanTransactionsFromBillSummary(
    BuildContext context,
    List<SplitPersonSummary> billSummary,
    Future<DeletePopupAction?> Function() resetBill,
    double multiplierAmount) async {
  String payee = await openBottomSheet(
    context,
    PopupFramework(
      title: "who-are-you-question".tr(),
      subtitle: "who-are-you-description".tr(),
      child: RadioItems(
        items: [
          for (SplitPersonSummary personSummary in billSummary)
            personSummary.splitPerson.name
        ],
        initial: null,
        onChanged: (value) async {
          Navigator.pop(context, value);
        },
      ),
    ),
  );
  String billName = await openBottomSheet(
    context,
    fullSnap: true,
    PopupFramework(
      title: "set-title".tr(),
      child: SelectText(
        setSelectedText: (value) {},
        labelText: "set-title".tr(),
        placeholder: "title-placeholder".tr(),
        nextWithInput: (text) async {
          Navigator.pop(context, text);
        },
        popContext: false,
      ),
    ),
  );
  TransactionCategory category = await openBottomSheet(
    context,
    PopupFramework(
      title: "select-category".tr(),
      child: SelectCategory(
        nextWithCategory: (TransactionCategory category) {
          Navigator.pop(context, category);
        },
      ),
    ),
  );
  print(category);
  for (SplitPersonSummary summary in billSummary) {
    String note = "";
    double amountSpentTotal = 0;
    for (BillSplitterItem billSplitterItem in summary.billSplitterItems) {
      SplitPerson? splitPerson;
      for (SplitPerson splitPersonCheck in billSplitterItem.userAmounts) {
        if (splitPersonCheck.name == summary.splitPerson.name) {
          splitPerson = splitPersonCheck;
          break;
        }
      }
      double amountSpent = 0;
      if (splitPerson == null) continue;
      double percentOfTotal = billSplitterItem.evenSplit
          ? billSplitterItem.userAmounts.length == 0
              ? 0
              : 1 / billSplitterItem.userAmounts.length
          : (splitPerson.percent ?? 0) / 100;
      amountSpent = billSplitterItem.cost * multiplierAmount * percentOfTotal;
      amountSpentTotal = amountSpentTotal + amountSpent;
      if (amountSpent == 0) percentOfTotal = 0;
      if (amountSpent == 0) continue;

      note += billSplitterItem.name +
          ": " +
          convertToMoney(
            Provider.of<AllWallets>(context, listen: false),
            amountSpent,
          ) +
          (percentOfTotal < 1
              ? (" / " +
                  convertToMoney(
                    Provider.of<AllWallets>(context, listen: false),
                    billSplitterItem.cost * multiplierAmount,
                  ))
              : "");
      note += "\n";
    }
    note = note.trim();
    bool isThePayee = summary.splitPerson.name == payee;

    await database.createOrUpdateTransaction(
      insert: true,
      Transaction(
        transactionPk: "-1",
        name: isThePayee
            ? billName.trim()
            : (summary.splitPerson.name.trim() + " - " + billName.trim()),
        amount: amountSpentTotal.abs() * -1,
        note: note,
        categoryFk: category.categoryPk,
        walletFk: appStateSettings["selectedWalletPk"],
        dateCreated: DateTime.now(),
        income: false,
        paid: true,
        type: isThePayee ? null : TransactionSpecialType.credit,
        skipPaid: false,
      ),
    );
  }
  openSnackbar(
    SnackbarMessage(
      icon: appStateSettings["outlinedIcons"]
          ? Icons.done_outlined
          : Icons.done_rounded,
      title: "success-generate-loans".tr(),
      description: "success-generate-loans-description".tr(),
    ),
  );
  resetBill();
  return true;
}

class SummaryPersonRowEntry extends StatefulWidget {
  const SummaryPersonRowEntry({
    required this.splitPersonName,
    required this.total,
    required this.billSplitterItems,
    required this.index,
    required this.multiplierAmount,
    super.key,
  });
  final String splitPersonName;
  final double total;
  final List<BillSplitterItem> billSplitterItems;
  final int index;
  final double multiplierAmount;

  @override
  State<SummaryPersonRowEntry> createState() => _SummaryPersonRowEntryState();
}

class _SummaryPersonRowEntryState extends State<SummaryPersonRowEntry> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: EditRowEntry(
        disableIntrinsicContentHeight: true,
        canDelete: false,
        onTap: () {
          setState(() {
            isExpanded = !isExpanded;
          });
        },
        openPage: Container(),
        canReorder: false,
        hideReorder: true,
        padding: EdgeInsets.symmetric(
          vertical: 7,
          horizontal: getPlatform() == PlatformOS.isIOS ? 17 : 7,
        ),
        currentReorder: false,
        index: widget.index,
        content: Padding(
          padding: EdgeInsets.only(left: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFont(
                      text: widget.splitPersonName,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      maxLines: 1,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextFont(
                        text: convertToMoney(
                          Provider.of<AllWallets>(context),
                          widget.total,
                        ),
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                      AnimatedRotation(
                        duration: Duration(milliseconds: 900),
                        curve: ElasticOutCurve(0.6),
                        turns: isExpanded ? 0.5 : 0,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              isExpanded = !isExpanded;
                            });
                          },
                          icon: Icon(appStateSettings["outlinedIcons"]
                              ? Icons.arrow_drop_down_outlined
                              : Icons.arrow_drop_down_rounded),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              AnimatedSizeSwitcher(
                sizeAlignment: Alignment.topCenter,
                child: isExpanded == false
                    ? Container(
                        key: ValueKey(1),
                      )
                    : Column(
                        children: [
                          for (BillSplitterItem billSplitterItem
                              in widget.billSplitterItems)
                            Builder(
                              builder: (context) {
                                SplitPerson? splitPerson;
                                for (SplitPerson splitPersonCheck
                                    in billSplitterItem.userAmounts) {
                                  if (splitPersonCheck.name ==
                                      widget.splitPersonName) {
                                    splitPerson = splitPersonCheck;
                                    break;
                                  }
                                }
                                if (splitPerson == null)
                                  return SizedBox.shrink();

                                double percentOfTotal = billSplitterItem
                                        .evenSplit
                                    ? billSplitterItem.userAmounts.length == 0
                                        ? 0
                                        : 1 /
                                            billSplitterItem.userAmounts.length
                                    : (splitPerson.percent ?? 0) / 100;
                                double amountSpent = billSplitterItem.cost *
                                    widget.multiplierAmount *
                                    percentOfTotal;
                                if (amountSpent == 0) percentOfTotal = 0;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 7),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFont(
                                              text: billSplitterItem.name,
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
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: Stack(
                                          children: [
                                            Container(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondaryContainer,
                                              height: 5,
                                            ),
                                            AnimatedFractionallySizedBox(
                                              duration:
                                                  Duration(milliseconds: 1500),
                                              curve: Curves
                                                  .easeInOutCubicEmphasized,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                child: Container(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
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
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
              ),
              AnimatedSizeSwitcher(
                sizeAlignment: Alignment.topCenter,
                child: isExpanded
                    ? Container(
                        height: 10,
                        key: ValueKey(1),
                      )
                    : Container(
                        key: ValueKey(2),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
