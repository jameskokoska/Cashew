// Modern minimalist theme ("Cashew Modern" build).
//
// One place for the palette, gradients and component styles. Light and dark
// both use neutral, low-contrast surfaces with a single gradient accent that
// follows the accent colour chosen in settings.

import 'package:flutter/material.dart';

class ModernPalette {
  // Light
  static const Color lightBackground = Color(0xFFF5F6FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFEEF0F6);
  static const Color lightBorder = Color(0xFFE6E8F0);
  static const Color lightText = Color(0xFF0F1222);
  static const Color lightTextMuted = Color(0xFF8A90A6);

  // Dark
  static const Color darkBackground = Color(0xFF0A0B10);
  static const Color darkSurface = Color(0xFF14161E);
  static const Color darkSurfaceAlt = Color(0xFF1C1F2A);
  static const Color darkBorder = Color(0xFF242836);
  static const Color darkText = Color(0xFFF2F3F8);
  static const Color darkTextMuted = Color(0xFF6E7489);

  // Money
  static const Color incomeLight = Color(0xFF10B981);
  static const Color incomeDark = Color(0xFF34D399);
  static const Color expenseLight = Color(0xFFF43F5E);
  static const Color expenseDark = Color(0xFFFB7185);

  // Default accent for new installs: indigo
  static const Color defaultAccent = Color(0xFF6366F1);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color background(Brightness b) =>
      b == Brightness.dark ? darkBackground : lightBackground;
  static Color surface(Brightness b) =>
      b == Brightness.dark ? darkSurface : lightSurface;
  static Color surfaceAlt(Brightness b) =>
      b == Brightness.dark ? darkSurfaceAlt : lightSurfaceAlt;
  static Color border(Brightness b) =>
      b == Brightness.dark ? darkBorder : lightBorder;
  static Color text(Brightness b) => b == Brightness.dark ? darkText : lightText;
  static Color textMuted(Brightness b) =>
      b == Brightness.dark ? darkTextMuted : lightTextMuted;
}

/// Three-stop gradient built from the accent: accent -> +35° hue -> +75° hue.
/// The default indigo gives indigo -> violet -> pink.
List<Color> modernGradientColors(Color accent, {Brightness? brightness}) {
  final HSLColor hsl = HSLColor.fromColor(accent);
  final double sat = hsl.saturation < 0.25 ? 0.25 : hsl.saturation;
  final bool dark = brightness == Brightness.dark;
  Color stop(double hueShift, double lightness) => hsl
      .withHue((hsl.hue + hueShift) % 360)
      .withSaturation(sat.clamp(0.0, 0.95).toDouble())
      .withLightness(lightness.clamp(0.0, 1.0).toDouble())
      .toColor();
  final double l =
      hsl.lightness.clamp(0.42, 0.62).toDouble() + (dark ? 0.06 : 0.0);
  return [stop(0, l), stop(35, l + 0.02), stop(75, l + 0.04)];
}

LinearGradient modernGradient(BuildContext context,
    {AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight}) {
  return LinearGradient(
    begin: begin,
    end: end,
    colors: modernGradientColors(Theme.of(context).colorScheme.primary,
        brightness: Theme.of(context).brightness),
  );
}

/// Paints [child] (text or icon) with the accent gradient.
class GradientMask extends StatelessWidget {
  const GradientMask({required this.child, this.enabled = true, super.key});
  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) => modernGradient(
        context,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: child,
    );
  }
}

/// Soft gradient glow used behind page headers.
class ModernHeaderGlow extends StatelessWidget {
  const ModernHeaderGlow({super.key});

  @override
  Widget build(BuildContext context) {
    final bool dark = ModernPalette.isDark(context);
    final List<Color> c = modernGradientColors(
        Theme.of(context).colorScheme.primary,
        brightness: Theme.of(context).brightness);
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.9, -1.1),
                  radius: 1.25,
                  colors: [
                    c[2].withOpacity(dark ? 0.20 : 0.16),
                    c[2].withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-1.0, -0.9),
                  radius: 1.1,
                  colors: [
                    c[0].withOpacity(dark ? 0.22 : 0.15),
                    c[0].withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Component styles shared by light and dark.
ThemeData applyModernComponentThemes(ThemeData base) {
  final Brightness b = base.brightness;
  final ColorScheme cs = base.colorScheme;
  final BorderRadius r16 = BorderRadius.circular(16);
  return base.copyWith(
    scaffoldBackgroundColor: ModernPalette.background(b),
    canvasColor: ModernPalette.background(b),
    dividerColor: ModernPalette.border(b),
    dividerTheme: DividerThemeData(
        color: ModernPalette.border(b), thickness: 1, space: 1),
    cardTheme: CardTheme(
      color: ModernPalette.surface(b),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: ModernPalette.border(b)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ModernPalette.surfaceAlt(b),
      border: OutlineInputBorder(borderRadius: r16, borderSide: BorderSide.none),
      enabledBorder:
          OutlineInputBorder(borderRadius: r16, borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: r16, borderSide: BorderSide(color: cs.primary, width: 1.5)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: r16),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: r16),
        side: BorderSide(color: ModernPalette.border(b)),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: StadiumBorder(side: BorderSide(color: ModernPalette.border(b))),
      backgroundColor: ModernPalette.surface(b),
      selectedColor: cs.primary.withOpacity(b == Brightness.dark ? 0.28 : 0.14),
      side: BorderSide(color: ModernPalette.border(b)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: ModernPalette.surface(b),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: ModernPalette.surface(b),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: r16),
    ),
    switchTheme: SwitchThemeData(
      trackOutlineColor: MaterialStatePropertyAll(Colors.transparent),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: ModernPalette.surface(b),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 68,
      indicatorColor: cs.primary.withOpacity(b == Brightness.dark ? 0.26 : 0.12),
      indicatorShape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
