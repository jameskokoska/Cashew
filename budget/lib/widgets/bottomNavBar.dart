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
    widget.onChanged(index);
    setState(() {
      selectedIndex = index;
    });
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
    return Padding(
      //Bottom padding is a container wrapped with absorb pointer
      padding: const EdgeInsets.only(bottom: 0, left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Theme.of(context)
                          .colorScheme
                          .shadowColorLight
                          .withAlpha(50)
                      : Colors.transparent,
                  blurRadius: 20,
                  offset: Offset(0, 4),
                  spreadRadius: 9,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  // backgroundColor:
                  //     Theme.of(context).colorScheme.secondaryContainer,
                  // indicatorColor: Theme.of(context)
                  //     .colorScheme
                  //     .secondary
                  //     .withOpacity(0.24),
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
                      icon: Icon(Icons.pie_chart_rounded),
                      label: "Budgets",
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.settings_rounded),
                      label: "Settings",
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
              height: 10,
            ),
          ),
        ],
      ),
    );
  }
}
