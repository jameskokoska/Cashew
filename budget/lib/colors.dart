import 'package:budget/main.dart';
import 'package:budget/struct/settings.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

//import 'package:budget/colors.dart';
//getColor(context, "lightDarkAccent")

late AppColors appColorsLight;

late AppColors appColorsDark;

Color getColor(BuildContext context, String colorName) {
  return Theme.of(context).extension<AppColors>()!.colors[colorName] ??
      Colors.red;
}

generateColors() {
  appColorsLight = AppColors(
    colors: {
      "white": Colors.white,
      "black": Colors.black,
      "textLight": appStateSettings["materialYou"]
          ? Colors.black.withOpacity(0.4)
          : Color(0xFF888888),
      "lightDarkAccent": appStateSettings["materialYou"]
          ? lightenPastel(HexColor(appStateSettings["accentColor"]),
              amount: 0.8)
          : Color(0xFFFAFAFA),
      "lightDarkAccentHeavyLight": appStateSettings["materialYou"]
          ? (appStateSettings["batterySaver"]
              ? lightenPastel(HexColor(appStateSettings["accentColor"]),
                  amount: 0.5)
              : lightenPastel(HexColor(appStateSettings["accentColor"]),
                  amount: 0.92))
          : (appStateSettings["batterySaver"]
              ? Color(0xFFF3F3F3)
              : Color(0xFFFFFFFF)),
      "canvasContainer": const Color(0xFFEBEBEB),
      "lightDarkAccentHeavy": Color(0xFFEBEBEB),
      "shadowColor": const Color(0x655A5A5A),
      "shadowColorLight": const Color(0x2D5A5A5A), //
      "unPaidUpcoming": appStateSettings["legacyTransactionAmountColors"]
          ? Color(0xFFE2CE13)
          : Color(0xFF58A4C2),
      "unPaidOverdue": appStateSettings["legacyTransactionAmountColors"]
          ? Color(0xFFEB4848)
          : Color(0xFF6577E0),
      "incomeAmount": appStateSettings["legacyTransactionAmountColors"]
          ? Color(0xFF59A849)
          : Color(0xFF59A849),
      "expenseAmount": appStateSettings["legacyTransactionAmountColors"]
          ? Colors.black
          : Color(0xFFCA5A5A),
      "starYellow": Color(0xFFFFD723),
    },
  );
  appColorsDark = AppColors(
    colors: {
      "white": Colors.black,
      "black": Colors.white,
      "textLight": appStateSettings["materialYou"]
          ? Colors.white.withOpacity(0.25)
          : Color(0xFF494949),
      "lightDarkAccent": appStateSettings["materialYou"]
          ? darkenPastel(HexColor(appStateSettings["accentColor"]),
              amount: 0.83)
          : Color(0xFF161616),
      "lightDarkAccentHeavyLight": appStateSettings["materialYou"]
          ? darkenPastel(HexColor(appStateSettings["accentColor"]), amount: 0.8)
          : Color(0xFF242424),
      "canvasContainer": const Color(0xFF242424),
      "lightDarkAccentHeavy": const Color(0xFF444444),
      "shadowColor": const Color(0x69BDBDBD),
      "shadowColorLight": appStateSettings["materialYou"]
          ? Colors.transparent
          : Color(0x28747474),
      "unPaidUpcoming": appStateSettings["legacyTransactionAmountColors"]
          ? Color(0xFFDED583)
          : Color(0xFF7DB6CC),
      "unPaidOverdue": appStateSettings["legacyTransactionAmountColors"]
          ? Color(0xFFDE8383)
          : Color(0xFF8395FF),
      "incomeAmount": appStateSettings["legacyTransactionAmountColors"]
          ? Color(0xFF62CA77)
          : Color(0xFF62CA77),
      "expenseAmount": appStateSettings["legacyTransactionAmountColors"]
          ? Colors.white
          : Color(0xFFDA7272),
      "starYellow": Colors.yellow,
    },
  );
}

