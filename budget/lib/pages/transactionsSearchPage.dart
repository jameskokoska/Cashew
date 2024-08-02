import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/transactionFilters.dart';
import 'package:budget/struct/defaultPreferences.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/selectedTransactionsAppBar.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
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
import 'package:budget/widgets/framework/popupFramework.dart';

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
  TextEditingController searchInputController = new TextEditingController();

  @override
  void initState() {
    searchFilters = widget.initialFilters != null
        ? widget.initialFilters!
        : SearchFilters();
    if (widget.initialFilters == null) {
      searchFilters.loadFilterString(
        appStateSettings["searchTransactionsSetFiltersString"],
        skipDateTimeRange: false,
        skipSearchQuery: true,
      );
    }

    _animationControllerSearch = AnimationController(vsync: this, value: 1);
    super.initState();
  }

  @override
  void dispose() {
    searchInputController.dispose();
    super.dispose();
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
    // Only clear the search query if there are special filters
    // identified within the search query
    String? savedSearchQuery;
    ParsedDateTimeQuery? parsedDateTimeQuery = searchFilters.searchQuery == null
        ? null
        : parseSearchQueryForDateTimeText(searchFilters.searchQuery ?? "");
    (double, double)? bounds = searchFilters.searchQuery == null
        ? null
        : parseSearchQueryForAmountText(searchFilters.searchQuery ?? "");
    if (parsedDateTimeQuery != null || bounds != null) {
      savedSearchQuery = null;
      setTextInput(searchInputController, "");
    } else {
      savedSearchQuery = searchFilters.searchQuery;
    }
    searchFilters.clearSearchFilters();
    searchFilters.dateTimeRange = dateTimeRange;
    searchFilters.searchQuery = savedSearchQuery;
    updateSettings("searchTransactionsSetFiltersString", null,
        updateGlobalState: false);
    setState(() {});
  }

  Future<void> selectDateRange(BuildContext context) async {
    final DateTimeRangeOrAllTime? picked = await showCustomDateRangePicker(
      context,
      DateTimeRangeOrAllTime(
        allTime: searchFilters.dateTimeRange == null,
        dateTimeRange: searchFilters.dateTimeRange,
      ),
      initialEntryMode: DatePickerEntryMode.input,
      allTimeButton: true,
    );
    if (picked != null) {
      if (searchFilters.dateTimeRange != picked.dateTimeRange)
        Future.delayed(Duration(milliseconds: 175), () {
          setState(() {
            searchFilters.dateTimeRange = picked.dateTimeRange;
          });
          updateSettings(
            "searchTransactionsSetFiltersString",
            searchFilters.getFilterString(),
            updateGlobalState: false,
          );
        });
    }
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
      child: PageFramework(
        scrollToTopButton: true,
        scrollToBottomButton: true,
        listID: "TransactionsSearch",
        dragDownToDismiss: true,
        onScroll: _scrollListener,
        title: "search".tr(),
        floatingActionButton: AnimateFABDelayed(
          fab: AddFAB(
            tooltip: "add-transaction".tr(),
            openPage: AddTransactionPage(
              routesToPopAfterDelete: RoutesToPopAfterDelete.None,
            ),
          ),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(
                  horizontal: getHorizontalPaddingConstrained(context)),
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
                        controller: searchInputController,
                        autoFocus: true,
                        labelText: "search-placeholder".tr(),
                        icon: appStateSettings["outlinedIcons"]
                            ? Icons.search_outlined
                            : Icons.search_rounded,
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
                        padding: EdgeInsetsDirectional.all(0),
                      ),
                    ),
                    SizedBox(width: 7),
                    Builder(builder: (context) {
                      // Wrap in a builder to prevent entire page from reloading with popup
                      return AnimatedSwitcher(
                        duration: Duration(milliseconds: 500),
                        child: ButtonIcon(
                          key: ValueKey(
                            (searchFilters.dateTimeRange == null).toString(),
                          ),
                          color: searchFilters.dateTimeRange == null
                              ? null
                              : Theme.of(context).colorScheme.tertiaryContainer,
                          iconColor: searchFilters.dateTimeRange == null
                              ? null
                              : Theme.of(context)
                                  .colorScheme
                                  .onTertiaryContainer,
                          onTap: () {
                            selectDateRange(context);
                          },
                          icon: appStateSettings["outlinedIcons"]
                              ? Icons.calendar_month_outlined
                              : Icons.calendar_month_rounded,
                        ),
                      );
                    }),
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
                            : Theme.of(context).colorScheme.tertiaryContainer,
                        iconColor: searchFilters.isClear(
                          ignoreDateTimeRange: true,
                          ignoreSearchQuery: true,
                        )
                            ? null
                            : Theme.of(context).colorScheme.onTertiaryContainer,
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
              padding: EdgeInsetsDirectional.symmetric(
                  horizontal: getHorizontalPaddingConstrained(context)),
              child: AppliedFilterChips(
                searchFilters: searchFilters,
                openFiltersSelection: () {
                  selectFilters(context);
                },
                clearSearchFilters: clearSearchFilters,
                //openSelectDate: () => selectDateRange(context),
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
                padding: const EdgeInsetsDirectional.only(
                  start: 10,
                  end: 10,
                  top: 10,
                  bottom: 8,
                ),
                child: TextFont(
                  text: searchFilters.dateTimeRange == null
                      ? "all-time".tr()
                      : getWordedDateShortMore(
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
              renderType:
                  appStateSettings["appAnimations"] != AppAnimations.all.index
                      ? TransactionEntriesRenderType.sliversNotSticky
                      : TransactionEntriesRenderType.slivers,
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
        selectedTransactionsAppBar: SelectedTransactionsAppBar(
          pageID: "TransactionsSearch",
        ),
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
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 4),
      child: Tappable(
        onTap: () {
          openFiltersSelection();
        },
        borderRadius: 8,
        color: (appStateSettings["materialYou"]
            ? Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5)
            : null),
        child: Container(
          padding:
              EdgeInsetsDirectional.only(start: 14, end: 14, top: 7, bottom: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadiusDirectional.circular(8),
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
                      padding: const EdgeInsetsDirectional.only(end: 5),
                      child: Icon(icon, size: 23),
                    ),
              TextFont(
                text: label,
                fontSize: 14,
              ),
              // Padding(
              //   padding: EdgeInsetsDirectional.only(start: 4.5),
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
