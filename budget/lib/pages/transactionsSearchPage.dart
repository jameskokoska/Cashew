import 'dart:developer';

import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/homePage.dart';
import 'package:budget/pages/transactionsListPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/SelectedTransactionsActionBar.dart';
import 'package:budget/widgets/budgetContainer.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:budget/main.dart';
import 'package:budget/colors.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'dart:math';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class TransactionsSearchPage extends StatefulWidget {
  const TransactionsSearchPage({Key? key}) : super(key: key);

  @override
  State<TransactionsSearchPage> createState() => TransactionsSearchPageState();
}

class TransactionsSearchPageState extends State<TransactionsSearchPage>
    with TickerProviderStateMixin {
  void refreshState() {
    setState(() {});
    searchTransaction("");
  }

  DateTime selectedStartDate = DateTime(
      DateTime.now().year, DateTime.now().month - 6, DateTime.now().day);
  DateTime selectedEndDate = DateTime.now();

  late Widget transactionWidgets;
  late AnimationController _animationControllerSearch;
  late List<int> selectedTransactionIDs = [];
  bool? selectedIncome;
  String selectedSearch = "";

  onSelected(Transaction transaction, bool selected) {
    // print(transaction.transactionPk.toString() + " selected!");
    // print(globalSelectedID["Transactions"]);
  }

  @override
  void initState() {
    super.initState();
    transactionWidgets = getTransactionsSlivers(
      selectedStartDate,
      selectedEndDate,
      onSelected: onSelected,
      listID: "TransactionsSearch",
      simpleListRender: true,
    );
    _animationControllerSearch = AnimationController(vsync: this, value: 1);
  }

  searchTransaction(String? search, {bool? income}) {
    setState(() {
      selectedSearch = search ?? "";
      selectedIncome = income;
      transactionWidgets = getTransactionsSlivers(
        selectedStartDate,
        selectedEndDate,
        search: search,
        onSelected: onSelected,
        listID: "TransactionsSearch",
        income: income,
        simpleListRender: true,
      );
    });
  }

  _scrollListener(position) {
    double percent = position / (MediaQuery.of(context).padding.top + 65 + 50);
    if (percent >= 0 && percent <= 1) {
      _animationControllerSearch.value = 1 - percent;
    }
  }

  Future<void> selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 10),
      lastDate: DateTime(DateTime.now().year + 2),
      initialDateRange: DateTimeRange(
        start: selectedStartDate,
        end: selectedEndDate,
      ),
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
      initialEntryMode: DatePickerEntryMode.input,
    );
    setState(() {
      selectedStartDate = picked!.start;
      selectedEndDate = picked.end;
    });
    searchTransaction("", income: selectedIncome);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if ((globalSelectedID.value["TransactionsSearch"] ?? []).length > 0) {
          globalSelectedID.value["TransactionsSearch"] = [];
          globalSelectedID.notifyListeners();
          return false;
        } else {
          return true;
        }
      },
      child: Stack(
        children: [
          Listener(
            onPointerDown: (_) {
              //Minimize keyboard when tap non interactive widget
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            },
            child: PageFramework(
              listID: "TransactionsSearch",
              navbar: false,
              dragDownToDismiss: true,
              onScroll: _scrollListener,
              title: "Search",
              slivers: [
                SliverToBoxAdapter(
                  child: AnimatedBuilder(
                    animation: _animationControllerSearch,
                    builder: (_, child) {
                      return Transform.translate(
                        offset: Offset(
                            0, 6.5 - 6.5 * (_animationControllerSearch.value)),
                        child: child,
                      );
                    },
                    child: Row(
                      children: [
                        SizedBox(width: 20),
                        Expanded(
                          child: TextInput(
                            labelText: "Search...",
                            icon: Icons.search_rounded,
                            onSubmitted: (value) {
                              searchTransaction(value, income: selectedIncome);
                            },
                            onChanged: (value) => searchTransaction(value,
                                income: selectedIncome),
                            padding: EdgeInsets.all(0),
                            autoFocus: true,
                          ),
                        ),
                        SizedBox(width: 10),
                        ButtonIcon(
                          onTap: () {
                            selectDateRange(context);
                          },
                          icon: Icons.calendar_month_rounded,
                        ),
                        SizedBox(width: 20),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: 13),
                ),
                SliverToBoxAdapter(
                  child: SlidingSelector(
                      onSelected: (index) {
                        setState(() {
                          selectedIncome = index == 1
                              ? null
                              : index == 2
                                  ? false
                                  : true;
                        });
                        searchTransaction(selectedSearch,
                            income: selectedIncome);
                      },
                      alternateTheme: true),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: 11),
                ),
                transactionWidgets,
                SliverToBoxAdapter(
                  child: GestureDetector(
                    onTap: () {
                      selectDateRange(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 20,
                        bottom: 40,
                      ),
                      child: TextFont(
                        fontSize: 13,
                        textAlign: TextAlign.center,
                        textColor: Theme.of(context).colorScheme.textLight,
                        text: "Showing transactions from" +
                            "\n" +
                            getWordedDateShortMore(selectedStartDate,
                                includeYear: true) +
                            " - " +
                            getWordedDateShortMore(selectedEndDate,
                                includeYear: true),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SelectedTransactionsActionBar(
            pageID: "TransactionsSearch",
          ),
        ],
      ),
    );
  }
}
