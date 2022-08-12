import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/colorPicker.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/popupFramework.dart';
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
    this.supportCustomColors = true,
  }) : super(key: key);
  final Function(Color)? setSelectedColor;
  final Color? selectedColor;
  final VoidCallback? next;
  final bool horizontalList;
  final bool supportCustomColors;

  @override
  _SelectColorState createState() => _SelectColorState();
}

class _SelectColorState extends State<SelectColor> {
  Color? selectedColor;
  int? selectedIndex;
  bool selectedCustomColor = false;

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
    if (widget.supportCustomColors) {
      selectableColorsList.add(Colors.transparent);
    }
    if (widget.horizontalList) {
      return ListView.builder(
        addAutomaticKeepAlives: true,
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        itemCount: selectableColorsList.length,
        itemBuilder: (context, index) {
          Color color;
          // Custom color as the last color
          color = selectableColorsList[index];
          return Padding(
            padding: EdgeInsets.only(
                left: index == 0 ? 12 : 0,
                right: index + 1 == selectableColorsList.length ? 12 : 0),
            child: ColorIcon(
              customColor: widget.supportCustomColors &&
                  index + 1 == selectableColorsList.length,
              onSelectCustomColor: (color) {
                widget.setSelectedColor!(color);
                setState(() {
                  selectedColor = color;
                  selectedCustomColor = true;
                  selectedIndex = index;
                });
                Future.delayed(Duration(milliseconds: 70), () {
                  if (widget.next != null) {
                    widget.next!();
                  }
                });
              },
              margin: EdgeInsets.all(5),
              color: (widget.supportCustomColors &&
                      index + 1 == selectableColorsList.length)
                  ? (selectedColor ?? Colors.transparent)
                  : color,
              size: 55,
              onTap: () {
                if (widget.setSelectedColor != null) {
                  widget.setSelectedColor!(color);
                  setState(() {
                    selectedColor = color;
                    selectedIndex = index;
                  });
                  Future.delayed(Duration(milliseconds: 70), () {
                    Navigator.pop(context);
                    if (widget.next != null) {
                      widget.next!();
                    }
                  });
                }
              },
              outline: (selectedIndex != null &&
                      selectedIndex == selectableColorsList.length - 1 &&
                      index == selectedIndex) ||
                  selectedColor.toString() == color.toString(),
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
                        customColor: widget.supportCustomColors &&
                            index + 1 == selectableColorsList.length,
                        onSelectCustomColor: (color) {
                          widget.setSelectedColor!(color);
                          Future.delayed(Duration(milliseconds: 70), () {
                            Navigator.pop(context);
                            if (widget.next != null) {
                              widget.next!();
                            }
                          });
                        },
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
    this.onSelectCustomColor,
    this.margin,
    this.outline = false,
    this.customColor = false,
  }) : super(key: key);

  final Color color;
  final double size;
  final VoidCallback? onTap;
  final Function(Color)? onSelectCustomColor;
  final EdgeInsets? margin;
  final bool outline;
  final bool customColor;

  Color selectedColor = Colors.transparent;
  @override
  Widget build(BuildContext context) {
    Widget colorPickerPopup = PopupFramework(
      title: "Custom Color",
      child: Column(
        children: [
          Center(
            child: ColorPicker(
              ringColor: Theme.of(context).colorScheme.black,
              ringSize: 10,
              width: MediaQuery.of(context).size.width - 100,
              onChange: (color) {
                selectedColor = color;
              },
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Button(
            label: "Select",
            onTap: () {
              Navigator.pop(context);
              onSelectCustomColor!(selectedColor);
            },
          )
        ],
      ),
    );
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      margin: margin ?? EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
      height: size,
      width: size,
      decoration: outline && customColor == false
          ? BoxDecoration(
              border: Border.all(
                color: dynamicPastel(context, color,
                    amountLight: 0.5, amountDark: 0.4, inverse: true),
                width: 3,
              ),
              borderRadius: BorderRadius.all(Radius.circular(500)),
            )
          : outline == true && customColor
              ? BoxDecoration(
                  border: Border.all(
                    color: color,
                    width: 2,
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
        color: customColor == true ? Colors.transparent : color,
        onTap: customColor
            ? () async {
                await openBottomSheet(context, colorPickerPopup);
              }
            : onTap,
        borderRadius: 500,
        child: customColor
            ? Icon(
                Icons.colorize_rounded,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
              )
            : SizedBox.shrink(),
      ),
    );
  }
}
