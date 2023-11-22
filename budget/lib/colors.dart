import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/bottomNavBar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:system_theme/system_theme.dart';

//import 'package:budget/colors.dart';
//getColor(context, "lightDarkAccent")

late AppColors appColorsLight;

late AppColors appColorsDark;

Color getColor(BuildContext context, String colorName) {
  // Custom lightDarkAccentHeavyLight when material you given context if system color
  // Makes the system color more vibrant in the UI
  if (appStateSettings["accentSystemColor"] == true &&
      colorName == "lightDarkAccentHeavyLight" &&
      appStateSettings["materialYou"] &&
      appStateSettings["batterySaver"] == false) {
    return dynamicPastel(
      context,
      Theme.of(context).colorScheme.primary,
      amountDark: 0.85,
      amountLight: 0.96,
    );
  }
  return Theme.of(context).extension<AppColors>()?.colors[colorName] ??
      Colors.red;
}

Color getStandardContainerColor(BuildContext context,
    {bool forceNonIOS = false}) {
  return getPlatform() == PlatformOS.isIOS && forceNonIOS == false
      ? Theme.of(context).canvasColor
      : appStateSettings["materialYou"]
          ? dynamicPastel(
              context,
              Theme.of(context).colorScheme.secondaryContainer,
              amountLight: 0.3,
              amountDark: 0.6,
            )
          : getColor(context, "lightDarkAccentHeavyLight");
}

generateColors() {
  appColorsLight = AppColors(
    colors: {
      "white": Colors.white,
      "black": Colors.black,
      "textLight": appStateSettings["increaseTextContrast"]
          ? Colors.black.withOpacity(0.7)
          : appStateSettings["materialYou"]
              ? Colors.black.withOpacity(0.4)
              : Color(0xFF888888),
      "lightDarkAccent": appStateSettings["materialYou"]
          ? lightenPastel(HexColor(appStateSettings["accentColor"]),
              amount: 0.6)
          : Color(0xFFF7F7F7),
      "lightDarkAccentHeavyLight": appStateSettings["materialYou"]
          ? (appStateSettings["batterySaver"]
              ? lightenPastel(HexColor(appStateSettings["accentColor"]),
                  amount: 0.8)
              : lightenPastel(HexColor(appStateSettings["accentColor"]),
                  amount: 0.92))
          : (appStateSettings["batterySaver"]
              ? Color(0xFFF3F3F3)
              : Color(0xFFFFFFFF)),
      "canvasContainer": const Color(0xFFEBEBEB),
      "lightDarkAccentHeavy": Color(0xFFEBEBEB),
      "shadowColor": const Color(0x655A5A5A),
      "shadowColorLight": const Color(0x2D5A5A5A), //
      "unPaidUpcoming": Color(0xFF58A4C2),
      "unPaidOverdue": Color(0xFF6577E0),
      "incomeAmount": Color(0xFF59A849),
      "expenseAmount": Color(0xFFCA5A5A),
      "warningOrange": Color(0xFFCA995A),
      "starYellow": Color(0xFFFFD723),
      "dividerColor": appStateSettings["materialYou"]
          ? Color(0x0F000000)
          : Color(0xFFF0F0F0),
    },
  );
  appColorsDark = AppColors(
    colors: {
      "white": Colors.black,
      "black": Colors.white,
      "textLight": appStateSettings["increaseTextContrast"]
          ? Colors.white.withOpacity(0.65)
          : appStateSettings["materialYou"]
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
      "unPaidUpcoming": Color(0xFF7DB6CC),
      "unPaidOverdue": Color(0xFF8395FF),
      "incomeAmount": Color(0xFF62CA77),
      "expenseAmount": Color(0xFFDA7272),
      "warningOrange": Color(0xFFDA9C72),
      "starYellow": Colors.yellow,
      "dividerColor": appStateSettings["materialYou"]
          ? Color(0x13FFFFFF)
          : Color(0xFF161616),
    },
  );
}

