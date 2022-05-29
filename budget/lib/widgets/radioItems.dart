import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class RadioItems extends StatefulWidget {
  final String initial;
  final List<String> items;
  final Function(String) onChanged;

  const RadioItems({
    Key? key,
    required this.initial,
    required this.items,
    required this.onChanged,
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
          GestureDetector(
            onTap: () {
              setState(() {
                currentValue = item;
              });
              widget.onChanged(item);
            },
            child: ListTile(
              title: Transform.translate(
                offset: Offset(-12, 0),
                child: TextFont(text: item),
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
