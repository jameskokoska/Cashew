import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/editObjectivesPage.dart';
import 'package:budget/pages/subscriptionsPage.dart';
import 'package:budget/pages/transactionsListPage.dart';
import 'package:budget/pages/upcomingOverdueTransactionsPage.dart';
import 'package:budget/struct/navBarIconsData.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/iconButtonScaled.dart';
import 'package:budget/widgets/moreIcons.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/outlinedButtonStacked.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:flutter/services.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({required this.onChanged, Key? key}) : super(key: key);
  final Function(int) onChanged;

  @override
  State<BottomNavBar> createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  int selectedIndex = 0;

  void onItemTapped(int index, {bool allowReApply = false}) {
    int navigationIndex = index;

    try {
      // Index 1 and 2 can be customized
      if (index == 1) {
        navigationIndex =
            navBarIconsData[appStateSettings["customNavBarShortcut1"]]!
                .navigationIndexedStackIndex;
      } else if (index == 2) {
        navigationIndex =
            navBarIconsData[appStateSettings["customNavBarShortcut2"]]!
                .navigationIndexedStackIndex;
      }
    } catch (e) {
      print(e.toString() + " Problem accessing the navigation index");
    }

    if (index == selectedIndex && allowReApply == false) {
      if (index == 0) homePageStateKey.currentState?.scrollToTop();
      if (navigationIndex == 1)
        transactionsListPageStateKey.currentState?.scrollToTop();
      if (navigationIndex == 2)
        budgetsListPageStateKey.currentState?.scrollToTop();
      if (index == 3) settingsPageStateKey.currentState?.scrollToTop();
    } else {
      // We need to change to the navigation index, however the selectedIndex remains unchanged
      // Since the selectedIndex is the index of the selected navigation bar entry
      widget.onChanged(navigationIndex);
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
                        icon: navBarIconsData["home"]!.iconData,
                        index: 0,
                        currentIndex: selectedIndex,
                      ),
                      CustomizableNavigationBarIcon(
                        shortcutAppSettingKey: "customNavBarShortcut1",
                        afterSet: () {
                          onItemTapped(1, allowReApply: true);
                        },
                        navigationBarIconBuilder: (NavBarIconData iconData) {
                          return NavBarIcon(
                            icon: iconData.iconData,
                            customIconScale: iconData.iconScale,
                            onItemTapped: onItemTapped,
                            index: 1,
                            currentIndex: selectedIndex,
                          );
                        },
                      ),
                      CustomizableNavigationBarIcon(
                        shortcutAppSettingKey: "customNavBarShortcut2",
                        afterSet: () {
                          onItemTapped(2, allowReApply: true);
                        },
                        navigationBarIconBuilder: (NavBarIconData iconData) {
                          return NavBarIcon(
                            icon: iconData.iconData,
                            customIconScale: iconData.iconScale,
                            onItemTapped: onItemTapped,
                            index: 2,
                            currentIndex: selectedIndex,
                          );
                        },
                      ),
                      NavBarIcon(
                        onItemTapped: onItemTapped,
                        icon: navBarIconsData["more"]!.iconData,
                        index: 3,
                        currentIndex: selectedIndex,
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.paddingOf(context).bottom)
                ],
              ),
            )
          ],
        ),
      );
    }
    // Android navbar
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
                fontFamilyFallback: ['Inter'],
                fontSize: 13,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.clip,
              );
            } else {
              return TextStyle(
                fontFamily: appStateSettings["font"],
                fontFamilyFallback: ['Inter'],
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
              icon: Icon(navBarIconsData["home"]!.iconData),
              label: navBarIconsData["home"]!.label.tr(),
              tooltip: "",
            ),
            CustomizableNavigationBarIcon(
              shortcutAppSettingKey: "customNavBarShortcut1",
              afterSet: () {
                onItemTapped(1, allowReApply: true);
              },
              navigationBarIconBuilder: (NavBarIconData iconData) {
                return NavigationDestination(
                  icon: Icon(iconData.iconData, size: iconData.iconSize),
                  label: iconData.label.tr(),
                  tooltip: "",
                );
              },
            ),
            CustomizableNavigationBarIcon(
              shortcutAppSettingKey: "customNavBarShortcut2",
              afterSet: () {
                onItemTapped(2, allowReApply: true);
              },
              navigationBarIconBuilder: (NavBarIconData iconData) {
                return NavigationDestination(
                  icon: Icon(iconData.iconData, size: iconData.iconSize),
                  label: iconData.label.tr(),
                  tooltip: "",
                );
              },
            ),
            NavigationDestination(
              icon: Icon(navBarIconsData["more"]!.iconData),
              label: navBarIconsData["more"]!.label.tr(),
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

class CustomizableNavigationBarIcon extends StatelessWidget {
  const CustomizableNavigationBarIcon({
    required this.navigationBarIconBuilder,
    required this.shortcutAppSettingKey,
    required this.afterSet,
    super.key,
  });
  final Widget Function(NavBarIconData) navigationBarIconBuilder;
  final String shortcutAppSettingKey;
  final VoidCallback afterSet;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        HapticFeedback.heavyImpact();
        dynamic result = await openBottomSheet(
          context,
          PopupFramework(
            title: "select-shortcut".tr(),
            child: SelectNavBarShortcutPopup(
              shortcutAppSettingKey: shortcutAppSettingKey,
            ),
          ),
        );
        if (result == true) {
          // User did choose one
          afterSet();
        }
      },
      child: navigationBarIconBuilder(
          navBarIconsData[appStateSettings[shortcutAppSettingKey]]!),
    );
  }
}

