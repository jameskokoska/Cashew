import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:flutter/material.dart';

class FAB extends StatelessWidget {
  FAB(
      {Key? key,
      required this.openPage,
      this.onTap,
      this.tooltip = "",
      this.color,
      this.colorPlus})
      : super(key: key);

  final Widget openPage;
  final String tooltip;
  final Function()? onTap;
  final Color? color;
  final Color? colorPlus;

  @override
  Widget build(BuildContext context) {
    double fabSize = getIsFullScreen(context) == false ? 60 : 70;
    return OpenContainerNavigation(
      closedElevation: 10,
      borderRadius: getIsFullScreen(context) == false ? 18 : 22,
      closedColor:
          color != null ? color : Theme.of(context).colorScheme.secondary,
      button: (openContainer) {
        return Tooltip(
          message: tooltip,
          child: Tappable(
            color:
                color != null ? color : Theme.of(context).colorScheme.secondary,
            onTap: () {
              if (onTap != null)
                onTap!();
              else
                openContainer();
            },
            child: SizedBox(
              height: fabSize,
              width: fabSize,
              child: Center(
                child: Icon(
                  appStateSettings["outlinedIcons"]
                      ? Icons.add_outlined
                      : Icons.add_rounded,
                  color: colorPlus != null
                      ? colorPlus
                      : Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
          ),
        );
      },
      openPage: openPage,
    );
  }
}
