import 'package:flutter/material.dart';
import 'package:budget/colors.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({required this.onChanged, Key? key}) : super(key: key);
  final Function(int) onChanged;

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int selectedIndex = 0;

  void onItemTapped(int index) {
    widget.onChanged(index);
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: "Home",
              backgroundColor:
                  darken(Theme.of(context).colorScheme.accentColor, 0.01),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_rounded),
              label: "Budgets",
              backgroundColor:
                  darken(Theme.of(context).colorScheme.accentColor, 0.1),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money_rounded),
              label: "Transactions",
              backgroundColor:
                  darken(Theme.of(context).colorScheme.accentColor, 0.2),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: "Settings",
              backgroundColor:
                  darken(Theme.of(context).colorScheme.accentColor, 0.3),
            ),
          ],
          currentIndex: selectedIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          onTap: onItemTapped,
        ),
      ),
    );
  }
}
