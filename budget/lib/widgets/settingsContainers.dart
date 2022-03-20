import 'package:budget/colors.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
                                  children: [
                                    Container(height: 3),
                                    TextFont(
                                      text: widget.description!,
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
