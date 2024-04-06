import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/outlinedButtonStacked.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AddFAB extends StatelessWidget {
  const AddFAB({
    this.openPage,
    this.onTap,
    this.tooltip,
    this.enableLongPress = false,
    this.color,
    this.colorIcon,
    super.key,
  });
  final Widget? openPage;
  final VoidCallback? onTap;
  final String? tooltip;
  final bool enableLongPress;
  final Color? color;
  final Color? colorIcon;

  @override
  Widget build(BuildContext context) {
    return FAB(
      colorIcon: colorIcon,
      color: color,
      tooltip: tooltip,
      iconData: appStateSettings["outlinedIcons"]
          ? Icons.add_outlined
          : Icons.add_rounded,
      openPage: openPage,
      onTap: onTap,
      fabSize: getIsFullScreen(context) == false ? 60 : 70,
      borderRadius: getIsFullScreen(context) == false ? 18 : 22,
      onLongPress: () {
        openBottomSheet(
          context,
          PopupFramework(
            child: AddMoreThingsPopup(),
          ),
        );
      },
    );
  }
}

class FAB extends StatelessWidget {
  const FAB({
    Key? key,
    this.openPage,
    this.onTap,
    this.onLongPress,
    this.tooltip,
    this.color,
    this.colorIcon,
    this.iconData,
    this.fabSize = 60,
    this.borderRadius = 18,
    this.label,
    this.labelSize = 18,
    this.isOutlined = false,
  }) : super(key: key);

  final Widget? openPage;
  final String? tooltip;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final Color? colorIcon;
  final IconData? iconData;
  final double fabSize;
  final double borderRadius;
  final String? label;
  final double labelSize;
  final bool isOutlined;

  @override
  Widget build(BuildContext context) {
    Color? containerColor = color != null
        ? color
        : isOutlined
            ? Theme.of(context).colorScheme.onSecondary
            : Theme.of(context).colorScheme.secondary;
    Color? iconColor = color != null
        ? colorIcon
        : isOutlined
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.onSecondary;
    return OpenContainerNavigation(
      closedElevation: 10,
      borderRadius: borderRadius,
      closedColor: containerColor,
      button: (openContainer) {
        return Tooltip(
          message: tooltip ?? "",
          child: Tappable(
            color: containerColor,
            onTap: () {
              if (onTap != null)
                onTap!();
              else
                openContainer();
            },
            onLongPress: onLongPress,
            child: OutlinedContainer(
              enabled: isOutlined,
              borderRadius: borderRadius,
              child: Builder(builder: (context) {
                Widget fabIcon = SizedBox(
                  height: fabSize,
                  width: fabSize,
                  child: Center(
                    child: Icon(
                      iconData,
                      color: iconColor,
                    ),
                  ),
                );
                if (label != null)
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      fabIcon,
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 5, bottom: 5, right: 20),
                        child: TextFont(
                          text: label ?? "",
                          fontSize: labelSize,
                          textColor: iconColor,
                        ),
                      ),
                    ],
                  );
                return fabIcon;
              }),
            ),
          ),
        );
      },
      openPage: openPage ?? Container(),
    );
  }
}
