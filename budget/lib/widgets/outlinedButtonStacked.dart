import 'package:budget/colors.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';

class OutlinedButtonStacked extends StatelessWidget {
  const OutlinedButtonStacked({
    super.key,
    required this.text,
    required this.onTap,
    required this.iconData,
    this.afterWidget,
    this.alignLeft = false,
    this.padding,
    this.alignBeside,
    this.filled = false,
  });
  final String text;
  final void Function()? onTap;
  final IconData iconData;
  final Widget? afterWidget;
  final bool alignLeft;
  final EdgeInsets? padding;
  final bool? alignBeside;
  final bool filled;
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 250),
      child: Row(
        key: ValueKey(filled),
        children: [
          Expanded(
            child: Tappable(
              onTap: onTap,
              borderRadius: 15,
              color: filled == true
                  ? Theme.of(context).colorScheme.secondary.withOpacity(0.2)
                  : Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: (appStateSettings["materialYou"]
                        ? Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.5)
                        : getColor(context, "lightDarkAccentHeavy")),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: padding ??
                      EdgeInsets.symmetric(horizontal: 8, vertical: 30),
                  child: Column(
                    crossAxisAlignment: alignLeft
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.center,
                    children: [
                      alignBeside != true
                          ? Column(
                              crossAxisAlignment: alignLeft
                                  ? CrossAxisAlignment.start
                                  : CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  iconData,
                                  size: 35,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                SizedBox(height: 10),
                                TextFont(
                                  text: text,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  maxLines: 2,
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Icon(
                                  iconData,
                                  size: 28,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                SizedBox(width: 10),
                                Flexible(
                                  child: TextFont(
                                    text: text,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                      afterWidget == null
                          ? SizedBox.shrink()
                          : SizedBox(height: 8),
                      afterWidget ?? SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
