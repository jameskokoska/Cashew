import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/scrollbarWrap.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
import 'package:budget/struct/shareBudget.dart';
import 'package:budget/widgets/selectedTransactionsAppBar.dart';
import 'package:budget/widgets/monthSelector.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntries.dart';
import 'package:budget/widgets/transactionEntry/swipeToSelectTransactions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:budget/widgets/util/sliverPinnedOverlapInjector.dart';
import 'package:budget/widgets/util/multiDirectionalInfiniteScroll.dart';

class TransactionsListPage extends StatefulWidget {
  const TransactionsListPage({Key? key}) : super(key: key);

  @override
  State<TransactionsListPage> createState() => TransactionsListPageState();
}

class TransactionsListPageState extends State<TransactionsListPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  void refreshState() {
    setState(() {});
  }

  void scrollToTop({int duration = 1200}) {
    if (_scrollController.offset <= 0) {
      pushRoute(context, TransactionsSearchPage());
    } else {
      _scrollController.animateTo(0,
          duration: Duration(
              milliseconds: (getPlatform() == PlatformOS.isIOS
                      ? duration * 0.2
                      : duration)
                  .round()),
          curve: getPlatform() == PlatformOS.isIOS
              ? Curves.easeInOut
              : Curves.elasticOut);
    }
  }

  @override
  bool get wantKeepAlive => true;

  bool showAppBarPaddingOffset = false;
  bool alreadyChanged = false;

  bool scaleInSearchIcon = false;

  late ScrollController _scrollController;
  late PageController _pageController;
  late List<int> selectedTransactionIDs = [];

  GlobalKey<MonthSelectorState> monthSelectorStateKey = GlobalKey();

  onSelected(Transaction transaction, bool selected) {
    // print(transaction.transactionPk.toString() + " selected!");
    // print(globalSelectedID["Transactions"]);
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _pageController = PageController(initialPage: 1000000);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: cancelParentScroll,
      builder: (context, value, widget) {
        return SharedBudgetRefresh(
          scrollController: _scrollController,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  //Minimize keyboard when tap non interactive widget
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                },
                child: NestedScrollView(
                  controller: _scrollController,
                  physics: value ? NeverScrollableScrollPhysics() : null,
                  headerSliverBuilder:
                      (BuildContext contextHeader, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverOverlapAbsorber(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                            contextHeader),
                        sliver: MultiSliver(
                          children: [
                            PageFrameworkSliverAppBar(
                              belowAppBarPaddingWhenCenteredTitleSmall: 0,
                              title: "transactions".tr(),
                              actions: [
                                IconButton(
                                  padding: EdgeInsets.all(15),
                                  tooltip: "search-transactions".tr(),
                                  onPressed: () {
                                    pushRoute(
                                        context, TransactionsSearchPage());
                                  },
                                  icon: Icon(appStateSettings["outlinedIcons"]
                                      ? Icons.search_outlined
                                      : Icons.search_rounded),
                                ),
                              ],
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: MonthSelector(
                                  key: monthSelectorStateKey,
                                  setSelectedDateStart:
                                      (DateTime currentDateTime, int index) {
                                    if (((_pageController.page ?? 0) -
                                                index -
                                                _pageController.initialPage)
                                            .abs() ==
                                        1) {
                                      _pageController.animateToPage(
                                        _pageController.initialPage + index,
                                        duration: Duration(milliseconds: 1000),
                                        curve: Curves.easeInOutCubicEmphasized,
                                      );
                                    } else {
                                      _pageController.jumpToPage(
                                        _pageController.initialPage + index,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                  body: Stack(
                    children: [
                      Builder(
                        builder: (contextPageView) {
                          return PageView.builder(
                            controller: _pageController,
                            onPageChanged: (int index) {
                              final int pageOffset =
                                  index - _pageController.initialPage;
                              DateTime startDate = DateTime(DateTime.now().year,
                                  DateTime.now().month + pageOffset);
                              monthSelectorStateKey.currentState
                                  ?.setSelectedDateStart(startDate, pageOffset);
                              double middle = -(MediaQuery.sizeOf(context)
                                              .width -
                                          getWidthNavigationSidebar(context)) /
                                      2 +
                                  100 / 2;
                              monthSelectorStateKey.currentState?.scrollTo(
                                  middle + (pageOffset - 1) * 100 + 100);
                              // transactionsListPageStateKey.currentState!
                              //     .scrollToTop();
                            },
                            itemBuilder: (BuildContext context, int index) {
                              final int pageOffset =
                                  index - _pageController.initialPage;
                              DateTime startDate = DateTime(DateTime.now().year,
                                  DateTime.now().month + pageOffset);

                              return SwipeToSelectTransactions(
                                listID: "Transactions",
                                child: ScrollbarWrap(
                                  child: CustomScrollView(
                                    slivers: [
                                      SliverPinnedOverlapInjector(
                                        handle: NestedScrollView
                                            .sliverOverlapAbsorberHandleFor(
                                                contextPageView),
                                      ),
                                      TransactionEntries(
                                        renderType: TransactionEntriesRenderType
                                            .implicitlyAnimatedSlivers,
                                        startDate,
                                        new DateTime(
                                            startDate.year,
                                            startDate.month + 1,
                                            startDate.day - 1),
                                        onSelected: onSelected,
                                        listID: "Transactions",
                                        noResultsMessage: "no-transactions-for"
                                                .tr() +
                                            " " +
                                            getMonth(startDate,
                                                includeYear: startDate.year !=
                                                    DateTime.now().year) +
                                            ".",
                                        showTotalCashFlow: true,
                                        enableSpendingSummary: true,
                                        showSpendingSummary: appStateSettings[
                                            "showTransactionsMonthlySpendingSummary"],
                                        onLongPressSpendingSummary: () {
                                          openBottomSheet(
                                            context,
                                            PopupFramework(
                                              hasPadding: false,
                                              child: Column(
                                                children: [
                                                  TextFont(
                                                    text:
                                                        "enabled-in-settings-at-any-time"
                                                            .tr(),
                                                    fontSize: 14,
                                                    maxLines: 5,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  SizedBox(height: 5),
                                                  ShowTransactionsMonthlySpendingSummarySettingToggle(),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),

                                      // Wipe all remaining pixels off - sometimes graphics artifacts are left behind
                                      SliverToBoxAdapter(
                                        child: SizedBox(
                                          height: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      getIsFullScreen(context) == false
                          ? SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  padding: EdgeInsets.all(15),
                                  icon: Icon(
                                    appStateSettings["outlinedIcons"]
                                        ? Icons.arrow_left_outlined
                                        : Icons.arrow_left_rounded,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    _pageController.animateToPage(
                                      (_pageController.page ??
                                                  _pageController.initialPage)
                                              .round() -
                                          1,
                                      duration: Duration(milliseconds: 1000),
                                      curve: Curves.easeInOutCubicEmphasized,
                                    );
                                  },
                                ),
                              ),
                            ),
                      getIsFullScreen(context) == false
                          ? SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  padding: EdgeInsets.all(15),
                                  icon: Icon(
                                    appStateSettings["outlinedIcons"]
                                        ? Icons.arrow_right_outlined
                                        : Icons.arrow_right_rounded,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    _pageController.animateToPage(
                                      (_pageController.page ??
                                                  _pageController.initialPage)
                                              .round() +
                                          1,
                                      duration: Duration(milliseconds: 1000),
                                      curve: Curves.easeInOutCubicEmphasized,
                                    );
                                  },
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              SelectedTransactionsAppBar(
                pageID: "Transactions",
              ),
            ],
          ),
        );
      },
    );
  }
}

class TransactionsSettings extends StatelessWidget {
  const TransactionsSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowTransactionsMonthlySpendingSummarySettingToggle();
  }
}

class ShowTransactionsMonthlySpendingSummarySettingToggle
    extends StatelessWidget {
  const ShowTransactionsMonthlySpendingSummarySettingToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerSwitch(
      title: "monthly-spending-summary".tr(),
      description: "monthly-spending-summary-description".tr(),
      onSwitched: (value) {
        updateSettings("showTransactionsMonthlySpendingSummary", value,
            updateGlobalState: false, pagesNeedingRefresh: [1]);
      },
      initialValue: appStateSettings["showTransactionsMonthlySpendingSummary"],
      icon: appStateSettings["outlinedIcons"]
          ? Icons.balance_outlined
          : Icons.balance_rounded,
    );
  }
}
