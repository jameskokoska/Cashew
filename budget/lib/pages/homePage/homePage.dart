import 'package:budget/colors.dart';
import 'package:budget/database/generatePreviewData.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/homePage/homePageHeatmap.dart';
import 'package:budget/pages/homePage/homePageLineGraph.dart';
import 'package:budget/pages/homePage/homePageNetWorth.dart';
import 'package:budget/pages/homePage/homePageObjectives.dart';
import 'package:budget/pages/homePage/homePagePieChart.dart';
import 'package:budget/pages/homePage/homePageWalletList.dart';
import 'package:budget/pages/homePage/homePageWalletSwitcher.dart';
import 'package:budget/pages/homePage/homeTransactions.dart';
import 'package:budget/pages/homePage/homeUpcomingTransactions.dart';
import 'package:budget/pages/homePage/homePageUsername.dart';
import 'package:budget/pages/homePage/homePageBudgets.dart';
import 'package:budget/pages/homePage/homePageUpcomingTransactions.dart';
import 'package:budget/pages/homePage/homePageAllSpendingSummary.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/pages/settingsPage.dart';
import 'package:budget/pages/homePage/homePageCreditDebts.dart';
import 'package:budget/struct/currencyFunctions.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/struct/shareBudget.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/lineGraph.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/selectedTransactionsAppBar.dart';
import 'package:budget/widgets/util/keepAliveClientMixin.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntries.dart';
import 'package:budget/widgets/transactionEntry/swipeToSelectTransactions.dart';
import 'package:budget/widgets/transactionEntry/transactionEntryAmount.dart';
import 'package:budget/widgets/viewAllTransactionsButton.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:budget/widgets/scrollbarWrap.dart';
import 'package:budget/widgets/slidingSelectorIncomeExpense.dart';
import 'package:provider/provider.dart';

