import 'package:budget/colors.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/editRowEntry.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsContainerSwitch extends StatefulWidget {
  const SettingsContainerSwitch({
    required this.title,
    this.description,
    this.descriptionWithValue,
    this.initialValue = false,
    this.icon,
    required this.onSwitched,
    this.verticalPadding,
    this.syncWithInitialValue = true,
    this.onLongPress,
    this.onTap,
    this.enableBorderRadius = false,
    this.hasMoreOptionsIcon = false,
    this.runOnSwitchedInitially = false,
    this.descriptionColor,
    Key? key,
  }) : super(key: key);

  final String title;
  final String? description;
  final String Function(bool)? descriptionWithValue;
  final bool initialValue;
  final IconData? icon;
  final Function(bool) onSwitched;
  final double? verticalPadding;
  final bool syncWithInitialValue;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;
  final bool enableBorderRadius;
  final bool hasMoreOptionsIcon;
  final bool runOnSwitchedInitially;
  final Color? descriptionColor;

  @override
  State<SettingsContainerSwitch> createState() =>
      _SettingsContainerSwitchState();
}

class _SettingsContainerSwitchState extends State<SettingsContainerSwitch> {
  bool value = true;
  bool waiting = false;

  @override
  void initState() {
    super.initState();
    value = widget.initialValue;
    Future.delayed(Duration.zero, () {
      if (widget.runOnSwitchedInitially == true) {
        widget.onSwitched(value);
      }
    });
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    if (widget.initialValue != value && widget.syncWithInitialValue) {
      setState(() {
        value = widget.initialValue;
      });
    }
  }

  void toggleSwitch() async {
    setState(() {
      waiting = true;
    });
    if (await widget.onSwitched(!value) != false) {
      setState(() {
        value = !value;
        waiting = false;
      });
    } else {
      setState(() {
        waiting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String? description = widget.description;
    if (widget.descriptionWithValue != null) {
      description = widget.descriptionWithValue!(value);
    }
    return AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      opacity: waiting ? 0.5 : 1,
      child: SettingsContainer(
        hasMoreOptionsIcon: widget.hasMoreOptionsIcon,
        enableBorderRadius: widget.enableBorderRadius,
        onLongPress: widget.onLongPress,
        onTap: widget.onTap ?? () => {toggleSwitch()},
        title: widget.title,
        description: description,
        afterWidget: Padding(
          padding: const EdgeInsets.only(left: 5),
          child: getPlatform() == PlatformOS.isIOS
              ? CupertinoSwitch(
                  activeColor: Theme.of(context).colorScheme.primary,
                  value: value,
                  onChanged: (_) {
                    toggleSwitch();
                  },
                )
              : Switch(
                  activeColor: Theme.of(context).colorScheme.primary,
                  value: value,
                  onChanged: (_) {
                    toggleSwitch();
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
        ),
        icon: widget.icon,
        verticalPadding: widget.verticalPadding,
        descriptionColor: widget.descriptionColor,
      ),
    );
  }
}

class SettingsContainerOpenPage extends StatelessWidget {
  const SettingsContainerOpenPage({
    Key? key,
    required this.openPage,
    this.onClosed,
    this.onOpen,
    required this.title,
    this.description,
    this.icon,
    this.iconSize,
    this.iconScale,
    this.isOutlined,
    this.isOutlinedColumn,
    this.isWideOutlined,
    this.descriptionColor,
  }) : super(key: key);

  final Widget openPage;
  final VoidCallback? onClosed;
  final VoidCallback? onOpen;
  final String title;
  final String? description;
  final IconData? icon;
  final double? iconSize;
  final double? iconScale;
  final bool? isOutlined;
  final bool? isOutlinedColumn;
  final bool? isWideOutlined;
  final Color? descriptionColor;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: isOutlined == false || isOutlined == null
          ? EdgeInsets.zero
          : EdgeInsets.only(top: 5, bottom: 5, left: 4, right: 4),
      child: OpenContainerNavigation(
        onClosed: onClosed,
        onOpen: onOpen,
        closedColor: Theme.of(context).canvasColor,
        borderRadius: isOutlined == true
            ? 10
            : getIsFullScreen(context)
                ? 20
                : 0,
        button: (openContainer) {
          return SettingsContainer(
            title: title,
            description: description,
            icon: icon,
            iconSize: iconSize,
            iconScale: iconScale,
            onTap: () {
              openContainer();
              // Navigator.push(
              //   context,
              //   PageRouteBuilder(
              //     transitionDuration: Duration(milliseconds: 500),
              //     transitionsBuilder:
              //         (context, animation, secondaryAnimation, child) {
              //       return SharedAxisTransition(
              //         animation: animation,
              //         secondaryAnimation: secondaryAnimation,
              //         transitionType: SharedAxisTransitionType.horizontal,
              //         child: child,
              //       );
              //     },
              //     pageBuilder: (context, animation, secondaryAnimation) {
              //       return openPage;
              //     },
              //   ),
              // );
            },
            afterWidget: isOutlined ?? false
                ? SizedBox.shrink()
                : Icon(
                    appStateSettings["outlinedIcons"]
                        ? Icons.chevron_right_outlined
                        : Icons.chevron_right_rounded,
                    size: isOutlined == true ? 20 : 30,
                    color: colorScheme.secondary,
                  ),
            isOutlined: isOutlined,
            isOutlinedColumn: isOutlinedColumn,
            isWideOutlined: isWideOutlined,
            descriptionColor: descriptionColor,
          );
        },
        openPage: openPage,
      ),
    );
  }
}

class SettingsContainerDropdown extends StatefulWidget {
  const SettingsContainerDropdown({
    Key? key,
    required this.title,
    this.description,
    this.icon,
    required this.initial,
    required this.items,
    required this.onChanged,
    this.getLabel,
    this.verticalPadding,
    this.enableBorderRadius = false,
  }) : super(key: key);

  final String title;
  final String? description;
  final IconData? icon;
  final String initial;
  final List<String> items;
  final Function(String) onChanged;
  final Function(String)? getLabel;
  final double? verticalPadding;
  final bool enableBorderRadius;

  @override
  State<SettingsContainerDropdown> createState() =>
      _SettingsContainerDropdownState();
}

class _SettingsContainerDropdownState extends State<SettingsContainerDropdown> {
  late GlobalKey<DropdownSelectState>? _dropdownKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SettingsContainer(
      enableBorderRadius: widget.enableBorderRadius,
      verticalPadding: widget.verticalPadding,
      title: widget.title,
      description: widget.description,
      icon: widget.icon,
      onTap: () {
        _dropdownKey!.currentState!.openDropdown();
      },
      afterWidget: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: DropdownSelect(
          key: _dropdownKey,
          compact: true,
          initial: widget.items.contains(widget.initial) == false
              ? widget.items[0]
              : widget.initial,
          items: widget.items,
          onChanged: widget.onChanged,
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          getLabel: widget.getLabel,
        ),
      ),
    );
  }
}

