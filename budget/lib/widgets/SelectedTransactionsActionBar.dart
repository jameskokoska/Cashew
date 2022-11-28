import 'dart:developer';

import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/selectCategory.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

class SelectedTransactionsActionBar extends StatelessWidget {
  const SelectedTransactionsActionBar({Key? key, required this.pageID})
      : super(key: key);

  final String pageID;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: globalSelectedID,
      builder: (context, value, widget) {
        List<int> listOfIDs = (value as Map)[pageID] ?? [];
        bool animateIn =
            (value as Map)[pageID] != null && (value as Map)[pageID].length > 0;
        return AnimatedPositioned(
          left: 0,
          right: 0,
          duration: Duration(milliseconds: 500),
          top: animateIn ? 0 : -(MediaQuery.of(context).padding.top + 80),
          curve: Curves.easeInOutCubic,
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 2, bottom: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    boxShadow: boxShadowCheck(
                      [
                        BoxShadow(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Theme.of(context)
                                      .colorScheme
                                      .shadowColorLight
                                      .withOpacity(0.3)
                                  : Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          offset: Offset(0, 4),
                          spreadRadius: 9,
                        ),
                      ],
                    ),
                    color: Theme.of(context).colorScheme.secondaryContainer,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              color: Theme.of(context).colorScheme.secondary,
                              icon: Icon(
                                Icons.arrow_back_rounded,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              onPressed: () {
                                globalSelectedID.value[pageID] = [];
                                globalSelectedID.notifyListeners();
                              },
                            ),
                            StreamBuilder<double?>(
                              stream: database.watchTotalSpentGivenList(
                                  listOfIDs = listOfIDs),
                              builder: (context, snapshot) {
                                return CountUp(
                                  prefix: getCurrencyString(),
                                  count: snapshot.hasData ? snapshot.data! : 0,
                                  duration: Duration(milliseconds: 250),
                                  fontSize: 18,
                                );
                              },
                            ),
                            TextFont(
                                fontSize: 18,
                                text: " (" +
                                    listOfIDs.length.toString() +
                                    " selected)"),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              color: Theme.of(context).colorScheme.secondary,
                              icon: Icon(
                                Icons.edit,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              onPressed: () {
                                openPopupCustom(
                                  context,
                                  title: "Edit Selected",
                                  child: Column(
                                    children: [
                                      TextFont(text: "Modify amount"),
                                      AmountEntry(),
                                      TextFont(text: "Modify category"),
                                      Tappable(
                                        onTap: () {
                                          openBottomSheet(
                                            context,
                                            PopupFramework(
                                              title: "Select Category",
                                              child: SelectCategory(
                                                setSelectedCategory: (_) {},
                                              ),
                                            ),
                                          );
                                        },
                                        child: CategoryIcon(
                                          canEditByLongPress: false,
                                          noBackground: true,
                                          categoryPk: 0,
                                          size: 60,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              color: Theme.of(context).colorScheme.secondary,
                              icon: Icon(
                                Icons.delete,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              onPressed: () {
                                openPopup(
                                  context,
                                  title: "Delete selected transactions?",
                                  description:
                                      "Are you sure you want to delete " +
                                          (value as Map)[pageID]
                                              .length
                                              .toString() +
                                          " transactions?",
                                  icon: Icons.delete_rounded,
                                  onCancel: () {
                                    Navigator.pop(context);
                                  },
                                  onCancelLabel: "Cancel",
                                  onSubmit: () {
                                    for (int transactionID
                                        in (value as Map)[pageID]) {
                                      database.deleteTransaction(transactionID);
                                    }
                                    openSnackbar(
                                      SnackbarMessage(
                                        title: "Deleted " +
                                            (value as Map)[pageID]
                                                .length
                                                .toString() +
                                            pluralString(
                                                (value as Map)[pageID].length ==
                                                    1,
                                                " transaction"),
                                        icon: Icons.delete_rounded,
                                      ),
                                    );
                                    globalSelectedID.value[pageID] = [];
                                    globalSelectedID.notifyListeners();
                                    Navigator.pop(context);
                                  },
                                  onSubmitLabel: "Delete",
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AmountEntry extends StatefulWidget {
  const AmountEntry({super.key});

  @override
  State<AmountEntry> createState() => _AmountEntryState();
}

class _AmountEntryState extends State<AmountEntry> {
  double? selectedAmount;
  String? selectedAmountCalculation;

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

  Future<void> selectAmount(BuildContext context) async {
    openBottomSheet(
      context,
      PopupFramework(
        title: "Enter Amount",
        child: SelectAmount(
          amountPassed: selectedAmountCalculation ?? "",
          setSelectedAmount: setSelectedAmount,
          next: () async {
            Navigator.pop(context);
          },
          nextLabel: "Set Amount",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TappableTextEntry(
      title: convertToMoney(selectedAmount ?? 0),
      placeholder: convertToMoney(0),
      showPlaceHolderWhenTextEquals: convertToMoney(0),
      onTap: () {
        selectAmount(context);
      },
      fontSize: 35,
      fontWeight: FontWeight.bold,
      internalPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 3),
    );
  }
}
