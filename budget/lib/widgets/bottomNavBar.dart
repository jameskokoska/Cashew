import 'dart:math';
import 'package:budget/functions.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/pages/editObjectivesPage.dart';
import 'package:budget/pages/subscriptionsPage.dart';
import 'package:budget/pages/transactionsListPage.dart';
import 'package:budget/pages/upcomingOverdueTransactionsPage.dart';
import 'package:budget/struct/navBarIconsData.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/outlinedButtonStacked.dart';
import 'package:budget/widgets/framework/navigation_bar/navigation_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart'
    hide NavigationDestination, NavigationBar;
import 'package:budget/colors.dart';
import 'package:flutter/services.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar(
      {required this.onChanged,
      required this.currentNavigationStackedIndex,
      Key? key})
      : super(key: key);
  final Function(int) onChanged;

  // current
  final int currentNavigationStackedIndex;

  @override
  State<BottomNavBar> createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  void onItemTapped(int indexOfNavigationBar, {bool allowReApply = false}) {
    int navigationStackedIndex =
        getNavigationStackedIndexFromBarIndex(indexOfNavigationBar);

    if (navigationStackedIndex == widget.currentNavigationStackedIndex &&
        allowReApply == false) {
      if (navigationStackedIndex == 0)
        homePageStateKey.currentState?.scrollToTop();
      if (navigationStackedIndex == 1)
        transactionsListPageStateKey.currentState?.scrollToTop();
      if (navigationStackedIndex == 2)
        budgetsListPageStateKey.currentState?.scrollToTop();
      if (navigationStackedIndex == 3)
        settingsPageStateKey.currentState?.scrollToTop();
      if (navigationStackedIndex == 5)
        subscriptionsPageStateKey.currentState?.scrollToTop();
      if (navigationStackedIndex == 7)
        walletDetailsAllSpendingPageStateKey.currentState?.scrollToTop();
      if (navigationStackedIndex == 14)
        objectivesListPageStateKey.currentState?.scrollToTop();
      if (navigationStackedIndex == 16)
        upcomingOverdueTransactionsStateKey.currentState?.scrollToTop();
      if (navigationStackedIndex == 17)
        creditDebtTransactionsKey.currentState?.scrollToTop();
    } else {
      // We need to change to the navigation index
      widget.onChanged(navigationStackedIndex);
    }
    FocusScope.of(context).unfocus(); //remove keyboard focus on any input boxes
  }

  int getNavigationStackedIndexFromBarIndex(int barIndex) {
    if (barIndex == 0) {
      return navBarIconsData[appStateSettings["customNavBarShortcut0"]]
              ?.navigationIndexedStackIndex ??
          0;
    } else if (barIndex == 1) {
      return navBarIconsData[appStateSettings["customNavBarShortcut1"]]
              ?.navigationIndexedStackIndex ??
          1;
    } else if (barIndex == 2) {
      return navBarIconsData[appStateSettings["customNavBarShortcut2"]]
              ?.navigationIndexedStackIndex ??
          2;
    } else {
      return 3;
    }
  }

  int getNavigationBarIndexFromStackedIndex(int stackedIndex) {
    if (stackedIndex ==
        (navBarIconsData[appStateSettings["customNavBarShortcut0"]]
                ?.navigationIndexedStackIndex ??
            0))
      return 0;
    else if (stackedIndex ==
        (navBarIconsData[appStateSettings["customNavBarShortcut1"]]
                ?.navigationIndexedStackIndex ??
            1))
      return 1;
    else if (stackedIndex ==
        (navBarIconsData[appStateSettings["customNavBarShortcut2"]]
                ?.navigationIndexedStackIndex ??
            2))
      return 2;
    else
      return 3;
  }

  @override
  Widget build(BuildContext context) {
    // The index of the actual navigation bar, this is not the navigation stack index
    int navigationBarIndex = getNavigationBarIndexFromStackedIndex(
        widget.currentNavigationStackedIndex);

    if (getIsFullScreen(context)) return SizedBox.shrink();
    if (getPlatform() == PlatformOS.isIOS) {
      return IntrinsicHeight(
        child: Container(
          decoration: BoxDecoration(
            color: getBottomNavbarBackgroundColor(
              colorScheme: Theme.of(context).colorScheme,
              brightness: Theme.of(context).brightness,
              lightDarkAccent: getColor(context, "lightDarkAccent"),
            ),
            boxShadow: boxShadowSharp(context),
          ),
          padding: EdgeInsetsDirectional.only(
              top: 2,
              bottom: max(2, MediaQuery.paddingOf(context).bottom - 5.5)),
          child: Row(
            children: [
              NavBarSpaceButton(
                onPress: () => onItemTapped(0),
                flex: 9,
                child: Container(),
              ),
              NavBarSpaceButton(
                onPress: () => onItemTapped(0),
                flex: 20,
                child: CustomizableNavigationBarIcon(
                  shortcutAppSettingKey: "customNavBarShortcut0",
                  afterSet: () {
                    onItemTapped(0, allowReApply: true);
                  },
                  navigationBarIconBuilder: (NavBarIconData iconData) {
                    return NavBarIcon(
                      icon: iconData.iconData,
                      customIconScale: iconData.iconScale,
                      onItemTapped: onItemTapped,
                      navigationBarIndex: 0,
                      currentNavigationBarIndex: navigationBarIndex,
                    );
                  },
                ),
              ),
              NavBarSpaceButton(
                onPress: () => onItemTapped(1),
                flex: 20,
                child: CustomizableNavigationBarIcon(
                  shortcutAppSettingKey: "customNavBarShortcut1",
                  afterSet: () {
                    onItemTapped(1, allowReApply: true);
                  },
                  navigationBarIconBuilder: (NavBarIconData iconData) {
                    return NavBarIcon(
                      icon: iconData.iconData,
                      customIconScale: iconData.iconScale,
                      onItemTapped: onItemTapped,
                      navigationBarIndex: 1,
                      currentNavigationBarIndex: navigationBarIndex,
                    );
                  },
                ),
              ),
              NavBarSpaceButton(
                onPress: () => onItemTapped(2),
                flex: 20,
                child: CustomizableNavigationBarIcon(
                  shortcutAppSettingKey: "customNavBarShortcut2",
                  afterSet: () {
                    onItemTapped(2, allowReApply: true);
                  },
                  navigationBarIconBuilder: (NavBarIconData iconData) {
                    return NavBarIcon(
                      icon: iconData.iconData,
                      customIconScale: iconData.iconScale,
                      onItemTapped: onItemTapped,
                      navigationBarIndex: 2,
                      currentNavigationBarIndex: navigationBarIndex,
                    );
                  },
                ),
              ),
              NavBarSpaceButton(
                onPress: () => onItemTapped(3),
                flex: 20,
                child: NavBarIcon(
                  onItemTapped: onItemTapped,
                  icon: navBarIconsData["more"]!.iconData,
                  navigationBarIndex: 3,
                  currentNavigationBarIndex: navigationBarIndex,
                ),
              ),
              NavBarSpaceButton(
                onPress: () => onItemTapped(3),
                flex: 9,
                child: Container(),
              ),
            ],
          ),
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
            CustomizableNavigationBarIcon(
              shortcutAppSettingKey: "customNavBarShortcut0",
              afterSet: () {
                onItemTapped(0, allowReApply: true);
              },
              navigationBarIconBuilder: (NavBarIconData iconData) {
                return NavigationDestination(
                  icon: Icon(iconData.iconData, size: iconData.iconSize),
                  label: iconData.label.tr().length > 15 &&
                          iconData.labelShort != null
                      ? (iconData.labelShort ?? "").tr()
                      : iconData.label.tr(),
                  tooltip: "",
                );
              },
            ),
            CustomizableNavigationBarIcon(
              shortcutAppSettingKey: "customNavBarShortcut1",
              afterSet: () {
                onItemTapped(1, allowReApply: true);
              },
              navigationBarIconBuilder: (NavBarIconData iconData) {
                return NavigationDestination(
                  icon: Icon(iconData.iconData, size: iconData.iconSize),
                  label: iconData.label.tr().length > 15 &&
                          iconData.labelShort != null
                      ? (iconData.labelShort ?? "").tr()
                      : iconData.label.tr(),
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
                  label: iconData.label.tr().length > 15 &&
                          iconData.labelShort != null
                      ? (iconData.labelShort ?? "").tr()
                      : iconData.label.tr(),
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
          selectedIndex: navigationBarIndex,
          onDestinationSelected: (value) {
            onItemTapped(value);
          },
        ),
      ),
    );
  }
}

class NavBarSpaceButton extends StatelessWidget {
  const NavBarSpaceButton(
      {required this.onPress,
      required this.flex,
      required this.child,
      super.key});
  final VoidCallback onPress;
  final int flex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Feedback.forTap(context);
          onPress();
        },
        child: child,
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
    NavBarIconData navBarIconData;
    if (navBarIconsData.containsKey(appStateSettings[shortcutAppSettingKey])) {
      navBarIconData =
          navBarIconsData[appStateSettings[shortcutAppSettingKey]]!;
    } else {
      navBarIconData = navBarIconsData["home"]!;
    }

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
          // Refresh this because we want to open up the budgets detail page
          // When the budgets icon is tapped on the more page
          // If budgets were removed
          settingsPageStateKey.currentState?.refreshState();
          // User did choose one
          afterSet();
        }
      },
      child: navigationBarIconBuilder(navBarIconData),
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
          navBarIconDataKey: "home",
          onSettings: () {
            pushRoute(context, EditHomePage());
          },
        ),
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
      padding: const EdgeInsetsDirectional.only(
        bottom: 5,
        top: 5,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButtonStacked(
              filled:
                  appStateSettings[shortcutAppSettingKey] == navBarIconDataKey,
              alignStart: true,
              alignBeside: true,
              padding: onSettings == null
                  ? EdgeInsetsDirectional.symmetric(
                      horizontal: 20, vertical: 15)
                  : EdgeInsetsDirectional.only(
                      start: 20,
                      end: 5,
                      top: 3,
                      bottom: 3,
                    ),
              text: iconData.label.tr().capitalizeFirst,
              iconData: iconData.iconData,
              iconScale: iconData.iconScale,
              onTap: () async {
                await updateSettings(shortcutAppSettingKey, navBarIconDataKey,
                    updateGlobalState: false);
                popRoute(context, true);
              },
              infoButton: onSettings == null
                  ? null
                  : IconButton(
                      padding: EdgeInsetsDirectional.all(15),
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
    required this.navigationBarIndex,
    required this.currentNavigationBarIndex,
    this.customIconScale = 1,
    super.key,
  });
  final Function(int index) onItemTapped;
  final IconData icon;
  final int navigationBarIndex;
  final int currentNavigationBarIndex;
  final double customIconScale;

  @override
  Widget build(BuildContext context) {
    bool selected = navigationBarIndex == currentNavigationBarIndex;
    return Stack(
      alignment: AlignmentDirectional.center,
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
                  margin: EdgeInsetsDirectional.all(5),
                ),
              )
            : Container(
                color: Colors.transparent,
                height: 52,
                width: 52,
                margin: EdgeInsetsDirectional.all(5),
              ),
        IconButton(
          padding: EdgeInsetsDirectional.all(15),
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
            onItemTapped(navigationBarIndex);
          },
        ),
      ],
    );
  }
}