import '../../widgets/linearGradientFadedEdges.dart';
import '../../widgets/pullDownToRefreshSync.dart';
import '../../widgets/util/rightSideClipper.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  void refreshState() {
    setState(() {});
  }

  void scrollToTop({int duration = 1200}) {
    _scrollController.animateTo(0,
        duration: Duration(
            milliseconds:
                (getPlatform() == PlatformOS.isIOS ? duration * 0.2 : duration)
                    .round()),
        curve: getPlatform() == PlatformOS.isIOS
            ? Curves.easeInOut
            : Curves.elasticOut);
  }

  @override
  bool get wantKeepAlive => true;
  bool showElevation = false;
  late ScrollController _scrollController;
  late AnimationController _animationControllerHeader;
  late AnimationController _animationControllerHeader2;
  int selectedSlidingSelector = 1;

  void initState() {
    super.initState();
    _animationControllerHeader = AnimationController(vsync: this, value: 1);
    _animationControllerHeader2 = AnimationController(vsync: this, value: 1);

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  _scrollListener() {
    double percent = _scrollController.offset / (200);
    if (percent <= 1) {
      double offset = _scrollController.offset;
      if (percent >= 1) offset = 0;
      _animationControllerHeader.value = 1 - offset / (200);
      _animationControllerHeader2.value = 1 - offset * 2 / (200);
    }
  }

  @override
  void dispose() {
    _animationControllerHeader.dispose();
    _animationControllerHeader2.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool areAllDisabledAfterTransactionsList(
      Map<String, Widget?> homePageSections) {
    int countAfter = -1;
    for (String sectionKey in appStateSettings["homePageOrder"]) {
      if (sectionKey == "transactionsList" &&
          homePageSections[sectionKey] != null) {
        countAfter = 0;
      } else if (countAfter == 0 && homePageSections[sectionKey] != null) {
        countAfter++;
      }
    }
    return countAfter == 0;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    bool showUsername = appStateSettings["username"] != "";
    Widget slidingSelector = SlidingSelectorIncomeExpense(
        useHorizontalPaddingConstrained: false,
        onSelected: (index) {
          setState(() {
            selectedSlidingSelector = index;
          });
        });
    Widget? homePageTransactionsList =
        isHomeScreenSectionEnabled(context, "showTransactionsList") == true ||
                enableDoubleColumn(context)
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  slidingSelector,
                  SizedBox(height: 8),
                  HomeUpcomingTransactions(
                      selectedSlidingSelector: selectedSlidingSelector),
                  HomeTransactions(
                      selectedSlidingSelector: selectedSlidingSelector),
                  SizedBox(height: 7),
                  Center(
                    child: ViewAllTransactionsButton(),
                  ),
                ],
              )
            : null;
    if (homePageTransactionsList != null)
      homePageTransactionsList = enableDoubleColumn(context)
          ? Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 5),
                child: homePageTransactionsList,
              ),
            )
          : KeepAliveClientMixin(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: homePageTransactionsList,
              ),
            );

    Map<String, Widget?> homePageSections = {
      "wallets": isHomeScreenSectionEnabled(context, "showWalletSwitcher")
          ? HomePageWalletSwitcher()
          : null,
      "walletsList": isHomeScreenSectionEnabled(context, "showWalletList")
          ? HomePageWalletList()
          : null,
      "budgets": isHomeScreenSectionEnabled(context, "showPinnedBudgets")
          ? HomePageBudgets()
          : null,
      "overdueUpcoming":
          isHomeScreenSectionEnabled(context, "showOverdueUpcoming")
              ? HomePageUpcomingTransactions()
              : null,
      "allSpendingSummary":
          isHomeScreenSectionEnabled(context, "showAllSpendingSummary")
              ? HomePageAllSpendingSummary()
              : null,
      "netWorth": isHomeScreenSectionEnabled(context, "showNetWorth")
          ? HomePageNetWorth()
          : null,
      "objectives": isHomeScreenSectionEnabled(context, "showObjectives")
          ? HomePageObjectives()
          : null,
      "creditDebts": isHomeScreenSectionEnabled(context, "showCreditDebt")
          ? HomePageCreditDebts()
          : null,
      "spendingGraph": isHomeScreenSectionEnabled(context, "showSpendingGraph")
          ? HomePageLineGraph(selectedSlidingSelector: selectedSlidingSelector)
          : null,
      "pieChart": isHomeScreenSectionEnabled(context, "showPieChart")
          ? HomePagePieChart(selectedSlidingSelector: selectedSlidingSelector)
          : null,
      "heatMap": isHomeScreenSectionEnabled(context, "showHeatMap")
          ? HomePageHeatMap()
          : null,
      "transactionsList": homePageTransactionsList ?? SizedBox.shrink(),
    };
    bool showWelcomeBanner =
        isHomeScreenSectionEnabled(context, "showUsernameWelcomeBanner");
    bool useSmallBanner = showWelcomeBanner == false;

    List<String> homePageSectionsAboveInFullScreen = [
      "wallets",
      "budgets",
    ];
    return SwipeToSelectTransactions(
      listID: "0",
      child: PullDownToRefreshSync(
        scrollController: _scrollController,
        child: Stack(
          children: [
            Scaffold(
              resizeToAvoidBottomInset: false,
              body: ScrollbarWrap(
                child: ListView(
                  controller: _scrollController,
                  children: [
                    PreviewDemoWarning(),
                    if (useSmallBanner) SizedBox(height: 13),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        useSmallBanner
                            ? HomePageWelcomeBannerSmall(
                                showUsername: showUsername,
                              )
                            : SizedBox.shrink(),
                        Tooltip(
                          message: "edit-home".tr(),
                          child: IconButton(
                            padding: EdgeInsets.all(15),
                            onPressed: () {
                              pushRoute(context, EditHomePage());
                            },
                            icon: Icon(appStateSettings["outlinedIcons"]
                                ? Icons.more_vert_outlined
                                : Icons.more_vert_rounded),
                          ),
                        ),
                      ],
                    ),
                    // Wipe all remaining pixels off - sometimes graphics artifacts are left behind
                    Container(height: 1, color: Theme.of(context).canvasColor),

                    showWelcomeBanner
                        ? ConstrainedBox(
                            constraints: BoxConstraints(
                                minHeight: getExpandedHeaderHeight(
                                        context, null,
                                        isHomePageSpace: true) /
                                    1.34),
                            child: Container(
                              // Subtract one (1) here because of the thickness of the wiper above
                              alignment: Alignment.bottomLeft,
                              padding: EdgeInsets.only(
                                  left: 9,
                                  bottom: enableDoubleColumn(context) ? 10 : 17,
                                  right: 9),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  HomePageUsername(
                                    animationControllerHeader:
                                        _animationControllerHeader,
                                    animationControllerHeader2:
                                        _animationControllerHeader2,
                                    showUsername: showUsername,
                                    appStateSettings: appStateSettings,
                                    enterNameBottomSheet: enterNameBottomSheet,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SizedBox(height: 5),
                    // Not full screen
                    ...[
                      for (String sectionKey
                          in appStateSettings["homePageOrder"])
                        enableDoubleColumn(context) == true
                            ? SizedBox.shrink()
                            : homePageSections[sectionKey] ?? SizedBox.shrink()
                    ],
                    // Full screen top section
                    ...[
                      for (String sectionKey
                          in appStateSettings["homePageOrder"])
                        enableDoubleColumn(context) == false ||
                                homePageSectionsAboveInFullScreen
                                        .contains(sectionKey) ==
                                    false
                            ? SizedBox.shrink()
                            : homePageSections[sectionKey] ?? SizedBox.shrink()
                    ],
                    // Full screen bottom split section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              for (String sectionKey
                                  in appStateSettings["homePageOrder"])
                                enableDoubleColumn(context) == false ||
                                        homePageSectionsAboveInFullScreen
                                                .contains(sectionKey) ==
                                            true ||
                                        sectionKey == "transactionsList"
                                    // Always show the transactions list in split section
                                    ? SizedBox.shrink()
                                    : homePageSections[sectionKey] ??
                                        SizedBox.shrink(),
                            ],
                          ),
                        ),
                        enableDoubleColumn(context) == false
                            ? SizedBox.shrink()
                            : homePageSections["transactionsList"] ??
                                SizedBox.shrink()
                      ],
                    ),
                    SizedBox(
                      height: enableDoubleColumn(context) == true
                          ? 40
                          : areAllDisabledAfterTransactionsList(
                                  homePageSections)
                              ? 25
                              : 73,
                    ),
                    // Wipe all remaining pixels off - sometimes graphics artifacts are left behind
                    Container(height: 1, color: Theme.of(context).canvasColor),
                  ],
                ),
              ),
            ),
            SelectedTransactionsAppBar(
              pageID: "0",
            ),
          ],
        ),
      ),
    );
  }
}
