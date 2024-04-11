import 'package:budget/colors.dart';
import 'package:budget/database/generatePreviewData.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/homePage/homePageHeatmap.dart';
import 'package:budget/pages/homePage/homePageLineGraph.dart';
import 'package:budget/pages/homePage/homePageNetWorth.dart';
import 'package:budget/pages/homePage/homePageObjectives.dart';
import 'package:budget/pages/homePage/homePagePieChart.dart';
import 'package:budget/pages/homePage/homePageWalletList.dart';
import 'package:budget/pages/homePage/homePageWalletSwitcher.dart';
import 'package:budget/pages/homePage/homeTransactions.dart';
import 'package:budget/pages/homePage/homePageUsername.dart';
import 'package:budget/pages/homePage/homePageBudgets.dart';
import 'package:budget/pages/homePage/homePageUpcomingTransactions.dart';
import 'package:budget/pages/homePage/homePageAllSpendingSummary.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/pages/settingsPage.dart';
import 'package:budget/pages/homePage/homePageCreditDebts.dart';
import 'package:budget/pages/transactionFilters.dart';
import 'package:budget/pages/walletDetailsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/initializeNotifications.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/pieChart.dart';
import 'package:budget/widgets/ratingPopup.dart';
import 'package:budget/widgets/selectedTransactionsAppBar.dart';
import 'package:budget/widgets/util/deepLinks.dart';
import 'package:budget/widgets/util/keepAliveClientMixin.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry/swipeToSelectTransactions.dart';
import 'package:budget/widgets/viewAllTransactionsButton.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:budget/widgets/scrollbarWrap.dart';
import 'package:budget/widgets/slidingSelectorIncomeExpense.dart';
import 'package:budget/widgets/linearGradientFadedEdges.dart';
import 'package:budget/widgets/pullDownToRefreshSync.dart';
import 'package:budget/widgets/util/rightSideClipper.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:provider/provider.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/widgets/util/checkWidgetLaunch.dart';
import 'package:flutter/foundation.dart';

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
    // if (_scrollController.offset <= 0) {
    //   pushRoute(context, EditHomePage());
    // } else {

    // }
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
    Widget slidingSelector = GestureDetector(
      onLongPress: () async {
        HapticFeedback.heavyImpact();
        await openBottomSheet(
          context,
          TransactionsListHomePageBottomSheetSettings(),
        );
        homePageStateKey.currentState?.refreshState();
      },
      child: SlidingSelectorIncomeExpense(
          options: appStateSettings[
                      "homePageTransactionsListIncomeAndExpenseOnly"] ==
                  true
              ? null
              : ["all".tr(), "outgoing".tr(), "incoming".tr()],
          useHorizontalPaddingConstrained: false,
          onSelected: (index) {
            setState(() {
              selectedSlidingSelector = index;
            });
          }),
    );
    Widget? homePageTransactionsList =
        isHomeScreenSectionEnabled(context, "showTransactionsList") == true
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  slidingSelector,
                  SizedBox(height: 8),
                  HomeTransactions(
                      selectedSlidingSelector: selectedSlidingSelector),
                  SizedBox(height: 7),
                  Center(
                    child: ViewAllTransactionsButton(),
                  ),
                  if (enableDoubleColumn(context)) SizedBox(height: 35),
                ],
              )
            : null;
    if (homePageTransactionsList != null)
      homePageTransactionsList = enableDoubleColumn(context)
          ? KeepAliveClientMixin(
              child: homePageTransactionsList,
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
          ? HomePageObjectives(objectiveType: ObjectiveType.goal)
          : null,
      "creditDebts": isHomeScreenSectionEnabled(context, "showCreditDebt")
          ? HomePageCreditDebts()
          : null,
      "objectiveLoans":
          isHomeScreenSectionEnabled(context, "showObjectiveLoans")
              ? HomePageObjectives(objectiveType: ObjectiveType.loan)
              : null,
      "spendingGraph": isHomeScreenSectionEnabled(context, "showSpendingGraph")
          ? HomePageLineGraph(selectedSlidingSelector: selectedSlidingSelector)
          : null,
      "pieChart": isHomeScreenSectionEnabled(context, "showPieChart")
          ? HomePagePieChart()
          : null,
      "heatMap": isHomeScreenSectionEnabled(context, "showHeatMap")
          ? HomePageHeatMap()
          : null,
      "transactionsList": homePageTransactionsList ?? SizedBox.shrink(),
    };
    bool showWelcomeBanner =
        isHomeScreenSectionEnabled(context, "showUsernameWelcomeBanner");
    bool useSmallBanner = showWelcomeBanner == false;

    List<String> homePageSectionsFullScreenCenter = [];
    List<String> homePageSectionsFullScreenLeft = [];
    List<String> homePageSectionsFullScreenRight = [];

    String section = "";

    for (String item
        in appStateSettings[getHomePageOrderSettingsKey(context)]) {
      if (item == "ORDER:LEFT") {
        section = item;
      } else if (item == "ORDER:RIGHT") {
        section = item;
      } else if (section == "ORDER:LEFT") {
        homePageSectionsFullScreenLeft.add(item);
      } else if (section == "ORDER:RIGHT") {
        homePageSectionsFullScreenRight.add(item);
      } else {
        homePageSectionsFullScreenCenter.add(item);
      }
    }

    return SwipeToSelectTransactions(
      listID: "0",
      child: PullDownToRefreshSync(
        scrollController: _scrollController,
        child: Stack(
          children: [
            AndroidOnly(child: CheckWidgetLaunch()),
            AndroidOnly(child: RenderHomePageWidgets()),
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
                            ? Expanded(
                                child: HomePageWelcomeBannerSmall(
                                  showUsername: showUsername,
                                ),
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
                    if (enableDoubleColumn(context) != true) ...[
                      KeepAliveClientMixin(child: HomePageRatingBox()),
                      for (String sectionKey
                          in appStateSettings["homePageOrder"])
                        homePageSections[sectionKey] ?? SizedBox.shrink(),
                    ],
                    // Full screen top section
                    if (enableDoubleColumn(context) == true) ...[
                      for (String sectionKey
                          in appStateSettings["homePageOrderFullScreen"])
                        if (homePageSectionsFullScreenCenter
                            .contains(sectionKey))
                          homePageSections[sectionKey] ?? SizedBox.shrink()
                    ],
                    // Full screen bottom split section
                    if (enableDoubleColumn(context) == true)
                      LayoutBuilder(builder: (context, constraints) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Column(
                                children: [
                                  for (String sectionKey in appStateSettings[
                                      "homePageOrderFullScreen"])
                                    if (homePageSectionsFullScreenLeft
                                        .contains(sectionKey))
                                      LinearGradientFadedEdges(
                                        enableLeft: false,
                                        enableBottom: false,
                                        enableTop: false,
                                        child: ClipRRect(
                                          clipper: RightSideClipper(),
                                          child: homePageSections[sectionKey] ??
                                              SizedBox.shrink(),
                                        ),
                                      ),
                                ],
                              ),
                            ),
                            Flexible(
                              child: Column(
                                children: [
                                  for (String sectionKey in appStateSettings[
                                      "homePageOrderFullScreen"])
                                    if (homePageSectionsFullScreenRight
                                        .contains(sectionKey))
                                      LinearGradientFadedEdges(
                                        enableRight: false,
                                        enableBottom: false,
                                        enableTop: false,
                                        child: ClipRRect(
                                          clipper: RightSideClipper(),
                                          child: homePageSections[sectionKey] ??
                                              SizedBox.shrink(),
                                        ),
                                      ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
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

class HomePageRatingBox extends StatefulWidget {
  const HomePageRatingBox({super.key});

  @override
  State<HomePageRatingBox> createState() => _HomePageRatingBoxState();
}

class _HomePageRatingBoxState extends State<HomePageRatingBox> {
  bool hidden = true;

  @override
  void initState() {
    if ((appStateSettings["numLogins"] + 1) % 13 == 0 &&
        appStateSettings["dismissedStoreRating"] != true &&
        appStateSettings["openedStoreRating"] != true) {
      setState(() {
        hidden = false;
      });
    }
    super.initState();
  }

  hide() {
    setState(() {
      hidden = true;
    });
    updateSettings("dismissedStoreRating", true, updateGlobalState: true);
  }

  open() {
    setState(() {
      hidden = true;
    });
    updateSettings("openedStoreRating", true, updateGlobalState: true);
    inAppReview.openStoreListing(
      appStoreId: "6463662930",
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return SizedBox.shrink();
    return AnimatedSizeSwitcher(
      child: hidden
          ? Container(
              key: ValueKey(1),
            )
          : Padding(
              key: ValueKey(2),
              padding: const EdgeInsets.only(bottom: 13),
              child: Container(
                padding:
                    EdgeInsets.only(left: 15, right: 15, bottom: 18, top: 18),
                margin: EdgeInsets.symmetric(horizontal: 13),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  color: getColor(context, "lightDarkAccentHeavyLight"),
                  boxShadow: boxShadowCheck(boxShadowGeneral(context)),
                ),
                child: Column(
                  children: [
                    TextFont(
                      text: "enjoying-cashew-question".tr(),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    ),
                    SizedBox(height: 7),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextFont(
                        text: "consider-rating".tr(),
                        fontSize: 16,
                        textAlign: TextAlign.center,
                        maxLines: 5,
                      ),
                    ),
                    SizedBox(height: 10),
                    ScalingStars(
                      selectedStars: 5,
                      onTap: (i) {
                        if (i >= 4) {
                          open();
                        } else {
                          shareFeedback(
                            "from-homepage-stars",
                            "rating",
                            selectedStars: i,
                          );
                          hide();
                        }
                      },
                      size: 50,
                      color: getColor(context, "starYellow"),
                      loop: true,
                      loopDelay: Duration(milliseconds: 1900),
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: Opacity(
                            opacity: 0.7,
                            child: Button(
                              label: "no-thanks".tr(),
                              onTap: () {
                                hide();
                              },
                              expandedLayout: true,
                              color: Theme.of(context).colorScheme.tertiary,
                              textColor:
                                  Theme.of(context).colorScheme.onTertiary,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Button(
                            label: "rate".tr(),
                            onTap: () {
                              open();
                            },
                            expandedLayout: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
