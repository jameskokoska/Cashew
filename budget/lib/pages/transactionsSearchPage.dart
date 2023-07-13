import 'dart:developer';

import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/pastBudgetsPage.dart';
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
import 'package:budget/widgets/util/showDatePicker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:provider/provider.dart';
import 'package:budget/widgets/selectChips.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/framework/popupFramework.dart';

class TransactionsSearchPage extends StatefulWidget {
  const TransactionsSearchPage({this.initialFilters, Key? key})
      : super(key: key);

  final SearchFilters? initialFilters;

  @override
  State<TransactionsSearchPage> createState() => TransactionsSearchPageState();
}

class TransactionsSearchPageState extends State<TransactionsSearchPage>
    with TickerProviderStateMixin {
  void refreshState() {
    setState(() {});
  }

  late AnimationController _animationControllerSearch;
  final _debouncer = Debouncer(milliseconds: 500);

  late SearchFilters searchFilters;

  @override
  void initState() {
    DateTimeRange initialDateTimeRange = DateTimeRange(
      start: DateTime(
          DateTime.now().year, DateTime.now().month - 6, DateTime.now().day),
      end: DateTime.now(),
    );
    searchFilters = widget.initialFilters != null
        ? widget.initialFilters!
        : SearchFilters();

    searchFilters.dateTimeRange = initialDateTimeRange;
    super.initState();
    _animationControllerSearch = AnimationController(vsync: this, value: 1);
  }

  _scrollListener(position) {
    double percent = position / (MediaQuery.of(context).padding.top + 65 + 50);
    if (percent >= 0 && percent <= 1) {
      _animationControllerSearch.value = 1 - percent;
    }
  }

  Future<void> selectFilters(BuildContext context) async {
    await openBottomSheet(
      context,
      PopupFramework(
        title: "filters".tr(),
        padding: false,
        child: TransactionFiltersSelection(
          setSearchFilters: setSearchFilters,
          searchFilters: searchFilters,
        ),
      ),
    );
    Future.delayed(Duration(milliseconds: 250), () {
      setState(() {});
    });
  }

  void setSearchFilters(SearchFilters searchFilters) {
    this.searchFilters = searchFilters;
  }

  Future<void> selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showCustomDateRangePicker(
      context,
      searchFilters.dateTimeRange,
      initialEntryMode: DatePickerEntryMode.input,
    );
    if (picked != null)
      setState(() {
        searchFilters.dateTimeRange = picked;
      });
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
              scrollToTopButton: true,
              listID: "TransactionsSearch",
              dragDownToDismiss: true,
              onScroll: _scrollListener,
              title: "search".tr(),
              floatingActionButton: AnimateFABDelayed(
                fab: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewPadding.bottom),
                  child: FAB(
                    tooltip: "add-transaction".tr(),
                    openPage: AddTransactionPage(
                      title: "add-transaction".tr(),
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
                            labelText: "search-placeholder".tr(),
                            icon: Icons.search_rounded,
                            onSubmitted: (value) {
                              setState(() {
                                searchFilters.searchQuery = value;
                              });
                            },
                            onChanged: (value) {
                              _debouncer.run(() {
                                if (searchFilters.searchQuery != value)
                                  setState(() {
                                    searchFilters.searchQuery = value;
                                  });
                              });
                            },
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
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 500),
                          child: ButtonIcon(
                            key: ValueKey(
                              searchFilters.isClear(
                                ignoreDateTimeRange: true,
                                ignoreSearchQuery: true,
                              ),
                            ),
                            color: searchFilters.isClear(
                              ignoreDateTimeRange: true,
                              ignoreSearchQuery: true,
                            )
                                ? null
                                : Theme.of(context)
                                    .colorScheme
                                    .tertiaryContainer,
                            iconColor: searchFilters.isClear(
                              ignoreDateTimeRange: true,
                              ignoreSearchQuery: true,
                            )
                                ? null
                                : Theme.of(context)
                                    .colorScheme
                                    .onTertiaryContainer,
                            onTap: () {
                              selectFilters(context);
                            },
                            icon: Icons.filter_alt_rounded,
                          ),
                        ),
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
                getTransactionsSlivers(
                  null,
                  null,
                  listID: "TransactionsSearch",
                  simpleListRender: true,
                  noResultsMessage: "No transactions found.",
                  noSearchResultsVariation: true,
                  searchFilters: searchFilters,
                ),
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
                            getWordedDateShortMore(
                                searchFilters.dateTimeRange?.start ??
                                    DateTime.now(),
                                includeYear: true) +
                            " - " +
                            getWordedDateShortMore(
                                searchFilters.dateTimeRange?.end ??
                                    DateTime.now(),
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
  const AmountRangeSlider({
    required this.rangeLimit,
    required this.onChange,
    required this.initialRange,
    super.key,
  });
  final RangeValues rangeLimit;
  final RangeValues? initialRange;
  final Function(RangeValues) onChange;
  @override
  State<AmountRangeSlider> createState() => _AmountSlideRangerState();
}

class _AmountSlideRangerState extends State<AmountRangeSlider> {
  late RangeValues _currentRangeValues = widget.initialRange ??
      RangeValues(widget.rangeLimit.start, widget.rangeLimit.end);

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
              max: widget.rangeLimit.end,
              min: widget.rangeLimit.start,
              onChanged: (RangeValues values) {
                widget.onChange(values);
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
                    fontSize: 14,
                  ),
                  TextFont(
                    text: convertToMoney(Provider.of<AllWallets>(context),
                        _currentRangeValues.end),
                    fontSize: 14,
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
  SearchFilters({
    this.walletPks = const [],
    this.categoryPks = const [],
    this.budgetPks = const [],
    this.expenseIncome = const [],
    this.paidStatus = const [],
    this.transactionTypes = const [],
    this.budgetTransactionFilters = const [],
    // this.reoccurence,
    this.methodAdded = const [],
    this.amountRange,
    this.dateTimeRange,
    this.searchQuery,
  }) {
    walletPks = this.walletPks.isEmpty ? [] : this.walletPks;
    categoryPks = this.categoryPks.isEmpty ? [] : this.categoryPks;
    budgetPks = this.budgetPks.isEmpty ? [] : this.budgetPks;
    expenseIncome = this.expenseIncome.isEmpty ? [] : this.expenseIncome;
    paidStatus = this.paidStatus.isEmpty ? [] : this.paidStatus;
    transactionTypes =
        this.transactionTypes.isEmpty ? [] : this.transactionTypes;
    budgetTransactionFilters = this.budgetTransactionFilters.isEmpty
        ? []
        : this.budgetTransactionFilters;
    // reoccurence = [];
    methodAdded = this.methodAdded.isEmpty ? [] : this.methodAdded;
  }
  //if the value is empty, it means all/ignore
  // think of it, if the tag is added it will be considered in the search
  List<int> walletPks;
  List<int> categoryPks;
  List<int?> budgetPks;
  List<ExpenseIncome> expenseIncome;
  List<PaidStatus> paidStatus;
  List<TransactionSpecialType?> transactionTypes;
  List<BudgetTransactionFilters> budgetTransactionFilters;
  // List<BudgetReoccurence> reoccurence;
  List<MethodAdded> methodAdded;
  RangeValues? amountRange;
  DateTimeRange? dateTimeRange;
  String? searchQuery;

  clearSearchFilters() {
    walletPks = [];
    categoryPks = [];
    budgetPks = [];
    expenseIncome = [];
    paidStatus = [];
    transactionTypes = [];
    budgetTransactionFilters = [];
    // reoccurence = [];
    methodAdded = [];
    amountRange = null;
    dateTimeRange = null;
    searchQuery = null;
  }

  bool isClear({bool? ignoreDateTimeRange, bool? ignoreSearchQuery}) {
    if (walletPks.isEmpty &&
        categoryPks.isEmpty &&
        budgetPks.isEmpty &&
        expenseIncome.isEmpty &&
        paidStatus.isEmpty &&
        transactionTypes.isEmpty &&
        budgetTransactionFilters.isEmpty &&
        // reoccurence == [] &&
        methodAdded.isEmpty &&
        amountRange == null &&
        (ignoreDateTimeRange == true || dateTimeRange == null) &&
        (ignoreSearchQuery == true || searchQuery == null))
      return true;
    else
      return false;
  }
}

class TransactionFiltersSelection extends StatefulWidget {
  const TransactionFiltersSelection(
      {required this.searchFilters, required this.setSearchFilters, super.key});

  final SearchFilters searchFilters;
  final Function(SearchFilters searchFilters) setSearchFilters;

  @override
  State<TransactionFiltersSelection> createState() =>
      _TransactionFiltersSelectionState();
}

class _TransactionFiltersSelectionState
    extends State<TransactionFiltersSelection> {
  late SearchFilters selectedFilters = widget.searchFilters;

  void setSearchFilters() {
    widget.setSearchFilters(selectedFilters);
    setState(() {});
  }

  void clearSearchFilters() {
    // Don't change the DateTime selected, as its handles separately
    DateTimeRange? dateTimeRange = selectedFilters.dateTimeRange;
    selectedFilters.clearSearchFilters();
    selectedFilters.dateTimeRange = dateTimeRange;
    widget.setSearchFilters(selectedFilters);
    setState(() {});
  }

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
            selectedCategories: selectedFilters.categoryPks,
            setSelectedCategories: (List<int>? categories) {
              selectedFilters.categoryPks = categories ?? [];
              setSearchFilters();
            },
          ),
        ),
        StreamBuilder<RangeValues>(
          stream: database.getHighestLowestAmount(
            SearchFilters(
              dateTimeRange: selectedFilters.dateTimeRange,
            ),
          ),
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              RangeValues rangeLimit = RangeValues(
                  (snapshot.data?.start ?? 0) - 0.00000001,
                  (snapshot.data?.end ?? 0) + 0.00000001);
              if ((selectedFilters.amountRange?.start ?? 0) <
                      rangeLimit.start ||
                  (selectedFilters.amountRange?.end ?? 0) > rangeLimit.end) {
                selectedFilters.amountRange = rangeLimit;
              }
              return AmountRangeSlider(
                rangeLimit: rangeLimit,
                initialRange: selectedFilters.amountRange,
                onChange: (RangeValues rangeValue) {
                  if (rangeLimit == rangeValue)
                    selectedFilters.amountRange = null;
                  else
                    selectedFilters.amountRange = rangeValue;
                },
              );
            }
            return SizedBox.shrink();
          }),
        ),
        SizedBox(height: 10),
        SelectChips(
          darkerBackground: true,
          items: ExpenseIncome.values,
          getLabel: (item) {
            return item == ExpenseIncome.expense
                ? "expense".tr()
                : item == ExpenseIncome.income
                    ? "income".tr()
                    : "";
          },
          onSelected: (item) {
            if (selectedFilters.expenseIncome.contains(item)) {
              selectedFilters.expenseIncome.remove(item);
            } else {
              selectedFilters.expenseIncome.add(item);
            }
            setSearchFilters();
          },
          getSelected: (item) {
            return selectedFilters.expenseIncome.contains(item);
          },
        ),
        SelectChips(
          darkerBackground: true,
          items: [null, ...TransactionSpecialType.values],
          getLabel: (item) {
            return transactionTypeDisplayToEnum[item] ?? "";
          },
          onSelected: (item) {
            if (selectedFilters.transactionTypes.contains(item)) {
              selectedFilters.transactionTypes.remove(item);
            } else {
              selectedFilters.transactionTypes.add(item);
            }
            setSearchFilters();
          },
          getSelected: (item) {
            return selectedFilters.transactionTypes.contains(item);
          },
        ),
        SelectChips(
          darkerBackground: true,
          items: PaidStatus.values,
          getLabel: (item) {
            return item == PaidStatus.paid
                ? "paid".tr()
                : item == PaidStatus.notPaid
                    ? "not-paid".tr()
                    : item == PaidStatus.skipped
                        ? "skipped".tr()
                        : "";
          },
          onSelected: (item) {
            if (selectedFilters.paidStatus.contains(item)) {
              selectedFilters.paidStatus.remove(item);
            } else {
              selectedFilters.paidStatus.add(item);
            }
            setSearchFilters();
          },
          getSelected: (item) {
            return selectedFilters.paidStatus.contains(item);
          },
        ),
        SelectChips(
          darkerBackground: true,
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
            setSearchFilters();
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
                darkerBackground: true,
                items: snapshot.data!,
                getLabel: (item) {
                  return item?.name ?? "No Wallet";
                },
                onSelected: (item) {
                  if (selectedFilters.walletPks.contains(item.walletPk)) {
                    selectedFilters.walletPks.remove(item.walletPk);
                  } else {
                    selectedFilters.walletPks.add(item.walletPk);
                  }
                  setSearchFilters();
                },
                getSelected: (item) {
                  return selectedFilters.walletPks.contains(item.walletPk);
                },
                getCustomBorderColor: (item) {
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
                darkerBackground: true,
                items: [null, ...snapshot.data!],
                getLabel: (item) {
                  if (item == null) return "No Budget";
                  return item?.name ?? "No Budget";
                },
                onSelected: (item) {
                  if (selectedFilters.budgetPks.contains(item?.budgetPk)) {
                    selectedFilters.budgetPks.remove(item?.budgetPk);
                  } else {
                    selectedFilters.budgetPks.add(item?.budgetPk);
                  }
                  setSearchFilters();
                },
                getSelected: (item) {
                  return selectedFilters.budgetPks.contains(item?.budgetPk);
                },
                getCustomBorderColor: (item) {
                  if (item == null) return null;
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
              );
            } else {
              return SizedBox.shrink();
            }
          },
        ),
        // SelectChips(
        //   items: MethodAdded.values,
        //   getLabel: (item) {
        //     return item == MethodAdded.csv
        //         ? "CSV"
        //         : item == MethodAdded.shared
        //             ? "Shared"
        //             : item == MethodAdded.email
        //                 ? "Email"
        //                 : "";
        //   },
        //   onSelected: (item) {
        //     if (selectedFilters.methodAdded.contains(item)) {
        //       selectedFilters.methodAdded.remove(item);
        //     } else {
        //       selectedFilters.methodAdded.add(item);
        //     }
        //     setSearchFilters();
        //   },
        //   getSelected: (item) {
        //     return selectedFilters.methodAdded.contains(item);
        //   },
        // ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Flexible(
                child: Button(
                  expandedLayout: true,
                  label: "reset".tr(),
                  onTap: () {
                    clearSearchFilters();
                  },
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  textColor: Theme.of(context).colorScheme.onTertiaryContainer,
                ),
              ),
              SizedBox(width: 13),
              Flexible(
                child: Button(
                  expandedLayout: true,
                  label: "apply".tr(),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
