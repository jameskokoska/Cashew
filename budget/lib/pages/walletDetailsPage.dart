import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/pages/creditDebtTransactionsPage.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/pages/homePage/homePageLineGraph.dart';
import 'package:budget/pages/homePage/homePageNetWorth.dart';
import 'package:budget/pages/homePage/homePageWalletSwitcher.dart';
import 'package:budget/pages/pastBudgetsPage.dart';
import 'package:budget/pages/premiumPage.dart';
import 'package:budget/pages/transactionFilters.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
import 'package:budget/pages/upcomingOverdueTransactionsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/struct/spendingSummaryHelper.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/budgetHistoryLineGraph.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/countNumber.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/editRowEntry.dart';
import 'package:budget/widgets/extraInfoBoxes.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/iconButtonScaled.dart';
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
import 'package:budget/widgets/settingsContainers.dart';
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
import 'package:budget/widgets/util/widgetSize.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:budget/widgets/viewAllTransactionsButton.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
import 'package:provider/provider.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:async/async.dart' show StreamZip;
import 'package:sliver_tools/sliver_tools.dart';
import 'package:budget/widgets/util/rightSideClipper.dart';

// Also known as the all spending page

DateTimeRange? createSafeDateTimeRange({DateTime? start, DateTime? end}) {
  if (start == null || end == null) {
    return null;
  } else if (start.isAfter(end)) {
    return DateTimeRange(start: end, end: start);
  } else if (start.isBefore(end)) {
    return DateTimeRange(start: start, end: end);
  } else if (start.isAtSameMomentAs(end) || start == end) {
    return DateTimeRange(start: start, end: start);
  }
  return null;
}

DateTimeRange? getDateTimeRangeForPassedSearchFilters(
    {required String cycleSettingsExtension,
    DateTimeRange? selectedDateTimeRange}) {
  if (selectedDateTimeRange != null) return selectedDateTimeRange;
  if (getStartDateOfSelectedCustomPeriod(cycleSettingsExtension) == null)
    return null;
  return createSafeDateTimeRange(
    start: getStartDateOfSelectedCustomPeriod(cycleSettingsExtension) ??
        DateTime.now(),
    end: getEndDateOfSelectedCustomPeriod(cycleSettingsExtension) ??
        DateTime(
          DateTime.now().year,
          DateTime.now().month + 1,
          DateTime.now().day,
        ),
  );
}

