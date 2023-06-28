import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/slidingSelectorIncomeExpense.dart';
import 'package:budget/pages/transactionsListPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/selectedTransactionsActionBar.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/selectCategory.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:provider/provider.dart';
import 'package:budget/widgets/selectChips.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/framework/popupFramework.dart';

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
      noResultsMessage: "No transactions found.",
      noSearchResultsVariation: true,
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
        noResultsMessage: "No transactions found.",
        noSearchResultsVariation: true,
      );
    });
  }

  _scrollListener(position) {
    double percent = position / (MediaQuery.of(context).padding.top + 65 + 50);
    if (percent >= 0 && percent <= 1) {
      _animationControllerSearch.value = 1 - percent;
    }
  }

  Future<void> selectFilters(BuildContext context) async {
    List<Budget> allSharedBudgets = [];
    List<Budget> allAddedTransactionBudgets = [];
    allSharedBudgets = await database.getAllBudgets(sharedBudgetsOnly: true);
    allAddedTransactionBudgets =
        await database.getAllBudgetsAddedTransactionsOnly();
    openBottomSheet(
      context,
      PopupFramework(
        title: "Filters",
        padding: false,
        child: TransactionFiltersSelection(),
      ),
    );
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
        if (appStateSettings["materialYou"]) return child ?? SizedBox.shrink();
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
          child: child ?? SizedBox.shrink(),
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
              dragDownToDismiss: true,
              onScroll: _scrollListener,
              title: "Search",
              floatingActionButton: AnimateFABDelayed(
                fab: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewPadding.bottom),
                  child: FAB(
                    tooltip: "Add Transaction",
                    openPage: AddTransactionPage(
                      title: "Add Transaction",
                    ),
                  ),
                ),
              ),
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
                        SizedBox(width: 7),
                        ButtonIcon(
                          onTap: () {
                            selectDateRange(context);
                          },
                          icon: Icons.calendar_month_rounded,
                        ),
                        SizedBox(width: 7),
                        appStateSettings["searchFilters"] == true
                            ? ButtonIcon(
                                onTap: () {
                                  selectFilters(context);
                                },
                                icon: Icons.filter_alt_rounded,
                              )
                            : SizedBox.shrink(),
                        SizedBox(width: 20),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: 13),
                ),
                // SliverToBoxAdapter(
                //   child: SlidingSelectorIncomeExpense(
                //       onSelected: (index) {
                //         setState(() {
                //           selectedIncome = index == 1
                //               ? null
                //               : index == 2
                //                   ? false
                //                   : true;
                //         });
                //         searchTransaction(selectedSearch,
                //             income: selectedIncome);
                //       },
                //       alternateTheme: true),
                // ),
                // SliverToBoxAdapter(
                //   child: SizedBox(height: 7),
                // ),
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
                        textColor: getColor(context, "textLight"),
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

class AmountRangeSlider extends StatefulWidget {
  const AmountRangeSlider({super.key});

  @override
  State<AmountRangeSlider> createState() => _AmountSlideRangerState();
}