// Ensure you specify a shade, otherwise type will be of MaterialColor which can't be compared
// when using in other widgets, such as the Color Picker
extension ColorsDefined on ColorScheme {
  Color get selectableColorRed => Colors.red.shade400;
  Color get selectableColorGreen => Colors.green.shade400;
  Color get selectableColorBlue => Colors.blue.shade400;
  Color get selectableColorPurple => Colors.purple.shade400;
  Color get selectableColorOrange => Colors.orange.shade400;
  Color get selectableColorBlueGrey => Colors.blueGrey.shade400;
  Color get selectableColorYellow => Colors.yellow.shade400;
  Color get selectableColorAqua => Colors.teal.shade400;
  Color get selectableColorInidigo => Colors.indigo.shade500;
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
  if (amountLight > 1) {
    amountLight = 1;
  }
  if (amountDark > 1) {
    amountDark = 1;
  }
  if (amount > 1) {
    amount = 1;
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

Future<String?> getAccentColorSystemString() async {
  if (supportsSystemColor() && appStateSettings["accentSystemColor"] == true) {
    SystemTheme.fallbackColor = Colors.blue;
    await SystemTheme.accentColor.load();
    Color accentColor = SystemTheme.accentColor.accent;
    if (accentColor.toString() == "Color(0xff80cbc4)") {
      // A default cyan color returned from an unsupported accent color Samsung device
      return null;
    }
    print("System color loaded");
    return toHexString(accentColor);
  } else {
    return null;
  }
}

Future<bool> systemColorByDefault() async {
  if (getPlatform() == PlatformOS.isAndroid) {
    if (supportsSystemColor()) {
      int? androidVersion = await getAndroidVersion();
      print("Android version: " + androidVersion.toString());
      if (androidVersion != null && androidVersion >= 12) {
        return true;
      }
    }
    return false;
  }
  return supportsSystemColor();
}

bool supportsSystemColor() {
  return defaultTargetPlatform.supportsAccentColor &&
      kIsWeb != true &&
      getPlatform() != PlatformOS.isIOS;
}

getColorScheme(Brightness brightness) {
  if (brightness == Brightness.light) {
    return ColorScheme.fromSeed(
      seedColor: getSettingConstants(appStateSettings)["accentColor"],
      brightness: Brightness.light,
      background: appStateSettings["materialYou"]
          ? lightenPastel(getSettingConstants(appStateSettings)["accentColor"],
              amount: 0.91)
          : Colors.white,
    );
  } else {
    return ColorScheme.fromSeed(
      seedColor: getSettingConstants(appStateSettings)["accentColor"],
      brightness: Brightness.dark,
      background: appStateSettings["materialYou"]
          ? darkenPastel(getSettingConstants(appStateSettings)["accentColor"],
              amount: 0.92)
          : Colors.black,
    );
  }
}

SystemUiOverlayStyle getSystemUiOverlayStyle(Brightness brightness) {
  if (brightness == Brightness.light) {
    return SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      systemStatusBarContrastEnforced: false,
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: kIsWeb ? Colors.black : Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: getBottomNavbarBackgroundColor(
        colorScheme: getColorScheme(brightness),
        brightness: Brightness.light,
        lightDarkAccent: appColorsLight.colors["lightDarkAccent"] ?? Colors.red,
      ),
    );
  } else {
    return SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      systemStatusBarContrastEnforced: false,
      statusBarIconBrightness: Brightness.light,
      statusBarColor: kIsWeb ? Colors.black : Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarColor: getBottomNavbarBackgroundColor(
        colorScheme: getColorScheme(brightness),
        brightness: Brightness.dark,
        lightDarkAccent: appColorsDark.colors["lightDarkAccent"] ?? Colors.red,
      ),
    );
  }
}

Color getBottomNavbarBackgroundColor({
  required ColorScheme colorScheme,
  required Brightness brightness,
  required Color lightDarkAccent,
}) {
  if (getPlatform() == PlatformOS.isIOS) {
    return brightness == Brightness.light
        ? lightenPastel(colorScheme.secondaryContainer,
            amount: appStateSettings["materialYou"] ? 0.4 : 0.55)
        : darkenPastel(colorScheme.secondaryContainer,
            amount: appStateSettings["materialYou"] ? 0.4 : 0.55);
  } else if (appStateSettings["materialYou"] == true) {
    if (brightness == Brightness.light) {
      return lightenPastel(
        colorScheme.secondaryContainer,
        amount: 0.4,
      );
    } else {
      return darkenPastel(
        colorScheme.secondaryContainer,
        amount: 0.45,
      );
    }
  } else {
    return lightDarkAccent;
  }
}
