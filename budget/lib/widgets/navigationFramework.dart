import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/homePage.dart';
import 'package:budget/pages/settingsPage.dart';
import 'package:budget/widgets/bottomNavBar.dart';
import 'package:budget/widgets/fab.dart';
import 'package:flutter/material.dart';

class PageNavigationFramework extends StatefulWidget {
  const PageNavigationFramework({Key? key}) : super(key: key);

  @override
  State<PageNavigationFramework> createState() =>
      PageNavigationFrameworkState();
}

class PageNavigationFrameworkState extends State<PageNavigationFramework> {
  List<Widget> pages = [HomePage(), Container(), SettingsPage(), Container()];

  final pageController = PageController();
  final GlobalKey<PageNavigationFrameworkState> navigationKey = GlobalKey();

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
        padding: const EdgeInsets.all(50.0),
        child: Row(
          children: [
            FAB(
              openPage: AddTransactionPage(
                title: "Add Transaction",
              ),
            ),
            FAB(
              openPage: AddBudgetPage(title: "Add Budget"),
            ),
            FAB(
              openPage: EditBudgetPage(title: "Edit Budgets"),
            ),
          ],
        ),
      ),
    );
  }
}
