import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/moreIcons.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:easy_localization/easy_localization.dart';
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
                        ? getColor(context, "shadowColorLight").withOpacity(0.3)
                        : Theme.of(context).brightness == Brightness.light
                            ? getColor(context, "shadowColorLight")
                                .withOpacity(0.35)
                            : Colors.black.withOpacity(0.8),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                    spreadRadius: 9,
                  ),
                ],
              ),
            ),
            child: Transform.translate(
              offset: Offset(0, -MediaQuery.of(context).padding.bottom),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: NavigationBarTheme(
                  data: NavigationBarThemeData(
                    backgroundColor: appStateSettings["materialYou"]
                        ? null
                        : getColor(context, "lightDarkAccent"),
                    surfaceTintColor: appStateSettings["materialYou"]
                        ? null
                        : getColor(context, "lightDarkAccent"),
                    indicatorColor: appStateSettings["materialYou"]
                        ? dynamicPastel(
                            context, Theme.of(context).colorScheme.primary,
                            amount: 0.6)
                        : null,
                    labelBehavior:
                        NavigationDestinationLabelBehavior.alwaysHide,
                    height: 50,
                  ),
                  child: Transform.translate(
                    offset: Offset(0, MediaQuery.of(context).padding.bottom),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: NavigationBar(
                        animationDuration: Duration(milliseconds: 1000),
                        destinations: [
                          NavigationDestination(
                            icon: Icon(Icons.home_rounded),
                            label: "home-page-title".tr(),
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.payments_rounded),
                            label: "transactions-page-title".tr(),
                          ),
                          NavigationDestination(
                            icon: Icon(MoreIcons.chart_pie, size: 20),
                            label: "budgets-page-title".tr(),
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.more_horiz_rounded),
                            label: "more-actions-page-title".tr(),
                          ),
                        ],
                        selectedIndex: selectedIndex,
                        onDestinationSelected: onItemTapped,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          AbsorbPointer(
            child: Container(
              height: MediaQuery.of(context).viewPadding.bottom > 10 ? 0 : 10,
            ),
          ),
        ],
      ),
    );
  }
}
