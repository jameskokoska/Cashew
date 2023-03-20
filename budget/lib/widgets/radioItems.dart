import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';

class RadioItems extends StatefulWidget {
  final String initial;
  final List<String> items;
  final Function(String) onChanged;
  final Function(String)? displayFilter;
  final Function(String)? onLongPress;

  const RadioItems({
    Key? key,
    required this.initial,
    required this.items,
    required this.onChanged,
    this.onLongPress,
    this.displayFilter,
  }) : super(key: key);

  @override
  State<RadioItems> createState() => _RadioItemsState();
}

class _RadioItemsState extends State<RadioItems> {
  String? currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (var item in widget.items)
          Tappable(
            onLongPress: widget.onLongPress != null
                ? () => widget.onLongPress!(item)
                : null,
            borderRadius: 20,
            color: Colors.transparent,
            onTap: () {
              setState(() {
                currentValue = item;
              });
              widget.onChanged(item);
            },
            child: ListTile(
              title: Transform.translate(
                offset: Offset(-12, 0),
                child: TextFont(
                    fontSize: 20,
                    text: widget.displayFilter == null
                        ? item
                        : widget.displayFilter!(item)),
              ),
              dense: true,
              leading: Radio<String>(
                value: item,
                groupValue: currentValue,
                onChanged: (String? value) {
                  setState(() {
                    currentValue = value;
                  });
                  widget.onChanged(item);
                },
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          )
      ],
    );
  }
}