class SelectNavBarShortcutPopup extends StatelessWidget {
  const SelectNavBarShortcutPopup(
      {required this.shortcutAppSettingKey, super.key});
  final String shortcutAppSettingKey;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NavBarShortcutSelection(
          shortcutAppSettingKey: shortcutAppSettingKey,
          navBarIconDataKey: "transactions",
          onSettings: () {
            openBottomSheet(
              context,
              PopupFramework(
                hasPadding: false,
                child: TransactionsSettings(),
              ),
            );
          },
        ),
        NavBarShortcutSelection(
          shortcutAppSettingKey: shortcutAppSettingKey,
          navBarIconDataKey: "budgets",
          onSettings: () {
            openBottomSheet(
              context,
              PopupFramework(
                hasPadding: false,
                child: BudgetSettings(),
              ),
            );
          },
        ),
        NavBarShortcutSelection(
          shortcutAppSettingKey: shortcutAppSettingKey,
          navBarIconDataKey: "goals",
          onSettings: () {
            openBottomSheet(
              context,
              PopupFramework(
                hasPadding: false,
                child: ObjectiveSettings(),
              ),
            );
          },
        ),
        NavBarShortcutSelection(
          shortcutAppSettingKey: shortcutAppSettingKey,
          navBarIconDataKey: "allSpending",
        ),
        NavBarShortcutSelection(
          shortcutAppSettingKey: shortcutAppSettingKey,
          navBarIconDataKey: "subscriptions",
          onSettings: () {
            openBottomSheet(
              context,
              PopupFramework(
                hasPadding: false,
                child: SubscriptionSettings(),
              ),
            );
          },
        ),
        NavBarShortcutSelection(
          shortcutAppSettingKey: shortcutAppSettingKey,
          navBarIconDataKey: "scheduled",
          onSettings: () {
            openBottomSheet(
              context,
              PopupFramework(
                hasPadding: false,
                child: UpcomingOverdueSettings(),
              ),
            );
          },
        ),
        NavBarShortcutSelection(
          shortcutAppSettingKey: shortcutAppSettingKey,
          navBarIconDataKey: "loans",
        ),
      ],
    );
  }
}

class NavBarShortcutSelection extends StatelessWidget {
  const NavBarShortcutSelection({
    required this.shortcutAppSettingKey,
    required this.navBarIconDataKey,
    this.onSettings,
    super.key,
  });

  final String shortcutAppSettingKey;
  final String navBarIconDataKey;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    NavBarIconData iconData = navBarIconsData[navBarIconDataKey]!;
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 5,
        top: 5,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButtonStacked(
              filled:
                  appStateSettings[shortcutAppSettingKey] == navBarIconDataKey,
              alignLeft: true,
              alignBeside: true,
              padding: onSettings == null
                  ? EdgeInsets.symmetric(horizontal: 20, vertical: 15)
                  : EdgeInsets.only(
                      left: 20,
                      right: 5,
                      top: 3,
                      bottom: 3,
                    ),
              text: iconData.label.tr().capitalizeFirst,
              iconData: iconData.iconData,
              iconScale: iconData.iconScale,
              onTap: () async {
                await updateSettings(shortcutAppSettingKey, navBarIconDataKey,
                    updateGlobalState: false);
                Navigator.pop(context, true);
              },
              infoButton: onSettings == null
                  ? null
                  : IconButton(
                      padding: EdgeInsets.all(15),
                      onPressed: onSettings,
                      icon: Icon(
                        appStateSettings["outlinedIcons"]
                            ? Icons.settings_outlined
                            : Icons.settings_rounded,
                      ),
                    ),
            ),
          ),
        ],
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
