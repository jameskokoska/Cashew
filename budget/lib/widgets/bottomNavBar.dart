import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/moreIcons.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
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
      if (index == 0) homePageStateKey.currentState?.scrollToTop();
      if (index == 1) transactionsListPageStateKey.currentState?.scrollToTop();
      if (index == 2) budgetsListPageStateKey.currentState?.scrollToTop();
      if (index == 3) settingsPageStateKey.currentState?.scrollToTop();
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
    if (getIsFullScreen(context)) return SizedBox.shrink();
    if (getPlatform() == PlatformOS.isIOS) {
      return Container(
        decoration: BoxDecoration(
          color: getBottomNavbarBackgroundColor(
            colorScheme: Theme.of(context).colorScheme,
            brightness: Theme.of(context).brightness,
            lightDarkAccent: getColor(context, "lightDarkAccent"),
          ),
          boxShadow: boxShadowSharp(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 2),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      NavBarIcon(
                        onItemTapped: onItemTapped,
                        icon: Icons.home_rounded,
                        index: 0,
                        currentIndex: selectedIndex,
                      ),
                      NavBarIcon(
                        onItemTapped: onItemTapped,
                        icon: Icons.payments_rounded,
                        index: 1,
                        currentIndex: selectedIndex,
                      ),
                      NavBarIcon(
                        onItemTapped: onItemTapped,
                        icon: MoreIcons.chart_pie,
                        index: 2,
                        currentIndex: selectedIndex,
                        customIconScale: 0.87,
                      ),
                      NavBarIcon(
                        onItemTapped: onItemTapped,
                        icon: appStateSettings["outlinedIcons"]
                            ? Icons.more_horiz_outlined
                            : Icons.more_horiz_rounded,
                        index: 3,
                        currentIndex: selectedIndex,
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom)
                ],
              ),
            )
          ],
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        boxShadow: boxShadowSharp(context),
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: getBottomNavbarBackgroundColor(
            colorScheme: Theme.of(context).colorScheme,
            brightness: Theme.of(context).brightness,
            lightDarkAccent: getColor(context, "lightDarkAccent"),
          ),
          surfaceTintColor: Colors.transparent,
          indicatorColor: appStateSettings["materialYou"]
              ? dynamicPastel(context, Theme.of(context).colorScheme.primary,
                  amount: 0.6)
              : null,
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return TextStyle(
                fontFamily: appStateSettings["font"],
                fontSize: 13,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.clip,
              );
            } else {
              return TextStyle(
                fontFamily: appStateSettings["font"],
                fontSize: 13,
                overflow: TextOverflow.clip,
              );
            }
          }),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
        child: NavigationBar(
          animationDuration: Duration(milliseconds: 1000),
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_rounded),
              label: "home".tr(),
              tooltip: "",
            ),
            NavigationDestination(
              icon: Icon(Icons.payments_rounded),
              label: "transactions".tr(),
              tooltip: "",
            ),
            NavigationDestination(
              icon: Icon(MoreIcons.chart_pie, size: 20),
              label: "budgets".tr(),
              tooltip: "",
            ),
            NavigationDestination(
              icon: Icon(appStateSettings["outlinedIcons"]
                  ? Icons.more_horiz_outlined
                  : Icons.more_horiz_rounded),
              label: "more".tr(),
              tooltip: "",
            ),
          ],
          selectedIndex: selectedIndex,
          onDestinationSelected: onItemTapped,
        ),
      ),
    );
  }
}

class NavBarIcon extends StatelessWidget {
  const NavBarIcon({
    required this.onItemTapped,
    required this.icon,
    required this.index,
    required this.currentIndex,
    this.customIconScale = 1,
    super.key,
  });
  final Function(int index) onItemTapped;
  final IconData icon;
  final int index;
  final int currentIndex;
  final double customIconScale;

  @override
  Widget build(BuildContext context) {
    bool selected = currentIndex == index;
    return Stack(
      alignment: Alignment.center,
      children: [
        selected
            ? ScaleIn(
                duration: Duration(milliseconds: 200),
                curve: Curves.fastOutSlowIn,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.secondaryContainer
                        : Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.3),
                  ),
                  height: 52,
                  width: 52,
                  margin: EdgeInsets.all(5),
                ),
              )
            : Container(
                color: Colors.transparent,
                height: 52,
                width: 52,
                margin: EdgeInsets.all(5),
              ),
        IconButton(
          padding: EdgeInsets.all(15),
          color: selected
              ? Theme.of(context).colorScheme.onSecondaryContainer
              : null,
          icon: Transform.scale(
            scale: customIconScale,
            child: Icon(
              icon,
              size: 27,
            ),
          ),
          onPressed: () {
            onItemTapped(index);
          },
        ),
      ],
    );
  }
}
