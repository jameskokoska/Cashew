import 'package:budget/functions.dart';
import 'package:budget/pages/homePage/homePageLineGraph.dart';
import 'package:budget/pages/homePage/homePageWalletSwitcher.dart';
import 'package:budget/pages/homePage/homeTransactionSlivers.dart';
import 'package:budget/pages/homePage/homeUpcomingTransactionSlivers.dart';
import 'package:budget/pages/homePage/homePageUsername.dart';
import 'package:budget/pages/homePage/homePageBudgets.dart';
import 'package:budget/pages/homePage/homePageUpcomingTransactions.dart';
import 'package:budget/pages/homePage/homePageAllSpendingSummary.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/pages/settingsPage.dart';
import 'package:budget/pages/homePage/homePageCreditDebts.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/struct/shareBudget.dart';
import 'package:budget/widgets/selectedTransactionsActionBar.dart';
import 'package:budget/widgets/keepAliveClientMixin.dart';
import 'package:budget/widgets/viewAllTransactionsButton.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/material.dart';
import 'package:budget/widgets/scrollbarWrap.dart';
import 'package:budget/widgets/slidingSelectorIncomeExpense.dart';

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

  void scrollToTop() {
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 1200), curve: Curves.elasticOut);
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
    if (percent >= 0 && percent <= 1) {
      _animationControllerHeader.value = 1 - _scrollController.offset / (200);
      _animationControllerHeader2.value =
          1 - _scrollController.offset * 2 / (200);
    }
  }

  @override
  void dispose() {
    _animationControllerHeader.dispose();
    _animationControllerHeader2.dispose();
    _scrollController.dispose();
    super.dispose();
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

    Map<String, Widget> homePageSections = {
      "wallets": HomePageWalletSwitcher(),
      "budgets": HomePageBudgets(),
      "overdueUpcoming": HomePageUpcomingTransactions(),
      "allSpendingSummary": HomePageAllSpendingSummary(),
      "creditDebts": HomePageCreditDebts(),
      "spendingGraph":
          HomePageLineGraph(selectedSlidingSelector: selectedSlidingSelector),
    };
    return SwipeToSelectTransactions(
      listID: "0",
      child: SharedBudgetRefresh(
        scrollController: _scrollController,
        child: Stack(
          children: [
            Scaffold(
              // resizeToAvoidBottomInset: false,
              resizeToAvoidBottomInset: true,
              body: ScrollbarWrap(
                child: ListView(
                  controller: _scrollController,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        enableDoubleColumn(context)
                            ? SizedBox(height: 78)
                            : IconButton(
                                padding: EdgeInsets.all(15),
                                onPressed: () async {
                                  await pushRoute(context, EditHomePage());
                                  // We need to refresh the home page when this route is popped
                                  setState(() {});
                                },
                                icon: Icon(Icons.more_vert_rounded),
                              ),
                        // PopupMenuButton<String>(
                        //   icon: Opacity(
                        //     opacity: 0.5,
                        //     child: Icon(Icons.more_vert_rounded),
                        //   ),
                        //   onSelected: (option) {
                        //     if (option == "Edit")
                        //       pushRoute(context, EditHomePage());
                        //   },
                        //   itemBuilder: (BuildContext context) {
                        //     return {'Edit'}.map((String choice) {
                        //       return PopupMenuItem<String>(
                        //         value: choice,
                        //         child: Text(choice),
                        //       );
                        //     }).toList();
                        //   },
                        // ),
                      ],
                    ),
                    // Wipe all remaining pixels off - sometimes graphics artifacts are left behind
                    Container(height: 1, color: Theme.of(context).canvasColor),

                    Container(
                      // Subtract one (1) here because of the thickness of the wiper above
                      height: 179 -
                          1 +
                          (MediaQuery.of(context).padding.top > 30
                              ? 30
                              : MediaQuery.of(context).padding.top) -
                          48 -
                          10,
                      alignment: Alignment.bottomLeft,
                      padding: EdgeInsets.only(left: 9, bottom: 17, right: 9),

                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Profile icon
                          // AnimatedBuilder(
                          //   animation: _animationControllerHeader,
                          //   builder: (_, child) {
                          //     return Transform.scale(
                          //       alignment: Alignment.bottomRight,
                          //       scale: _animationControllerHeader.value < 0.5
                          //           ? 0.25 + 0.5
                          //           : (_animationControllerHeader.value) * 0.5 +
                          //               0.5,
                          //       child: child,
                          //     );
                          //   },
                          //   child: Container(
                          //     width: 50,
                          //     height: 50,
                          //     color: Colors.red,
                          //   ),
                          // ),
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
                    ...[
                      for (String sectionKey
                          in appStateSettings["homePageOrder"])
                        enableDoubleColumn(context) == true
                            ? SizedBox.shrink()
                            : homePageSections[sectionKey] ?? SizedBox.shrink()
                    ],
                    enableDoubleColumn(context) == false
                        ? SizedBox.shrink()
                        : HomePageWalletSwitcher(),
                    enableDoubleColumn(context) == false
                        ? SizedBox.shrink()
                        : HomePageBudgets(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // enableDoubleColumn(context) == false
                              //     ? SizedBox.shrink()
                              //     : HomePageAllSpendingSummary(),
                              enableDoubleColumn(context) == false
                                  ? SizedBox.shrink()
                                  : HomePageUpcomingTransactions(),
                              enableDoubleColumn(context) == false
                                  ? SizedBox.shrink()
                                  : HomePageCreditDebts(),
                              enableDoubleColumn(context) == false
                                  ? SizedBox.shrink()
                                  : HomePageLineGraph(
                                      selectedSlidingSelector:
                                          selectedSlidingSelector),
                            ],
                          ),
                        ),
                        enableDoubleColumn(context) == false
                            ? SizedBox.shrink()
                            : Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      slidingSelector,
                                      SizedBox(height: 8),
                                      HomeUpcomingTransactionSlivers(),
                                      HomeTransactionSlivers(
                                          selectedSlidingSelector:
                                              selectedSlidingSelector),
                                      SizedBox(height: 7),
                                      Center(
                                          child: ViewAllTransactionsButton()),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ),
                    enableDoubleColumn(context) == true
                        ? SizedBox.shrink()
                        : KeepAliveClientMixin(
                            child: slidingSelector,
                          ),
                    enableDoubleColumn(context) == true
                        ? SizedBox.shrink()
                        : KeepAliveClientMixin(
                            child: SizedBox(height: 8),
                          ),
                    enableDoubleColumn(context) == true
                        ? SizedBox.shrink()
                        : KeepAliveClientMixin(
                            child: HomeUpcomingTransactionSlivers(),
                          ),
                    enableDoubleColumn(context) == true
                        ? SizedBox.shrink()
                        : HomeTransactionSlivers(
                            selectedSlidingSelector: selectedSlidingSelector),
                    enableDoubleColumn(context) == true
                        ? SizedBox.shrink()
                        : Container(height: 7),
                    enableDoubleColumn(context) == true
                        ? SizedBox.shrink()
                        : Center(child: ViewAllTransactionsButton()),
                    SizedBox(height: 40),
                    // Wipe all remaining pixels off - sometimes graphics artifacts are left behind
                    Container(height: 1, color: Theme.of(context).canvasColor),
                  ],
                ),
              ),
            ),
            SelectedTransactionsActionBar(
              pageID: "0",
            ),
          ],
        ),
      ),
    );
  }
}
