import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addObjectivePage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/selectedTransactionsAppBar.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/selectCategory.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntries.dart';
import 'package:budget/widgets/transactionEntry/transactionEntry.dart';
import 'package:budget/widgets/util/debouncer.dart';
import 'package:budget/widgets/util/showDatePicker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:provider/provider.dart';
import 'package:budget/widgets/selectChips.dart';
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
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 0), () {
      // This detaches the focus so that any popup does not trigger a rerendering of list widgets
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
      _searchFocusNode.requestFocus();
    });
    DateTimeRange initialDateTimeRange = DateTimeRange(
      start: DateTime(
          DateTime.now().year, DateTime.now().month - 6, DateTime.now().day),
      end: DateTime(
          DateTime.now().year, DateTime.now().month + 1, DateTime.now().day),
    );
    searchFilters = widget.initialFilters != null
        ? widget.initialFilters!
        : SearchFilters();

    searchFilters.dateTimeRange = initialDateTimeRange;
    _animationControllerSearch = AnimationController(vsync: this, value: 1);
    _searchFocusNode = new FocusNode();
    super.initState();
  }

  _scrollListener(position) {
    double percent = position / (MediaQuery.paddingOf(context).top + 65 + 50);
    if (percent >= 0 && percent <= 1) {
      _animationControllerSearch.value = 1 - percent;
    }
  }

  Future<void> selectFilters(BuildContext context) async {
    await openBottomSheet(
      context,
      PopupFramework(
        title: "filters".tr(),
        hasPadding: false,
        child: TransactionFiltersSelection(
          setSearchFilters: setSearchFilters,
          searchFilters: searchFilters,
          clearSearchFilters: clearSearchFilters,
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

  void clearSearchFilters() {
    // Don't change the DateTime selected, as its handles separately
    DateTimeRange? dateTimeRange = searchFilters.dateTimeRange;
    // Don't change the search query, as its handled by the text box
    String? searchQuery = searchFilters.searchQuery;
    searchFilters.clearSearchFilters();
    searchFilters.dateTimeRange = dateTimeRange;
    searchFilters.searchQuery = searchQuery;
    setState(() {});
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
                      bottom: MediaQuery.viewPaddingOf(context).bottom),
                  child: FAB(
                    tooltip: "add-transaction".tr(),
                    openPage: AddTransactionPage(
                      routesToPopAfterDelete: RoutesToPopAfterDelete.None,
                    ),
                  ),
                ),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: getHorizontalPaddingConstrained(context)),
                    child: AnimatedBuilder(
                      animation: _animationControllerSearch,
                      builder: (_, child) {
                        return Transform.translate(
                          offset: Offset(0,
                              6.5 - 6.5 * (_animationControllerSearch.value)),
                          child: child,
                        );
                      },
                      child: Row(
                        children: [
                          SizedBox(width: 20),
                          Expanded(
                            child: TextInput(
                              labelText: "search-placeholder".tr(),
                              icon: appStateSettings["outlinedIcons"]
                                  ? Icons.search_outlined
                                  : Icons.search_rounded,
                              onSubmitted: (value) {
                                searchFilters.searchQuery = value;
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
                              focusNode: _searchFocusNode,
                            ),
                          ),
                          SizedBox(width: 7),
                          ButtonIcon(
                            onTap: () {
                              selectDateRange(context);
                            },
                            icon: appStateSettings["outlinedIcons"]
                                ? Icons.calendar_month_outlined
                                : Icons.calendar_month_rounded,
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
                              icon: appStateSettings["outlinedIcons"]
                                  ? Icons.filter_alt_outlined
                                  : Icons.filter_alt_rounded,
                            ),
                          ),
                          SizedBox(width: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: 13),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: getHorizontalPaddingConstrained(context)),
                    child: AppliedFilterChips(
                      searchFilters: searchFilters,
                      openFiltersSelection: () {
                        selectFilters(context);
                      },
                      clearSearchFilters: clearSearchFilters,
                    ),
                  ),
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
                TransactionEntries(
                  null, null,
                  listID: "TransactionsSearch",
                  simpleListRender: false,
                  noResultsMessage: "no-transactions-found".tr(),
                  noSearchResultsVariation: true,
                  searchFilters: searchFilters,
                  // limit: 250,
                  showTotalCashFlow: true,
                  extraCashFlowInformation: getWordedDateShortMore(
                          searchFilters.dateTimeRange?.start ?? DateTime.now(),
                          includeYear: true) +
                      " - " +
                      getWordedDateShortMore(
                          searchFilters.dateTimeRange?.end ?? DateTime.now(),
                          includeYear: true),
                  onTapCashFlow: () {
                    selectDateRange(context);
                  },
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: 50),
                ),
              ],
            ),
          ),
          SelectedTransactionsAppBar(
            pageID: "TransactionsSearch",
          ),
        ],
      ),
    );
  }
}

