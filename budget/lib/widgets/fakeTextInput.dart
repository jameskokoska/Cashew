import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';

class FakeTextInput extends StatelessWidget {
  const FakeTextInput({
    Key? key,
    required this.onTap,
    required this.icon,
    this.label = "",
    this.edgeInsetsVertical = 13,
    this.backgroundColor,
    this.content,
  }) : super(key: key);

  final VoidCallback onTap;
  final String label;
  final IconData icon;
  final double edgeInsetsVertical;
  final Color? backgroundColor;
  final String? content;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      color: backgroundColor ??
          (appStateSettings["materialYou"]
              ? Theme.of(context).colorScheme.secondaryContainer
              : getColor(context, "canvasContainer")),
      borderRadius: 15,
      child: Container(
        margin: EdgeInsets.only(
            left: 18,
            top: edgeInsetsVertical,
            bottom: edgeInsetsVertical,
            right: 13),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            content == null || content == ""
                ? TextFont(
                    text: label,
                    fontSize: 15,
                    textColor: getColor(context, "black").withOpacity(0.6),
                  )
                : TextFont(
                    text: content ?? "",
                    fontSize: 15,
                    textColor: getColor(context, "black"),
                  ),
            Icon(
              icon,
              color: Theme.of(context).colorScheme.secondary,
              size: 20,
            )
          ],
        ),
      ),
    );
  }
}
