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
    this.horizontalList = false,
  }) : super(key: key);
  final Function(Color)? setSelectedColor;
  final Color? selectedColor;
  final VoidCallback? next;
  final bool horizontalList;

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
    List<Color> selectableColorsList = selectableColors(context);
    if (widget.horizontalList) {
      return ListView.builder(
        addAutomaticKeepAlives: true,
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        itemCount: selectableColorsList.length,
        itemBuilder: (context, index) {
          Color color = selectableColorsList[index];
          return Padding(
            padding: EdgeInsets.only(
                left: index == 0 ? 12 : 0,
                right: index == selectableColorsList.length - 1 ? 12 : 0),
            child: ColorIcon(
              margin: EdgeInsets.all(5),
              color: color,
              size: 55,
              onTap: () {
                if (widget.setSelectedColor != null) {
                  widget.setSelectedColor!(color);
                  setState(() {
                    selectedColor = color;
                  });
                  Future.delayed(Duration(milliseconds: 70), () {
                    if (widget.next != null) {
                      widget.next!();
                    }
                  });
                }
              },
              outline: selectedColor.toString() == color.toString(),
            ),
          );
        },
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              children: selectableColorsList
                  .asMap()
                  .map(
                    (index, color) => MapEntry(
                      index,
                      ColorIcon(
                        margin: EdgeInsets.all(5),
                        color: color,
                        size: 55,
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
    this.outline = false,
  }) : super(key: key);

  final Color color;
  final double size;
  final VoidCallback? onTap;
  final EdgeInsets? margin;
  final bool outline;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      margin: margin ?? EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
      height: size,
      width: size,
      decoration: outline
          ? BoxDecoration(
              border: Border.all(
                color: dynamicPastel(context, color,
                    amountLight: 0.5, amountDark: 0.4, inverse: true),
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
