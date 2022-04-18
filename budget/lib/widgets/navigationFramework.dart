import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/budgetsListPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/homePage.dart';
import 'package:budget/pages/settingsPage.dart';
import 'package:budget/pages/transactionsListPage.dart';
import 'package:budget/widgets/bottomNavBar.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:flutter/material.dart';

class PageNavigationFramework extends StatefulWidget {
  const PageNavigationFramework({Key? key}) : super(key: key);

  @override
  State<PageNavigationFramework> createState() =>
      PageNavigationFrameworkState();
}

//can also do GlobalKey<dynamic> for private state classes, but bad practice and no autocomplete
GlobalKey<HomePageState> homePageStateKey = GlobalKey();
GlobalKey<TransactionsListPageState> transactionsListPageStateKey = GlobalKey();
GlobalKey<BudgetsListPageState> budgetsListPageStateKey = GlobalKey();
GlobalKey<SettingsPageState> settingsPageStateKey = GlobalKey();

class PageNavigationFrameworkState extends State<PageNavigationFramework> {
  List<Widget> pages = [
    HomePage(key: homePageStateKey),
    TransactionsListPage(key: transactionsListPageStateKey),
    BudgetsListPage(key: budgetsListPageStateKey),
    SettingsPage(key: settingsPageStateKey)
  ];

  int currentPage = 0;
  Map<int, bool> pagesNeedingRefresh = {
    0: false,
    1: false,
    2: false,
    3: false,
  };

  sendRequestRefresh(List<int> newPagesNeedingRefresh) {
    for (int page in newPagesNeedingRefresh) {
      print("page" + page.toString());
      print("currentPage" + currentPage.toString());

      if (currentPage == 0 && page == 0) {
        homePageStateKey.currentState?.refreshState();
      } else if (currentPage == 1 && page == 1) {
        transactionsListPageStateKey.currentState?.refreshState();
      } else if (currentPage == 2 && page == 2) {
        budgetsListPageStateKey.currentState?.refreshState();
      } else if (currentPage == 3 && page == 3) {
        settingsPageStateKey.currentState?.refreshState();
      } else {
        pagesNeedingRefresh[page] = true;
      }
    }
    print(pagesNeedingRefresh);
  }

  final pageController = PageController();

  void changePage(int page) {
    setState(() {
      currentPage = page;
    });
    // pageController.animateToPage(page,
    //     duration: Duration(milliseconds: 100), curve: Curves.easeInOut);
    pageController.jumpToPage(page);

    // Send a request for refresh, if this page needs to be updated
    if (pagesNeedingRefresh[currentPage] == true) {
      print("UPDATING CURRENT PAGE");
      sendRequestRefresh([currentPage]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        PageView(
          controller: pageController,
          onPageChanged: (int index) {},
          children: pages,
          physics: NeverScrollableScrollPhysics(),
        ),
        // IndexedStack(
        //   children: pages,
        //   index: index,
        // ),
        BottomNavBar(onChanged: (index) {
          changePage(index);
        }),
      ]),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60, right: 10),
        child: Stack(
          children: [
            AnimatedScale(
              duration: currentPage == 0 || currentPage == 1
                  ? Duration(milliseconds: 1300)
                  : Duration(milliseconds: 0),
              scale: currentPage == 0 || currentPage == 1 ? 1 : 0,
              curve: Curves.elasticOut,
              child: FAB(
                tooltip: "Add Transaction",
                openPage: AddTransactionPage(
                  title: "Add Transaction",
                ),
              ),
            ),
            AnimatedScale(
              duration: currentPage == 2
                  ? Duration(milliseconds: 1300)
                  : Duration(milliseconds: 0),
              scale: currentPage == 2 ? 1 : 0,
              curve: Curves.elasticOut,
              child: FAB(
                openPage: AddBudgetPage(title: "Add Budget"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
