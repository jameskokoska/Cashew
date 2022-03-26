import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/homePage.dart';
import 'package:budget/pages/settingsPage.dart';
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
  List<Widget> pages = [HomePage(), Container(), SettingsPage(), Container()];

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
        padding: const EdgeInsets.all(50.0),
        child: Row(
          children: [
            FAB(
              tooltip: "Add Transaction",
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
            Tappable(
              color: Colors.green,
              child: Container(width: 20, height: 20),
              onTap: () {
                openPopup(
                  context,
                  icon: Icons.ac_unit_outlined,
                  description: "hello",
                );
              },
            ),
            Tappable(
              color: Colors.green,
              child: Container(width: 20, height: 20),
              onTap: () {
                openPopup(context, title: "hello", description: "test");
              },
            ),
            Tappable(
              color: Colors.green,
              child: Container(width: 20, height: 20),
              onTap: () {
                openPopup(
                  context,
                  title: "hello",
                  description: "test",
                  onSubmitLabel: "submit",
                  onCancelLabel: "cancel",
                );
              },
            ),
            Tappable(
              color: Colors.green,
              child: Container(width: 20, height: 20),
              onTap: () {
                openPopup(
                  context,
                  icon: Icons.ac_unit_outlined,
                  description: "hello",
                  onSubmitLabel: "submit",
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
