import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/widgets/moreIcons.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({required this.onChanged, Key? key}) : super(key: key);
  final Function(int) onChanged;

  @override
  State<BottomNavBar> createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  int selectedIndex = 0;

  void onItemTapped(int index) {
    if (index == selectedIndex) {
      if (index == 0) homePageStateKey.currentState!.scrollToTop();
      if (index == 1) transactionsListPageStateKey.currentState!.scrollToTop();
      if (index == 2) budgetsListPageStateKey.currentState!.scrollToTop();
      if (index == 3) settingsPageStateKey.currentState!.scrollToTop();
    } else {
      widget.onChanged(index);
      setState(() {
        selectedIndex = index;
      });
    }
    FocusScope.of(context).unfocus(); //remove keyboard focus on any input boxes
  }

  void setSelectedIndex(index) {
    setState(() {
      selectedIndex = index;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    if (getWidthNavigationSidebar(context) > 0) return SizedBox.shrink();
    return Padding(
      //Bottom padding is a container wrapped with absorb pointer
      padding: const EdgeInsets.only(bottom: 0, left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width >= 600 ? 350 : 600),
            decoration: BoxDecoration(
              boxShadow: boxShadowCheck(
                [
                  BoxShadow(
                    color: MediaQuery.of(context).size.width >= 600
                        ? Theme.of(context)
                            .colorScheme
                            .shadowColorLight
                            .withOpacity(0.3)
                        : Theme.of(context).brightness == Brightness.light
                            ? Theme.of(context)
                                .colorScheme
                                .shadowColorLight
                                .withOpacity(0.35)
                            : Colors.black.withOpacity(0.8),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                    spreadRadius: 9,
                  ),
                ],
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  backgroundColor: appStateSettings["materialYou"]
                      ? dynamicPastel(
                          context, Theme.of(context).colorScheme.primary,
                          amount: 0.9)
                      : null,
                  indicatorColor: appStateSettings["materialYou"]
                      ? dynamicPastel(
                          context, Theme.of(context).colorScheme.primary,
                          amount: 0.6)
                      : null,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                  height: 50,
                ),
                child: NavigationBar(
                  animationDuration: Duration(milliseconds: 1000),
                  destinations: [
                    NavigationDestination(
                      icon: Icon(Icons.home_rounded),
                      label: "Home",
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.payments_rounded),
                      label: "Transactions",
                    ),
                    NavigationDestination(
                      icon: Icon(MoreIcons.chart_pie, size: 20),
                      label: "Budgets",
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.more_horiz_rounded),
                      label: "More",
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onItemTapped,
                ),
              ),
            ),
          ),
          AbsorbPointer(
            child: Container(
              height: 10 + bottomPaddingSafeArea,
            ),
          ),
        ],
      ),
    );
  }
}