class WatchedWalletDetailsPage extends StatelessWidget {
  const WatchedWalletDetailsPage({required this.walletPk, super.key});
  final String walletPk;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TransactionWallet>(
      stream: database.getWallet(walletPk),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Color accentColor = HexColor(snapshot.data?.colour,
              defaultColor: Theme.of(context).colorScheme.primary);
          return CustomColorTheme(
            accentColor: accentColor,
            child: WalletDetailsPage(
              wallet: snapshot.data,
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}

bool categoryIsSelectedOnAllSpending = false;

class WalletDetailsPage extends StatefulWidget {
  final TransactionWallet? wallet;
  final SearchFilters? initialSearchFilters;
  const WalletDetailsPage(
      {required this.wallet, this.initialSearchFilters, Key? key})
      : super(key: key);

  @override
  State<WalletDetailsPage> createState() => WalletDetailsPageState();
}

class WalletDetailsPageState extends State<WalletDetailsPage>
    with SingleTickerProviderStateMixin {
  late String listID = widget.wallet == null
      ? "All Spending Summary"
      : widget.wallet!.walletPk.toString() + " Wallet Summary";
  GlobalKey<PageFrameworkState> pageState = GlobalKey();
  SearchFilters? searchFilters;
  late ScrollController _scrollController = ScrollController();
  late TabController _tabController = TabController(
    length: widget.wallet == null ? 2 : 1,
    vsync: this,
    initialIndex: widget.wallet == null
        ? (appStateSettings["allSpendingLastPage"] == 1 ? 1 : 0)
        : 0,
  );

  DateTimeRange? selectedDateTimeRange;
  int? selectedDateTimeRangeIndex;

  bool appStateSettingsNetAllSpendingTotal =
      appStateSettings["netAllSpendingTotal"] == true;

  void scrollToTop() {
    print("SCROLLING TO TOP");
    pageState.currentState?.scrollToTop();
  }

  @override
  void initState() {
    _tabController.addListener(onTabController);
    searchFilters = SearchFilters();
    if (widget.initialSearchFilters != null) {
      searchFilters = widget.initialSearchFilters;
    } else if (widget.wallet == null) {
      allSpendingHistoryDismissedPremium = false;
      searchFilters?.loadFilterString(
        appStateSettings["allSpendingSetFiltersString"],
        skipDateTimeRange: true,
        skipSearchQuery: true,
      );
    }
    super.initState();
  }

  void onTabController() {
    updateSettings(
      "allSpendingLastPage",
      _tabController.index == 1 ? 1 : 0,
      updateGlobalState: false,
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(onTabController);
    _tabController.dispose();
    // PageFramework takes care of the dispose lifecycle
    // _scrollController.dispose();
    super.dispose();
  }

  void selectAllSpendingPeriod({bool onlyShowCycleOption = false}) async {
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

  void changeSelectedDateRange(int delta) {
    int index = (selectedDateTimeRangeIndex ?? 0) - delta;
    if (selectedDateTimeRangeIndex != null && index >= 0) {
      setState(() {
        selectedDateTimeRangeIndex = index;
        selectedDateTimeRange = getCycleDateTimeRange(
          "",
          currentDate: getDatePastToDetermineBudgetDate(
            index,
            getCustomCycleTempBudget(""),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Make the information displayed follow the date range of search filters
    // Force set date time range in case its set back to null we want to override its original value
    searchFilters = searchFilters?.copyWith(
      dateTimeRange: getDateTimeRangeForPassedSearchFilters(
          cycleSettingsExtension: "",
          selectedDateTimeRange: selectedDateTimeRange),
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
        widget.wallet == null ? null : [widget.wallet?.walletPk ?? ""];

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

    List<Widget> historyTabPage = [
      AllSpendingPastSpendingGraph(
        appStateSettingsNetAllSpendingTotal:
            appStateSettingsNetAllSpendingTotal,
        searchFilters: searchFilters,
        onEntryTapped: (DateTimeRange tappedRange, int tappedRangeIndex) {
          setState(() {
            // Clear selection is tapped again when full split screen
            if (enableDoubleColumn(context) &&
                tappedRange == selectedDateTimeRange) {
              selectedDateTimeRange = null;
              selectedDateTimeRangeIndex = null;
            } else {
              selectedDateTimeRange = tappedRange;
              selectedDateTimeRangeIndex = tappedRangeIndex;
            }
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

    String timeRangeString = "";
    if (selectedDateTimeRange != null) {
      String startDateString = getWordedDateShort(selectedDateTimeRange!.start);
      String endDateString = getWordedDateShort(selectedDateTimeRange!.end);
      timeRangeString = startDateString == endDateString
          ? startDateString
          : startDateString + " – " + endDateString;
    }

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
                          ? timeRangeString
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
                icon: appStateSettings["outlinedIcons"]
                    ? Icons.close_outlined
                    : Icons.close_rounded,
                color: Theme.of(context).colorScheme.tertiaryContainer,
                iconColor: Theme.of(context).colorScheme.onTertiaryContainer,
              ),
            ),
    );

    Widget historySettingsButtonAlwaysShow = Padding(
      padding: const EdgeInsets.only(left: 7),
      child: ButtonIcon(
        key: ValueKey(2),
        onTap: () {
          openBottomSheet(
            context,
            PopupFramework(
              title: "settings".tr(),
              hasPadding: true,
              child: Column(
                children: [
                  SettingsContainerDropdown(
                    enableBorderRadius: true,
                    title: "spending-totals".tr(),
                    icon: appStateSettings["outlinedIcons"]
                        ? Icons.create_new_folder_outlined
                        : Icons.create_new_folder_rounded,
                    initial: appStateSettings["netAllSpendingTotal"].toString(),
                    items: ["false", "true"],
                    onChanged: (value) {
                      updateSettings("netAllSpendingTotal", value == "true",
                          updateGlobalState: false);
                      setState(() {
                        appStateSettingsNetAllSpendingTotal = value == "true";
                      });
                    },
                    getLabel: (item) {
                      if (item == "true") {
                        return "cumulative".tr();
                      } else if (item == "false") {
                        return "per-period".tr();
                      } else {
                        return "";
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
        icon: appStateSettings["outlinedIcons"]
            ? Icons.tune_outlined
            : Icons.tune_rounded,
      ),
    );

    Widget historySettingsButton = AnimatedBuilder(
      animation: _tabController.animation!,
      builder: (BuildContext context, Widget? child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(
              getPlatform() == PlatformOS.isIOS ? 10 : 15),
          child: SizeTransition(
            sizeFactor: _tabController.animation!,
            axis: Axis.horizontal,
            child: FadeTransition(
              opacity: _tabController.animation!,
              child: historySettingsButtonAlwaysShow,
            ),
          ),
        );
      },
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
        hasBorderRadius: true,
        onTabChanged: (_) {},
        initialTabIsIncome: appStateSettings["allSpendingLastPage"] == 1,
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
                          _tabController.animation?.value ?? 0;
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(
                            getPlatform() == PlatformOS.isIOS ? 10 : 15),
                        child: Stack(
                          alignment: Alignment.center,
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
                Stack(
                  alignment: Alignment.center,
                  children: [
                    historySettingsButton,
                    clearSelectedPeriodButton,
                  ],
                ),
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

    Widget totalNetContainer = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: getHorizontalPaddingConstrained(
          context,
          enabled:
              enableDoubleColumn(context) == false && widget.wallet == null,
        )),
        child: TransactionsAmountBox(
          onLongPress: () {
            if (widget.wallet == null) {
              selectAllSpendingPeriod();
            }
          },
          label:
              widget.wallet != null ? "account-total".tr() : "net-total".tr(),
          absolute: false,
          currencyKey: Provider.of<AllWallets>(context)
              .indexedByPk[appStateSettings["selectedWalletPk"]]
              ?.currency,
          totalWithCountStream: database.watchTotalWithCountOfWallet(
            isIncome: null,
            allWallets: Provider.of<AllWallets>(context),
            cycleSettingsExtension: "",
            // When wallet type is normal, forcefully show all time for net-spending
            followCustomPeriodCycle: widget.wallet == null ? true : false,
            searchFilters: widget.wallet != null
                ? SearchFilters().copyWith(walletPks: walletPks)
                : (searchFilters ?? SearchFilters())
                    .copyWith(walletPks: walletPks),
            forcedDateTimeRange: selectedDateTimeRange,
          ),
          textColor: getColor(context, "black"),
          openPage: TransactionsSearchPage(
            initialFilters: widget.wallet != null
                ? SearchFilters().copyWith(walletPks: walletPks)
                : (searchFilters == null ? SearchFilters() : searchFilters)
                    ?.copyWith(
                    dateTimeRange: getDateTimeRangeForPassedSearchFilters(
                      cycleSettingsExtension: "",
                      selectedDateTimeRange: selectedDateTimeRange,
                    ),
                    walletPks: walletPks,
                  ),
          ),
        ),
      ),
    );

    List<Widget> currentTabPage = [
      SliverToBoxAdapter(
        child: Column(
          children: [
            SizedBox(height: 10),
            if (widget.wallet == null)
              Padding(
                padding: const EdgeInsets.only(bottom: 13),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: totalNetContainer),
                  ],
                ),
              ),
            if (widget.wallet != null)
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 13 + getHorizontalPaddingConstrained(context)),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 13),
                      child: selectedTabCurrent,
                    ),
                    // TipBox(
                    //   padding: const EdgeInsets.only(bottom: 13),
                    //   onTap: () {
                    //     pushRoute(
                    //       context,
                    //       WalletDetailsPage(
                    //         wallet: null,
                    //       ),
                    //     );
                    //   },
                    //   text: "view-all-spending-page-tip".tr(),
                    //   settingsString: "allSpendingPageTip",
                    // ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: 13, left: 13, right: 13),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: getHorizontalPaddingConstrained(
                  context,
                  enabled: (enableDoubleColumn(context) == false &&
                          widget.wallet == null) ||
                      widget.wallet != null,
                )),
                child: Container(
                  decoration: BoxDecoration(
                    color: getColor(context, "lightDarkAccentHeavyLight"),
                    boxShadow: boxShadowCheck(boxShadowGeneral(context)),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(height: 10),
                        if (widget.wallet != null)
                          AmountSpentEntryRow(
                            hide: getDateTimeRangeForPassedSearchFilters(
                                    cycleSettingsExtension: "",
                                    selectedDateTimeRange:
                                        selectedDateTimeRange) ==
                                null,
                            openPage: TransactionsSearchPage(
                              initialFilters: (searchFilters == null
                                      ? SearchFilters()
                                      : searchFilters)
                                  ?.copyWith(
                                dateTimeRange:
                                    getDateTimeRangeForPassedSearchFilters(
                                        cycleSettingsExtension: "",
                                        selectedDateTimeRange:
                                            selectedDateTimeRange),
                                walletPks: walletPks,
                              ),
                            ),
                            absolute: false,
                            textColor: getColor(context, "black"),
                            label: "net-total".tr(),
                            totalWithCountStream:
                                database.watchTotalWithCountOfWallet(
                              isIncome: null,
                              allWallets: Provider.of<AllWallets>(context),
                              cycleSettingsExtension: "",
                              followCustomPeriodCycle: true,
                              searchFilters: widget.wallet != null
                                  ? SearchFilters()
                                      .copyWith(walletPks: walletPks)
                                  : (searchFilters ?? SearchFilters())
                                      .copyWith(walletPks: walletPks),
                              forcedDateTimeRange: selectedDateTimeRange,
                            ),
                            onLongPress: () {
                              selectAllSpendingPeriod();
                            },
                          ),
                        AmountSpentEntryRow(
                          forceShow: true,
                          openPage: TransactionsSearchPage(
                            initialFilters: (searchFilters == null
                                    ? SearchFilters()
                                    : searchFilters)
                                ?.copyWith(
                              dateTimeRange:
                                  getDateTimeRangeForPassedSearchFilters(
                                      cycleSettingsExtension: "",
                                      selectedDateTimeRange:
                                          selectedDateTimeRange),
                              walletPks: walletPks,
                              expenseIncome: [ExpenseIncome.expense],
                            ),
                          ),
                          textColor: getColor(context, "expenseAmount"),
                          label: "expense".tr(),
                          totalWithCountStream:
                              database.watchTotalWithCountOfWallet(
                            isIncome: false,
                            allWallets: Provider.of<AllWallets>(context),
                            followCustomPeriodCycle: widget.wallet == null,
                            cycleSettingsExtension: "",
                            searchFilters: (searchFilters ?? SearchFilters())
                                .copyWith(walletPks: walletPks),
                            forcedDateTimeRange: selectedDateTimeRange,
                            onlyIncomeAndExpense: true,
                          ),
                          onLongPress: () {
                            selectAllSpendingPeriod();
                          },
                        ),
                        AmountSpentEntryRow(
                          forceShow: true,
                          openPage: TransactionsSearchPage(
                            initialFilters: (searchFilters == null
                                    ? SearchFilters()
                                    : searchFilters)
                                ?.copyWith(
                              dateTimeRange:
                                  getDateTimeRangeForPassedSearchFilters(
                                      cycleSettingsExtension: "",
                                      selectedDateTimeRange:
                                          selectedDateTimeRange),
                              walletPks: walletPks,
                              expenseIncome: [ExpenseIncome.income],
                            ),
                          ),
                          textColor: getColor(context, "incomeAmount"),
                          label: "income".tr(),
                          totalWithCountStream:
                              database.watchTotalWithCountOfWallet(
                            isIncome: true,
                            allWallets: Provider.of<AllWallets>(context),
                            followCustomPeriodCycle: widget.wallet == null,
                            cycleSettingsExtension: "",
                            searchFilters: (searchFilters ?? SearchFilters())
                                .copyWith(walletPks: walletPks),
                            forcedDateTimeRange: selectedDateTimeRange,
                            onlyIncomeAndExpense: true,
                          ),
                          onLongPress: () {
                            selectAllSpendingPeriod();
                          },
                        ),
                        AmountSpentEntryRow(
                          openPage: widget.wallet == null &&
                                  (searchFilters?.walletPks == null ||
                                      (searchFilters?.walletPks.length ?? 0) <=
                                          0)
                              ? UpcomingOverdueTransactions(
                                  overdueTransactions: false)
                              : TransactionsSearchPage(
                                  initialFilters: (searchFilters == null
                                          ? SearchFilters()
                                          : searchFilters)
                                      ?.copyWith(
                                    dateTimeRange:
                                        getDateTimeRangeForPassedSearchFilters(
                                                  cycleSettingsExtension: "",
                                                  selectedDateTimeRange:
                                                      selectedDateTimeRange,
                                                ) ==
                                                null
                                            ? null
                                            : createSafeDateTimeRange(
                                                start: DateTime.now(),
                                                end:
                                                    getDateTimeRangeForPassedSearchFilters(
                                                  cycleSettingsExtension: "",
                                                  selectedDateTimeRange:
                                                      selectedDateTimeRange,
                                                )?.end,
                                              ),
                                    walletPks: walletPks,
                                    transactionTypes: [
                                      TransactionSpecialType.upcoming,
                                      TransactionSpecialType.repetitive,
                                      TransactionSpecialType.subscription,
                                    ],
                                    paidStatus: [PaidStatus.notPaid],
                                  ),
                                ),
                          textColor: getColor(context, "unPaidUpcoming"),
                          label: "upcoming".tr(),
                          absolute: false,
                          totalWithCountStream:
                              database.watchTotalWithCountOfUpcomingOverdue(
                            isOverdueTransactions: false,
                            allWallets: Provider.of<AllWallets>(context),
                            followCustomPeriodCycle: widget.wallet == null,
                            cycleSettingsExtension: "",
                            searchFilters: searchFilters?.copyWith(
                              walletPks: walletPks,
                            ),
                            forcedDateTimeRange: selectedDateTimeRange,
                          ),
                          onLongPress: () {
                            selectAllSpendingPeriod();
                          },
                        ),
                        AmountSpentEntryRow(
                          openPage: widget.wallet == null &&
                                  (searchFilters?.walletPks == null ||
                                      (searchFilters?.walletPks.length ?? 0) <=
                                          0)
                              ? UpcomingOverdueTransactions(
                                  overdueTransactions: true)
                              : TransactionsSearchPage(
                                  initialFilters: (searchFilters == null
                                          ? SearchFilters()
                                          : searchFilters)
                                      ?.copyWith(
                                    dateTimeRange:
                                        getDateTimeRangeForPassedSearchFilters(
                                                  cycleSettingsExtension: "",
                                                  selectedDateTimeRange:
                                                      selectedDateTimeRange,
                                                ) ==
                                                null
                                            ? null
                                            : createSafeDateTimeRange(
                                                start:
                                                    getDateTimeRangeForPassedSearchFilters(
                                                  cycleSettingsExtension: "",
                                                  selectedDateTimeRange:
                                                      selectedDateTimeRange,
                                                )?.start,
                                                end: DateTime.now(),
                                              ),
                                    walletPks: walletPks,
                                    transactionTypes: [
                                      TransactionSpecialType.upcoming,
                                      TransactionSpecialType.repetitive,
                                      TransactionSpecialType.subscription,
                                    ],
                                    paidStatus: [PaidStatus.notPaid],
                                  ),
                                ),
                          textColor: getColor(context, "unPaidOverdue"),
                          label: "overdue".tr(),
                          absolute: false,
                          totalWithCountStream:
                              database.watchTotalWithCountOfUpcomingOverdue(
                            isOverdueTransactions: true,
                            allWallets: Provider.of<AllWallets>(context),
                            followCustomPeriodCycle: widget.wallet == null,
                            cycleSettingsExtension: "",
                            searchFilters: searchFilters?.copyWith(
                              walletPks: walletPks,
                            ),
                            forcedDateTimeRange: selectedDateTimeRange,
                          ),
                          onLongPress: () {
                            selectAllSpendingPeriod();
                          },
                        ),
                        // Only show borrowed and lent totals when all time
                        // There is no point in showing it for time periods, because when marked as collected/paid
                        // It doesn't count towards total, and partial loans may not include all transactions and calculate properly
                        // I guess we could track amount paid back/amount lent out for period instead
                        // But that's not what this does...
                        AmountSpentEntryRow(
                          hide: selectedDateTimeRange != null,
                          extraText: CycleType.values[appStateSettings[
                                          "selectedPeriodCycleType"] ??
                                      0] !=
                                  CycleType.allTime
                              ? "all-time".tr()
                              : null,
                          openPage: widget.wallet == null &&
                                  (searchFilters?.walletPks == null ||
                                      (searchFilters?.walletPks.length ?? 0) <=
                                          0)
                              ? CreditDebtTransactions(isCredit: true)
                              : TransactionsSearchPage(
                                  initialFilters: (searchFilters == null
                                          ? SearchFilters()
                                          : searchFilters)
                                      ?.copyWith(
                                    forceSetDateTimeRange: true,
                                    dateTimeRange: null,
                                    walletPks: walletPks,
                                    transactionTypes: [
                                      TransactionSpecialType.credit
                                    ],
                                  ),
                                ),
                          textColor: getColor(context, "unPaidUpcoming"),
                          label: "lent".tr(),
                          absolute: false,
                          invertSign: true,
                          totalWithCountStream:
                              database.watchTotalWithCountOfCreditDebt(
                            isCredit: true,
                            allWallets: Provider.of<AllWallets>(context),
                            followCustomPeriodCycle: widget.wallet == null,
                            cycleSettingsExtension: null, //all time
                            searchFilters: searchFilters?.copyWith(
                              dateTimeRange: null,
                              forceSetDateTimeRange: true,
                              walletPks: walletPks,
                            ),
                            forcedDateTimeRange: selectedDateTimeRange,
                            selectedTab: null,
                          ),
                          totalWithCountStream2: database
                              .watchTotalWithCountOfCreditDebtLongTermLoansOffset(
                            isCredit: true,
                            allWallets: Provider.of<AllWallets>(context),
                            followCustomPeriodCycle: widget.wallet == null,
                            cycleSettingsExtension: null, //all time
                            searchFilters: searchFilters?.copyWith(
                              dateTimeRange: null,
                              forceSetDateTimeRange: true,
                              walletPks: walletPks,
                            ),
                            forcedDateTimeRange: selectedDateTimeRange,
                            selectedTab: null,
                          ),
                          onLongPress: () {
                            // Since always all time, disable long press custom period for these rows
                            //selectAllSpendingPeriod();
                          },
                        ),
                        AmountSpentEntryRow(
                          hide: selectedDateTimeRange != null,
                          extraText: CycleType.values[appStateSettings[
                                          "selectedPeriodCycleType"] ??
                                      0] !=
                                  CycleType.allTime
                              ? "all-time".tr()
                              : null,
                          openPage: widget.wallet == null &&
                                  (searchFilters?.walletPks == null ||
                                      (searchFilters?.walletPks.length ?? 0) <=
                                          0)
                              ? CreditDebtTransactions(isCredit: false)
                              : TransactionsSearchPage(
                                  initialFilters: (searchFilters == null
                                          ? SearchFilters()
                                          : searchFilters)
                                      ?.copyWith(
                                    forceSetDateTimeRange: true,
                                    dateTimeRange: null,
                                    walletPks: walletPks,
                                    transactionTypes: [
                                      TransactionSpecialType.debt
                                    ],
                                  ),
                                ),
                          textColor: getColor(context, "unPaidOverdue"),
                          label: "borrowed".tr(),
                          absolute: false,
                          totalWithCountStream:
                              database.watchTotalWithCountOfCreditDebt(
                            isCredit: false,
                            allWallets: Provider.of<AllWallets>(context),
                            followCustomPeriodCycle: widget.wallet == null,
                            cycleSettingsExtension: null, //all time
                            searchFilters: searchFilters?.copyWith(
                              dateTimeRange: null,
                              forceSetDateTimeRange: true,
                              walletPks: walletPks,
                            ),
                            forcedDateTimeRange: selectedDateTimeRange,
                            selectedTab: null,
                          ),
                          totalWithCountStream2: database
                              .watchTotalWithCountOfCreditDebtLongTermLoansOffset(
                            isCredit: false,
                            allWallets: Provider.of<AllWallets>(context),
                            followCustomPeriodCycle: widget.wallet == null,
                            cycleSettingsExtension: null, //all time
                            searchFilters: searchFilters?.copyWith(
                              dateTimeRange: null,
                              forceSetDateTimeRange: true,
                              walletPks: walletPks,
                            ),
                            forcedDateTimeRange: selectedDateTimeRange,
                            selectedTab: null,
                          ),
                          onLongPress: () {
                            // Since always all time, disable long press custom period for these rows
                            //selectAllSpendingPeriod();
                          },
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.only(bottom: 13, left: 13, right: 13),
            //   child: Padding(
            //     padding: EdgeInsets.symmetric(
            //       horizontal: getHorizontalPaddingConstrained(context),
            //     ),
            //     child: Row(
            //       crossAxisAlignment: CrossAxisAlignment.center,
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Expanded(
            //           child: TransactionsAmountBox(
            //             onLongPress: () {
            //               selectAllSpendingPeriod();
            //             },
            //             label: "expense".tr(),
            //             textColor: getColor(context, "expenseAmount"),
            //             totalWithCountStream:
            //                 database.watchTotalWithCountOfWallet(
            //               isIncome: false,
            //               allWallets: Provider.of<AllWallets>(context),
            //               followCustomPeriodCycle: widget.wallet == null,
            //               cycleSettingsExtension: "",
            //               searchFilters: (searchFilters ?? SearchFilters())
            //                   .copyWith(walletPks: walletPks),
            //               forcedDateTimeRange: selectedDateTimeRange,
            //               onlyIncomeAndExpense: true,
            //             ),
            //             openPage: TransactionsSearchPage(
            //               initialFilters: (searchFilters == null
            //                       ? SearchFilters()
            //                       : searchFilters)
            //                   ?.copyWith(
            //                 dateTimeRange:
            //                     getDateTimeRangeForPassedSearchFilters(
            //                         cycleSettingsExtension: "",
            //                         selectedDateTimeRange:
            //                             selectedDateTimeRange),
            //                 walletPks: walletPks,
            //                 expenseIncome: [ExpenseIncome.expense],
            //               ),
            //             ),
            //           ),
            //         ),
            //         SizedBox(width: 13),
            //         Expanded(
            //           child: TransactionsAmountBox(
            //             onLongPress: () {
            //               selectAllSpendingPeriod();
            //             },
            //             label: "income".tr(),
            //             textColor: getColor(context, "incomeAmount"),
            //             totalWithCountStream:
            //                 database.watchTotalWithCountOfWallet(
            //               isIncome: true,
            //               allWallets: Provider.of<AllWallets>(context),
            //               followCustomPeriodCycle: widget.wallet == null,
            //               cycleSettingsExtension: "",
            //               searchFilters: (searchFilters ?? SearchFilters())
            //                   .copyWith(walletPks: walletPks),
            //               forcedDateTimeRange: selectedDateTimeRange,
            //               onlyIncomeAndExpense: true,
            //             ),
            //             openPage: TransactionsSearchPage(
            //               initialFilters: (searchFilters == null
            //                       ? SearchFilters()
            //                       : searchFilters)
            //                   ?.copyWith(
            //                 dateTimeRange:
            //                     getDateTimeRangeForPassedSearchFilters(
            //                         cycleSettingsExtension: "",
            //                         selectedDateTimeRange:
            //                             selectedDateTimeRange),
            //                 walletPks: walletPks,
            //                 expenseIncome: [ExpenseIncome.income],
            //               ),
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            WalletDetailsLineGraph(
              walletPks: walletPks,
              followCustomPeriodCycle: true,
              cycleSettingsExtension: "",
              searchFilters: (searchFilters ?? SearchFilters())
                  .copyWith(walletPks: walletPks),
              selectedDateTimeRange: selectedDateTimeRange,
            ),
          ],
        ),
      ),
      WalletDetailsCategorySelection(
        walletPks: walletPks,
        walletColorScheme: walletColorScheme,
        searchFilters: searchFilters,
        selectedDateTimeRange: selectedDateTimeRange,
        wallet: widget.wallet,
        listID: listID,
        getDateTimeRangeForPassedSearchFilters: () =>
            getDateTimeRangeForPassedSearchFilters(
          cycleSettingsExtension: "",
          selectedDateTimeRange: selectedDateTimeRange,
        ),
      ),
      SliverToBoxAdapter(child: SizedBox(height: 40)),
    ];

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
            appBarBackgroundColor:
                enableDoubleColumn(context) == true && widget.wallet == null
                    ? Theme.of(context).colorScheme.secondaryContainer
                    : null,
            appBarBackgroundColorStart:
                enableDoubleColumn(context) == true && widget.wallet == null
                    ? Theme.of(context).colorScheme.secondaryContainer
                    : null,
            backgroundColor: Theme.of(context).canvasColor,
            scrollController: _scrollController,
            key: pageState,
            listID: listID,
            floatingActionButton: AnimateFABDelayed(
              fab: AddFAB(
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
                  ],
                ),
              if (widget.wallet == null)
                AppBarIconAppear(
                  scrollController: _scrollController,
                  child: CustomPopupMenuButton(
                    showButtons: true,
                    keepOutFirst: true,
                    items: [
                      // DropdownItemMenu(
                      //   id: "select-period",
                      //   label: "select-period-tooltip".tr(),
                      //   icon: appStateSettings["outlinedIcons"]
                      //       ? Icons.timelapse_outlined
                      //       : Icons.timelapse_rounded,
                      //   action: () async {
                      //     selectAllSpendingPeriod();
                      //   },
                      // ),
                      DropdownItemMenu(
                        id: "filters",
                        label: "filters".tr(),
                        icon: appStateSettings["outlinedIcons"]
                            ? Icons.filter_alt_outlined
                            : Icons.filter_alt_rounded,
                        action: () async {
                          selectAllSpendingFilters();
                        },
                        selected:
                            searchFilters?.isClear(ignoreDateTimeRange: true) ==
                                false,
                      ),
                    ],
                  ),
                ),
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
                          top: topPaddingOfBanner + 5,
                          right: 55,
                          child: historySettingsButtonAlwaysShow,
                        ),
                        Positioned(
                          top: topPaddingOfBanner + 5,
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
                                                    alignment: Alignment.center,
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
              return Stack(
                children: [
                  NestedScrollView(
                    controller: _scrollController,
                    headerSliverBuilder:
                        (BuildContext contextHeader, bool innerBoxIsScrolled) {
                      return <Widget>[
                        SliverOverlapAbsorber(
                          handle:
                              NestedScrollView.sliverOverlapAbsorberHandleFor(
                                  contextHeader),
                          sliver: MultiSliver(
                            children: [
                              sliverAppBar,
                              if (widget.wallet != null)
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          getHorizontalPaddingConstrained(
                                              context),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: totalNetContainer,
                                    ),
                                  ),
                                ),
                              if (widget.wallet == null)
                                SliverToBoxAdapter(
                                    child: tabDateFilterSelectorHeader),
                              if (searchFilters != null &&
                                  widget.wallet == null)
                                SliverToBoxAdapter(
                                    child: appliedFilterChipsWidget),
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
                  ),
                  // Selected period dropdown switcher
                  AnimatedBuilder(
                    animation: _tabController.animation!,
                    builder: (BuildContext context, Widget? child) {
                      double animationProgress =
                          _tabController.animation!.value;
                      return SelectedPeriodAppBar(
                        scrollController: _scrollController,
                        forceHide: selectedDateTimeRange == null,
                        animationProgress: animationProgress,
                        selectPeriodContent: Padding(
                          padding: const EdgeInsets.only(bottom: 3, top: 3),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: IconButtonScaled(
                                  iconData: appStateSettings["outlinedIcons"]
                                      ? Icons.chevron_left_outlined
                                      : Icons.chevron_left_rounded,
                                  iconSize: 18,
                                  scale: 1,
                                  onTap: () {
                                    changeSelectedDateRange(-1);
                                  },
                                ),
                              ),
                              Flexible(
                                child: AnimatedSizeSwitcher(
                                  child: TextFont(
                                    key: ValueKey(timeRangeString),
                                    text: timeRangeString,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    textAlign: TextAlign.center,
                                    textColor: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                              IgnorePointer(
                                ignoring: selectedDateTimeRangeIndex == 0,
                                child: AnimatedOpacity(
                                  duration: Duration(milliseconds: 200),
                                  opacity:
                                      selectedDateTimeRangeIndex == 0 ? 0.5 : 1,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: IconButtonScaled(
                                      iconData:
                                          appStateSettings["outlinedIcons"]
                                              ? Icons.chevron_right_outlined
                                              : Icons.chevron_right_rounded,
                                      iconSize: 18,
                                      scale: 1,
                                      onTap: () {
                                        changeSelectedDateRange(1);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
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

class AppBarIconAppear extends StatefulWidget {
  const AppBarIconAppear({
    required this.scrollController,
    required this.child,
    Key? key,
  }) : super(key: key);

  final ScrollController scrollController;
  final Widget child;

  @override
  _AppBarIconAppearState createState() => _AppBarIconAppearState();
}

class _AppBarIconAppearState extends State<AppBarIconAppear> {
  bool animateIn = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    bool tempAnimateIn;
    if (widget.scrollController.offset /
            widget.scrollController.position.maxScrollExtent >=
        0.99)
      tempAnimateIn = true;
    else
      tempAnimateIn = false;

    if (tempAnimateIn != animateIn) {
      setState(() {
        animateIn = tempAnimateIn;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScaleOpacity(
      animateIn: animateIn,
      child: widget.child,
    );
  }
}

class SelectedPeriodAppBar extends StatefulWidget {
  const SelectedPeriodAppBar({
    required this.scrollController,
    required this.forceHide,
    required this.selectPeriodContent,
    required this.animationProgress,
    Key? key,
  }) : super(key: key);

  final ScrollController scrollController;
  final bool forceHide;
  final Widget selectPeriodContent;
  final double animationProgress;

  @override
  _SelectedPeriodAppBarState createState() => _SelectedPeriodAppBarState();
}

class _SelectedPeriodAppBarState extends State<SelectedPeriodAppBar> {
  bool dropdown = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    bool tempDropdown;
    if (widget.scrollController.offset /
            widget.scrollController.position.maxScrollExtent >=
        0.99)
      tempDropdown = true;
    else
      tempDropdown = false;

    if (tempDropdown != dropdown) {
      setState(() {
        dropdown = tempDropdown;
      });
    }
  }

  Size bannerSize = Size(0, 0);

  @override
  Widget build(BuildContext context) {
    double totalTranslation = 56 + MediaQuery.of(context).padding.top;
    return Transform.translate(
      offset: Offset(0, -1),
      child: ClipRRect(
        clipper: TopSideClipper(totalTranslation),
        child: Stack(
          children: [
            AnimatedPositioned(
              curve: Curves.easeInOutCubicEmphasized,
              duration: Duration(milliseconds: 650),
              top: (dropdown &&
                      widget.animationProgress < 0.5 &&
                      widget.forceHide == false)
                  ? totalTranslation
                  : (-bannerSize.height),
              left: 0,
              right: 0,
              child: WidgetSize(
                onChange: (size) {
                  bannerSize = size;
                },
                child: Container(
                  child: widget.selectPeriodContent,
                  decoration: BoxDecoration(
                    boxShadow: boxShadowCheck(boxShadowSharp(context)),
                    color: dynamicPastel(
                      context,
                      Theme.of(context).colorScheme.secondaryContainer,
                      amountDark: 0.15,
                      amountLight: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TopSideClipper extends CustomClipper<RRect> {
  final double customAmount;

  TopSideClipper(this.customAmount);

  @override
  RRect getClip(Size size) {
    final radius = Radius.circular(0);
    final topRect = RRect.fromRectAndRadius(
      Rect.fromPoints(Offset(0, customAmount), Offset(size.width, size.height)),
      radius,
    );
    return topRect;
  }

  @override
  bool shouldReclip(CustomClipper<RRect> oldClipper) {
    return false;
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

class WalletDetailsCategorySelection extends StatefulWidget {
  const WalletDetailsCategorySelection({
    required this.walletPks,
    required this.walletColorScheme,
    required this.searchFilters,
    required this.selectedDateTimeRange,
    required this.wallet,
    required this.listID,
    required this.getDateTimeRangeForPassedSearchFilters,
    super.key,
  });

  final List<String>? walletPks;
  final ColorScheme walletColorScheme;
  final SearchFilters? searchFilters;
  final DateTimeRange? selectedDateTimeRange;
  final TransactionWallet? wallet;
  final String listID;
  final DateTimeRange? Function() getDateTimeRangeForPassedSearchFilters;

  @override
  State<WalletDetailsCategorySelection> createState() =>
      _WalletDetailsCategorySelectionState();
}

class _WalletDetailsCategorySelectionState
    extends State<WalletDetailsCategorySelection> {
  TransactionCategory? selectedCategory;
  bool isIncome = false;

  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      SliverToBoxAdapter(
        child: WalletCategoryPieChart(
          cycleSettingsExtension: "",
          selectedDateTimeRange: widget.selectedDateTimeRange,
          searchFilters: widget.searchFilters,
          isAllSpending: widget.wallet == null,
          walletPks: widget.walletPks,
          walletColorScheme: widget.walletColorScheme,
          onSelectedCategory: (TransactionCategory? category) {
            // pageState.currentState?.scrollTo(500);
            setState(() {
              selectedCategory = category;
            });
            if (category == null) {
              categoryIsSelectedOnAllSpending = false;
            } else {
              categoryIsSelectedOnAllSpending = true;
            }
          },
          onSelectedIncome: (bool isIncome) {
            setState(() {
              this.isIncome = isIncome;
            });
          },
        ),
      ),
      if (selectedCategory != null)
        TransactionEntries(
          enableFutureTransactionsCollapse: false,
          // If the wallet is null, then we show use the spending time period
          widget.wallet == null
              ? getStartDateOfSelectedCustomPeriod("",
                  forcedDateTimeRange: widget.selectedDateTimeRange)
              : null,
          widget.wallet == null
              ? getEndDateOfSelectedCustomPeriod("",
                  forcedDateTimeRange: widget.selectedDateTimeRange)
              : null,
          categoryFks:
              selectedCategory != null ? [selectedCategory!.categoryPk] : [],
          walletFks: widget.walletPks ?? [],
          limit: selectedCategory == null ? 0 : 10,
          listID: widget.listID,
          showNoResults: false,
          // isIncome should be treated like outgoing/incoming
          searchFilters: widget.searchFilters?.copyWith(
            positiveCashFlow: isIncome,
          ),
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
                    initialFilters: (widget.searchFilters == null
                            ? SearchFilters()
                            : widget.searchFilters)
                        ?.copyWith(
                      dateTimeRange:
                          widget.getDateTimeRangeForPassedSearchFilters(),
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
                      positiveCashFlow:
                          selectedCategory == null ? null : isIncome,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    ]);
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
      _pieChartDisplayStateKey.currentState
          ?.setTouchedCategoryPk(selectedCategory?.categoryPk);
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
            enabled: enableDoubleColumn(context) == false ||
                widget.isAllSpending == false,
          )),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: boxShadowCheck(boxShadowGeneral(context)),
              ),
              child: IncomeExpenseTabSelector(
                hasBorderRadius: true,
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
                incomeLabel: "incoming".tr(),
                expenseLabel: "outgoing".tr(),
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
                showAllSubcategories: showAllSubcategories,
                multiplyTotalBy: -1,
              );
              // print(s.totalSpent);
              List<Widget> categoryEntries = [];
              double totalSpentPercent = 45 / 360;
              snapshot.data!.asMap().forEach((index, category) {
                categoryEntries.add(
                  CategoryEntry(
                    percentageOffset: totalSpentPercent,
                    useHorizontalPaddingConstrained:
                        enableDoubleColumn(context) == false ||
                            widget.isAllSpending == false,
                    selectedSubCategoryPk: selectedCategory?.categoryPk,
                    expandSubcategories: showAllSubcategories ||
                        category.category.categoryPk ==
                            selectedCategory?.categoryPk ||
                        category.category.categoryPk ==
                            selectedCategory?.mainCategoryPk,
                    subcategoriesWithTotalMap:
                        s.subCategorySpendingIndexedByMainCategoryPk,
                    extraText: isIncome
                        ? "of-income".tr().toLowerCase()
                        : "of-expense".tr().toLowerCase(),
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
                        _pieChartDisplayStateKey.currentState
                            ?.setTouchedIndex(-1);
                      } else {
                        if (showAllSubcategories ||
                            tappedCategory.mainCategoryPk == null) {
                          setState(() {
                            selectedCategory = tappedCategory;
                          });
                          _pieChartDisplayStateKey.currentState
                              ?.setTouchedCategoryPk(tappedCategory.categoryPk);
                        } else {
                          // We are tapping a subcategoryEntry and it is not in the pie chart
                          // because showAllSubcategories is false and mainCategoryPk is not null
                          setState(() {
                            selectedCategory = tappedCategory;
                          });
                          _pieChartDisplayStateKey.currentState
                              ?.setTouchedCategoryPk(
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
                    getPercentageAfterText: (double categorySpent) {
                      return categorySpent > 0
                          ? "of-incoming".tr().toLowerCase()
                          : "of-outgoing".tr().toLowerCase();
                    },
                  ),
                );
                if (s.totalSpent != 0)
                  totalSpentPercent += category.total.abs() / s.totalSpent;
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
                    isIncomeBudget: false,
                    hasSubCategories: s.hasSubCategories,
                    selectedCategory: selectedCategory,
                    onClearSelection: () {
                      setState(() {
                        selectedCategory = null;
                      });
                      _pieChartDisplayStateKey.currentState
                          ?.setTouchedIndex(-1);
                      widget.onSelectedCategory(selectedCategory);
                    },
                    onEditSpendingGoals: null,
                    toggleAllSubCategories: toggleAllSubcategories,
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

class WalletDetailsLineGraph extends StatelessWidget {
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
  Widget build(BuildContext context) {
    DateTime? customPeriodStartDate = getStartDateOfSelectedCustomPeriod("",
        forcedDateTimeRange: selectedDateTimeRange);
    DateTime? customPeriodEndDate = getEndDateOfSelectedCustomPeriod("",
        forcedDateTimeRange: selectedDateTimeRange);
    return PastSpendingGraph(
      allTimeUpToFirstTransaction: selectedDateTimeRange == null,
      isIncome: null,
      walletPks: walletPks,
      followCustomPeriodCycle: followCustomPeriodCycle,
      cycleSettingsExtension: cycleSettingsExtension,
      forcedDateTimeRange: selectedDateTimeRange,
      // If all spending, earliestDateTime is used
      customStartDate:
          followCustomPeriodCycle == true ? customPeriodStartDate : null,
      customEndDate:
          followCustomPeriodCycle == true ? customPeriodEndDate : null,
      searchFilters: searchFilters,
      hideIfOnlyOneEntry: true,
      // extraLeftPaddingIfSmall:
      //     10, //we want this because the corner has the load more dates button
      builder: (Widget spendingGraph) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 13),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              color: getColor(context, "lightDarkAccentHeavyLight"),
              boxShadow: boxShadowCheck(boxShadowGeneral(context)),
            ),
            child: spendingGraph,
          ),
        );
      },
    );
  }
}

bool allSpendingHistoryDismissedPremium = false;

class AllSpendingPastSpendingGraph extends StatefulWidget {
  const AllSpendingPastSpendingGraph({
    required this.searchFilters,
    required this.onEntryTapped,
    required this.selectedDateTimeRange,
    required this.appStateSettingsNetAllSpendingTotal,
    super.key,
  });
  final SearchFilters? searchFilters;
  final Function(DateTimeRange tappedRange, int tappedRangeIndex) onEntryTapped;
  final DateTimeRange? selectedDateTimeRange;
  final bool appStateSettingsNetAllSpendingTotal;

  @override
  State<AllSpendingPastSpendingGraph> createState() =>
      _AllSpendingPastSpendingGraphState();
}

class _AllSpendingPastSpendingGraphState
    extends State<AllSpendingPastSpendingGraph> {
  Stream<List<TotalWithCount?>>? mergedStreamsIncome;
  Stream<List<TotalWithCount?>>? mergedStreamsExpense;
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
    List<Stream<TotalWithCount?>> watchedStreamsIncome = [];
    List<Stream<TotalWithCount?>> watchedStreamsExpense = [];
    for (int index = 0; index < amountLoaded; index++) {
      DateTime datePast = getCycleDatePastToDetermineBudgetDate("", index);
      DateTimeRange budgetRange =
          getCycleDateTimeRange("", currentDate: datePast);
      dateTimeRanges.add(budgetRange);
      watchedStreamsIncome.add(
        database.watchTotalWithCountOfWallet(
          isIncome: true,
          includeBalanceCorrection: widget.appStateSettingsNetAllSpendingTotal,
          allWallets: Provider.of<AllWallets>(context, listen: false),
          followCustomPeriodCycle: false,
          cycleSettingsExtension: "",
          searchFilters:
              widget.searchFilters?.copyWith(dateTimeRange: budgetRange),
        ),
      );
      watchedStreamsExpense.add(
        database.watchTotalWithCountOfWallet(
          isIncome: false,
          includeBalanceCorrection: widget.appStateSettingsNetAllSpendingTotal,
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

  Widget buildSpendingHistorySummaryContainer({
    required int index,
    required Color containerColor,
    required DateTimeRange budgetRange,
    required double netSpending,
    required double incomeSpending,
    required double expenseSpending,
  }) {
    return FadeIn(
      duration: Duration(milliseconds: 400),
      child: Container(
        decoration: BoxDecoration(
          border: getPlatform() == PlatformOS.isIOS
              ? Border(
                  top: BorderSide(
                    color: getColor(context, "dividerColor"),
                    width: index == 0 ? 2 : 0,
                  ),
                  bottom: BorderSide(
                    color: getColor(context, "dividerColor"),
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
                      enabled: enableDoubleColumn(context) == false,
                    ) +
                    13,
                right: getHorizontalPaddingConstrained(
                      context,
                      enabled: enableDoubleColumn(context) == false,
                    ) +
                    13,
                bottom: 10,
              ),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(getPlatform() == PlatformOS.isIOS ? 0 : 18),
          child: Stack(
            children: [
              Tappable(
                color: containerColor,
                onTap: () {
                  widget.onEntryTapped(budgetRange, index);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: (getPlatform() == PlatformOS.isIOS
                              ? getHorizontalPaddingConstrained(
                                  context,
                                  enabled: enableDoubleColumn(context) == false,
                                )
                              : 0) +
                          30,
                      vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: TextFont(
                                    text: getPercentBetweenDates(
                                                budgetRange, DateTime.now()) <=
                                            100
                                        ? "current-budget-period".tr()
                                        : getWordedDateShortMore(
                                            budgetRange.start),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 2,
                                    left: 5,
                                  ),
                                  child: TextFont(
                                    text: budgetRange.start.year !=
                                            DateTime.now().year
                                        ? budgetRange.start.year.toString()
                                        : "",
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2),
                            TextFont(
                              text: convertToMoney(
                                Provider.of<AllWallets>(context),
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
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IncomeOutcomeArrow(
                                color: getColor(context, "incomeAmount"),
                                isIncome: true,
                                iconSize: 20,
                                width: 17,
                              ),
                              Flexible(
                                child: TextFont(
                                  text: convertToMoney(
                                      Provider.of<AllWallets>(context),
                                      incomeSpending.abs()),
                                  fontSize: 16,
                                  textColor: getColor(context, "incomeAmount"),
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 3),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IncomeOutcomeArrow(
                                color: getColor(context, "expenseAmount"),
                                isIncome: false,
                                iconSize: 20,
                                width: 17,
                              ),
                              Flexible(
                                child: TextFont(
                                  text: convertToMoney(
                                      Provider.of<AllWallets>(context),
                                      expenseSpending.abs()),
                                  fontSize: 16,
                                  textColor: getColor(context, "expenseAmount"),
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
                    expand: widget.selectedDateTimeRange == budgetRange,
                    axis: Axis.horizontal,
                    child: Container(
                      width: 5,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (mergedStreamsIncome == null && mergedStreamsExpense == null)
      return SliverToBoxAdapter(child: SizedBox.shrink());
    return StreamBuilder<double?>(
      stream: database.watchTotalNetBeforeStartDate(
        searchFilters: widget.searchFilters
            ?.copyWith(forceSetDateTimeRange: true, dateTimeRange: null),
        allWallets: Provider.of<AllWallets>(context, listen: true),
        startDate:
            nullIfIndexOutOfRange(dateTimeRanges, dateTimeRanges.length - 1)
                    ?.start ??
                DateTime.now(),
        isIncome: false,
      ),
      builder: (context, snapshotTotalExpenseBefore) {
        return StreamBuilder<double?>(
          stream: database.watchTotalNetBeforeStartDate(
            searchFilters: widget.searchFilters
                ?.copyWith(forceSetDateTimeRange: true, dateTimeRange: null),
            allWallets: Provider.of<AllWallets>(context, listen: true),
            startDate:
                nullIfIndexOutOfRange(dateTimeRanges, dateTimeRanges.length - 1)
                        ?.start ??
                    DateTime.now(),
            isIncome: true,
          ),
          builder: (context, snapshotTotalIncomeBefore) {
            double totalNetBefore = (snapshotTotalIncomeBefore.data ?? 0) +
                (snapshotTotalExpenseBefore.data ?? 0);
            double totalIncomeBefore = snapshotTotalIncomeBefore.data ?? 0;
            double totalExpenseBefore = snapshotTotalExpenseBefore.data ?? 0;
            return StreamBuilder<List<TotalWithCount?>>(
              stream: mergedStreamsIncome,
              builder: (context, snapshotIncome) {
                List<TotalWithCount?> incomeData = snapshotIncome.data ?? [];
                return StreamBuilder<List<TotalWithCount?>>(
                  stream: mergedStreamsExpense,
                  builder: (context, snapshotExpense) {
                    List<TotalWithCount?> expenseData =
                        snapshotExpense.data ?? [];
                    if (expenseData.length <= 0 && incomeData.length <= 0)
                      return SliverToBoxAdapter(
                        child: SizedBox.shrink(),
                      );
                    double minimumYValue = 0.00000000001;
                    List<List<FlSpot>> allSpots = [];
                    if (widget.appStateSettingsNetAllSpendingTotal) {
                      List<FlSpot> spots = [];
                      double total = totalNetBefore;
                      for (int i = expenseData.length - 1; i >= 0; i--) {
                        double expenseSpending =
                            (nullIfIndexOutOfRange(expenseData, i) ??
                                    TotalWithCount(total: 0, count: 0))
                                .total;
                        double incomeSpending =
                            (nullIfIndexOutOfRange(incomeData, i) ??
                                    TotalWithCount(total: 0, count: 0))
                                .total;

                        total = total +
                            expenseSpending.abs() * -1 +
                            incomeSpending.abs();
                        spots.add(FlSpot(
                          expenseData.length - 1 - i.toDouble(),
                          (total).abs() == 0 ? minimumYValue : total,
                        ));
                      }
                      allSpots.add(spots);
                    } else {
                      List<FlSpot> spots = [];
                      if (expenseData.toSet().length > 1) {
                        for (int i = expenseData.length - 1; i >= 0; i--) {
                          double expenseSpending =
                              (nullIfIndexOutOfRange(expenseData, i) ??
                                      TotalWithCount(total: 0, count: 0))
                                  .total;

                          spots.add(FlSpot(
                            expenseData.length - 1 - i.toDouble(),
                            expenseSpending.abs() == 0
                                ? minimumYValue
                                : expenseSpending.abs(),
                          ));
                        }
                        allSpots.add(spots);
                      }

                      // Only add income points if there is an income data point!
                      if (incomeData.toSet().length > 1) {
                        spots = [];
                        for (int i = incomeData.length - 1; i >= 0; i--) {
                          if (incomeData[i] == null) continue;
                          double incomeSpending =
                              (nullIfIndexOutOfRange(incomeData, i) ??
                                      TotalWithCount(total: 0, count: 0))
                                  .total;
                          spots.add(FlSpot(
                            incomeData.length - 1 - i.toDouble(),
                            incomeSpending.abs() == 0
                                ? minimumYValue
                                : incomeSpending.abs(),
                          ));
                        }
                        allSpots.add(spots);
                      }
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
                                        padding:
                                            const EdgeInsets.only(right: 5),
                                        child: ClipRRect(
                                          child: BudgetHistoryLineGraph(
                                            forceMinYIfPositive: widget
                                                    .appStateSettingsNetAllSpendingTotal
                                                ? null
                                                : 0,
                                            showDateOnHover: true,
                                            onTouchedIndex: (index) {},
                                            color: dynamicPastel(
                                              context,
                                              Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              amountLight: 0.4,
                                              amountDark: 0.2,
                                            ),
                                            dateRanges: dateTimeRanges,
                                            lineColors: allSpots.length > 1
                                                ? [
                                                    getColor(context,
                                                        "expenseAmount"),
                                                    getColor(context,
                                                        "incomeAmount"),
                                                  ]
                                                : null,
                                            spots: allSpots,
                                            horizontalLineAt: null,
                                            budget:
                                                getCustomCycleTempBudget(""),
                                            extraCategorySpots: {},
                                            categoriesMapped: {},
                                            loadAllEvenIfZero:
                                                amountLoadedPressedOnce,
                                            setNoPastRegionsAreZero:
                                                (bool value) {
                                              amountLoadedPressedOnce = true;
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    LoadMorePeriodsButton(
                                      onPressed: () {
                                        if (amountLoadedPressedOnce == false) {
                                          setState(() {
                                            amountLoadedPressedOnce = true;
                                          });
                                        } else {
                                          int amountMoreToLoad =
                                              getIsFullScreen(context) == false
                                                  ? 3
                                                  : 5;
                                          loadLines(
                                              amountLoaded + amountMoreToLoad);
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
                                      Theme.of(context)
                                          .canvasColor
                                          .withOpacity(0.0),
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
                          Builder(builder: (context) {
                            double currentTotalNetSpending =
                                totalExpenseBefore + totalIncomeBefore;
                            double currentTotalNetIncome = totalIncomeBefore;
                            double currentTotalNetExpense = totalExpenseBefore;
                            List<double> totalNetPoints = [];
                            List<double> totalIncomePoints = [];
                            List<double> totalExpensePoints = [];
                            for (int i = amountLoaded - 1; i >= 0; i--) {
                              double expenseSpending =
                                  (nullIfIndexOutOfRange(expenseData, i) ??
                                          TotalWithCount(total: 0, count: 0))
                                      .total;
                              double incomeSpending =
                                  (nullIfIndexOutOfRange(incomeData, i) ??
                                          TotalWithCount(total: 0, count: 0))
                                      .total;

                              double netSpending =
                                  expenseSpending.toDouble().abs() * -1 +
                                      incomeSpending.toDouble().abs();

                              if (widget.appStateSettingsNetAllSpendingTotal) {
                                currentTotalNetSpending += netSpending;
                                currentTotalNetIncome += incomeSpending;
                                currentTotalNetExpense += expenseSpending;
                              } else {
                                currentTotalNetSpending = netSpending;
                                currentTotalNetIncome = incomeSpending;
                                currentTotalNetExpense = expenseSpending;
                              }

                              totalNetPoints.add(currentTotalNetSpending);
                              totalIncomePoints.add(currentTotalNetIncome);
                              totalExpensePoints.add(currentTotalNetExpense);
                            }

                            return SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                                  DateTime datePast =
                                      getDatePastToDetermineBudgetDate(
                                          index, getCustomCycleTempBudget(""));
                                  DateTimeRange budgetRange =
                                      getCycleDateTimeRange("",
                                          currentDate: datePast);
                                  Color containerColor = getPlatform() ==
                                          PlatformOS.isIOS
                                      ? widget.selectedDateTimeRange ==
                                              budgetRange
                                          ? Theme.of(context)
                                              .colorScheme
                                              .secondaryContainer
                                              .withOpacity(0.3)
                                          : Colors.transparent
                                      : getColor(
                                          context, "standardContainerColor");

                                  return buildSpendingHistorySummaryContainer(
                                    index: index,
                                    containerColor: containerColor,
                                    budgetRange: budgetRange,
                                    netSpending: totalNetPoints[
                                        totalNetPoints.length - 1 - index],
                                    incomeSpending: totalIncomePoints[
                                        totalIncomePoints.length - 1 - index],
                                    expenseSpending: totalExpensePoints[
                                        totalExpensePoints.length - 1 - index],
                                  );
                                },
                                childCount: amountLoaded,
                              ),
                            );
                          }),
                          SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  bottom: 45,
                                  top: getPlatform() == PlatformOS.isIOS
                                      ? 10
                                      : 0,
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
                                            getIsFullScreen(context) == false
                                                ? 3
                                                : 5;
                                        loadLines(
                                            amountLoaded + amountMoreToLoad);
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

class AmountSpentEntryRow extends StatelessWidget {
  const AmountSpentEntryRow({
    super.key,
    required this.openPage,
    required this.textColor,
    required this.label,
    required this.totalWithCountStream,
    this.totalWithCountStream2,
    required this.onLongPress,
    this.hide = false,
    this.forceShow = false,
    this.extraText,
    this.absolute = true,
    this.invertSign = false,
  });
  final Color textColor;
  final String label;
  final Widget openPage;
  final Stream<TotalWithCount?> totalWithCountStream;
  final Stream<TotalWithCount?>? totalWithCountStream2;
  final VoidCallback onLongPress;
  final bool hide;
  final bool forceShow;
  final String? extraText;
  final bool absolute;
  final bool invertSign;

  @override
  Widget build(BuildContext context) {
    return DoubleTotalWithCountStreamBuilder(
      totalWithCountStream: totalWithCountStream,
      totalWithCountStream2: totalWithCountStream2,
      builder: (context, snapshot) {
        double totalSpent = absolute
            ? (snapshot.data?.total ?? 0).abs()
            : (snapshot.data?.total ?? 0) * (invertSign == true ? -1 : 1);
        int totalCount = snapshot.data?.count ?? 0;
        return AnimatedExpanded(
          axis: Axis.vertical,
          expand: forceShow || (totalSpent != 0 && hide == false),
          child: OpenContainerNavigation(
            borderRadius: 0,
            openPage: openPage,
            closedColor: getColor(context, "lightDarkAccentHeavyLight"),
            button: (openContainer) {
              return Tappable(
                color: getColor(context, "lightDarkAccentHeavyLight"),
                borderRadius: 0,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Row(
                                children: [
                                  // Constrained box allows us to achieve a full width expander
                                  // Constrained box allows for text wrapping/cut-off since we set a maxWidth
                                  // We can get a layout that is more dynamic and looks like:
                                  // [-----------------------Full Width-------------------------]
                                  // [---Label----] [-------------------------------------------]
                                  // [--------------------Label--------------------] [----------]
                                  // Compared to
                                  // [-----------------------Full Width-------------------------]
                                  // [---------Expanded---------][--Flexible--]
                                  // Where expanded is limited to 50%
                                  // Can see this issue: https://stackoverflow.com/a/74310309
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxWidth: constraints.maxWidth),
                                    child: TextFont(
                                      text: "",
                                      maxLines: 1,
                                      textAlign: TextAlign.left,
                                      richTextSpan: [
                                        TextSpan(
                                          text: label,
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: getColor(context, "black"),
                                            fontFamily:
                                                appStateSettings["font"],
                                            fontFamilyFallback: ['Inter'],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(
                                          text: addAmountToString(
                                              " ", totalCount,
                                              extraText: extraText),
                                          style: TextStyle(
                                            fontSize: 15,
                                            color:
                                                getColor(context, "textLight"),
                                            fontFamily:
                                                appStateSettings["font"],
                                            fontFamilyFallback: ['Inter'],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          left: 15, right: 10, top: 1),
                                      height: 2,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        CountNumber(
                          lazyFirstRender: false,
                          count: totalSpent,
                          duration: Duration(milliseconds: 1000),
                          initialCount: 0,
                          textBuilder: (number) {
                            return TextFont(
                              textAlign: TextAlign.right,
                              text: convertToMoney(
                                Provider.of<AllWallets>(context),
                                number,
                                finalNumber: totalSpent.abs(),
                              ),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              textColor: textColor,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                onTap: () async {
                  openContainer();
                },
                onLongPress: onLongPress,
              );
            },
          ),
        );
      },
    );
  }
}