extension ColorsDefined on ColorScheme {
  Color get selectableColorRed => Colors.red.shade400;
  Color get selectableColorGreen => Colors.green.shade400;
  Color get selectableColorBlue => Colors.blue.shade400;
  Color get selectableColorPurple => Colors.purple.shade400;
  Color get selectableColorOrange => Colors.orange.shade400;
  Color get selectableColorBlueGrey => Colors.blueGrey.shade400;
  Color get selectableColorYellow => Colors.yellow.shade400;
  Color get selectableColorAqua => Colors.teal.shade400;
  Color get selectableColorInidigo => Colors.indigo;
  Color get selectableColorGrey => Colors.grey.shade400;
  Color get selectableColorBrown => Colors.brown.shade400;
  Color get selectableColorDeepPurple => Colors.deepPurple.shade400;
  Color get selectableColorDeepOrange => Colors.deepOrange.shade400;
  Color get selectableColorCyan => Colors.cyan.shade400;
}

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.colors,
  });

  final Map<String, Color?> colors;

  @override
  AppColors copyWith({Map<String, Color?>? colors}) {
    return AppColors(
      colors: colors ?? this.colors,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }

    final Map<String, Color?> lerpColors = {};
    colors.forEach((key, value) {
      lerpColors[key] = Color.lerp(colors[key], other.colors[key], t);
    });

    return AppColors(
      colors: lerpColors,
    );
  }
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

Color lightenPastel(Color color, {double amount = 0.1}) {
  return Color.alphaBlend(
    Colors.white.withOpacity(amount),
    color,
  );
}

Color darkenPastel(Color color, {double amount = 0.1}) {
  return Color.alphaBlend(
    Colors.black.withOpacity(amount),
    color,
  );
}

Color dynamicPastel(
  BuildContext context,
  Color color, {
  double amount = 0.1,
  bool inverse = false,
  double? amountLight,
  double? amountDark,
}) {
  if (amountLight == null) {
    amountLight = amount;
  }
  if (amountDark == null) {
    amountDark = amount;
  }
  if (inverse) {
    if (Theme.of(context).brightness == Brightness.light) {
      return darkenPastel(color, amount: amountDark);
    } else {
      return lightenPastel(color, amount: amountLight);
    }
  } else {
    if (Theme.of(context).brightness == Brightness.light) {
      return lightenPastel(color, amount: amountLight);
    } else {
      return darkenPastel(color, amount: amountDark);
    }
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String? hexColor, Color? defaultColor, context) {
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

  HexColor(final String? hexColor, {final Color? defaultColor})
      : super(_getColorFromHex(hexColor, defaultColor, context));
}

String? toHexString(Color? color) {
  if (color == null) {
    return null;
  }
  String valueString = color.value.toRadixString(16);
  return "0x" + valueString;
}

List<Color> selectableColors(context) {
  return [
    Theme.of(context).colorScheme.selectableColorGreen,
    Theme.of(context).colorScheme.selectableColorAqua,
    Theme.of(context).colorScheme.selectableColorCyan,
    Theme.of(context).colorScheme.selectableColorBlue,
    Theme.of(context).colorScheme.selectableColorInidigo,
    Theme.of(context).colorScheme.selectableColorDeepPurple,
    Theme.of(context).colorScheme.selectableColorPurple,
    Theme.of(context).colorScheme.selectableColorRed,
    Theme.of(context).colorScheme.selectableColorOrange,
    Theme.of(context).colorScheme.selectableColorYellow,
    Theme.of(context).colorScheme.selectableColorDeepOrange,
    Theme.of(context).colorScheme.selectableColorBrown,
    Theme.of(context).colorScheme.selectableColorGrey,
    Theme.of(context).colorScheme.selectableColorBlueGrey,
  ];
}

const ColorFilter greyScale = ColorFilter.matrix(<double>[
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
]);
