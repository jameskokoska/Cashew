import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';

class RadioItems<T> extends StatefulWidget {
  final T initial;
  final List<T> items;
  final List<String>? descriptions;
  final Function(T item) onChanged;
  final String Function(T item)? displayFilter;
  final Color? Function(T item)? colorFilter;
  final Function(T item)? onLongPress;
  final bool ifNullSelectNone;
  final bool itemsAreFonts;
  final bool Function(T item)? getSelected;

  const RadioItems({
    Key? key,
    required this.initial,
    required this.items,
    this.descriptions,
    required this.onChanged,
    this.onLongPress,
    this.displayFilter,
    this.colorFilter,
    this.getSelected,
    this.ifNullSelectNone = false,
    this.itemsAreFonts = false,
  }) : super(key: key);

  @override
  State<RadioItems<T>> createState() => _RadioItemsState<T>();
}

class _RadioItemsState<T> extends State<RadioItems<T>> {
  T? currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    int index = -1;
    for (T item in widget.items) {
      index += 1;
      bool selected = false;
      if (currentValue == item ||
          (widget.getSelected != null && widget.getSelected!(item)))
        selected = true;
      if (item == null && widget.ifNullSelectNone == true) selected = false;
      bool noDescription = widget.descriptions == null ||
          widget.descriptions!.length <= index ||
          widget.descriptions![index] == "";
      children.add(
        AnimatedSwitcher(
          duration: Duration(milliseconds: 150),
          child: Tappable(
            key: ValueKey((currentValue == item).toString()),
            onLongPress: widget.onLongPress != null
                ? () => widget.onLongPress!(item)
                : null,
            borderRadius: getPlatform() == PlatformOS.isIOS ? 10 : 20,
            color: selected
                ? Theme.of(context).colorScheme.secondaryContainer
                : Colors.transparent,
            onTap: () {
              setState(() {
                currentValue = item;
              });
              widget.onChanged(item);
            },
            child: ListTile(
              title: Transform.translate(
                offset: Offset(-12, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.itemsAreFonts == true &&
                        (item != "Avenir" ||
                            appStateSettings["font"] != "Avenir"))
                      Text(
                        widget.displayFilter == null
                            ? item.toString()
                            : widget.displayFilter!(item),
                        style: TextStyle(
                          fontSize: noDescription ? 18 : 16,
                          fontFamily: item.toString(),
                        ),
                      ),
                    if (widget.itemsAreFonts == false ||
                        (item == "Avenir" &&
                            appStateSettings["font"] == "Avenir"))
                      TextFont(
                        fontSize: noDescription ? 18 : 16,
                        text: widget.displayFilter == null
                            ? item.toString()
                            : widget.displayFilter!(item),
                        maxLines: 3,
                      ),
                    noDescription
                        ? SizedBox.shrink()
                        : TextFont(
                            fontSize: 14,
                            text: widget.descriptions![index],
                            maxLines: 3,
                          ),
                  ],
                ),
              ),
              dense: true,
              leading: Radio<String>(
                visualDensity: VisualDensity.compact,
                value: selected ? "true" : "false",
                groupValue: "true",
                onChanged: (_) {
                  setState(() {
                    currentValue = item;
                  });
                  widget.onChanged(item);
                },
                fillColor: widget.colorFilter != null &&
                        widget.colorFilter!(item) != null
                    ? MaterialStateColor.resolveWith(
                        (states) => widget.colorFilter!(item)!)
                    : null,
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      );
    }
    return Column(
      children: children,
    );
  }
}

class CheckItems<T> extends StatefulWidget {
  final List<T>? initial;
  final List<T> items;
  final Function(List<T> currentValues) onChanged;
  final String Function(T item, int itemIndex)? displayFilter;
  final Color? Function(T item)? colorFilter;
  final Function(T item)? onLongPress;
  final Widget Function(
      List<T> currentValues,
      T item,
      bool selected,
      void Function(T item) addItem,
      void Function(T item) removeItem)? buildSuffix;
  final double? minVerticalPadding;
  final bool allSelected;
  final bool syncWithInitial;
  final bool triggerInitialOnChanged;
  final IconData? selectedIcon;
  final IconData? unSelectedIcon;