class AppliedFilterChip extends StatelessWidget {
  const AppliedFilterChip({
    required this.label,
    required this.openFiltersSelection,
    this.icon,
    this.customBorderColor,
    super.key,
  });
  final Color? customBorderColor;
  final String label;
  final IconData? icon;
  final Function openFiltersSelection;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Tappable(
        onTap: () {
          openFiltersSelection();
        },
        borderRadius: 8,
        color:
            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
        child: Container(
          padding: EdgeInsets.only(left: 14, right: 14, top: 7, bottom: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: customBorderColor == null
                  ? Theme.of(context).colorScheme.secondaryContainer
                  : customBorderColor!.withOpacity(0.4),
            ),
          ),
          child: Row(
            children: [
              icon == null
                  ? SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Icon(icon, size: 23),
                    ),
              TextFont(
                text: label,
                fontSize: 14,
              ),
              // Padding(
              //   padding: EdgeInsets.only(left: 4.5),
              //   child: Opacity(
              //     opacity: 0.6,
              //     child: Icon(
              //       Icons.close,
              //       size: 14,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppliedFilterChips extends StatelessWidget {
  const AppliedFilterChips({
    required this.searchFilters,
    required this.openFiltersSelection,
    required this.clearSearchFilters,
    super.key,
  });
  final SearchFilters searchFilters;
  final Function openFiltersSelection;
  final Function clearSearchFilters;

  Future<List<Widget>> getSearchFilterWidgets(BuildContext context) async {
    AllWallets allWallets = Provider.of<AllWallets>(context);
    List<Widget> out = [];
    // Categories
    for (TransactionCategory category in await database.getAllCategories(
        categoryFks: searchFilters.categoryPks, allCategories: false)) {
      out.add(AppliedFilterChip(
        label: category.name,
        customBorderColor: HexColor(category.colour),
        openFiltersSelection: openFiltersSelection,
      ));
    }
    for (TransactionCategory category in await database.getAllCategories(
        categoryFks: searchFilters.subcategoryPks,
        allCategories: false,
        includeSubCategories: true)) {
      out.add(AppliedFilterChip(
        label: category.name,
        customBorderColor: HexColor(category.colour),
        openFiltersSelection: openFiltersSelection,
      ));
    }
    if (searchFilters.subcategoryPks == null) {
      out.add(AppliedFilterChip(
        label: "no-subcategory".tr(),
        openFiltersSelection: openFiltersSelection,
      ));
    }
    // Amount range
    if (searchFilters.amountRange != null) {
      out.add(
        AppliedFilterChip(
          label: convertToMoney(allWallets, searchFilters.amountRange!.start) +
              " - " +
              convertToMoney(
                allWallets,
                searchFilters.amountRange!.end,
              ),
          openFiltersSelection: openFiltersSelection,
        ),
      );
    }
    // Expense Income
    if (searchFilters.expenseIncome.contains(ExpenseIncome.expense)) {
      out.add(AppliedFilterChip(
        label: "expense".tr(),
        openFiltersSelection: openFiltersSelection,
      ));
    }
    if (searchFilters.expenseIncome.contains(ExpenseIncome.income)) {
      out.add(AppliedFilterChip(
        label: "income".tr(),
        openFiltersSelection: openFiltersSelection,
      ));
    }
    // Transaction Types
    for (TransactionSpecialType? transactionType
        in searchFilters.transactionTypes) {
      out.add(AppliedFilterChip(
        label: transactionTypeDisplayToEnum[transactionType]
                ?.toString()
                .toLowerCase()
                .tr() ??
            "default".tr(),
        openFiltersSelection: openFiltersSelection,
      ));
    }
    // Paid status
    if (searchFilters.paidStatus.contains(PaidStatus.paid)) {
      out.add(AppliedFilterChip(
        label: "paid".tr(),
        openFiltersSelection: openFiltersSelection,
      ));
    }
    if (searchFilters.paidStatus.contains(PaidStatus.notPaid)) {
      out.add(AppliedFilterChip(
        label: "not-paid".tr(),
        openFiltersSelection: openFiltersSelection,
      ));
    }
    if (searchFilters.paidStatus.contains(PaidStatus.skipped)) {
      out.add(AppliedFilterChip(
        label: "skipped".tr(),
        openFiltersSelection: openFiltersSelection,
      ));
    }
    // Budget Transaction Filters
    if (searchFilters.budgetTransactionFilters
        .contains(BudgetTransactionFilters.sharedToOtherBudget)) {
      out.add(AppliedFilterChip(
        label: "added-to-other-budgets".tr(),
        openFiltersSelection: openFiltersSelection,
      ));
    }
    if (searchFilters.budgetTransactionFilters
        .contains(BudgetTransactionFilters.addedToOtherBudget)) {
      out.add(AppliedFilterChip(
        label: "shared-to-other-budgets".tr(),
        openFiltersSelection: openFiltersSelection,
      ));
    }
    // Wallets
    for (String walletPk in searchFilters.walletPks) {
      out.add(AppliedFilterChip(
        label: allWallets.indexedByPk[walletPk]?.name ?? "",
        customBorderColor: HexColor(allWallets.indexedByPk[walletPk]?.colour),
        openFiltersSelection: openFiltersSelection,
      ));
    }
    // Budgets
    for (Budget budget in await database.getAllBudgets()) {
      if (searchFilters.budgetPks.contains(budget.budgetPk))
        out.add(AppliedFilterChip(
          label: budget.name,
          customBorderColor: HexColor(budget.colour),
          openFiltersSelection: openFiltersSelection,
        ));
    }
    if (searchFilters.budgetPks.contains(null)) {
      out.add(AppliedFilterChip(
        label: "no-budget".tr(),
        openFiltersSelection: openFiltersSelection,
      ));
    }
    // Objectives
    for (Objective objective in await database.getAllObjectives()) {
      if (searchFilters.objectivePks.contains(objective.objectivePk))
        out.add(AppliedFilterChip(
          label: objective.name,
          customBorderColor: HexColor(objective.colour),
          openFiltersSelection: openFiltersSelection,
        ));
    }
    if (searchFilters.objectivePks.contains(null)) {
      out.add(AppliedFilterChip(
        label: "no-goal".tr(),
        openFiltersSelection: openFiltersSelection,
      ));
    }

    return out;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        openFiltersSelection();
      },
      child: FutureBuilder(
        future: getSearchFilterWidgets(context),
        builder: (context, AsyncSnapshot<List<Widget>> snapshot) {
          return AnimatedSize(
            curve: Curves.easeInOutCubicEmphasized,
            duration: Duration(milliseconds: 1000),
            child: snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.length > 0
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      child: AnimatedSizeSwitcher(
                        clipBehavior: Clip.none,
                        child: Row(
                          key: ValueKey(snapshot.data.toString()),
                          children: [
                            SizedBox(width: 5),
                            Transform.scale(
                              scale: 1.3,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Tappable(
                                  color: Colors.transparent,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 17,
                                    ),
                                  ),
                                  onTap: () {
                                    clearSearchFilters();
                                  },
                                ),
                              ),
                            ),
                            SizedBox(width: 2),
                            ...(snapshot.data ?? [])
                          ],
                        ),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          );
        },
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
  late RangeValues _currentRangeValues;

  @override
  void initState() {
    _currentRangeValues = widget.initialRange ??
        RangeValues(widget.rangeLimit.start, widget.rangeLimit.end);
    super.initState();
  }

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
    this.subcategoryPks = const [],
    this.budgetPks = const [],
    this.objectivePks = const [],
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
    subcategoryPks =
        this.subcategoryPks?.isEmpty == true ? [] : this.subcategoryPks;
    budgetPks = this.budgetPks.isEmpty ? [] : this.budgetPks;
    objectivePks = this.objectivePks.isEmpty ? [] : this.objectivePks;
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
  List<String> walletPks;
  List<String> categoryPks;
  List<String>?
      subcategoryPks; // if this is null, it means any transaction WITHOUT a subcategory (blank list means all)
  List<String?> budgetPks;
  List<String?> objectivePks;
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
    subcategoryPks = [];
    budgetPks = [];
    objectivePks = [];
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
        subcategoryPks?.isEmpty == true &&
        budgetPks.isEmpty &&
        objectivePks.isEmpty &&
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
      {required this.searchFilters,
      required this.setSearchFilters,
      required this.clearSearchFilters,
      super.key});

