import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/pages/homePage/homePageLineGraph.dart';
import 'package:budget/pages/homePage/homePageNetWorth.dart';
import 'package:budget/pages/homePage/homePageWalletSwitcher.dart';
import 'package:budget/pages/pastBudgetsPage.dart';
import 'package:budget/pages/premiumPage.dart';
import 'package:budget/pages/transactionFilters.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/struct/spendingSummaryHelper.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/budgetHistoryLineGraph.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/countNumber.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/editRowEntry.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/incomeExpenseTabSelector.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/outlinedButtonStacked.dart';
import 'package:budget/widgets/periodCyclePicker.dart';
import 'package:budget/widgets/radioItems.dart';
import 'package:budget/widgets/scrollbarWrap.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/selectedTransactionsAppBar.dart';
import 'package:budget/widgets/categoryEntry.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/pieChart.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/tappableTextEntry.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntries.dart';
import 'package:budget/widgets/transactionEntry/incomeAmountArrow.dart';
import 'package:budget/widgets/transactionEntry/swipeToSelectTransactions.dart';
import 'package:budget/widgets/transactionEntry/transactionEntry.dart';
import 'package:budget/widgets/transactionsAmountBox.dart';
import 'package:budget/widgets/util/keepAliveClientMixin.dart';
import 'package:budget/widgets/util/showDatePicker.dart';
import 'package:budget/widgets/util/sliverPinnedOverlapInjector.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:budget/widgets/viewAllTransactionsButton.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:provider/provider.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:async/async.dart' show StreamZip;
import 'package:sliver_tools/sliver_tools.dart';

// Also known as the all spending page

class WatchedWalletDetailsPage extends StatelessWidget {
  const WatchedWalletDetailsPage({required this.walletPk, super.key});
  final String walletPk;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TransactionWallet>(
      stream: database.getWallet(walletPk),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return WalletDetailsPage(wallet: snapshot.data);
        }
        return SizedBox.shrink();
      },
    );
  }
}

class WalletDetailsPage extends StatefulWidget {
  final TransactionWallet? wallet;
  const WalletDetailsPage({required this.wallet, Key? key}) : super(key: key);

  @override
  State<WalletDetailsPage> createState() => _WalletDetailsPageState();
}

