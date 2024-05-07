import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/bottomNavBar.dart';
import 'package:budget/widgets/util/checkWidgetLaunch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:system_theme/system_theme.dart';

//import 'package:budget/colors.dart';
//getColor(context, "lightDarkAccent")

Color getColor(BuildContext context, String colorName) {
  return Theme.of(context).extension<AppColors>()?.colors[colorName] ??
      Colors.red;
}

AppColors getAppColors(
    {required Brightness brightness,
    required ThemeData themeData,
    required Color accentColor}) {
  Color lightDarkAccentHeavyLight = brightness == Brightness.light
      ? appStateSettings["accentSystemColor"] == true &&
              appStateSettings["materialYou"] &&
              appStateSettings["batterySaver"] == false
          ? lightenPastel(
              themeData.colorScheme.primary,
              amount: 0.96,
            )
          : appStateSettings["materialYou"]
              ? (appStateSettings["batterySaver"]
                  ? lightenPastel(accentColor, amount: 0.8)
                  : lightenPastel(accentColor, amount: 0.92))
              : (appStateSettings["batterySaver"]
                  ? Color(0xFFF3F3F3)
                  : Color(0xFFFFFFFF))
      : appStateSettings["accentSystemColor"] == true &&
              appStateSettings["materialYou"] &&
              appStateSettings["batterySaver"] == false
          ? darkenPastel(
              themeData.colorScheme.primary,
              amount: 0.85,
            )
          : appStateSettings["materialYou"]
              ? darkenPastel(accentColor, amount: 0.8)
              : Color(0xFF242424);
  return brightness == Brightness.light
      ? AppColors(
          colors: {
            "white": Colors.white,
            "black": Colors.black,
            "textLight": appStateSettings["increaseTextContrast"]
                ? Colors.black.withOpacity(0.7)
                : appStateSettings["materialYou"]
                    ? Colors.black.withOpacity(0.4)
                    : Color(0xFF888888),
            "lightDarkAccent": appStateSettings["materialYou"]
                ? lightenPastel(accentColor, amount: 0.6)
                : Color(0xFFF7F7F7),
            "lightDarkAccentHeavyLight": lightDarkAccentHeavyLight,
            "canvasContainer": const Color(0xFFEBEBEB),
            "lightDarkAccentHeavy": Color(0xFFEBEBEB),
            "shadowColor": const Color(0x655A5A5A),
            "shadowColorLight": const Color(0x2D5A5A5A),
            "unPaidUpcoming": Color(0xFF58A4C2),
            "unPaidOverdue": Color(0xFF6577E0),
            "incomeAmount": Color(0xFF59A849),
            "expenseAmount": Color(0xFFCA5A5A),
            "warningOrange": Color(0xFFCA995A),
            "starYellow": Color(0xFFFFD723),
            "dividerColor": appStateSettings["materialYou"]
                ? Color(0x0F000000)
                : Color(0xFFF0F0F0),
            "standardContainerColor": getPlatform() == PlatformOS.isIOS
                ? themeData.canvasColor
                : appStateSettings["materialYou"]
                    ? lightenPastel(
                        themeData.colorScheme.secondaryContainer,
                        amount: 0.3,
                      )
                    : lightDarkAccentHeavyLight,
          },
        )
      : AppColors(
          colors: {
            "white": Colors.black,
            "black": Colors.white,
            "textLight": appStateSettings["increaseTextContrast"]
                ? Colors.white.withOpacity(0.65)
                : appStateSettings["materialYou"]
                    ? Colors.white.withOpacity(0.25)
                    : Color(0xFF494949),
            "lightDarkAccent": appStateSettings["materialYou"]
                ? darkenPastel(accentColor, amount: 0.83)
                : Color(0xFF161616),
            "lightDarkAccentHeavyLight": lightDarkAccentHeavyLight,
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
            "standardContainerColor": getPlatform() == PlatformOS.isIOS
                ? themeData.canvasColor
                : appStateSettings["materialYou"]
                    ? darkenPastel(
                        themeData.colorScheme.secondaryContainer,
                        amount: 0.6,
                      )
                    : lightDarkAccentHeavyLight,
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

List<Color> selectableAccentColors(context) {
  return [
    Theme.of(context).colorScheme.selectableColorGreen,
    Theme.of(context).colorScheme.selectableColorCyan,
    Theme.of(context).colorScheme.selectableColorBlue,
    Theme.of(context).colorScheme.selectableColorInidigo,
    Theme.of(context).colorScheme.selectableColorDeepPurple,
    Theme.of(context).colorScheme.selectableColorPurple,
    Theme.of(context).colorScheme.selectableColorRed,
    Theme.of(context).colorScheme.selectableColorOrange,
    Theme.of(context).colorScheme.selectableColorYellow,
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

ColorScheme getColorScheme(Brightness brightness) {
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
      background: appStateSettings["forceFullDarkBackground"] == true
          ? Colors.black
          : appStateSettings["materialYou"]
              ? darkenPastel(
                  getSettingConstants(appStateSettings)["accentColor"],
                  amount: 0.92)
              : Colors.black,
    );
  }
}

SystemUiOverlayStyle getSystemUiOverlayStyle(
    AppColors? colors, Brightness brightness) {
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
        lightDarkAccent: colors?.colors["lightDarkAccent"] ?? Colors.white,
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
        lightDarkAccent: colors?.colors["lightDarkAccent"] ?? Colors.black,
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

// For Android widget hex color code conversion
String colorToHex(Color color) {
  Color opaqueColor = color.withAlpha(255);
  String hexString = opaqueColor.value.toRadixString(16).padLeft(6, '0');
  return "#" + hexString.substring(2);
}

class CustomColorTheme extends StatelessWidget {
  const CustomColorTheme(
      {required this.child, required this.accentColor, super.key});
  final Widget child;
  final Color accentColor;
  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: accentColor,
      brightness: determineBrightnessTheme(context),
    );
    return Theme(
      data: generateThemeDataWithExtension(
        accentColor: accentColor,
        brightness: Theme.of(context).brightness,
        themeData: Theme.of(context).copyWith(
          colorScheme: colorScheme,
        ),
      ),
      child: child,
    );
  }
}

ThemeData generateThemeDataWithExtension(
    {required ThemeData themeData,
    required Brightness brightness,
    required Color accentColor}) {
  AppColors colors = getAppColors(
    accentColor: accentColor,
    brightness: brightness,
    themeData: themeData,
  );

  return themeData.copyWith(
    extensions: <ThemeExtension<dynamic>>[colors],
    appBarTheme: AppBarTheme(
      systemOverlayStyle: getSystemUiOverlayStyle(colors, brightness),
    ),
  );
}

ThemeData getLightTheme() {
  Brightness brightness = Brightness.light;
  ThemeData themeData = ThemeData(
    // pageTransitionsTheme: PageTransitionsTheme(builders: {
    //   // the page route animation is set in pushRoute() - functions.dart
    //   TargetPlatform.android: appStateSettings["iOSNavigation"]
    //       ? CupertinoPageTransitionsBuilder()
    //       : ZoomPageTransitionsBuilder(),
    //   TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    // }),
    fontFamily: appStateSettings["font"],
    fontFamilyFallback: ['Inter'],
    colorScheme: getColorScheme(brightness),
    useMaterial3: true,
    applyElevationOverlayColor: false,
    typography: Typography.material2014(),
    canvasColor: appStateSettings["materialYou"]
        ? lightenPastel(getSettingConstants(appStateSettings)["accentColor"],
            amount: 0.91)
        : Colors.white,
    splashColor: getPlatform() == PlatformOS.isIOS
        ? Colors.transparent
        : appStateSettings["materialYou"]
            ? darkenPastel(
                    lightenPastel(
                        getSettingConstants(appStateSettings)["accentColor"],
                        amount: 0.8),
                    amount: 0.2)
                .withOpacity(0.5)
            : null,
  );
  return generateThemeDataWithExtension(
    themeData: themeData,
    brightness: brightness,
    accentColor: getSettingConstants(appStateSettings)["accentColor"],
  );
}

ThemeData getDarkTheme() {
  Brightness brightness = Brightness.dark;
  ThemeData themeData = ThemeData(
    // pageTransitionsTheme: PageTransitionsTheme(builders: {
    //   // the page route animation is set in pushRoute() - functions.dart
    //   TargetPlatform.android: appStateSettings["iOSNavigation"]
    //       ? CupertinoPageTransitionsBuilder()
    //       : ZoomPageTransitionsBuilder(),
    //   TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    // }),
    fontFamily: appStateSettings["font"],
    fontFamilyFallback: ['Inter'],
    colorScheme: getColorScheme(brightness),
    useMaterial3: true,
    typography: Typography.material2014(),
    canvasColor: appStateSettings["forceFullDarkBackground"] == true
        ? Colors.black
        : appStateSettings["materialYou"]
            ? darkenPastel(getSettingConstants(appStateSettings)["accentColor"],
                amount: 0.92)
            : Colors.black,
    splashColor: getPlatform() == PlatformOS.isIOS
        ? Colors.transparent
        : appStateSettings["materialYou"]
            ? darkenPastel(
                    lightenPastel(
                        getSettingConstants(appStateSettings)["accentColor"],
                        amount: 0.86),
                    amount: 0.1)
                .withOpacity(0.2)
            : null,
  );
  return generateThemeDataWithExtension(
    themeData: themeData,
    brightness: brightness,
    accentColor: getSettingConstants(appStateSettings)["accentColor"],
  );
}