  final SearchFilters searchFilters;
  final Function(SearchFilters searchFilters) setSearchFilters;
  final Function() clearSearchFilters;

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SelectCategory(
          horizontalList: true,
          showSelectedAllCategoriesIfNoneSelected: true,
          addButton: false,
          selectedCategories: selectedFilters.categoryPks,
          setSelectedCategories: (List<String>? categories) async {
            selectedFilters.categoryPks = categories ?? [];
            if (selectedFilters.categoryPks.length <= 0)
              selectedFilters.subcategoryPks = [];

            // Remove any subcategories that are selected that no longer
            // have the primary category selected
            for (String subCategoryPk in ([
              ...selectedFilters.subcategoryPks ?? []
            ])) {
              TransactionCategory subCategory =
                  await database.getCategoryInstance(subCategoryPk);
              if ((categories ?? []).contains(subCategory.mainCategoryPk) ==
                  false) {
                (selectedFilters.subcategoryPks ?? []).remove(subCategoryPk);
              }
            }

            setSearchFilters();
          },
        ),
        SelectCategory(
          horizontalList: true,
          showSelectedAllCategoriesIfNoneSelected: true,
          addButton: false,
          selectedCategories: selectedFilters.subcategoryPks,
          setSelectedCategories: (List<String>? categories) {
            selectedFilters.subcategoryPks = categories ?? [];
            setSearchFilters();
          },
          mainCategoryPks: selectedFilters.categoryPks,
          forceSelectAllToFalse: selectedFilters.subcategoryPks == null,
          header: [
            SelectedCategoryHorizontalExtraButton(
              label: "none".tr(),
              onTap: () {
                selectedFilters.subcategoryPks = null;
                setSearchFilters();
              },
              isOutlined: selectedFilters.subcategoryPks == null,
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.block_outlined
                  : Icons.block_rounded,
            ),
          ],
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
                  (snapshot.data?.start ?? -0.00000001),
                  (snapshot.data?.end ?? 0.00000001));
              if ((selectedFilters.amountRange?.start ?? 0) <
                      rangeLimit.start ||
                  (selectedFilters.amountRange?.end ?? 0) > rangeLimit.end) {
                selectedFilters.amountRange = rangeLimit;
              }
              if (selectedFilters.amountRange?.end == rangeLimit.end &&
                  selectedFilters.amountRange?.start == rangeLimit.start) {
                selectedFilters.amountRange = null;
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
          items: ExpenseIncome.values,
          getLabel: (ExpenseIncome item) {
            return item == ExpenseIncome.expense
                ? "expense".tr()
                : item == ExpenseIncome.income
                    ? "income".tr()
                    : "";
          },
          onSelected: (ExpenseIncome item) {
            if (selectedFilters.expenseIncome.contains(item)) {
              selectedFilters.expenseIncome.remove(item);
            } else {
              selectedFilters.expenseIncome.add(item);
            }
            setSearchFilters();
          },
          getSelected: (ExpenseIncome item) {
            return selectedFilters.expenseIncome.contains(item);
          },
        ),
        SelectChips(
          items: [null, ...TransactionSpecialType.values],
          getLabel: (TransactionSpecialType? item) {
            return transactionTypeDisplayToEnum[item]
                    ?.toString()
                    .toLowerCase()
                    .tr() ??
                "";
          },
          onSelected: (TransactionSpecialType? item) {
            if (selectedFilters.transactionTypes.contains(item)) {
              selectedFilters.transactionTypes.remove(item);
            } else {
              selectedFilters.transactionTypes.add(item);
            }
            setSearchFilters();
          },
          getSelected: (TransactionSpecialType? item) {
            return selectedFilters.transactionTypes.contains(item);
          },
        ),
        SelectChips(
          items: PaidStatus.values,
          getLabel: (PaidStatus item) {
            return item == PaidStatus.paid
                ? "paid".tr()
                : item == PaidStatus.notPaid
                    ? "not-paid".tr()
                    : item == PaidStatus.skipped
                        ? "skipped".tr()
                        : "";
          },
          onSelected: (PaidStatus item) {
            if (selectedFilters.paidStatus.contains(item)) {
              selectedFilters.paidStatus.remove(item);
            } else {
              selectedFilters.paidStatus.add(item);
            }
            setSearchFilters();
          },
          getSelected: (PaidStatus item) {
            return selectedFilters.paidStatus.contains(item);
          },
        ),
        SelectChips(
          items: <BudgetTransactionFilters>[
            BudgetTransactionFilters.addedToOtherBudget,
            ...(appStateSettings["sharedBudgets"]
                ? [BudgetTransactionFilters.sharedToOtherBudget]
                : []),
          ],
          getLabel: (BudgetTransactionFilters item) {
            return item == BudgetTransactionFilters.addedToOtherBudget
                ? "added-to-other-budgets".tr()
                : item == BudgetTransactionFilters.sharedToOtherBudget
                    ? "shared-to-other-budgets".tr()
                    : "";
          },
          onSelected: (BudgetTransactionFilters item) {
            if (selectedFilters.budgetTransactionFilters.contains(item)) {
              selectedFilters.budgetTransactionFilters.remove(item);
            } else {
              selectedFilters.budgetTransactionFilters.add(item);
            }
            setSearchFilters();
          },
          getSelected: (BudgetTransactionFilters item) {
            return selectedFilters.budgetTransactionFilters.contains(item);
          },
        ),
        StreamBuilder<List<TransactionWallet>>(
          stream: database.watchAllWallets(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SelectChips(
                items: snapshot.data!,
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
                getLabel: (TransactionWallet item) {
                  return item.name;
                },
                onSelected: (TransactionWallet item) {
                  if (selectedFilters.walletPks.contains(item.walletPk)) {
                    selectedFilters.walletPks.remove(item.walletPk);
                  } else {
                    selectedFilters.walletPks.add(item.walletPk);
                  }
                  setSearchFilters();
                },
                getSelected: (TransactionWallet item) {
                  return selectedFilters.walletPks.contains(item.walletPk);
                },
                getCustomBorderColor: (TransactionWallet item) {
                  return dynamicPastel(
                    context,
                    lightenPastel(
                      HexColor(
                        item.colour,
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
                items: [null, ...snapshot.data!],
                onLongPress: (Budget? item) {
                  pushRoute(
                    context,
                    AddBudgetPage(
                      budget: item,
                      routesToPopAfterDelete:
                          RoutesToPopAfterDelete.PreventDelete,
                    ),
                  );
                },
                getLabel: (Budget? item) {
                  if (item == null) return "no-budget".tr();
                  return item.name;
                },
                onSelected: (Budget? item) {
                  if (selectedFilters.budgetPks.contains(item?.budgetPk)) {
                    selectedFilters.budgetPks.remove(item?.budgetPk);
                  } else {
                    selectedFilters.budgetPks.add(item?.budgetPk);
                  }
                  setSearchFilters();
                },
                getSelected: (Budget? item) {
                  return selectedFilters.budgetPks.contains(item?.budgetPk);
                },
                getCustomBorderColor: (Budget? item) {
                  if (item == null) return null;
                  return dynamicPastel(
                    context,
                    lightenPastel(
                      HexColor(
                        item.colour,
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

        StreamBuilder<List<Objective>>(
          stream: database.watchAllObjectives(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SelectChips(
                items: [null, ...snapshot.data!],
                onLongPress: (Objective? item) {
                  pushRoute(
                    context,
                    AddObjectivePage(
                      objective: item,
                      routesToPopAfterDelete:
                          RoutesToPopAfterDelete.PreventDelete,
                    ),
                  );
                },
                getLabel: (Objective? item) {
                  if (item == null) return "no-goal".tr();
                  return item.name;
                },
                onSelected: (Objective? item) {
                  if (selectedFilters.objectivePks
                      .contains(item?.objectivePk)) {
                    selectedFilters.objectivePks.remove(item?.objectivePk);
                  } else {
                    selectedFilters.objectivePks.add(item?.objectivePk);
                  }
                  setSearchFilters();
                },
                getSelected: (Objective? item) {
                  return selectedFilters.objectivePks
                      .contains(item?.objectivePk);
                },
                getCustomBorderColor: (Objective? item) {
                  if (item == null) return null;
                  return dynamicPastel(
                    context,
                    lightenPastel(
                      HexColor(
                        item.colour,
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
                    widget.clearSearchFilters();
                    Navigator.pop(context);
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
