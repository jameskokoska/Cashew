import 'dart:async';

import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:budget/widgets/moreIcons.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';

// returns 0 if no navigation sidebar should be shown
double getWidthNavigationSidebar(context) {
  double screenPercent = 0.3;
  double maxWidthNavigation = 270;
  double minScreenWidth = 700;
  if (MediaQuery.of(context).size.width < minScreenWidth) return 0;
  return MediaQuery.of(context).size.width * screenPercent > maxWidthNavigation
      ? maxWidthNavigation
      : MediaQuery.of(context).size.width * screenPercent;
}

class NavigationSidebar extends StatefulWidget {
  const NavigationSidebar({super.key});

  @override
  State<NavigationSidebar> createState() => NavigationSidebarState();
}

class NavigationSidebarState extends State<NavigationSidebar> {
  int selectedIndex = 0;

  void setSelectedIndex(index) {
    setState(() {
      selectedIndex = index;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    bool showUsername = appStateSettings["username"] != "";
    double widthNavigationSidebar = getWidthNavigationSidebar(context);
    if (widthNavigationSidebar <= 0) {
      return SizedBox.shrink();
    }
    print(selectedIndex);
    return SizedBox(
      width: getWidthNavigationSidebar(context),
      child: ListView(
        children: [
          SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: TextFont(
              text: getWelcomeMessage(),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          showUsername
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Expanded(
                    child: TextFont(
                      maxLines: 3,
                      text: appStateSettings["username"],
                      fontWeight: FontWeight.bold,
                      fontSize: 39,
                      textColor:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                )
              : SizedBox.shrink(),
          SizedBox(height: 20),
          NavigationSidebarButton(
            icon: Icons.home_rounded,
            label: "Home",
            isSelected: selectedIndex == 0,
            onTap: () {
              pageNavigationFrameworkKey.currentState!
                  .changePage(0, switchNavbar: true);
            },
          ),
          NavigationSidebarButton(
            icon: Icons.payments_rounded,
            label: "Transactions",
            isSelected: selectedIndex == 1,
            onTap: () {
              pageNavigationFrameworkKey.currentState!
                  .changePage(1, switchNavbar: true);
            },
          ),
          NavigationSidebarButton(
            icon: MoreIcons.chart_pie,
            iconSize: 15,
            label: "Budgets",
            isSelected: selectedIndex == 2,
            onTap: () {
              pageNavigationFrameworkKey.currentState!
                  .changePage(2, switchNavbar: true);
            },
          ),
          NavigationSidebarButton(
            icon: Icons.event_repeat_rounded,
            label: "Subscriptions",
            isSelected: selectedIndex == 5,
            onTap: () {
              pageNavigationFrameworkKey.currentState!
                  .changePage(5, switchNavbar: true);
            },
          ),
          kIsWeb
              ? SizedBox.shrink()
              : NavigationSidebarButton(
                  icon: Icons.notifications_rounded,
                  label: "Notifications",
                  isSelected: selectedIndex == 6,
                  onTap: () {
                    pageNavigationFrameworkKey.currentState!
                        .changePage(6, switchNavbar: true);
                  },
                ),
          NavigationSidebarButton(
            icon: Icons.line_weight_rounded,
            label: "All Spending",
            isSelected: selectedIndex == 7,
            onTap: () {
              pageNavigationFrameworkKey.currentState!
                  .changePage(7, switchNavbar: true);
            },
          ),
          GoogleAccountLoginButton(
            navigationSidebarButton: true,
            onTap: () {
              setSelectedIndex(8);
            },
            isButtonSelected: selectedIndex == 8,
          ),
          NavigationSidebarButton(
            icon: Icons.account_balance_wallet_rounded,
            label: "Wallet Details",
            isSelected: selectedIndex == 9,
            onTap: () {
              pageNavigationFrameworkKey.currentState!
                  .changePage(9, switchNavbar: true);
            },
          ),
          NavigationSidebarButton(
            icon: MoreIcons.chart_pie,
            label: "Budgets Details",
            isSelected: selectedIndex == 10,
            onTap: () {
              pageNavigationFrameworkKey.currentState!
                  .changePage(10, switchNavbar: true);
            },
          ),
          NavigationSidebarButton(
            icon: Icons.category_rounded,
            label: "Categories Details",
            isSelected: selectedIndex == 11,
            onTap: () {
              pageNavigationFrameworkKey.currentState!
                  .changePage(11, switchNavbar: true);
            },
          ),
          NavigationSidebarButton(
            icon: Icons.text_fields_rounded,
            label: "Titles Details",
            isSelected: selectedIndex == 12,
            onTap: () {
              pageNavigationFrameworkKey.currentState!
                  .changePage(12, switchNavbar: true);
            },
          ),
          NavigationSidebarButton(
            icon: Icons.info_outline_rounded,
            label: "About",
            isSelected: selectedIndex == 13,
            onTap: () {
              pageNavigationFrameworkKey.currentState!
                  .changePage(13, switchNavbar: true);
            },
          ),
          NavigationSidebarButton(
            icon: Icons.settings_rounded,
            label: "Settings",
            isSelected: selectedIndex == 4,
            onTap: () {
              pageNavigationFrameworkKey.currentState!
                  .changePage(4, switchNavbar: true);
            },
          ),
        ],
      ),
    );
  }
}

class NavigationSidebarButton extends StatelessWidget {
  const NavigationSidebarButton({
    super.key,
    required this.icon,
    this.iconSize = 30,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final double iconSize;
  final String label;
  final bool isSelected;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: Tappable(
          key: ValueKey(isSelected),
          borderRadius: 50,
          color: isSelected
              ? Theme.of(context).colorScheme.secondaryContainer
              : null,
          onTap: () {
            navigatorKey.currentState!.popUntil((route) => route.isFirst);
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onSecondaryContainer
                      : Theme.of(context).colorScheme.secondary,
                ),
                SizedBox(width: 15),
                Expanded(
                  child: TextFont(
                    text: label,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
