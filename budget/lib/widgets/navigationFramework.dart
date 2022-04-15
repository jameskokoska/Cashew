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

class PageNavigationFrameworkState extends State<PageNavigationFramework> {
  List<Widget> pages = [
    HomePage(),
    TransactionsListPage(),
    BudgetsListPage(),
    SettingsPage()
  ];

  final pageController = PageController();

  void changePage(int index2) {
    // pageController.animateToPage(index,
    //     duration: Duration(milliseconds: 100), curve: Curves.easeInOut);
    // pageController.jumpToPage(index);

    setState(() {
      index = index2;
    });
  }

  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        // PageView(
        //   controller: pageController,
        //   onPageChanged: (int index) {},
        //   children: pages,
        //   physics: NeverScrollableScrollPhysics(),
        // ),
        IndexedStack(
          children: pages,
          index: index,
        ),
        BottomNavBar(onChanged: (index) {
          changePage(index);
        }),
      ]),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60, right: 10),
        child: Stack(
          children: [
            AnimatedScale(
              duration: index == 0 || index == 1
                  ? Duration(milliseconds: 1300)
                  : Duration(milliseconds: 0),
              scale: index == 0 || index == 1 ? 1 : 0,
              curve: Curves.elasticOut,
              child: FAB(
                tooltip: "Add Transaction",
                openPage: AddTransactionPage(
                  title: "Add Transaction",
                ),
              ),
            ),
            AnimatedScale(
              duration: index == 2
                  ? Duration(milliseconds: 1300)
                  : Duration(milliseconds: 0),
              scale: index == 2 ? 1 : 0,
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
