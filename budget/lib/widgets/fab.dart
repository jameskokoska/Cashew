import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class FAB extends StatelessWidget {
  FAB({
    Key? key,
    this.openPage,
    this.onTap,
    this.tooltip = "",
    this.color,
    this.colorIcon,
    this.onLongPressAddAllPopup = true,
    this.iconData,
    this.customFabSize,
    this.customBorderRadius,
  }) : super(key: key);

  final Widget? openPage;
  final String tooltip;
  final Function()? onTap;
  final Color? color;
  final Color? colorIcon;
  final bool? onLongPressAddAllPopup;
  final IconData? iconData;
  final double? customFabSize;
  final double? customBorderRadius;

  @override
  Widget build(BuildContext context) {
    double fabSize =
        customFabSize ?? (getIsFullScreen(context) == false ? 60 : 70);
    return OpenContainerNavigation(
      closedElevation: 10,
      borderRadius:
          customBorderRadius ?? (getIsFullScreen(context) == false ? 18 : 22),
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
            onLongPress: onLongPressAddAllPopup == false
                ? null
                : () {
                    openBottomSheet(
                      context,
                      PopupFramework(
                        child: AddMoreThingsPopup(),
                      ),
                    );
                  },
            child: SizedBox(
              height: fabSize,
              width: fabSize,
              child: Center(
                child: Icon(
                  iconData ??
                      (appStateSettings["outlinedIcons"]
                          ? Icons.add_outlined
                          : Icons.add_rounded),
                  color: colorIcon ?? Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
          ),
        );
      },
      openPage: openPage ?? Container(),
    );
  }
}
