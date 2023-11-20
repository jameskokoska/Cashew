import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
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
          PageNavigationFramework.changePage(
            context,
            1,
            switchNavbar:
                appStateSettings["customNavBarShortcut1"] == "transactions",
          );
      },
      text: "view-all-transactions".tr(),
    );
  }
}

class LowKeyButton extends StatelessWidget {
  const LowKeyButton({
    super.key,
    required this.onTap,
    required this.text,
    this.extraWidget,
    this.color,
    this.textColor,
  });
  final VoidCallback onTap;
  final String text;
  final Widget? extraWidget;
  final Color? color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      color: color ??
          (appStateSettings["materialYou"]
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : getColor(context, "lightDarkAccent")),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFont(
              text: text,
              textAlign: TextAlign.center,
              fontSize: 14,
              textColor:
                  textColor ?? getColor(context, "black").withOpacity(0.5),
            ),
            extraWidget ?? SizedBox.shrink(),
          ],
        ),
      ),
      onTap: onTap,
      borderRadius: 13,
    );
  }
}
