import 'package:budget/colors.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/premiumPage.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/colorPicker.dart';
import 'package:budget/widgets/linearGradientFadedEdges.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:flutter/services.dart';
import 'package:gradient_borders/gradient_borders.dart';

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
        if (useSystemColor == false)
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
      return LinearGradientFadedEdges(
        enableTop: false,
        enableBottom: false,
        enableLeft: getHorizontalPaddingConstrained(context) > 0,
        enableRight: getHorizontalPaddingConstrained(context) > 0,
        child: ClipRRect(
          child: ListView.builder(
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
                                selectedIndex ==
                                    selectableColorsList.length - 1,
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
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          widget.useSystemColorPrompt == true && supportsSystemColor()
              ? SettingsContainerSwitch(
                  enableBorderRadius: true,
                  title: "use-system-color".tr(),
                  onSwitched: (value) async {
                    await updateSettings("accentSystemColor", value,
                        updateGlobalState: true);
                    if (value == true) {
                      // Need to set "accentSystemColor" to true before getAccentColorSystemString
                      await updateSettings(
                          "accentColor", await getAccentColorSystemString(),
                          updateGlobalState: true);
                      generateColors();
                    } else {
                      widget.setSelectedColor!(selectedColor);
                    }
                    setState(() {
                      useSystemColor = value;
                    });
                  },
                  initialValue: useSystemColor,
                  icon: appStateSettings["outlinedIcons"]
                      ? Icons.devices_outlined
                      : Icons.devices_rounded,
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
                                outline: selectedColor.toString() ==
                                    color.toString(),
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
    return Tooltip(
      message: "theme-color".tr(),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        margin: margin ?? EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
        height: size,
        width: size,
        decoration: outline
            ? BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: dynamicPastel(
                      context, Theme.of(context).colorScheme.primary,
                      amountLight: 0.5, amountDark: 0.4, inverse: true),
                  width: 3,
                ),
              )
            : BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.transparent,
                  width: 0,
                ),
              ),
        child: Tappable(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
          onTap: onTap,
          borderRadius: 500,
          child: Icon(
            appStateSettings["outlinedIcons"]
                ? Icons.color_lens_outlined
                : Icons.color_lens_rounded,
            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
          ),
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
      title: "custom-color".tr(),
      outsideExtraWidget: IconButton(
        iconSize: 25,
        padding: EdgeInsets.all(getPlatform() == PlatformOS.isIOS ? 15 : 20),
        icon: Icon(
          appStateSettings["outlinedIcons"]
              ? Icons.numbers_outlined
              : Icons.numbers_rounded,
        ),
        onPressed: () async {
          enterColorCodeBottomSheet(
            context,
            initialSelectedColor: widget.initialSelectedColor,
            setSelectedColor: widget.onTap,
          );
        },
      ),
      child: Column(
        children: [
          Center(
            child: ColorPicker(
              colorSliderPosition: colorSliderPosition,
              shadeSliderPosition: shadeSliderPosition,
              ringColor: getColor(context, "black"),
              ringSize: 10,
              width: getWidthBottomSheet(context) - 100,
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
            label: "select".tr(),
            onTap: () {
              Navigator.pop(context);
              widget.onTap(selectedColor);
            },
          )
        ],
      ),
    );
    return Tooltip(
      message: "custom-color".tr(),
      child: LockedFeature(
        actionAfter: () async {
          await openBottomSheet(context, colorPickerPopup);
        },
        child: Container(
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
                  border: GradientBoxBorder(
                    gradient: LinearGradient(colors: [
                      Colors.red.withOpacity(0.8),
                      Colors.yellow.withOpacity(0.8),
                      Colors.green.withOpacity(0.8),
                      Colors.blue.withOpacity(0.8),
                      Colors.purple.withOpacity(0.8),
                    ]),
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(500),
                ),
          child: Tappable(
            color: Colors.transparent,
            onTap: () async {
              await openBottomSheet(context, colorPickerPopup);
            },
            borderRadius: 500,
            child: Icon(
              appStateSettings["outlinedIcons"]
                  ? Icons.colorize_outlined
                  : Icons.colorize_rounded,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      ),
    );
  }
}

Future enterColorCodeBottomSheet(
  context, {
  required Color initialSelectedColor,
  required Function(Color) setSelectedColor,
}) async {
  Navigator.pop(context);
  return await openBottomSheet(
    context,
    fullSnap: true,
    PopupFramework(
      title: "enter-color-code".tr(),
      child: Column(
        children: [
          HexColorPicker(
            initialSelectedColor: initialSelectedColor,
            setSelectedColor: setSelectedColor,
          )
        ],
      ),
    ),
  );
}

class HexColorPicker extends StatefulWidget {
  const HexColorPicker({
    super.key,
    required this.initialSelectedColor,
    required this.setSelectedColor,
  });
  final Color initialSelectedColor;
  final Function(Color) setSelectedColor;

  @override
  State<HexColorPicker> createState() => _HexColorPickerState();
}

class _HexColorPickerState extends State<HexColorPicker> {
  late Color selectedColor = widget.initialSelectedColor;

  setColor(String input) {
    if (input.length == 8) {
      Color color = HexColor("0xFF" + input.replaceAll("0x", ""),
          defaultColor: widget.initialSelectedColor);

      setState(() {
        selectedColor = color;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print(selectedColor);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SelectText(
              margin: EdgeInsets.zero,
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.color_lens_outlined
                  : Icons.color_lens_rounded,
              setSelectedText: setColor,
              nextWithInput: (String input) {
                setColor(input);
                widget.setSelectedColor(selectedColor);
              },
              selectedText: toHexString(widget.initialSelectedColor)
                  .toString()
                  .allCaps
                  .replaceAll("0XFF", "0x"),
              placeholder: toHexString(widget.initialSelectedColor)
                  .toString()
                  .allCaps
                  .replaceAll("0XFF", "0x"),
              autoFocus: false,
              requestLateAutoFocus: true,
              inputFormatters: [ColorCodeFormatter()],
            ),
          ),
          SizedBox(width: 15),
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selectedColor,
            ),
          )
        ],
      ),
    );
  }
}

class ColorCodeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Validate and format the input value
    String formattedText = _formatColorCode(newValue.text);
    if (oldValue.text == "0x" && newValue.text == "0") {
      formattedText = "";
    }
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(
        offset: newValue.selection.baseOffset > 8
            ? 8
            : newValue.selection.baseOffset,
      ),
    );
  }

  String _formatColorCode(String input) {
    String cleanedInput = input;
    if (cleanedInput == "0") return "0x";
    // Remove any non-hexadecimal characters
    cleanedInput = cleanedInput
        .replaceAll("0x", "")
        .allCaps
        .replaceAll(RegExp(r'[^a-fA-F0-9]'), '');
    cleanedInput = "0x" + cleanedInput;

    if (cleanedInput.length > 8) {
      cleanedInput = cleanedInput.substring(0, 8);
    }

    return cleanedInput;
  }
}
