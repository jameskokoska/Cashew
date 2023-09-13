import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import '../colors.dart';

class DropdownSelect extends StatefulWidget {
  final String initial;
  final List<String> items;
  final Function(String) onChanged;
  final Color? backgroundColor;
  final bool compact;
  final bool
      checkInitialValue; //Check if the initial value not in list, default to using the first index
  final List<String> boldedValues;
  final Function(String)? getLabel;

  const DropdownSelect({
    Key? key,
    required this.initial,
    required this.items,
    required this.onChanged,
    this.backgroundColor,
    this.compact = false,
    this.checkInitialValue = false,
    this.boldedValues = const [],
    this.getLabel,
  }) : super(key: key);

  @override
  State<DropdownSelect> createState() => DropdownSelectState();
}

class DropdownSelectState extends State<DropdownSelect> {
  String? currentValue;

  late GlobalKey? _dropdownButtonKey = GlobalKey();

  void openDropdown() {
    GestureDetector? detector;
    void searchForGestureDetector(BuildContext? element) {
      element?.visitChildElements((element) {
        if (element.widget is GestureDetector) {
          detector = element.widget as GestureDetector?;
        } else {
          searchForGestureDetector(element);
        }
      });
    }

    searchForGestureDetector(_dropdownButtonKey?.currentContext);
    assert(detector != null);

    detector?.onTap?.call();
  }

  @override
  void initState() {
    super.initState();
    if (widget.checkInitialValue == true &&
        !widget.items.contains(widget.initial)) {
      currentValue = widget.items[0];
    } else {
      currentValue = widget.initial;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          left: widget.compact ? 13 : 15,
          right: widget.compact ? 1 : 6,
          top: widget.compact ? 2 : 10,
          bottom: widget.compact ? 2 : 10),
      decoration: BoxDecoration(
        color: widget.backgroundColor == null
            ? getColor(context, "lightDarkAccent")
            : widget.backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<String>(
        key: _dropdownButtonKey,
        underline: Container(),
        style: TextStyle(color: getColor(context, "black"), fontSize: 15),
        dropdownColor: widget.backgroundColor == null
            ? getColor(context, "lightDarkAccent")
            : widget.backgroundColor,
        isDense: true,
        value: currentValue ?? widget.initial,
        elevation: 15,
        iconSize: 32,
        borderRadius: BorderRadius.circular(10),
        icon: Icon(appStateSettings["outlinedIcons"]
            ? Icons.arrow_drop_down_outlined
            : Icons.arrow_drop_down_rounded),
        onChanged: (String? value) {
          widget.onChanged(value ?? widget.items[0]);
          setState(() {
            currentValue = value;
          });
        },
        items: widget.items
            .toSet()
            .toList()
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem(
            alignment: Alignment.centerLeft,
            child: TextFont(
              text: widget.getLabel != null ? widget.getLabel!(value) : value,
              fontSize: widget.compact ? 14 : 18,
              fontWeight: widget.boldedValues.contains(value)
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
            value: value,
          );
        }).toList(),
      ),
    );
  }
}

class DropdownItemMenu {
  final String id;
  final String label;
  final IconData icon;
  final Function action;
  final double? iconScale;

  DropdownItemMenu({
    required this.id,
    required this.label,
    required this.icon,
    required this.action,
    this.iconScale,
  });
}

class CustomPopupMenuButton extends StatelessWidget {
  final List<DropdownItemMenu> items;
  final bool showButtons;
  final bool keepOutFirst;

  CustomPopupMenuButton({
    required this.items,
    this.showButtons = false,
    this.keepOutFirst = true,
  });

  @override
  Widget build(BuildContext context) {
    bool keepOutFirstConsideringHeader = keepOutFirst &&
        getCenteredTitleSmall(context: context, backButtonEnabled: true) ==
            false;
    List<DropdownItemMenu> itemsFiltered = [...items];
    if (keepOutFirstConsideringHeader) itemsFiltered.removeAt(0);

    if (showButtons) {
      return Row(
        children: [
          ...(items).asMap().entries.map((item) {
            int idx = item.key;
            int length = items.length;
            double offsetX = (length - 1 - idx) * 7;
            return Transform.translate(
              offset: Offset(offsetX, 0),
              child: Tooltip(
                message: item.value.label,
                child: IconButton(
                  padding: EdgeInsets.all(15),
                  onPressed: () {
                    item.value.action();
                  },
                  icon: Transform.scale(
                    scale: item.value.iconScale ?? 1,
                    child: Icon(
                      item.value.icon,
                    ),
                  ),
                ),
              ),
            );
          })
        ],
      );
    }

    return Row(
      children: [
        if (keepOutFirstConsideringHeader)
          Transform.translate(
            offset: Offset(7, 0),
            child: Tooltip(
              message: items[0].label,
              child: IconButton(
                padding: EdgeInsets.all(15),
                onPressed: () {
                  items[0].action();
                },
                icon: Transform.scale(
                  scale: items[0].iconScale ?? 1,
                  child: Icon(
                    items[0].icon,
                  ),
                ),
              ),
            ),
          ),
        PopupMenuButton<String>(
          padding: EdgeInsets.all(15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(getPlatform() == PlatformOS.isIOS ? 5 : 10),
            ),
          ),
          onSelected: (value) {
            for (DropdownItemMenu item in items) {
              if (item.id == value) {
                item.action();
                break;
              }
            }
          },
          itemBuilder: (BuildContext context) {
            return itemsFiltered.map((item) {
              return PopupMenuItem<String>(
                value: item.id,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Transform.scale(
                      scale: item.iconScale ?? 1,
                      child: Icon(item.icon),
                    ),
                    SizedBox(width: 9),
                    TextFont(
                      text: item.label,
                      fontSize: 14.5,
                    ),
                  ],
                ),
              );
            }).toList();
          },
        ),
      ],
    );
  }
}
