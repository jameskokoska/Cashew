import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addObjectivePage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/pages/transactionFilters.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/iconButtonScaled.dart';
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

import '../widgets/amountRangeSlider.dart';

int roundToNearestNextFifthYear(int year) {
  return (((year + 5) / 5).ceil()) * 5;
}

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
      start: DateTime(1900),
      end: DateTime(roundToNearestNextFifthYear(DateTime.now().year)),
    );
    searchFilters = widget.initialFilters != null
        ? widget.initialFilters!
        : SearchFilters();
    if (widget.initialFilters == null) {
      searchFilters.loadFilterString(
        appStateSettings["searchTransactionsSetFiltersString"],
        skipDateTimeRange: true,
        skipSearchQuery: true,
      );
    }
    if (widget.initialFilters == null ||
        widget.initialFilters?.dateTimeRange == null) {
      searchFilters.dateTimeRange = initialDateTimeRange;
    }

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
      updateSettings(
        "searchTransactionsSetFiltersString",
        searchFilters.getFilterString(),
        updateGlobalState: false,
      );
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
    updateSettings("searchTransactionsSetFiltersString", null,
        updateGlobalState: false);
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
                fab: FAB(
                  tooltip: "add-transaction".tr(),
                  openPage: AddTransactionPage(
                    routesToPopAfterDelete: RoutesToPopAfterDelete.None,
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
                Builder(builder: (context) {
                  Widget dateRangeWidget = Tappable(
                    borderRadius: 10,
                    onTap: () {
                      selectDateRange(context);
                    },
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 10,
                        bottom: 8,
                      ),
                      child: TextFont(
                        text: getWordedDateShortMore(
                                searchFilters.dateTimeRange?.start ??
                                    DateTime.now(),
                                includeYear: true) +
                            " – " +
                            getWordedDateShortMore(
                                searchFilters.dateTimeRange?.end ??
                                    DateTime.now(),
                                includeYear: true),
                        fontSize: 13,
                        textAlign: TextAlign.center,
                        textColor: getColor(context, "textLight"),
                      ),
                    ),
                  );
                  return TransactionEntries(
                    renderType: TransactionEntriesRenderType.slivers,
                    null, null,
                    listID: "TransactionsSearch",
                    noResultsMessage: "no-transactions-found".tr(),
                    noSearchResultsVariation: true,
                    searchFilters: searchFilters,
                    // limit: 250,
                    noResultsExtraWidget: dateRangeWidget,
                    totalCashFlowExtraWidget: Transform.translate(
                        offset: Offset(0, -15), child: dateRangeWidget),
                    showTotalCashFlow: true,
                  );
                }),
                // TransactionEntries(
                //   simpleListRender: true,
                //   null, null,
                //   listID: "TransactionsSearch",
                //   noResultsMessage: "no-transactions-found".tr(),
                //   noSearchResultsVariation: true,
                //   searchFilters: searchFilters,
                //   // limit: 250,
                //   showTotalCashFlow: true,
                //   extraCashFlowInformation: getWordedDateShortMore(
                //           searchFilters.dateTimeRange?.start ?? DateTime.now(),
                //           includeYear: true) +
                //       " - " +
                //       getWordedDateShortMore(
                //           searchFilters.dateTimeRange?.end ?? DateTime.now(),
                //           includeYear: true),
                //   onTapCashFlow: () {
                //     selectDateRange(context);
                //   },
                // ),
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