class _WalletDetailsPageState extends State<WalletDetailsPage>
    with SingleTickerProviderStateMixin {
  TransactionCategory? selectedCategory;
  bool isIncome = false;
  late String listID = widget.wallet == null
      ? "All Spending Summary"
      : widget.wallet!.walletPk.toString() + " Wallet Summary";
  GlobalKey<PageFrameworkState> pageState = GlobalKey();
  SearchFilters? searchFilters;
  late TabController _tabController;
  late ScrollController _scrollController;
  DateTimeRange? selectedDateTimeRange;

  @override
  void initState() {
    _tabController =
        TabController(length: widget.wallet == null ? 2 : 1, vsync: this);
    _scrollController = ScrollController();
    if (widget.wallet == null) {
      allSpendingHistoryDismissedPremium = false;
      searchFilters = SearchFilters();
      searchFilters?.loadFilterString(
        appStateSettings["allSpendingSetFiltersString"],
        skipDateTimeRange: true,
        skipSearchQuery: true,
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    // PageFramework takes care of the dispose lifecycle
    // _scrollController.dispose();
    super.dispose();
  }

  void selectAllSpendingPeriod({bool onlyShowCycleOption = false}) async {
    if (widget.wallet == null) {
      await openBottomSheet(
        context,
        PopupFramework(
          title: "select-period".tr(),
          child: WalletPickerPeriodCycle(
            allWalletsSettingKey: null,
            cycleSettingsExtension: "",
            homePageWidgetDisplay: null,
            onlyShowCycleOption: onlyShowCycleOption,
          ),
        ),
      );
      setState(() {
        selectedDateTimeRange = null;
      });
      homePageStateKey.currentState?.refreshState();
    }
  }

  void selectAllSpendingFilters() async {
    if (widget.wallet == null && searchFilters != null) {
      await openBottomSheet(
        context,
        PopupFramework(
          title: "filters".tr(),
          hasPadding: false,
          child: TransactionFiltersSelection(
            setSearchFilters: setSearchFilters,
            searchFilters: searchFilters!,
            clearSearchFilters: clearSearchFilters,
          ),
        ),
      );
      Future.delayed(Duration(milliseconds: 250), () {
        updateSettings(
          "allSpendingSetFiltersString",
          searchFilters?.getFilterString(),
          updateGlobalState: false,
        );
        setState(() {});
      });
      setState(() {});
      homePageStateKey.currentState?.refreshState();
    }
  }

  void clearSearchFilters() {
    searchFilters?.clearSearchFilters();
    updateSettings("allSpendingSetFiltersString", null,
        updateGlobalState: false);
    setState(() {});
  }

  void setSearchFilters(SearchFilters searchFilters) {
    this.searchFilters = searchFilters;
  }

  DateTimeRange? getDateTimeRangeForPassedSearchFilters() {
    if (selectedDateTimeRange != null) return selectedDateTimeRange;
    if (getStartDateOfSelectedCustomPeriod("") == null) return null;
    try {
      return DateTimeRange(
        start: getStartDateOfSelectedCustomPeriod("") ?? DateTime.now(),
        end: getEndDateOfSelectedCustomPeriod("") ??
            DateTime(
              DateTime.now().year,
              DateTime.now().month + 1,
              DateTime.now().day,
            ),
      );
    } catch (e) {
      print("Date range error");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Make the information displayed follow the date range of search filters
    // Force set date time range in case its set back to null we want to override its original value
    searchFilters = searchFilters?.copyWith(
      dateTimeRange: getDateTimeRangeForPassedSearchFilters(),
      forceSetDateTimeRange: true,
    );

    ColorScheme walletColorScheme = widget.wallet == null
        ? Theme.of(context).colorScheme
        : ColorScheme.fromSeed(
            seedColor: HexColor(widget.wallet!.colour,
                defaultColor: Theme.of(context).colorScheme.primary),
            brightness: determineBrightnessTheme(context),
          );

    List<String>? walletPks =
        widget.wallet == null ? null : [widget.wallet!.walletPk];

    // if (widget.wallet == null &&
    //     appStateSettings["allSpendingAllWallets"] == false) {
    //   walletPks = [];
    //   for (TransactionWallet wallet in Provider.of<AllWallets>(context).list) {
    //     if ((wallet.homePageWidgetDisplay ?? [])
    //         .contains(HomePageWidgetDisplay.AllSpending)) {
    //       walletPks.add(wallet.walletPk);
    //     }
    //   }
    // }

    List<Widget> currentTabPage = [
      SliverToBoxAdapter(
        child: Column(
          children: [
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(bottom: 13, left: 13, right: 13),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: getHorizontalPaddingConstrained(
                  context,
                  enabled: enableDoubleColumn(context) == false &&
                      widget.wallet == null,
                )),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TransactionsAmountBox(
                        onLongPress: () {
                          selectAllSpendingPeriod();
                        },
                        label: "net-total".tr(),
                        absolute: false,
                        currencyKey: Provider.of<AllWallets>(context)
                            .indexedByPk[appStateSettings["selectedWalletPk"]]
                            ?.currency,
                        amountStream: database.watchTotalOfWallet(
                          walletPks,
                          isIncome: null,
                          allWallets: Provider.of<AllWallets>(context),
                          followCustomPeriodCycle: widget.wallet == null,
                          cycleSettingsExtension: "",
                          searchFilters: searchFilters,
                          forcedDateTimeRange: selectedDateTimeRange,
                        ),
                        textColor: getColor(context, "black"),
                        transactionsAmountStream:
                            database.watchTotalCountOfTransactionsInWallet(
                          walletPks,
                          isIncome: null,
                          followCustomPeriodCycle: widget.wallet == null,
                          cycleSettingsExtension: "",
                          searchFilters: searchFilters,
                          forcedDateTimeRange: selectedDateTimeRange,
                        ),
                        openPage: TransactionsSearchPage(
                          initialFilters: (searchFilters == null
                                  ? SearchFilters()
                                  : searchFilters)
                              ?.copyWith(
                            dateTimeRange:
                                getDateTimeRangeForPassedSearchFilters(),
                            walletPks: widget.wallet == null
                                ? null
                                : [widget.wallet?.walletPk ?? ""],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 13, left: 13, right: 13),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: getHorizontalPaddingConstrained(
                  context,
                  enabled: enableDoubleColumn(context) == false &&
                      widget.wallet == null,
                )),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TransactionsAmountBox(
                        onLongPress: () {
                          selectAllSpendingPeriod();
                        },
                        label: "expense".tr(),
                        amountStream: database.watchTotalOfWallet(
                          walletPks,
                          isIncome: false,
                          allWallets: Provider.of<AllWallets>(context),
                          followCustomPeriodCycle: widget.wallet == null,
                          cycleSettingsExtension: "",
                          searchFilters: searchFilters,
                          forcedDateTimeRange: selectedDateTimeRange,
                        ),
                        textColor: getColor(context, "expenseAmount"),
                        transactionsAmountStream:
                            database.watchTotalCountOfTransactionsInWallet(
                          walletPks,
                          isIncome: false,
                          followCustomPeriodCycle: widget.wallet == null,
                          cycleSettingsExtension: "",
                          searchFilters: searchFilters,
                          forcedDateTimeRange: selectedDateTimeRange,
                        ),
                        openPage: TransactionsSearchPage(
                          initialFilters: (searchFilters == null
                                  ? SearchFilters()
                                  : searchFilters)
                              ?.copyWith(
                            dateTimeRange:
                                getDateTimeRangeForPassedSearchFilters(),
                            walletPks: widget.wallet == null
                                ? null
                                : [widget.wallet?.walletPk ?? ""],
                            expenseIncome: [ExpenseIncome.expense],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 13),
                    Expanded(
                      child: TransactionsAmountBox(
                        onLongPress: () {
                          selectAllSpendingPeriod();
                        },
                        label: "income".tr(),
                        amountStream: database.watchTotalOfWallet(
                          walletPks,
                          isIncome: true,
                          allWallets: Provider.of<AllWallets>(context),
                          followCustomPeriodCycle: widget.wallet == null,
                          cycleSettingsExtension: "",
                          searchFilters: searchFilters,
                          forcedDateTimeRange: selectedDateTimeRange,
                        ),
                        textColor: getColor(context, "incomeAmount"),
                        transactionsAmountStream:
                            database.watchTotalCountOfTransactionsInWallet(
                          walletPks,
                          isIncome: true,
                          followCustomPeriodCycle: widget.wallet == null,
                          cycleSettingsExtension: "",
                          searchFilters: searchFilters,
                          forcedDateTimeRange: selectedDateTimeRange,
                        ),
                        openPage: TransactionsSearchPage(
                          initialFilters: (searchFilters == null
                                  ? SearchFilters()
                                  : searchFilters)
                              ?.copyWith(
                            dateTimeRange:
                                getDateTimeRangeForPassedSearchFilters(),
                            walletPks: widget.wallet == null
                                ? null
                                : [widget.wallet?.walletPk ?? ""],
                            expenseIncome: [ExpenseIncome.income],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            WalletDetailsLineGraph(
              walletPks: walletPks,
              followCustomPeriodCycle: widget.wallet == null,
              cycleSettingsExtension: "",
              searchFilters: searchFilters,
              selectedDateTimeRange: selectedDateTimeRange,
            ),
            WalletCategoryPieChart(
              cycleSettingsExtension: "",
              selectedDateTimeRange: selectedDateTimeRange,
              searchFilters: searchFilters,
              isAllSpending: widget.wallet == null,
              walletPks: walletPks,
              walletColorScheme: walletColorScheme,
              onSelectedCategory: (TransactionCategory? category) {
                // pageState.currentState?.scrollTo(500);
                setState(() {
                  selectedCategory = category;
                });
              },
              onSelectedIncome: (bool isIncome) {
                setState(() {
                  this.isIncome = isIncome;
                });
              },
            ),
          ],
        ),
      ),
      if (selectedCategory != null)
        TransactionEntries(
          // If the wallet is null, then we show use the spending time period
          widget.wallet == null
              ? getStartDateOfSelectedCustomPeriod("",
                  forcedDateTimeRange: selectedDateTimeRange)
              : null,
          widget.wallet == null
              ? getEndDateOfSelectedCustomPeriod("",
                  forcedDateTimeRange: selectedDateTimeRange)
              : null,
          categoryFks:
              selectedCategory != null ? [selectedCategory!.categoryPk] : [],
          walletFks: walletPks ?? [],
          limit: selectedCategory == null ? 0 : 10,
          listID: listID,
          showNoResults: false,
          income: isIncome,
          searchFilters: searchFilters,
          useHorizontalPaddingConstrained:
              enableDoubleColumn(context) == false && widget.wallet == null,
        ),
      // Animates the size when a category is deselected
      if (selectedCategory == null) SliverToBoxAdapter(child: SizeOut()),
      SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ViewAllTransactionsButton(
              onPress: () {
                pushRoute(
                  context,
                  TransactionsSearchPage(
                    initialFilters: (searchFilters == null
                            ? SearchFilters()
                            : searchFilters)
                        ?.copyWith(
                      dateTimeRange: getDateTimeRangeForPassedSearchFilters(),
                      walletPks: widget.wallet == null
                          ? null
                          : [widget.wallet?.walletPk ?? ""],
                      categoryPks: selectedCategory?.mainCategoryPk != null
                          ? [selectedCategory!.mainCategoryPk ?? ""]
                          : selectedCategory == null
                              ? null
                              : [selectedCategory!.categoryPk],
                      subcategoryPks: selectedCategory != null &&
                              selectedCategory?.mainCategoryPk != null
                          ? [selectedCategory!.categoryPk]
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(child: SizedBox(height: 40)),
    ];

    List<Widget> historyTabPage = [
      AllSpendingPastSpendingGraph(
        searchFilters: searchFilters,
        onEntryTapped: (DateTimeRange tappedRange) {
          setState(() {
            selectedDateTimeRange = tappedRange;
          });
          Future.delayed(Duration(milliseconds: 100), () {
            _tabController.animateTo(0);
          });
        },
        selectedDateTimeRange: selectedDateTimeRange,
      )
    ];

    Widget selectedTabCurrent = SelectedPeriodHeaderLabel(
      color: Theme.of(context).colorScheme.secondaryContainer,
      textColor: Theme.of(context).colorScheme.onSecondaryContainer,
      text: getLabelOfSelectedCustomPeriod(""),
      onTap: () {
        selectAllSpendingPeriod();
      },
      iconData: appStateSettings["outlinedIcons"]
          ? Icons.timelapse_outlined
          : Icons.timelapse_rounded,
    );

    Widget selectedTabHistory = Builder(builder: (context) {
      String selectedRecurrenceDisplay = "";
      Budget tempBudget = getCustomCycleTempBudget("");
      if (tempBudget.periodLength == 1) {
        selectedRecurrenceDisplay = tempBudget.periodLength.toString() +
            " " +
            nameRecurrence[tempBudget.reoccurrence];
      } else {
        selectedRecurrenceDisplay = tempBudget.periodLength.toString() +
            " " +
            namesRecurrence[tempBudget.reoccurrence];
      }
      return SelectedPeriodHeaderLabel(
        color: Theme.of(context).colorScheme.secondaryContainer,
        textColor: Theme.of(context).colorScheme.onSecondaryContainer,
        text: selectedRecurrenceDisplay,
        onTap: () {
          selectAllSpendingPeriod(onlyShowCycleOption: true);
        },
        iconData: appStateSettings["outlinedIcons"]
            ? Icons.restart_alt_outlined
            : Icons.restart_alt_rounded,
      );
    });

    Widget Function(VoidCallback onTap) selectedTabPeriodSelected =
        (VoidCallback onTap) => AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: selectedDateTimeRange == null
                  ? Container(
                      key: ValueKey(selectedDateTimeRange),
                    )
                  : SelectedPeriodHeaderLabel(
                      key: ValueKey(selectedDateTimeRange),
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                      textColor:
                          Theme.of(context).colorScheme.onTertiaryContainer,
                      text: selectedDateTimeRange != null
                          ? getWordedDateShort(selectedDateTimeRange!.start) +
                              " – " +
                              getWordedDateShort(selectedDateTimeRange!.end)
                          : getLabelOfSelectedCustomPeriod(""),
                      onTap: onTap,
                      iconData: appStateSettings["outlinedIcons"]
                          ? Icons.timelapse_outlined
                          : Icons.timelapse_rounded,
                    ),
            );

    Widget clearSelectedPeriodButton = AnimatedSizeSwitcher(
      child: selectedDateTimeRange == null
          ? Container(
              key: ValueKey(1),
            )
          : Padding(
              padding: const EdgeInsets.only(left: 7),
              child: ButtonIcon(
                key: ValueKey(2),
                onTap: () {
                  setState(() {
                    selectedDateTimeRange = null;
                  });
                },
                icon: Icons.close_rounded,
              ),
            ),
    );

    Widget selectFiltersButton = AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.only(left: 7),
        child: ButtonIcon(
          key: ValueKey(
            searchFilters?.isClear(ignoreDateTimeRange: true),
          ),
          color: searchFilters?.isClear(ignoreDateTimeRange: true) == true
              ? null
              : Theme.of(context).colorScheme.tertiaryContainer,
          iconColor: searchFilters?.isClear(ignoreDateTimeRange: true) == true
              ? null
              : Theme.of(context).colorScheme.onTertiaryContainer,
          onTap: () {
            selectAllSpendingFilters();
          },
          icon: appStateSettings["outlinedIcons"]
              ? Icons.filter_alt_outlined
              : Icons.filter_alt_rounded,
        ),
      ),
    );

    Widget tabDateFilterSelectorHeader = Padding(
      padding: EdgeInsets.symmetric(
          horizontal: getHorizontalPaddingConstrained(
                context,
                enabled: enableDoubleColumn(context) == false &&
                    widget.wallet == null,
              ) +
              13),
      child: IncomeExpenseTabSelector(
        onTabChanged: (_) {},
        initialTabIsIncome: false,
        showIcons: false,
        tabController: _tabController,
        expenseLabel: "current".tr(),
        incomeLabel: "history".tr(),
        expenseCustomIcon: Icon(
          appStateSettings["outlinedIcons"]
              ? Icons.event_note_outlined
              : Icons.event_note_rounded,
        ),
        incomeCustomIcon: Icon(
          appStateSettings["outlinedIcons"]
              ? Icons.history_outlined
              : Icons.history_rounded,
        ),
        belowWidgetBuilder: (bool selectedHistoryTab) {
          return Padding(
            padding: EdgeInsets.only(top: 10),
            child: Row(
              children: [
                // Expanded(
                //   child: AnimatedSwitcher(
                //     duration: Duration(milliseconds: 500),
                //     child: OutlinedButtonStacked(
                //       key: ValueKey(getLabelOfSelectedCustomPeriod("")),
                //       fontSize: 18.5,
                //       borderRadius: 10,
                //       padding: EdgeInsets.symmetric(
                //           horizontal: 10, vertical: 5),
                //       text: getLabelOfSelectedCustomPeriod(""),
                //       iconData: appStateSettings["outlinedIcons"]
                //           ? Icons.timelapse_outlined
                //           : Icons.timelapse_rounded,
                //       onTap: () {
                //         selectAllSpendingPeriod();
                //       },
                //       alignBeside: true,
                //     ),
                //   ),
                // ),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _tabController.animation!,
                    builder: (BuildContext context, Widget? child) {
                      double animationProgress =
                          _tabController.animation!.value;
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(
                            getPlatform() == PlatformOS.isIOS ? 10 : 15),
                        child: Stack(
                          children: [
                            IgnorePointer(
                              ignoring: animationProgress > 0.5,
                              child: Transform.translate(
                                offset: Offset(-animationProgress * 100, 0),
                                child: Opacity(
                                  opacity: 1 - animationProgress,
                                  child: selectedTabCurrent,
                                ),
                              ),
                            ),
                            IgnorePointer(
                              ignoring: animationProgress < 0.5,
                              child: Transform.translate(
                                offset:
                                    Offset((1 - animationProgress) * 100, 0),
                                child: Opacity(
                                  opacity: animationProgress,
                                  child: selectedTabHistory,
                                ),
                              ),
                            ),
                            selectedTabPeriodSelected(() {
                              if (animationProgress > 0.5) {
                                selectAllSpendingPeriod(
                                    onlyShowCycleOption: true);
                              } else {
                                selectAllSpendingPeriod(
                                    onlyShowCycleOption: false);
                              }
                            }),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                clearSelectedPeriodButton,
                selectFiltersButton,
              ],
            ),
          );
        },
      ),
    );

    Widget appliedFilterChipsWidget =
        searchFilters != null && widget.wallet == null
            ? Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: getHorizontalPaddingConstrained(
                    context,
                    enabled: enableDoubleColumn(context) == false &&
                        widget.wallet == null,
                  ),
                ),
                child: AppliedFilterChips(
                  padding: EdgeInsets.only(top: 10),
                  searchFilters: searchFilters!,
                  openFiltersSelection: () {
                    selectAllSpendingFilters();
                  },
                  clearSearchFilters: clearSearchFilters,
                ),
              )
            : SizedBox.shrink();

    return WillPopScope(
      onWillPop: () async {
        if ((globalSelectedID.value[listID] ?? []).length > 0) {
          globalSelectedID.value[listID] = [];
          globalSelectedID.notifyListeners();
          return false;
        } else {
          return true;
        }
      },
      child: Stack(
        children: [
          PageFramework(
            scrollController: _scrollController,
            key: pageState,
            listID: listID,
            floatingActionButton: AnimateFABDelayed(
              fab: FAB(
                tooltip: "add-transaction".tr(),
                openPage: AddTransactionPage(
                  routesToPopAfterDelete: RoutesToPopAfterDelete.One,
                ),
              ),
            ),
            title: widget.wallet == null
                ? "all-spending".tr()
                : widget.wallet!.name,
            actions: [
              if (widget.wallet != null)
                CustomPopupMenuButton(
                  showButtons: enableDoubleColumn(context),
                  keepOutFirst: true,
                  items: [
                    DropdownItemMenu(
                      id: "edit-account",
                      label: "edit-account".tr(),
                      icon: appStateSettings["outlinedIcons"]
                          ? Icons.edit_outlined
                          : Icons.edit_rounded,
                      action: () {
                        pushRoute(
                          context,
                          AddWalletPage(
                            wallet: widget.wallet,
                            routesToPopAfterDelete: RoutesToPopAfterDelete.All,
                          ),
                        );
                      },
                    ),
                    DropdownItemMenu(
                      id: "correct-total-balance",
                      label: "correct-total-balance".tr(),
                      icon: appStateSettings["outlinedIcons"]
                          ? Icons.library_add_outlined
                          : Icons.library_add_rounded,
                      action: () {
                        openBottomSheet(
                          context,
                          fullSnap: true,
                          CorrectBalancePopup(wallet: widget.wallet!),
                        );
                      },
                    ),
                    DropdownItemMenu(
                      id: "transfer-balance",
                      label: "transfer-balance".tr(),
                      icon: appStateSettings["outlinedIcons"]
                          ? Icons.compare_arrows_outlined
                          : Icons.compare_arrows_rounded,
                      action: () {
                        openBottomSheet(
                          context,
                          fullSnap: true,
                          TransferBalancePopup(
                              wallet: widget.wallet!, allowEditWallet: false),
                        );
                      },
                    ),
                    DropdownItemMenu(
                      id: "decimal-precision",
                      label: "decimal-precision".tr(),
                      icon: appStateSettings["outlinedIcons"]
                          ? Icons.more_horiz_outlined
                          : Icons.more_horiz_rounded,
                      action: () {
                        openBottomSheet(
                          context,
                          PopupFramework(
                            title: "decimal-precision".tr(),
                            child: SelectAmountValue(
                              amountPassed: widget.wallet!.decimals.toString(),
                              setSelectedAmount: (amount, _) async {
                                int selectedDecimals = amount.toInt();
                                if (amount > 10) {
                                  selectedDecimals = 10;
                                } else if (amount < 0) {
                                  selectedDecimals = 0;
                                }
                                TransactionWallet wallet = await database
                                    .getWalletInstance(widget.wallet!.walletPk);
                                await database.createOrUpdateWallet(wallet
                                    .copyWith(decimals: selectedDecimals));
                              },
                              next: () async {
                                Navigator.pop(context);
                              },
                              nextLabel: "set-amount".tr(),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              // if (widget.wallet == null)
              //   CustomPopupMenuButton(
              //     showButtons: true,
              //     keepOutFirst: true,
              //     items: [
              //       DropdownItemMenu(
              //         id: "select-period",
              //         label: "select-period-tooltip".tr(),
              //         icon: appStateSettings["outlinedIcons"]
              //             ? Icons.timelapse_outlined
              //             : Icons.timelapse_rounded,
              //         action: () async {
              //           selectAllSpendingPeriod();
              //         },
              //       ),
              //       DropdownItemMenu(
              //         id: "filters",
              //         label: "filters".tr(),
              //         icon: appStateSettings["outlinedIcons"]
              //             ? Icons.filter_alt_outlined
              //             : Icons.filter_alt_rounded,
              //         action: () async {
              //           selectAllSpendingFilters();
              //         },
              //         selected: searchFilters?.isClear() == false,
              //       ),
              //     ],
              //   ),
            ],
            dragDownToDismiss: true,
            bodyBuilder: (scrollController, scrollPhysics, sliverAppBar) {
              if (widget.wallet == null && enableDoubleColumn(context)) {
                double heightOfBanner = 56;
                double topPaddingOfBanner =
                    MediaQuery.viewPaddingOf(context).top;
                double totalHeaderHeight = heightOfBanner + topPaddingOfBanner;
                return Column(
                  children: [
                    Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                height: totalHeaderHeight,
                                padding:
                                    EdgeInsets.only(top: topPaddingOfBanner),
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                child: Center(
                                  child: TextFont(
                                    text: "all-spending".tr(),
                                    textColor: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          top: topPaddingOfBanner,
                          right: 10,
                          child: selectFiltersButton,
                        ),
                      ],
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 1800),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: MediaQuery.sizeOf(context).height -
                                  totalHeaderHeight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Flexible(
                                    child: ConstrainedBox(
                                      constraints:
                                          BoxConstraints(maxWidth: 700),
                                      child: SwipeToSelectTransactions(
                                        listID: listID,
                                        child: ScrollbarWrap(
                                          child: CustomScrollView(
                                            controller: _scrollController,
                                            slivers: [
                                              SliverToBoxAdapter(
                                                  child: SizedBox(height: 20)),
                                              SliverToBoxAdapter(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 13),
                                                  child: Stack(
                                                    children: [
                                                      selectedTabCurrent,
                                                      selectedTabPeriodSelected(
                                                        () {
                                                          selectAllSpendingPeriod(
                                                              onlyShowCycleOption:
                                                                  false);
                                                        },
                                                      ),
                                                      Positioned(
                                                        right: 0,
                                                        child:
                                                            clearSelectedPeriodButton,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SliverToBoxAdapter(
                                                child: appliedFilterChipsWidget,
                                              ),
                                              ...currentTabPage,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: ConstrainedBox(
                                      constraints:
                                          BoxConstraints(maxWidth: 700),
                                      child: SwipeToSelectTransactions(
                                        listID: listID,
                                        child: ScrollbarWrap(
                                          child: CustomScrollView(
                                            slivers: [
                                              SliverToBoxAdapter(
                                                  child: SizedBox(height: 20)),
                                              SliverToBoxAdapter(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 13),
                                                  child: selectedTabHistory,
                                                ),
                                              ),
                                              ...historyTabPage,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder:
                    (BuildContext contextHeader, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverOverlapAbsorber(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                          contextHeader),
                      sliver: MultiSliver(
                        children: [
                          sliverAppBar,
                          if (widget.wallet == null)
                            SliverToBoxAdapter(
                                child: tabDateFilterSelectorHeader),
                          if (searchFilters != null && widget.wallet == null)
                            SliverToBoxAdapter(child: appliedFilterChipsWidget),
                        ],
                      ),
                    ),
                  ];
                },
                body: Builder(
                  builder: (contextPageView) {
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        SwipeToSelectTransactions(
                          listID: listID,
                          child: ScrollbarWrap(
                            child: CustomScrollView(
                              slivers: [
                                SliverPinnedOverlapInjector(
                                  handle: NestedScrollView
                                      .sliverOverlapAbsorberHandleFor(
                                          contextPageView),
                                ),
                                ...currentTabPage,
                              ],
                            ),
                          ),
                        ),
                        if (widget.wallet == null)
                          SwipeToSelectTransactions(
                            listID: listID,
                            child: ScrollbarWrap(
                              child: CustomScrollView(
                                slivers: [
                                  SliverPinnedOverlapInjector(
                                    handle: NestedScrollView
                                        .sliverOverlapAbsorberHandleFor(
                                            contextPageView),
                                  ),
                                  ...historyTabPage,
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
          SelectedTransactionsAppBar(
            pageID: listID,
          ),
        ],
      ),
    );
  }
}

class SizeOut extends StatefulWidget {
  const SizeOut({super.key});

  @override
  State<SizeOut> createState() => _SizeOutState();
}

class _SizeOutState extends State<SizeOut> {
  bool expanded = true;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        expanded = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: Duration(milliseconds: 700),
      curve: Curves.easeInOutCubicEmphasized,
      child: Container(
        height: expanded ? 1000 : 0,
      ),
    );
  }
}

class WalletCategoryPieChart extends StatefulWidget {
  const WalletCategoryPieChart({
    required this.walletPks,
    required this.walletColorScheme,
    required this.onSelectedCategory,
    required this.onSelectedIncome,
    required this.cycleSettingsExtension,
    required this.isAllSpending,
    this.searchFilters,
    this.selectedDateTimeRange,
    super.key,
  });

  final List<String>? walletPks;
  final ColorScheme walletColorScheme;
  final Function(TransactionCategory?) onSelectedCategory;
  final Function(bool) onSelectedIncome;
  final String cycleSettingsExtension;
  final bool isAllSpending;
  final SearchFilters? searchFilters;
  final DateTimeRange? selectedDateTimeRange;

  @override
  State<WalletCategoryPieChart> createState() => _WalletCategoryPieChartState();
}

class _WalletCategoryPieChartState extends State<WalletCategoryPieChart> {
  TransactionCategory? selectedCategory = null;
  bool isIncome = false;
  GlobalKey<PieChartDisplayState> _pieChartDisplayStateKey = GlobalKey();
  bool showAllSubcategories = appStateSettings["showAllSubcategories"];

  void toggleAllSubcategories() {
    setState(() {
      showAllSubcategories = !showAllSubcategories;
    });
    Future.delayed(Duration(milliseconds: 10), () {
      _pieChartDisplayStateKey.currentState!
          .setTouchedCategoryPk(selectedCategory?.categoryPk);
    });

    updateSettings("showAllSubcategories", showAllSubcategories,
        updateGlobalState: false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: getHorizontalPaddingConstrained(
            context,
            enabled: enableDoubleColumn(context) == false,
          )),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: boxShadowCheck(boxShadowGeneral(context)),
              ),
              child: ClipRRect(
                borderRadius: getPlatform() == PlatformOS.isIOS
                    ? BorderRadius.circular(10)
                    : BorderRadius.circular(15),
                child: IncomeExpenseTabSelector(
                  onTabChanged: (income) {
                    setState(() {
                      isIncome = income;
                      selectedCategory = null;
                    });
                    _pieChartDisplayStateKey.currentState?.setTouchedIndex(-1);
                    widget.onSelectedIncome(income);
                    widget.onSelectedCategory(selectedCategory);
                  },
                  initialTabIsIncome: false,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        StreamBuilder<List<CategoryWithTotal>>(
          stream:
              database.watchTotalSpentInEachCategoryInTimeRangeFromCategories(
            allWallets: Provider.of<AllWallets>(context),
            start: DateTime.now(),
            end: DateTime.now(),
            categoryFks: null,
            categoryFksExclude: null,
            budgetTransactionFilters: null,
            memberTransactionFilters: null,
            allTime: true,
            walletPks: widget.walletPks,
            isIncome: isIncome,
            followCustomPeriodCycle: widget.isAllSpending,
            cycleSettingsExtension: widget.cycleSettingsExtension,
            forcedDateTimeRange: widget.selectedDateTimeRange,
            countUnassignedTransactions: true,
            includeAllSubCategories: true,
            searchFilters: widget.searchFilters,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              TotalSpentCategoriesSummary s = watchTotalSpentInTimeRangeHelper(
                  dataInput: snapshot.data ?? [],
                  showAllSubcategories: showAllSubcategories);
              List<Widget> categoryEntries = [];
              snapshot.data!.asMap().forEach((index, category) {
                categoryEntries.add(
                  CategoryEntry(
                    useHorizontalPaddingConstrained:
                        enableDoubleColumn(context) == false &&
                            widget.isAllSpending,
                    selectedSubCategoryPk: selectedCategory?.categoryPk,
                    expandSubcategories: showAllSubcategories ||
                        category.category.categoryPk ==
                            selectedCategory?.categoryPk ||
                        category.category.categoryPk ==
                            selectedCategory?.mainCategoryPk,
                    subcategoriesWithTotalMap:
                        s.subCategorySpendingIndexedByMainCategoryPk,
                    extraText: isIncome ? "of-income".tr() : "of-expense".tr(),
                    budgetColorScheme: widget.walletColorScheme,
                    category: category.category,
                    totalSpent: s.totalSpent,
                    transactionCount: category.transactionCount,
                    categorySpent: category.total,
                    onTap: (TransactionCategory tappedCategory, _) {
                      if (selectedCategory?.categoryPk ==
                          tappedCategory.categoryPk) {
                        setState(() {
                          selectedCategory = null;
                        });
                        _pieChartDisplayStateKey.currentState!
                            .setTouchedIndex(-1);
                      } else {
                        if (showAllSubcategories ||
                            tappedCategory.mainCategoryPk == null) {
                          setState(() {
                            selectedCategory = tappedCategory;
                          });
                          _pieChartDisplayStateKey.currentState!
                              .setTouchedCategoryPk(tappedCategory.categoryPk);
                        } else {
                          // We are tapping a subcategoryEntry and it is not in the pie chart
                          // because showAllSubcategories is false and mainCategoryPk is not null
                          setState(() {
                            selectedCategory = tappedCategory;
                          });
                          _pieChartDisplayStateKey.currentState!
                              .setTouchedCategoryPk(
                                  tappedCategory.mainCategoryPk);
                        }
                      }
                      widget.onSelectedCategory(selectedCategory);
                    },
                    selected: category.category.categoryPk ==
                            selectedCategory?.mainCategoryPk ||
                        selectedCategory?.categoryPk ==
                            category.category.categoryPk,
                    allSelected: selectedCategory == null,
                    showIncomeExpenseIcons: true,
                  ),
                );
              });
              return Column(
                children: [
                  SizedBox(height: 30),
                  PieChartWrapper(
                    isPastBudget: true,
                    pieChartDisplayStateKey: _pieChartDisplayStateKey,
                    data: s.dataFilterUnassignedTransactions,
                    totalSpent: s.totalSpent,
                    setSelectedCategory: (categoryPk, category) async {
                      setState(() {
                        selectedCategory = category;
                      });
                      widget.onSelectedCategory(selectedCategory);
                    },
                  ),
                  PieChartOptions(
                    hasSubCategories: s.hasSubCategories,
                    selectedCategory: selectedCategory,
                    onClearSelection: () {
                      setState(() {
                        selectedCategory = null;
                      });
                      _pieChartDisplayStateKey.currentState!
                          .setTouchedIndex(-1);
                      widget.onSelectedCategory(selectedCategory);
                    },
                    onEditSpendingGoals: null,
                    toggleAllSubCategories: toggleAllSubcategories,
                    colorScheme: Theme.of(context).colorScheme,
                    showAllSubcategories: showAllSubcategories,
                    useHorizontalPaddingConstrained:
                        enableDoubleColumn(context) == false &&
                            widget.isAllSpending == true,
                  ),
                  ...categoryEntries,
                  SizedBox(height: 10),
                ],
              );
            }
            return SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

class WalletDetailsLineGraph extends StatefulWidget {
  const WalletDetailsLineGraph({
    super.key,
    required this.walletPks,
    required this.followCustomPeriodCycle,
    required this.cycleSettingsExtension,
    this.searchFilters,
    this.selectedDateTimeRange,
  });
  final List<String>? walletPks;
  final bool followCustomPeriodCycle;
  final String cycleSettingsExtension;
  final SearchFilters? searchFilters;
  final DateTimeRange? selectedDateTimeRange;

  @override
  State<WalletDetailsLineGraph> createState() => _WalletDetailsLineGraphState();
}

class _WalletDetailsLineGraphState extends State<WalletDetailsLineGraph> {
  int numberMonthsToLoad = 1;

  @override
  Widget build(BuildContext context) {
    DateTime? customPeriodStartDate = getStartDateOfSelectedCustomPeriod("",
        forcedDateTimeRange: widget.selectedDateTimeRange);
    DateTime? customPeriodEndDate = getEndDateOfSelectedCustomPeriod("",
        forcedDateTimeRange: widget.selectedDateTimeRange);
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          color: getColor(context, "lightDarkAccentHeavyLight"),
          boxShadow: boxShadowCheck(boxShadowGeneral(context)),
        ),
        child: Stack(
          children: [
            if (widget.followCustomPeriodCycle == false ||
                customPeriodStartDate == null)
              Positioned(
                right: 0,
                top: 0,
                child: Transform.translate(
                  offset: Offset(5, -5),
                  child: IconButton(
                    icon: Icon(
                      appStateSettings["outlinedIcons"]
                          ? Icons.history_outlined
                          : Icons.history_rounded,
                      size: 22,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.8),
                    ),
                    onPressed: () {
                      setState(() {
                        numberMonthsToLoad++;
                      });
                    },
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(left: 7, right: 7, bottom: 12, top: 18),
              child: PastSpendingGraph(
                isIncome: null,
                walletPks: widget.walletPks,
                monthsToLoad: numberMonthsToLoad,
                followCustomPeriodCycle: widget.followCustomPeriodCycle,
                cycleSettingsExtension: widget.cycleSettingsExtension,
                forcedDateTimeRange: widget.selectedDateTimeRange,
                customStartDate: widget.followCustomPeriodCycle == true
                    ? customPeriodStartDate
                    : null,
                customEndDate: widget.followCustomPeriodCycle == true
                    ? customPeriodEndDate
                    : null,
                searchFilters: widget.searchFilters,
                // extraLeftPaddingIfSmall:
                //     10, //we want this because the corner has the load more dates button
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool allSpendingHistoryDismissedPremium = false;

class AllSpendingPastSpendingGraph extends StatefulWidget {
  const AllSpendingPastSpendingGraph(
      {required this.searchFilters,
      required this.onEntryTapped,
      required this.selectedDateTimeRange,
      super.key});
  final SearchFilters? searchFilters;
  final Function(DateTimeRange) onEntryTapped;
  final DateTimeRange? selectedDateTimeRange;

  @override
  State<AllSpendingPastSpendingGraph> createState() =>
      _AllSpendingPastSpendingGraphState();
}

class _AllSpendingPastSpendingGraphState
    extends State<AllSpendingPastSpendingGraph> {
  Stream<List<double?>>? mergedStreamsIncome;
  Stream<List<double?>>? mergedStreamsExpense;
  List<DateTimeRange> dateTimeRanges = [];
  int amountLoaded = 8;
  bool amountLoadedPressedOnce = false;

  initState() {
    Future.delayed(Duration.zero, () async {
      loadLines(amountLoaded);
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AllSpendingPastSpendingGraph oldWidget) {
    loadLines(amountLoaded);
    super.didUpdateWidget(oldWidget);
  }

  void loadLines(amountLoaded) async {
    dateTimeRanges = [];
    List<Stream<double?>> watchedStreamsIncome = [];
    List<Stream<double?>> watchedStreamsExpense = [];
    for (int index = 0; index < amountLoaded; index++) {
      DateTime datePast = getCycleDatePastToDetermineBudgetDate("", index);
      DateTimeRange budgetRange =
          getCycleDateTimeRange("", currentDate: datePast);
      dateTimeRanges.add(budgetRange);
      watchedStreamsIncome.add(
        database.watchTotalOfWallet(
          null,
          isIncome: true,
          allWallets: Provider.of<AllWallets>(context, listen: false),
          followCustomPeriodCycle: false,
          cycleSettingsExtension: "",
          searchFilters:
              widget.searchFilters?.copyWith(dateTimeRange: budgetRange),
        ),
      );
      watchedStreamsExpense.add(
        database.watchTotalOfWallet(
          null,
          isIncome: false,
          allWallets: Provider.of<AllWallets>(context, listen: false),
          followCustomPeriodCycle: false,
          cycleSettingsExtension: "",
          searchFilters:
              widget.searchFilters?.copyWith(dateTimeRange: budgetRange),
        ),
      );
    }

    setState(() {
      mergedStreamsIncome = StreamZip(watchedStreamsIncome);
      mergedStreamsExpense = StreamZip(watchedStreamsExpense);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<double?>>(
      stream: mergedStreamsIncome,
      builder: (context, snapshotIncome) {
        List<double?> incomeData = snapshotIncome.data ?? [];
        return StreamBuilder<List<double?>>(
          stream: mergedStreamsExpense,
          builder: (context, snapshotExpense) {
            List<double?> expenseData = snapshotExpense.data ?? [];
            if (expenseData.length <= 0 && incomeData.length <= 0)
              return SliverToBoxAdapter(
                child: SizedBox.shrink(),
              );
            double maxY = 0.1;
            double minY = -0.00000000000001;
            List<List<FlSpot>> allSpots = [];

            List<FlSpot> spots = [];
            if (expenseData.toSet().length > 1) {
              for (int i = expenseData.length - 1; i >= 0; i--) {
                if ((expenseData[i] ?? 0).abs() > maxY) {
                  maxY = (expenseData[i] ?? 0).abs();
                }
                spots.add(FlSpot(
                  expenseData.length - 1 - i.toDouble(),
                  (expenseData[i] ?? 0).abs() == 0
                      ? 0.00000000001
                      : (expenseData[i] ?? 0).abs(),
                ));
              }
              allSpots.add(spots);
            }

            // Only add income points if there is an income data point!
            if (incomeData.toSet().length > 1) {
              spots = [];
              for (int i = incomeData.length - 1; i >= 0; i--) {
                if ((incomeData[i] ?? 0).abs() > maxY) {
                  maxY = (incomeData[i] ?? 0).abs();
                }
                spots.add(FlSpot(
                  incomeData.length - 1 - i.toDouble(),
                  (incomeData[i] ?? 0).abs() == 0
                      ? 0.00000000001
                      : (incomeData[i] ?? 0).abs(),
                ));
              }
              allSpots.add(spots);
            }

            return SliverStickyHeader(
              header: Transform.translate(
                offset: Offset(0, -1),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      color: Theme.of(context).canvasColor,
                      child: FadeOutAndLockFeature(
                        hasInitiallyDismissed:
                            allSpendingHistoryDismissedPremium,
                        actionAfter: () {
                          allSpendingHistoryDismissedPremium = true;
                        },
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 7, horizontal: 0),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: BudgetHistoryLineGraph(
                                  showDateOnHover: true,
                                  onTouchedIndex: (index) {},
                                  color: dynamicPastel(
                                    context,
                                    Theme.of(context).colorScheme.primary,
                                    amountLight: 0.4,
                                    amountDark: 0.2,
                                  ),
                                  dateRanges: dateTimeRanges,
                                  maxY: maxY,
                                  minY: minY,
                                  lineColors: allSpots.length > 1
                                      ? [
                                          getColor(context, "expenseAmount"),
                                          getColor(context, "incomeAmount"),
                                        ]
                                      : null,
                                  spots: allSpots,
                                  horizontalLineAt: null,
                                  budget: getCustomCycleTempBudget(""),
                                  extraCategorySpots: {},
                                  categoriesMapped: {},
                                  loadAllEvenIfZero: amountLoadedPressedOnce,
                                  setNoPastRegionsAreZero: (bool value) {
                                    amountLoadedPressedOnce = true;
                                  },
                                ),
                              ),
                            ),
                            LoadMorePeriodsButton(
                              color: Theme.of(context).colorScheme.primary,
                              onPressed: () {
                                if (amountLoadedPressedOnce == false) {
                                  setState(() {
                                    amountLoadedPressedOnce = true;
                                  });
                                } else {
                                  int amountMoreToLoad =
                                      getIsFullScreen(context) == false ? 3 : 5;
                                  loadLines(amountLoaded + amountMoreToLoad);
                                  setState(() {
                                    amountLoaded =
                                        amountLoaded + amountMoreToLoad;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(0, -1),
                      child: Container(
                        height: 12,
                        foregroundDecoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).canvasColor,
                              Theme.of(context).canvasColor.withOpacity(0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.1, 1],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              sliver: MultiSliver(
                children: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        DateTime datePast = getDatePastToDetermineBudgetDate(
                            index, getCustomCycleTempBudget(""));
                        DateTimeRange budgetRange =
                            getCycleDateTimeRange("", currentDate: datePast);
                        Color containerColor = getPlatform() == PlatformOS.isIOS
                            ? widget.selectedDateTimeRange == budgetRange
                                ? Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer
                                    .withOpacity(0.3)
                                : Colors.transparent
                            : getStandardContainerColor(context);
                        double netSpending =
                            (nullIfIndexOutOfRange(incomeData, index) ?? 0)
                                    .toDouble()
                                    .abs() +
                                (nullIfIndexOutOfRange(expenseData, index) ?? 0)
                                        .toDouble()
                                        .abs() *
                                    -1;
                        double expenseSpending =
                            nullIfIndexOutOfRange(expenseData, index) ?? 0;
                        double incomeSpending =
                            nullIfIndexOutOfRange(incomeData, index) ?? 0;
                        return FadeIn(
                          duration: Duration(milliseconds: 400),
                          child: Container(
                            decoration: BoxDecoration(
                              border: getPlatform() == PlatformOS.isIOS
                                  ? Border(
                                      top: BorderSide(
                                        color:
                                            getColor(context, "dividerColor"),
                                        width: index == 0 ? 2 : 0,
                                      ),
                                      bottom: BorderSide(
                                        color:
                                            getColor(context, "dividerColor"),
                                        width: 2,
                                      ),
                                    )
                                  : null,
                              boxShadow: getPlatform() == PlatformOS.isIOS ||
                                      appStateSettings["materialYou"]
                                  ? []
                                  : boxShadowCheck(boxShadowGeneral(context)),
                            ),
                            margin: getPlatform() == PlatformOS.isIOS
                                ? EdgeInsets.zero
                                : EdgeInsets.only(
                                    left: getHorizontalPaddingConstrained(
                                          context,
                                          enabled:
                                              enableDoubleColumn(context) ==
                                                  false,
                                        ) +
                                        13,
                                    right: getHorizontalPaddingConstrained(
                                          context,
                                          enabled:
                                              enableDoubleColumn(context) ==
                                                  false,
                                        ) +
                                        13,
                                    bottom: 10,
                                  ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  getPlatform() == PlatformOS.isIOS ? 0 : 20),
                              child: Stack(
                                children: [
                                  Tappable(
                                    color: containerColor,
                                    onTap: () {
                                      widget.onEntryTapped(budgetRange);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: (getPlatform() ==
                                                      PlatformOS.isIOS
                                                  ? getHorizontalPaddingConstrained(
                                                      context,
                                                      enabled:
                                                          enableDoubleColumn(
                                                                  context) ==
                                                              false,
                                                    )
                                                  : 0) +
                                              30,
                                          vertical: 15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Flexible(
                                                      child: TextFont(
                                                        text: getPercentBetweenDates(
                                                                    budgetRange,
                                                                    DateTime
                                                                        .now()) <=
                                                                100
                                                            ? "current-budget-period"
                                                                .tr()
                                                            : getWordedDateShortMore(
                                                                budgetRange
                                                                    .start),
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        bottom: 2,
                                                        left: 5,
                                                      ),
                                                      child: TextFont(
                                                        text: budgetRange.start
                                                                    .year !=
                                                                DateTime.now()
                                                                    .year
                                                            ? budgetRange
                                                                .start.year
                                                                .toString()
                                                            : "",
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 2),
                                                TextFont(
                                                  text: convertToMoney(
                                                    Provider.of<AllWallets>(
                                                        context),
                                                    netSpending,
                                                  ),
                                                  fontSize: 16,
                                                  textAlign: TextAlign.left,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  IncomeOutcomeArrow(
                                                    color: getColor(context,
                                                        "incomeAmount"),
                                                    isIncome: true,
                                                    iconSize: 20,
                                                    width: 17,
                                                  ),
                                                  Flexible(
                                                    child: TextFont(
                                                      text: convertToMoney(
                                                          Provider.of<
                                                                  AllWallets>(
                                                              context),
                                                          incomeSpending.abs()),
                                                      fontSize: 16,
                                                      textColor: getColor(
                                                          context,
                                                          "incomeAmount"),
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 3),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  IncomeOutcomeArrow(
                                                    color: getColor(context,
                                                        "expenseAmount"),
                                                    isIncome: false,
                                                    iconSize: 20,
                                                    width: 17,
                                                  ),
                                                  Flexible(
                                                    child: TextFont(
                                                      text: convertToMoney(
                                                          Provider.of<
                                                                  AllWallets>(
                                                              context),
                                                          expenseSpending
                                                              .abs()),
                                                      fontSize: 16,
                                                      textColor: getColor(
                                                          context,
                                                          "expenseAmount"),
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (getPlatform() != PlatformOS.isIOS)
                                    Positioned(
                                      top: 0,
                                      bottom: 0,
                                      child: AnimatedExpanded(
                                        expand: widget.selectedDateTimeRange ==
                                            budgetRange,
                                        axis: Axis.horizontal,
                                        child: Container(
                                          width: 5,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: amountLoaded, //snapshot.data?.length
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: 45,
                          top: getPlatform() == PlatformOS.isIOS ? 10 : 0,
                        ),
                        child: Opacity(
                          opacity: 0.5,
                          child: LowKeyButton(
                            onTap: () {
                              if (amountLoadedPressedOnce == false) {
                                setState(() {
                                  amountLoadedPressedOnce = true;
                                });
                              } else {
                                int amountMoreToLoad =
                                    getIsFullScreen(context) == false ? 3 : 5;
                                loadLines(amountLoaded + amountMoreToLoad);
                                setState(() {
                                  amountLoaded =
                                      amountLoaded + amountMoreToLoad;
                                });
                              }
                            },
                            text: "view-more".tr(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class SelectedPeriodHeaderLabel extends StatelessWidget {
  const SelectedPeriodHeaderLabel(
      {required this.color,
      required this.textColor,
      required this.text,
      required this.onTap,
      required this.iconData,
      super.key});
  final Color color;
  final Color textColor;
  final String text;
  final VoidCallback onTap;
  final IconData iconData;
  @override
  Widget build(BuildContext context) {
    return Tappable(
      color: color,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(5),
              child: Icon(
                iconData,
                size: 24,
                color: textColor,
              ),
            ),
            SizedBox(
              width: 3,
            ),
            Flexible(
              child: TextFont(
                text: text,
                fontSize: 18.5,
                textColor: textColor,
                fontWeight: FontWeight.bold,
                maxLines: 2,
              ),
            )
          ],
        ),
      ),
      borderRadius: getPlatform() == PlatformOS.isIOS ? 10 : 15,
      onTap: onTap,
    );
  }
}
