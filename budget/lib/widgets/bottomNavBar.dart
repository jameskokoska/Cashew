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
          color: dynamicPastel(
              context, Theme.of(context).colorScheme.secondaryContainer,
              amount: appStateSettings["materialYou"] ? 0.4 : 0.55),
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
                        icon: Icons.more_horiz_rounded,
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
    if (appStateSettings["oldAndroidNavbar"] == true)
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
                  maxWidth:
                      MediaQuery.of(context).size.width >= 600 ? 350 : 600),
              decoration: BoxDecoration(
                boxShadow: boxShadowCheck(
                  [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.light
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
                              label: "home".tr(),
                            ),
                            NavigationDestination(
                              icon: Icon(Icons.payments_rounded),
                              label: "transactions".tr(),
                            ),
                            NavigationDestination(
                              icon: Icon(MoreIcons.chart_pie, size: 20),
                              label: "budgets".tr(),
                            ),
                            NavigationDestination(
                              icon: Icon(Icons.more_horiz_rounded),
                              label: "more-actions".tr(),
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
    return Container(
      decoration: BoxDecoration(
        boxShadow: boxShadowSharp(context),
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: appStateSettings["materialYou"]
              ? null
              : getColor(context, "lightDarkAccent"),
          surfaceTintColor: appStateSettings["materialYou"]
              ? null
              : getColor(context, "lightDarkAccent"),
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
              icon: Icon(Icons.more_horiz_rounded),
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