  const CheckItems({
    Key? key,
    this.initial,
    required this.items,
    required this.onChanged,
    this.onLongPress,
    this.displayFilter,
    this.colorFilter,
    this.buildSuffix,
    this.minVerticalPadding,
    this.allSelected = false,
    this.syncWithInitial = false,
    this.triggerInitialOnChanged = true,
    this.selectedIcon,
    this.unSelectedIcon,
  }) : super(key: key);

  @override
  State<CheckItems<T>> createState() => _CheckItemsState<T>();
}

class _CheckItemsState<T> extends State<CheckItems<T>> {
  List<T> currentValues = [];

  @override
  void initState() {
    super.initState();
    currentValues = widget.initial ?? [];
    Future.delayed(Duration.zero, () {
      if (widget.triggerInitialOnChanged) widget.onChanged(currentValues);
    });
  }

  void didUpdateWidget(oldWidget) {
    if (oldWidget != widget && widget.syncWithInitial) {
      setState(() {
        currentValues = widget.initial ?? [];
      });
    }
  }

  void addEntry(T item) {
    int index = currentValues.indexOf(item);
    if (index == -1) {
      currentValues.add(item);
    }
    widget.onChanged(currentValues);
  }

  void removeEntry(T item) {
    int index = currentValues.indexOf(item);
    if (index != -1) {
      currentValues.removeAt(index);
    }
    widget.onChanged(currentValues);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    double borderRadius = getPlatform() == PlatformOS.isIOS ? 10 : 20;
    for (int itemIndex = 0; itemIndex < widget.items.length; itemIndex++) {
      T item = widget.items[itemIndex];
      bool selected = false;
      if (currentValues.contains(item) || widget.allSelected) selected = true;
      bool isAfterSelected =
          widget.allSelected && itemIndex != widget.items.length - 1 ||
              nullIfIndexOutOfRange(widget.items, itemIndex + 1) != null &&
                  currentValues.contains(widget.items[itemIndex + 1]);
      bool isBeforeSelected = widget.allSelected && itemIndex != 0 ||
          nullIfIndexOutOfRange(widget.items, itemIndex - 1) != null &&
              currentValues.contains(widget.items[itemIndex - 1]);
      children.add(
        AnimatedSwitcher(
          duration: Duration(milliseconds: 150),
          child: Tappable(
            customBorderRadius: BorderRadius.vertical(
              top: Radius.circular(
                isBeforeSelected ? 0 : borderRadius,
              ),
              bottom: Radius.circular(
                isAfterSelected ? 0 : borderRadius,
              ),
            ),
            key: ValueKey(selected.toString()),
            onLongPress: widget.onLongPress != null
                ? () => widget.onLongPress!(item)
                : null,
            borderRadius: borderRadius,
            color: selected
                ? Theme.of(context).colorScheme.secondaryContainer
                : Colors.transparent,
            onTap: () {
              setState(() {
                int index = currentValues.indexOf(item);
                if (index != -1) {
                  currentValues.removeAt(index);
                } else {
                  currentValues.add(item);
                }
              });
              widget.onChanged(currentValues);
            },
            child: ListTile(
              minVerticalPadding: widget.minVerticalPadding,
              title: Transform.translate(
                offset: Offset(-12, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFont(
                        fontSize: 18,
                        text: widget.displayFilter == null
                            ? item.toString()
                            : widget.displayFilter!(item, itemIndex),
                        maxLines: 3,
                      ),
                    ),
                    widget.buildSuffix != null
                        ? widget.buildSuffix!(currentValues, item, selected,
                            addEntry, removeEntry)
                        : SizedBox.shrink()
                  ],
                ),
              ),
              dense: true,
              contentPadding: EdgeInsets.only(right: 0, left: 16),
              leading: Padding(
                padding: const EdgeInsets.only(right: 5),
                child: selected
                    ? Icon(
                        widget.selectedIcon ?? Icons.check_box,
                        color: widget.colorFilter != null
                            ? widget.colorFilter!(item)
                            : null,
                      )
                    : Icon(
                        widget.unSelectedIcon ?? Icons.check_box_outline_blank,
                        color: widget.colorFilter != null
                            ? widget.colorFilter!(item)
                            : null,
                      ),
              ),
            ),
          ),
        ),
      );
    }
    return Column(
      children: children,
    );
  }
}
