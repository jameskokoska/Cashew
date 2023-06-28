import 'package:budget/colors.dart';
import 'package:budget/main.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
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
        onLongPress: widget.onLongPress,
        onTap: () => {toggleSwitch()},
        title: widget.title,
        description: description,
        afterWidget: Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Switch(
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
      ),
    );
  }
}

class SettingsContainerOpenPage extends StatelessWidget {
  const SettingsContainerOpenPage({
    Key? key,
    required this.openPage,
    required this.title,
    this.description,
    this.icon,
    this.iconSize,
    this.isOutlined,
  }) : super(key: key);

  final Widget openPage;
  final String title;
  final String? description;
  final IconData? icon;
  final double? iconSize;
  final bool? isOutlined;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return OpenContainerNavigation(
      closedColor: Theme.of(context).canvasColor,
      borderRadius: 0,
      button: (openContainer) {
        return SettingsContainer(
          title: title,
          description: description,
          icon: icon,
          iconSize: iconSize,
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
                  Icons.chevron_right_rounded,
                  size: isOutlined == true ? 20 : 30,
                  color: colorScheme.secondary,
                ),
          isOutlined: isOutlined,
        );
      },
      openPage: openPage,
    );
  }
}

class SettingsContainerDropdown extends StatelessWidget {
  const SettingsContainerDropdown({
    Key? key,
    required this.title,
    this.description,
    this.icon,
    required this.initial,
    required this.items,
    required this.onChanged,
    this.verticalPadding,
  }) : super(key: key);

  final String title;
  final String? description;
  final IconData? icon;
  final String initial;
  final List<String> items;
  final Function(String) onChanged;
  final double? verticalPadding;

  @override
  Widget build(BuildContext context) {
    return SettingsContainer(
      verticalPadding: verticalPadding,
      title: title,
      description: description,
      icon: icon,
      afterWidget: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: DropdownSelect(
          compact: true,
          initial: items.contains(initial) == false ? items[0] : initial,
          items: items,
          onChanged: onChanged,
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
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
    this.isExpanded = true,
  }) : super(key: key);

  final String title;
  final String? description;
  final IconData? icon;
  final Widget? afterWidget;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? verticalPadding;
  final double? iconSize;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    double defaultIconSize = 25;
    Widget textContent = description == null
        ? TextFont(
            fixParagraphMargin: true,
            text: title,
            fontSize: isExpanded == false ? 16 : 15,
            fontWeight: FontWeight.bold,
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
                fontWeight: FontWeight.bold,
                maxLines: 1,
              ),
              Container(height: 3),
              TextFont(
                text: description!,
                fontSize: 11,
                maxLines: 5,
                textColor:
                    Theme.of(context).colorScheme.secondary.withOpacity(0.5),
              ),
            ],
          );
    return Padding(
      padding: EdgeInsets.only(top: 5, bottom: 5, left: 4, right: 4),
      child: Tappable(
        onLongPress: onLongPress,
        color: Colors.transparent,
        onTap: onTap,
        borderRadius: 10,
        child: Container(
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
                      child: Icon(
                        icon,
                        size: iconSize ?? defaultIconSize,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
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
        ),
      ),
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
    this.isOutlined,
  }) : super(key: key);

  final String title;
  final String? description;
  final IconData? icon;
  final Widget? afterWidget;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? verticalPadding;
  final double? iconSize;
  final bool? isOutlined;

  @override
  Widget build(BuildContext context) {
    return isOutlined == true
        ? SettingsContainerOutlined(
            title: title,
            afterWidget: afterWidget,
            description: description,
            icon: icon,
            iconSize: iconSize,
            onTap: onTap,
            onLongPress: onLongPress,
            verticalPadding: verticalPadding,
          )
        : Padding(
            padding: EdgeInsets.symmetric(vertical: 0),
            child: Tappable(
              color: Colors.transparent,
              onTap: onTap,
              onLongPress: onLongPress,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: verticalPadding ?? 11,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            icon == null
                                ? SizedBox.shrink()
                                : Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: Icon(
                                      icon,
                                      size: iconSize ?? 30,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                        TextFont(
                                          text: description!,
                                          fontSize: 14,
                                          maxLines: 5,
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    afterWidget ?? SizedBox()
                  ],
                ),
              ),
            ),
          );
  }
}

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 63.0,
        top: 15,
        bottom: 7,
      ),
      child: TextFont(
        text: title,
        fontSize: 15,
        fontWeight: FontWeight.bold,
        textColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
