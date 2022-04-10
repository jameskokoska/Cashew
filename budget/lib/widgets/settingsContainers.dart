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
    Key? key,
  }) : super(key: key);

  final String title;
  final String? description;
  final bool initialValue;
  final IconData? icon;
  final Function(bool) onSwitched;

  @override
  State<SettingsContainerSwitch> createState() =>
      _SettingsContainerSwitchState();
}

class _SettingsContainerSwitchState extends State<SettingsContainerSwitch> {
  bool value = true;

  @override
  void initState() {
    super.initState();
    value = widget.initialValue;
  }

  void toggleSwitch() {
    widget.onSwitched(!value);
    setState(() {
      value = !value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Tappable(
        onTap: () {
          toggleSwitch();
        },
        borderRadius: 10,
        color: Theme.of(context).colorScheme.lightDarkAccent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      widget.icon,
                      size: 27,
                      color: Theme.of(context).colorScheme.accentColorHeavy,
                    ),
                    Container(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFont(
                            fixParagraphMargin: true,
                            text: widget.title,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          widget.description == null
                              ? SizedBox.shrink()
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(height: 3),
                                    TextFont(
                                      text: widget.description!,
                                      fontSize: 15,
                                      maxLines: 5,
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoSwitch(
                activeColor: Theme.of(context).colorScheme.accentColorHeavy,
                value: value,
                onChanged: (_) {
                  toggleSwitch();
                },
              ),
            ],
          ),
        ),
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
  }) : super(key: key);

  final Widget openPage;
  final String title;
  final String? description;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return OpenContainerNavigation(
      closedColor: Colors.transparent,
      borderRadius: 10,
      button: (openContainer) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Tappable(
            onTap: () {
              openContainer();
            },
            borderRadius: 10,
            color: Theme.of(context).colorScheme.lightDarkAccent,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 22, vertical: 13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          icon,
                          size: 27,
                          color: Theme.of(context).colorScheme.accentColorHeavy,
                        ),
                        Container(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFont(
                                fixParagraphMargin: true,
                                text: title,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              description == null
                                  ? SizedBox.shrink()
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(height: 3),
                                        TextFont(
                                          text: description!,
                                          fontSize: 15,
                                          maxLines: 5,
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 27,
                    color: Theme.of(context).colorScheme.accentColor,
                  ),
                ],
              ),
            ),
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.lightDarkAccent,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.only(left: 22, right: 15, top: 13, bottom: 13),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    size: 27,
                    color: Theme.of(context).colorScheme.accentColorHeavy,
                  ),
                  Container(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFont(
                          fixParagraphMargin: true,
                          text: title,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        description == null
                            ? SizedBox.shrink()
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(height: 3),
                                  TextFont(
                                    text: description!,
                                    fontSize: 15,
                                    maxLines: 5,
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: DropdownSelect(
                compact: true,
                initial: initial,
                items: items,
                onChanged: onChanged,
                backgroundColor: Theme.of(context).canvasColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsContainerButton extends StatelessWidget {
  const SettingsContainerButton({
    Key? key,
    required this.title,
    this.description,
    this.icon,
    required this.onTap,
  }) : super(key: key);

  final String title;
  final String? description;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Tappable(
        onTap: () {
          onTap();
        },
        borderRadius: 10,
        color: Theme.of(context).colorScheme.lightDarkAccent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      icon,
                      size: 27,
                      color: Theme.of(context).colorScheme.accentColorHeavy,
                    ),
                    Container(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFont(
                            fixParagraphMargin: true,
                            text: title,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          description == null
                              ? SizedBox.shrink()
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(height: 3),
                                    TextFont(
                                      text: description!,
                                      fontSize: 15,
                                      maxLines: 5,
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 27,
                color: Theme.of(context).colorScheme.accentColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