class _AmountSlideRangerState extends State<AmountRangeSlider> {
  RangeValues _currentRangeValues = const RangeValues(0, 100);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: RangeSlider(
              values: _currentRangeValues,
              max: 100,
              min: 0,
              labels: RangeLabels(
                convertToMoney(Provider.of<AllWallets>(context),
                    _currentRangeValues.start),
                convertToMoney(
                    Provider.of<AllWallets>(context), _currentRangeValues.end),
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _currentRangeValues = values;
                });
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 35),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextFont(
                    text: convertToMoney(Provider.of<AllWallets>(context),
                        _currentRangeValues.start),
                    fontSize: 15,
                  ),
                  TextFont(
                    text: convertToMoney(Provider.of<AllWallets>(context),
                        _currentRangeValues.end),
                    fontSize: 15,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class SearchFilters {
  SearchFilters(
    this.isIncome,
    this.isExpense,
    this.isPaid,
    this.isNotPaid,
    this.transactionTypes,
    this.budgetTransactionFilters,
    this.walletPks,
    this.categoryPks,
    this.budgetPks,
    this.reoccurence,
    this.sharedOwnerMember,
    this.methodAdded,
  );

  bool isIncome;
  bool isExpense;
  bool isPaid;
  bool isNotPaid;

  List<TransactionSpecialType> transactionTypes;
  List<BudgetTransactionFilters> budgetTransactionFilters;
  List<int>? walletPks;
  List<int>? categoryPks;
  List<int>? budgetPks;
  List<BudgetReoccurence> reoccurence;
  List<SharedOwnerMember> sharedOwnerMember;
  List<MethodAdded> methodAdded;
}

class TransactionFiltersSelection extends StatefulWidget {
  const TransactionFiltersSelection({super.key});

  @override
  State<TransactionFiltersSelection> createState() =>
      _TransactionFiltersSelectionState();
}

class _TransactionFiltersSelectionState
    extends State<TransactionFiltersSelection> {
  SearchFilters selectedFilters = SearchFilters(
    false,
    false,
    false,
    false,
    [],
    [],
    null,
    null,
    null,
    [],
    [],
    [],
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 100,
          child: SelectCategory(
            horizontalList: true,
            showSelectedAllCategoriesIfNoneSelected: true,
            addButton: false,
            setSelectedCategories: (List<int>? categories) {
              selectedFilters.categoryPks = categories;
              setState(() {});
            },
          ),
        ),
        AmountRangeSlider(),
        SelectChips(
          items: ["income", "expense"],
          getLabel: (item) {
            return item == "income"
                ? "Income"
                : item == "expense"
                    ? "Expense"
                    : "";
          },
          onSelected: (item) {
            if (item == "income")
              selectedFilters.isIncome = !selectedFilters.isIncome;
            if (item == "expense")
              selectedFilters.isExpense = !selectedFilters.isExpense;
            setState(() {});
          },
          getSelected: (item) {
            if (item == "income") return selectedFilters.isIncome;
            if (item == "expense") return selectedFilters.isExpense;
            return false;
          },
        ),
        SelectChips(
          items: TransactionSpecialType.values,
          getLabel: (item) {
            return transactionTypeDisplayToEnum[item] ?? "";
          },
          onSelected: (item) {
            if (selectedFilters.transactionTypes.contains(item)) {
              selectedFilters.transactionTypes.remove(item);
            } else {
              selectedFilters.transactionTypes.add(item);
            }
            setState(() {});
          },
          getSelected: (item) {
            return selectedFilters.transactionTypes.contains(item);
          },
        ),
        SelectChips(
          items: ["paid", "notPaid"],
          getLabel: (item) {
            return item == "paid"
                ? "Paid"
                : item == "notPaid"
                    ? "Not Paid"
                    : "";
          },
          onSelected: (item) {
            if (item == "paid")
              selectedFilters.isPaid = !selectedFilters.isPaid;
            if (item == "notPaid")
              selectedFilters.isNotPaid = !selectedFilters.isNotPaid;
            setState(() {});
          },
          getSelected: (item) {
            if (item == "paid") return selectedFilters.isPaid;
            if (item == "notPaid") return selectedFilters.isNotPaid;
            return false;
          },
        ),
        SelectChips(
          items: [
            BudgetTransactionFilters.addedToOtherBudget,
            ...(appStateSettings["sharedBudgets"]
                ? [BudgetTransactionFilters.sharedToOtherBudget]
                : []),
          ],
          getLabel: (item) {
            return item == BudgetTransactionFilters.addedToOtherBudget
                ? "Added to Other Budgets"
                : item == BudgetTransactionFilters.sharedToOtherBudget
                    ? "Shared to Other Budgets"
                    : "";
          },
          onSelected: (item) {
            if (selectedFilters.budgetTransactionFilters.contains(item)) {
              selectedFilters.budgetTransactionFilters.remove(item);
            } else {
              selectedFilters.budgetTransactionFilters.add(item);
            }
            setState(() {});
          },
          getSelected: (item) {
            return selectedFilters.budgetTransactionFilters.contains(item);
          },
        ),
        StreamBuilder<List<TransactionWallet>>(
          stream: database.watchAllWallets(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SelectChips(
                items: [null, ...snapshot.data!],
                getLabel: (item) {
                  if (item == null) return "All Wallets";
                  return item?.name ?? "No Wallet";
                },
                onSelected: (item) {
                  if (selectedFilters.walletPks == null) {
                    selectedFilters.walletPks = [];
                  }
                  if (item == null) {
                    selectedFilters.walletPks = null;
                  } else if (selectedFilters.walletPks!
                      .contains(item.walletPk)) {
                    selectedFilters.walletPks!.remove(item.walletPk);
                  } else {
                    selectedFilters.walletPks!.add(item.walletPk);
                  }
                  setState(() {});
                },
                getSelected: (item) {
                  if (selectedFilters.walletPks == null)
                    return true;
                  else if (item == null && selectedFilters.walletPks == null)
                    return true;
                  else if (item == null)
                    return false;
                  else
                    return selectedFilters.walletPks!.contains(item.walletPk);
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
              );
            } else {
              return SizedBox.shrink();
            }
          },
        ),
        StreamBuilder<List<Budget>>(
          stream: database.watchAllAddableBudgets(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SelectChips(
                items: [null, ...snapshot.data!],
                getLabel: (item) {
                  if (item == null) return "All Budgets";
                  return item?.name ?? "No Budget";
                },
                onSelected: (item) {
                  if (selectedFilters.budgetPks == null) {
                    selectedFilters.budgetPks = [];
                  }
                  if (item == null) {
                    selectedFilters.budgetPks = null;
                  } else if (selectedFilters.budgetPks!
                      .contains(item.budgetPk)) {
                    selectedFilters.budgetPks!.remove(item.budgetPk);
                  } else {
                    selectedFilters.budgetPks!.add(item.budgetPk);
                  }
                  setState(() {});
                },
                getSelected: (item) {
                  if (selectedFilters.budgetPks == null)
                    return true;
                  else if (item == null && selectedFilters.budgetPks == null)
                    return true;
                  else if (item == null)
                    return false;
                  else
                    return selectedFilters.budgetPks!.contains(item.budgetPk);
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
              );
            } else {
              return SizedBox.shrink();
            }
          },
        ),
        // SelectChips(
        //   items: [
        //     MethodAdded.csv,
        //     MethodAdded.shared,
        //     MethodAdded.email,
        //   ],
        //   getLabel: (item) {
        //     return item == MethodAdded.csv
        //         ? "CSV"
        //         : item == MethodAdded.shared
        //             ? "Shared"
        //             : item == MethodAdded.email
        //                 ? "Email"
        //                 : "";
        //   },
        //   onSelected: (item) {},
        //   getSelected: (item) {
        //     return false;
        //   },
        // ),
        appStateSettings["sharedBudgets"]
            ? SelectChips(
                items: SharedOwnerMember.values,
                getLabel: (item) {
                  return item == SharedOwnerMember.owner
                      ? "Owner"
                      : item == SharedOwnerMember.member
                          ? "Member"
                          : "";
                },
                onSelected: (item) {
                  if (selectedFilters.sharedOwnerMember.contains(item)) {
                    selectedFilters.sharedOwnerMember.remove(item);
                  } else {
                    selectedFilters.sharedOwnerMember.add(item);
                  }
                  setState(() {});
                },
                getSelected: (item) {
                  return selectedFilters.sharedOwnerMember.contains(item);
                },
              )
            : SizedBox.shrink(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Button(
            label: "Apply Filters",
            onTap: () {
              Navigator.pop(context);
            },
          ),
        )
      ],
    );
  }
}
