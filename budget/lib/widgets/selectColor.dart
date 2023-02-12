import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/main.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/colorPicker.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';
import 'package:budget/widgets/scrollbarWrap.dart';

class SelectColor extends StatefulWidget {
  SelectColor({
    Key? key,
    this.setSelectedColor,
    this.selectedColor,
    this.next,
    this.horizontalList = false,
    this.supportCustomColors = true,
    this.includeThemeColor = true, // Will return null if theme color is chosen
    this.useSystemColorPrompt =
        false, // Will show the option to use the system color (horizontalList must be disabled)
  }) : super(key: key);
  final Function(Color?)? setSelectedColor;
  final Color? selectedColor;
  final VoidCallback? next;
  final bool horizontalList;
  final bool supportCustomColors;
  final bool includeThemeColor;
  final bool? useSystemColorPrompt;

  @override
  _SelectColorState createState() => _SelectColorState();
}

class _SelectColorState extends State<SelectColor> {
  Color? selectedColor;
  int? selectedIndex;
  bool useSystemColor = appStateSettings["accentSystemColor"];

  @override
  void initState() {
    super.initState();
    if (widget.selectedColor != null) {
      int index = 0;
      Future.delayed(Duration.zero, () {
        for (Color color in selectableColors(context)) {
          if (color.toString() == widget.selectedColor.toString()) {
            setState(() {
              selectedIndex = index;
              selectedColor = widget.selectedColor;
            });
            return;
          }
          index++;
        }
        print("color not found - must be custom color");
        setState(() {
          selectedIndex = -1;
          selectedColor = widget.selectedColor;
        });
      });
    } else {
      setState(() {
        selectedIndex = 0;
        selectedColor = null;
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
    if (widget.includeThemeColor) {
      selectableColorsList.insert(0, Colors.transparent);
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
            child: widget.includeThemeColor && index == 0
                ? ThemeColorIcon(
                    outline: selectedIndex == 0 && selectedColor == null,
                    margin: EdgeInsets.all(5),
                    size: 55,
                    onTap: () {
                      widget.setSelectedColor!(null);
                      setState(() {
                        selectedColor = null;
                        selectedIndex = index;
                      });
                    },
                  )
                : widget.supportCustomColors &&
                        index + 1 == selectableColorsList.length
                    ? ColorIconCustom(
                        initialSelectedColor: selectedColor ?? Colors.red,
                        outline: selectedIndex == -1 ||
                            selectedIndex == selectableColorsList.length - 1,
                        margin: EdgeInsets.all(5),
                        size: 55,
                        onTap: (colorPassed) {
                          widget.setSelectedColor!(colorPassed);
                          setState(() {
                            selectedColor = color;
                            selectedIndex = index;
                          });
                        },
                      )
                    : ColorIcon(
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
                              if (widget.next != null) {
                                widget.next!();
                              }
                            });
                          }
                        },
                        outline: (selectedIndex != null &&
                                selectedIndex ==
                                    selectableColorsList.length - 1 &&
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
          widget.useSystemColorPrompt == true
              ? SettingsContainerSwitch(
                  title: "Use System Color",
                  onSwitched: (value) async {
                    if (value == true) {
                      await SystemTheme.accentColor.load();
                      Color accentColor = SystemTheme.accentColor.accent;
                      updateSettings("accentColor", toHexString(accentColor),
                          updateGlobalState: true);
                    } else {
                      widget.setSelectedColor!(selectedColor);
                    }
                    updateSettings("accentSystemColor", value,
                        updateGlobalState: true);
                    setState(() {
                      useSystemColor = value;
                    });
                  },
                  initialValue: useSystemColor,
                  icon: Icons.devices_rounded,
                )
              : SizedBox.shrink(),
          AnimatedOpacity(
            duration: Duration(milliseconds: 400),
            opacity:
                widget.useSystemColorPrompt == true && useSystemColor == false
                    ? 1
                    : 0.5,
            child: Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                children: selectableColorsList
                    .asMap()
                    .map(
                      (index, color) => MapEntry(
                        index,
                        widget.supportCustomColors &&
                                index + 1 == selectableColorsList.length
                            ? ColorIconCustom(
                                initialSelectedColor:
                                    selectedColor ?? Colors.red,
                                margin: EdgeInsets.all(5),
                                size: 55,
                                onTap: (colorPassed) {
                                  widget.setSelectedColor!(colorPassed);
                                  setState(() {
                                    selectedColor = color;
                                    selectedIndex = index;
                                  });
                                  Future.delayed(Duration(milliseconds: 70),
                                      () {
                                    Navigator.pop(context);
                                    if (widget.next != null) {
                                      widget.next!();
                                    }
                                  });
                                },
                                outline: selectedIndex == -1 ||
                                    selectedIndex ==
                                        selectableColorsList.length - 1,
                              )
                            : ColorIcon(
                                margin: EdgeInsets.all(5),
                                color: color,
                                size: 55,
                                onTap: () {
                                  if (widget.setSelectedColor != null) {
                                    widget.setSelectedColor!(color);
                                    setState(() {
                                      selectedColor = color;
                                    });
                                    Future.delayed(Duration(milliseconds: 70),
                                        () {
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

class ThemeColorIcon extends StatelessWidget {
  const ThemeColorIcon({
    Key? key,
    required this.size,
    required this.onTap,
    this.margin,
    required this.outline,
  }) : super(key: key);

  final double size;
  final Function()? onTap;
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
                color: dynamicPastel(
                    context, Theme.of(context).colorScheme.primary,
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
        color: Colors.transparent,
        onTap: onTap,
        borderRadius: 500,
        child: Icon(
          Icons.color_lens_rounded,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
        ),
      ),
    );
  }
}

class ColorIconCustom extends StatefulWidget {
  ColorIconCustom({
    Key? key,
    required this.size,
    required this.onTap,
    this.margin,
    required this.outline,
    required this.initialSelectedColor,
  }) : super(key: key);

  final double size;
  final Function(Color) onTap;
  final EdgeInsets? margin;
  final bool outline;
  final Color initialSelectedColor;

  @override
  State<ColorIconCustom> createState() => _ColorIconCustomState();
}

class _ColorIconCustomState extends State<ColorIconCustom> {
  late Color selectedColor = widget.initialSelectedColor;
  double? colorSliderPosition;
  double? shadeSliderPosition;

  @override
  Widget build(BuildContext context) {
    Widget colorPickerPopup = PopupFramework(
      title: "Custom Color",
      child: Column(
        children: [
          Center(
            child: ColorPicker(
              colorSliderPosition: colorSliderPosition,
              shadeSliderPosition: shadeSliderPosition,
              ringColor: Theme.of(context).colorScheme.black,
              ringSize: 10,
              width: MediaQuery.of(context).size.width - 100,
              onChange: (color, colorSliderPositionPassed,
                  shadeSliderPositionPassed) {
                setState(() {
                  selectedColor = color;
                  colorSliderPosition = colorSliderPositionPassed;
                  shadeSliderPosition = shadeSliderPositionPassed;
                });
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
              widget.onTap(selectedColor);
            },
          )
        ],
      ),
    );
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      margin: widget.margin ??
          EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
      height: widget.size,
      width: widget.size,
      decoration: widget.outline
          ? BoxDecoration(
              border: Border.all(
                color: dynamicPastel(context, selectedColor,
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
        color: Colors.transparent,
        onTap: () async {
          await openBottomSheet(context, colorPickerPopup);
        },
        borderRadius: 500,
        child: Icon(
          Icons.colorize_rounded,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
        ),
      ),
    );
  }
}
