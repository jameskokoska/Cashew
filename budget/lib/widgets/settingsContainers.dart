import 'package:budget/colors.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:budget/database/tables.dart';

class SettingsContainerSwitch extends StatefulWidget {
  const SettingsContainerSwitch({
    required this.title,
    this.description,
    this.initialValue = false,
    this.icon,
    required this.onSwitched,
    this.verticalPadding,
    Key? key,
  }) : super(key: key);

  final String title;
  final String? description;
  final bool initialValue;
  final IconData? icon;
  final Function(bool) onSwitched;
  final double? verticalPadding;

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
    return AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      opacity: waiting ? 0.5 : 1,
      child: SettingsContainer(
        title: widget.title,
        description: widget.description,
        afterWidget: Padding(
          padding: const EdgeInsets.only(left: 5),
          child: CupertinoSwitch(
            activeColor: Theme.of(context).colorScheme.primary,
            value: value,
            onChanged: (_) {
              toggleSwitch();
            },
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
  }) : super(key: key);

  final Widget openPage;
  final String title;
  final String? description;
  final IconData? icon;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return OpenContainerNavigation(
      closedColor: Colors.transparent,
      borderRadius: 0,
      button: (openContainer) {
        return SettingsContainer(
          title: title,
          description: description,
          icon: icon,
          iconSize: iconSize,
          onTap: () {
            openContainer();
          },
          afterWidget: Icon(
            Icons.chevron_right_rounded,
            size: 30,
            color: Theme.of(context).colorScheme.secondary,
          ),
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
  }) : super(key: key);

  final String title;
  final String? description;
  final IconData? icon;
  final String initial;
  final List<String> items;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return SettingsContainer(
      title: title,
      description: description,
      icon: icon,
      afterWidget: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: DropdownSelect(
          compact: true,
          initial: initial,
          items: items,
          onChanged: onChanged,
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
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
    this.verticalPadding,
    this.iconSize,
  }) : super(key: key);

  final String title;
  final String? description;
  final IconData? icon;
  final Widget? afterWidget;
  final VoidCallback? onTap;
  final double? verticalPadding;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0),
      child: Tappable(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: 18, vertical: verticalPadding ?? 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: iconSize ?? 30,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    Container(width: 16),
                    Expanded(
                      child: description == null
                          ? TextFont(
                              fixParagraphMargin: true,
                              text: title,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              maxLines: 5,
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFont(
                                  fixParagraphMargin: true,
                                  text: title,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  maxLines: 5,
                                ),
                                Container(height: 3),
                                TextFont(
                                  text: description!,
                                  fontSize: 15,
                                  maxLines: 5,
                                ),
                              ],
                            ),
                    ),
                  ],
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
