import 'package:budget/colors.dart';
import 'package:budget/functions.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';

class SelectItems extends StatefulWidget {
  final List<String> initialItems;
  final List<String> items;
  final Function(List<String>)? onChanged;
  final Function(String)? onChangedSingleItem;
  final IconData? checkboxCustomIconUnselected;
  final IconData? checkboxCustomIconSelected;
  final Function(String)? displayFilter;
  final Function(String)? onLongPress;
  final bool syncWithInitial;
  final Color? Function(String, bool selected)? getColor;
  final bool highlightSelected;
  final bool allSelected;

  const SelectItems({
    Key? key,
    required this.initialItems,
    required this.items,
    this.onChanged,
    this.onChangedSingleItem,
    this.checkboxCustomIconSelected,
    this.checkboxCustomIconUnselected,
    this.onLongPress,
    this.displayFilter,
    this.syncWithInitial = false,
    this.getColor,
    this.highlightSelected = false,
    this.allSelected = false,
  }) : super(key: key);

  @override
  State<SelectItems> createState() => _SelectItemsState();
}

class _SelectItemsState extends State<SelectItems> {
  List<String> currentItems = [];

  @override
  void initState() {
    super.initState();
    currentItems = widget.initialItems;
  }

  void didUpdateWidget(oldWidget) {
    if (oldWidget != widget && widget.syncWithInitial) {
      setState(() {
        currentItems = widget.initialItems;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double borderRadius = getPlatform() == PlatformOS.isIOS ? 10 : 20;
    return Column(
      children: <Widget>[
        for (int i = 0; i < widget.items.length; i++)
          Builder(builder: (context) {
            dynamic item = widget.items[i];
            bool selected = widget.allSelected || currentItems.contains(item);
            Color? color = widget.getColor != null &&
                    widget.getColor!(item, selected) != null
                ? widget.getColor!(item, selected)
                : selected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary;
            bool isAfterSelected =
                widget.allSelected && i != widget.items.length - 1 ||
                    nullIfIndexOutOfRange(widget.items, i + 1) != null &&
                        currentItems.contains(widget.items[i + 1]);
            bool isBeforeSelected = widget.allSelected && i != 0 ||
                nullIfIndexOutOfRange(widget.items, i - 1) != null &&
                    currentItems.contains(widget.items[i - 1]);
            return Tappable(
              customBorderRadius: widget.highlightSelected == false
                  ? null
                  : BorderRadius.vertical(
                      top: Radius.circular(
                        isBeforeSelected ? 0 : borderRadius,
                      ),
                      bottom: Radius.circular(
                        isAfterSelected ? 0 : borderRadius,
                      ),
                    ),
              onLongPress: widget.onLongPress != null
                  ? () => widget.onLongPress!(item)
                  : null,
              borderRadius: 20,
              color: widget.highlightSelected == false
                  ? Colors.transparent
                  : selected
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : Colors.transparent,
              onTap: () {
                if (currentItems.contains(item))
                  currentItems.remove(item);
                else
                  currentItems.add(item);
                setState(() {});
                if (widget.onChanged != null) widget.onChanged!(currentItems);
                if (widget.onChangedSingleItem != null)
                  widget.onChangedSingleItem!(item);
              },
              child: ListTile(
                title: Transform.translate(
                  offset: Offset(-12, 0),
                  child: TextFont(
                      fontSize: 18,
                      text: widget.displayFilter == null
                          ? item
                          : widget.displayFilter!(item)),
                ),
                dense: true,
                leading: widget.checkboxCustomIconUnselected != null &&
                        widget.checkboxCustomIconSelected != null
                    ? Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ScaledAnimatedSwitcher(
                          keyToWatch: selected.toString(),
                          duration: Duration(milliseconds: 400),
                          child: Opacity(
                            opacity: selected ? 1 : 0.8,
                            child: Icon(
                              selected
                                  ? widget.checkboxCustomIconSelected
                                  : widget.checkboxCustomIconUnselected,
                              size: 30,
                              color: color,
                            ),
                          ),
                        ),
                      )
                    : IgnorePointer(
                        child: Checkbox(
                          onChanged: (_) {},
                          value: selected,
                          activeColor: color,
                          checkColor: dynamicPastel(context,
                              color ?? Theme.of(context).colorScheme.primary,
                              amount: 0.65),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
              ),
            );
          })
      ],
    );
  }
}