class SettingsContainerOutlined extends StatelessWidget {
  const SettingsContainerOutlined({
    Key? key,
    required this.title,
    this.description,
    this.icon,
    this.afterWidget,
    this.onTap,
    this.onLongPress,
    this.verticalPadding,
    this.iconSize,
    this.iconScale,
    this.isExpanded = true,
    this.isOutlinedColumn,
    this.isWideOutlined,
  }) : super(key: key);

  final String title;
  final String? description;
  final IconData? icon;
  final Widget? afterWidget;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? verticalPadding;
  final double? iconSize;
  final double? iconScale;
  final bool isExpanded;
  final bool? isOutlinedColumn;
  final bool? isWideOutlined;

  @override
  Widget build(BuildContext context) {
    double defaultIconSize = 25;
    Widget content;
    if (isOutlinedColumn == true) {
      content = Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: (appStateSettings["materialYou"]
                ? Theme.of(context).colorScheme.secondary.withOpacity(0.5)
                : getColor(context, "lightDarkAccentHeavy")),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.only(
          left: 3,
          right: 3,
          top: verticalPadding ?? 14,
          bottom: verticalPadding ?? 14,
        ),
        child: Column(
          children: [
            icon == null
                ? SizedBox.shrink()
                : Transform.scale(
                    scale: iconScale ?? 1,
                    child: Icon(
                      icon,
                      size: iconSize ?? defaultIconSize + 5,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
            SizedBox(height: 10),
            TextFont(
              text: title,
              fontSize: 13,
              textColor: getColor(context, "black").withOpacity(0.8),
              maxLines: 2,
              autoSizeText: true,
              textAlign: TextAlign.center,
            )
          ],
        ),
      );
    } else {
      Widget textContent = description == null
          ? TextFont(
              fixParagraphMargin: true,
              text: title,
              fontSize: isExpanded == false ? 16 : 14.5,
              maxLines: 1,
              overflow: TextOverflow.clip,
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFont(
                  fixParagraphMargin: true,
                  text: title,
                  fontSize: 16,
                  maxLines: 1,
                ),
                Container(height: 3),
                TextFont(
                  text: description!,
                  fontSize: 11,
                  maxLines: 5,
                  textColor: appStateSettings["increaseTextContrast"]
                      ? getColor(context, "textLight")
                      : Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.5),
                ),
              ],
            );
      content = Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: (appStateSettings["materialYou"]
                ? Theme.of(context).colorScheme.secondary.withOpacity(0.5)
                : getColor(context, "lightDarkAccentHeavy")),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.only(
          left: 13,
          right: 4,
          top: verticalPadding ?? 14,
          bottom: verticalPadding ?? 14,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize:
              isExpanded == false ? MainAxisSize.min : MainAxisSize.max,
          children: [
            icon == null
                ? SizedBox.shrink()
                : Padding(
                    padding: EdgeInsets.only(
                        right: 8 +
                            defaultIconSize -
                            (iconSize ?? defaultIconSize)),
                    child: Transform.scale(
                      scale: iconScale ?? 1,
                      child: Icon(
                        icon,
                        size: iconSize ?? defaultIconSize,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
            isWideOutlined == true ? SizedBox(width: 3) : SizedBox.shrink(),
            isExpanded
                ? Expanded(child: textContent)
                : Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: textContent,
                    ),
                  ),
            Opacity(opacity: 0.5, child: afterWidget ?? SizedBox())
          ],
        ),
      );
    }
    return Tappable(
      onLongPress: onLongPress,
      color: Colors.transparent,
      onTap: onTap,
      borderRadius: 10,
      child: content,
    );
  }
}

