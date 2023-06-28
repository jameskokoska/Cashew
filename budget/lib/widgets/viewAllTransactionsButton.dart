import 'package:budget/main.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';

class ViewAllTransactionsButton extends StatelessWidget {
  const ViewAllTransactionsButton({this.onPress, super.key});
  final Function? onPress;

  @override
  Widget build(BuildContext context) {
    return LowKeyButton(
      onTap: () {
        if (onPress != null)
          onPress!();
        else
          PageNavigationFramework.changePage(context, 1, switchNavbar: true);
      },
      text: "View All Transactions",
    );
  }
}

class LowKeyButton extends StatelessWidget {
  const LowKeyButton({super.key, required this.onTap, required this.text});
  final VoidCallback onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      color: appStateSettings["materialYou"]
          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
          : getColor(context, "lightDarkAccent"),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: TextFont(
          text: text,
          textAlign: TextAlign.center,
          fontSize: 14,
          textColor: getColor(context, "textLight"),
        ),
      ),
      onTap: onTap,
      borderRadius: 13,
    );
  }
}
