import 'package:budget/main.dart';
import 'package:flutter/material.dart';

//import 'package:budget/colors.dart';
//Theme.of(context).colorScheme.lightDarkAccent

extension ColorsDefined on ColorScheme {
  Color get white =>
      brightness == Brightness.light ? Colors.white : Colors.black;
  Color get black =>
      brightness == Brightness.light ? Colors.black : Colors.white;
  Color get textLight =>
      brightness == Brightness.light ? Color(0xFF888888) : Color(0xFF494949);
  Color get lightDarkAccent => brightness == Brightness.light
      ? const Color(0xFFFAFAFA)
      : const Color(0xFF242424);
  Color get lightDarkAccentHeavy => brightness == Brightness.light
      ? const Color(0xFFDBDBDB)
      : const Color(0xFF444444);
  Color get shadowColor => brightness == Brightness.light
      ? const Color(0x655A5A5A)
      : const Color(0x69BDBDBD);
  Color get shadowColorLight => brightness == Brightness.light
      ? const Color(0x2D5A5A5A)
      : const Color(0x4BBDBDBD);
  // Color get accentColor => brightness == Brightness.light
  //     ? const Color(0xFF4668A8)
  //     : const Color(0xFF1B447A);
  // Color get accentColorHeavy => brightness == Brightness.light
  //     ? const Color(0xFF29457A)
  //     : const Color(0xFF5586C5);

  Color get accentColor => brightness == Brightness.light
      ? getSettingConstants(appStateSettings)["accentColor"]
      : getSettingConstants(appStateSettings)["accentColor"];
  Color get accentColorHeavy => brightness == Brightness.light
      ? getSettingConstants(appStateSettings)["accentColor"]
      : getSettingConstants(appStateSettings)["accentColor"];

  Color get selectableColorRed => brightness == Brightness.light
      ? Colors.red.shade400
      : Colors.red.shade400;
  Color get selectableColorGreen => brightness == Brightness.light
      ? Colors.green.shade400
      : Colors.green.shade400;
  Color get selectableColorBlue => brightness == Brightness.light
      ? Colors.blue.shade400
      : Colors.blue.shade400;
  Color get selectableColorPurple => brightness == Brightness.light
      ? Colors.purple.shade400
      : Colors.purple.shade400;
  Color get selectableColorOrange => brightness == Brightness.light
      ? Colors.orange.shade400
      : Colors.orange.shade400;
  Color get selectableColorBlueGrey => brightness == Brightness.light
      ? Colors.blueGrey.shade400
      : Colors.blueGrey.shade400;
  Color get selectableColorYellow => brightness == Brightness.light
      ? Colors.yellow.shade400
      : Colors.yellow.shade400;
  Color get selectableColorAqua => brightness == Brightness.light
      ? Colors.teal.shade400
      : Colors.teal.shade400;
  Color get selectableColorInidigo =>
      brightness == Brightness.light ? Colors.indigo : Colors.indigo;
  Color get selectableColorGrey => brightness == Brightness.light
      ? Colors.grey.shade400
      : Colors.grey.shade400;
  Color get selectableColorBrown => brightness == Brightness.light
      ? Colors.brown.shade400
      : Colors.brown.shade400;
  Color get selectableColorDeepPurple => brightness == Brightness.light
      ? Colors.deepPurple.shade400
      : Colors.deepPurple.shade400;
  Color get selectableColorDeepOrange => brightness == Brightness.light
      ? Colors.deepOrange.shade400
      : Colors.deepOrange.shade400;
  Color get selectableColorCyan => brightness == Brightness.light
      ? Colors.cyan.shade400
      : Colors.cyan.shade400;
}

Color darken(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}

Color lighten(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

  return hslLight.toColor();
}

class HexColor extends Color {
  static int _getColorFromHex(String? hexColor, Color? defaultColor) {
    if (hexColor == null) {
      if (defaultColor == null) {
        return Colors.blue.value;
      } else {
        return defaultColor.value;
      }
    }
    hexColor = hexColor.replaceAll("#", "");
    hexColor = hexColor.replaceAll("0x", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String? hexColor, [final Color? defaultColor])
      : super(_getColorFromHex(hexColor, defaultColor));
}

String toHexString(Color color) {
  String valueString = color.value.toRadixString(16);
  return "0x" + valueString;
}

List<Color> selectableColors(context) {
  return [
    Theme.of(context).colorScheme.selectableColorRed,
    Theme.of(context).colorScheme.selectableColorGreen,
    Theme.of(context).colorScheme.selectableColorBlue,
    Theme.of(context).colorScheme.selectableColorPurple,
    Theme.of(context).colorScheme.selectableColorOrange,
    Theme.of(context).colorScheme.selectableColorBlueGrey,
    Theme.of(context).colorScheme.selectableColorYellow,
    Theme.of(context).colorScheme.selectableColorAqua,
    Theme.of(context).colorScheme.selectableColorInidigo,
    Theme.of(context).colorScheme.selectableColorGrey,
    Theme.of(context).colorScheme.selectableColorBrown,
    Theme.of(context).colorScheme.selectableColorDeepPurple,
    Theme.of(context).colorScheme.selectableColorDeepOrange,
    Theme.of(context).colorScheme.selectableColorCyan,
  ];
}
