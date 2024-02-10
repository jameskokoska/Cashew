import 'package:budget/colors.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AddButton extends StatelessWidget {
  const AddButton({
    Key? key,
    required this.onTap,
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
    this.width = 110,
    this.height = 52,
    this.openPage,
    this.borderRadius = 15,
    this.icon,
    this.afterOpenPage,
    this.onOpenPage,
    this.labelUnder,
  }) : super(key: key);

  final VoidCallback onTap;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final double? width;
  final double? height;
  final double borderRadius;
  final Widget? openPage;
  final IconData? icon;
  final Function? afterOpenPage;
  final Function? onOpenPage;
  final String? labelUnder;

  @override
  Widget build(BuildContext context) {
    Color color = appStateSettings["materialYou"]
        ? Theme.of(context).colorScheme.secondary.withOpacity(0.3)
        : getColor(context, "lightDarkAccentHeavy");
    Widget getButton(onTap) {
      return Tappable(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1.5,
              color: color,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          width: width,
          height: height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Icon(
                  icon ??
                      (appStateSettings["outlinedIcons"]
                          ? Icons.add_outlined
                          : Icons.add_rounded),
                  size: 22,
                  color: color,
                ),
              ),
              if (labelUnder != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: TextFont(
                    text: labelUnder ?? "",
                    fontSize: 14,
                    textColor: getColor(context, "textLight"),
                  ),
                ),
            ],
          ),
        ),
        onTap: () {
          onTap();
        },
      );
    }

    if (openPage != null) {
      return Padding(
        padding: margin,
        child: OpenContainerNavigation(
          openPage: openPage!,
          button: (openPage) {
            return getButton(openPage);
          },
          borderRadius: borderRadius,
          onClosed: () {
            if (afterOpenPage != null) afterOpenPage!();
          },
          onOpen: () {
            if (onOpenPage != null) onOpenPage!();
          },
        ),
      );
    }
    Widget button = getButton(onTap);
    return Padding(
      padding: margin,
      child: button,
    );
  }
}
