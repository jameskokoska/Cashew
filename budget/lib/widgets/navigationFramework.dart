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

  final pageController = PageController();

  void changePage(int page) {
    setState(() {
      currentPage = page;
    });
    // pageController.animateToPage(page,
    //     duration: Duration(milliseconds: 100), curve: Curves.easeInOut);
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        //Handle global back button
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        return false;
      },
      child: Stack(children: [
        Scaffold(
          body: PageView(
            controller: pageController,
            onPageChanged: (int index) {},
            children: pages,
            physics: NeverScrollableScrollPhysics(),
          ),
        ),
        // IndexedStack(
        //   children: pages,
        //   index: currentPage,
        // ),
        BottomNavBar(onChanged: (index) {
          changePage(index);
        }),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 75, right: 15),
            child: Stack(
              children: [
                AnimatedScale(
                  duration: currentPage == 0 || currentPage == 1
                      ? Duration(milliseconds: 1100)
                      : Duration(milliseconds: 0),
                  scale: currentPage == 0 || currentPage == 1 ? 1 : 0,
                  curve: ElasticOutCurve(0.8),
                  child: FAB(
                    tooltip: "Add Transaction",
                    openPage: AddTransactionPage(
                      title: "Add Transaction",
                    ),
                  ),
                ),
                AnimatedScale(
                  duration: currentPage == 2
                      ? Duration(milliseconds: 1100)
                      : Duration(milliseconds: 0),
                  scale: currentPage == 2 ? 1 : 0,
                  curve: ElasticOutCurve(0.8),
                  child: FAB(
                    openPage: AddBudgetPage(title: "Add Budget"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
