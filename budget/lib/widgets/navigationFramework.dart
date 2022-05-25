import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/budgetsListPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/homePage.dart';
import 'package:budget/pages/settingsPage.dart';
import 'package:budget/pages/transactionsListPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/bottomNavBar.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:budget/colors.dart';
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
          extendBody: true,
          resizeToAvoidBottomInset: false,
          bottomNavigationBar: BottomNavBar(onChanged: (index) {
            changePage(index);
          }),
        ),
        // IndexedStack(
        //   children: pages,
        //   index: currentPage,
        // ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 75, right: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SelectedTransactionsButton(
                  pageID: "Transactions",
                  currentPage: currentPage,
                  pageToShow: 1,
                ),
                SelectedTransactionsButton(
                  pageID: "0",
                  currentPage: currentPage,
                  pageToShow: 0,
                ),
                Stack(
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
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class SelectedTransactionsButton extends StatelessWidget {
  const SelectedTransactionsButton(
      {Key? key,
      required this.currentPage,
      required this.pageID,
      required this.pageToShow})
      : super(key: key);

  final int currentPage;
  final String pageID;
  final int pageToShow;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: globalSelectedID,
      builder: (context, value, widget) {
        if (currentPage != pageToShow) {
          return Container();
        }
        bool animateIn =
            (value as Map)[pageID] != null && (value as Map)[pageID].length > 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: AnimatedScale(
            duration: animateIn
                ? Duration(milliseconds: 1100)
                : Duration(milliseconds: 500),
            scale: animateIn ? 1 : 0,
            curve: animateIn ? ElasticOutCurve(0.8) : Curves.easeInOutCubic,
            child: Tappable(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: 50,
              child: Container(
                height: 45,
                width: 45,
                child: Center(
                  child: Icon(
                    Icons.delete,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ),
              onTap: () {
                openPopup(
                  context,
                  title: "Delete selected transactions?",
                  description: "Are you sure you want to delete " +
                      (value as Map)["Transactions"].length.toString() +
                      " transactions?",
                  icon: Icons.delete_rounded,
                  onCancel: () {
                    Navigator.pop(context);
                  },
                  onCancelLabel: "Cancel",
                  onSubmit: () {
                    for (int transactionID in (value as Map)[pageID]) {
                      database.deleteTransaction(transactionID);
                    }
                    openSnackbar(
                        context,
                        "Deleted " +
                            (value as Map)[pageID].length.toString() +
                            " transactions");
                    globalSelectedID.value[pageID] = [];
                    globalSelectedID.notifyListeners();
                    Navigator.pop(context);
                  },
                  onSubmitLabel: "Delete",
                );
              },
            ),
          ),
        );
      },
    );
  }
}
