import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/material.dart';

class SelectColor extends StatefulWidget {
  SelectColor({
    Key? key,
    this.setSelectedColor,
    this.selectedColor,
    this.next,
  }) : super(key: key);
  final Function(Color)? setSelectedColor;
  final Color? selectedColor;
  final VoidCallback? next;

  @override
  _SelectColorState createState() => _SelectColorState();
}

class _SelectColorState extends State<SelectColor> {
  Color? selectedColor;

  @override
  void initState() {
    super.initState();
    if (widget.selectedColor != null) {
      setState(() {
        selectedColor = widget.selectedColor;
      });
    }
  }

  //find the selected category using selectedCategory
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              children: selectableColors(context)
                  .asMap()
                  .map(
                    (index, color) => MapEntry(
                      index,
                      ColorIcon(
                        sizePadding: 5,
                        margin: EdgeInsets.all(5),
                        color: color,
                        size: 50,
                        onTap: () {
                          if (widget.setSelectedColor != null) {
                            widget.setSelectedColor!(color);
                            setState(() {
                              selectedColor = color;
                            });
                            Future.delayed(Duration(milliseconds: 70), () {
                              Navigator.pop(context);
                              if (widget.next != null) {
                                widget.next!();
                              }
                            });
                          }
                        },
                        outline: selectedColor == color,
                      ),
                    ),
                  )
                  .values
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class ColorIcon extends StatelessWidget {
  ColorIcon({
    Key? key,
    required this.color,
    required this.size,
    this.onTap,
    this.margin,
    this.sizePadding = 20,
    this.outline = false,
  }) : super(key: key);

  final Color color;
  final double size;
  final VoidCallback? onTap;
  final EdgeInsets? margin;
  final double sizePadding;
  final bool outline;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      margin: margin ?? EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
      height: size + sizePadding,
      width: size + sizePadding,
      decoration: outline
          ? BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.accentColorHeavy,
                width: 3,
              ),
              borderRadius: BorderRadius.all(Radius.circular(500)),
            )
          : BoxDecoration(
              border: Border.all(
                color: Colors.transparent,
                width: 0,
              ),
              borderRadius: BorderRadius.all(Radius.circular(500)),
            ),
      child: Tappable(
        color: color,
        onTap: onTap,
        borderRadius: 500,
        child: Container(),
      ),
    );
  }
}