class SettingsContainer extends StatelessWidget {
  const SettingsContainer({
    Key? key,
    required this.title,
    this.description,
    this.icon,
    this.afterWidget,
    this.onTap,
    this.onLongPress,
    this.verticalPadding,
    this.iconSize,
    this.iconScale,
    this.isOutlined,
    this.isOutlinedColumn,
    this.enableBorderRadius = false,
    this.isWideOutlined,
    this.hasMoreOptionsIcon,
    this.descriptionColor,
  }) : super(key: key);

  final String title;
  final String? description;
  final IconData? icon;
  final Widget? afterWidget;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? verticalPadding;
  final double? iconSize;
  final double? iconScale;
  final bool? isOutlined;
  final bool? isOutlinedColumn;
  final bool enableBorderRadius;
  final bool? isWideOutlined;
  final bool? hasMoreOptionsIcon;
  final Color? descriptionColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
          (enableBorderRadius || getIsFullScreen(context)) && isOutlined != true
              ? 20
              : 0),
      child: isOutlined == true
          ? SettingsContainerOutlined(
              title: title,
              afterWidget: afterWidget,
              description: description,
              icon: icon,
              iconSize: iconSize,
              iconScale: iconScale,
              onTap: onTap,
              onLongPress: onLongPress,
              verticalPadding: verticalPadding,
              isOutlinedColumn: isOutlinedColumn,
              isWideOutlined: isWideOutlined,
            )
          : Tappable(
              color: Colors.transparent,
              onTap: onTap,
              onLongPress: onLongPress,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: verticalPadding ?? 11,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          icon == null
                              ? SizedBox.shrink()
                              : Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: ScaledAnimatedSwitcher(
                                    keyToWatch: icon.toString(),
                                    child: Transform.scale(
                                      scale: iconScale ?? 1,
                                      child: Icon(
                                        icon,
                                        size: iconSize ?? 30,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      ),
                                    ),
                                  ),
                                ),
                          Expanded(
                            child: description == null
                                ? TextFont(
                                    fixParagraphMargin: true,
                                    text: title,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    maxLines: 5,
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextFont(
                                        fixParagraphMargin: true,
                                        text: title,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        maxLines: 5,
                                      ),
                                      Container(height: 3),
                                      AnimatedSizeSwitcher(
                                        child: TextFont(
                                          key: ValueKey(description.toString()),
                                          text: description!,
                                          fontSize: 14,
                                          maxLines: 5,
                                          textColor: descriptionColor,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                    hasMoreOptionsIcon == true
                        ? HasMoreOptionsIcon()
                        : SizedBox.shrink(),
                    afterWidget ?? SizedBox()
                  ],
                ),
              ),
            ),
    );
  }
}

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({
    Key? key,
    required this.title,
    this.hasLeftPadding = true,
  }) : super(key: key);
  final String title;
  final bool hasLeftPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: hasLeftPadding ? 63.0 : 0,
        top: 15,
        bottom: 7,
      ),
      child: TextFont(
        text: title.capitalizeFirst,
        fontSize: 15,
        fontWeight: FontWeight.bold,
        textColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
