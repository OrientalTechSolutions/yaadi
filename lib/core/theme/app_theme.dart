import 'package:flutter/material.dart';

abstract final class AppFonts {
  /// Bundled on every platform: real metrics in tests, and no font request
  /// from the web demo.
  static const ui = 'Roboto';
  static const urdu = 'NotoNastaliqUrdu';
}

const _seedColor = Color(0xFF0F766E);

ThemeData buildAppTheme(Brightness brightness) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: brightness,
  );
  return ThemeData(
    colorScheme: colorScheme,
    fontFamily: AppFonts.ui,
    fontFamilyFallback: const [AppFonts.urdu],
    materialTapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: VisualDensity.standard,
    appBarTheme: const AppBarTheme(centerTitle: false),
  );
}

/// Nastaliq's tall ascenders and deep descenders (ے ی ں) need far more line
/// height than Latin: 1.9 at normal size, easing to 1.55 by 1.3x so that a
/// 2.0x row is still usable.
double urduLineHeight(double textScale) {
  const normal = 1.9;
  const large = 1.55;
  if (textScale <= 1.0) return normal;
  if (textScale >= 1.3) return large;
  return normal - (textScale - 1.0) / 0.3 * (normal - large);
}

/// [theme] for the Urdu UI: Nastaliq in every Material text style, Roboto
/// behind it for Latin runs, and taller bars where labels would clip.
ThemeData urduTheme(ThemeData theme, {required double textScale}) {
  final height = urduLineHeight(textScale);
  return theme.copyWith(
    textTheme: _nastaliq(theme.textTheme, height),
    primaryTextTheme: _nastaliq(theme.primaryTextTheme, height),
    navigationBarTheme: theme.navigationBarTheme.copyWith(height: 88),
  );
}

TextTheme _nastaliq(TextTheme textTheme, double height) {
  TextStyle? style(TextStyle? base) => base?.copyWith(
    fontFamily: AppFonts.urdu,
    fontFamilyFallback: const [AppFonts.ui],
    height: height,
  );

  return TextTheme(
    displayLarge: style(textTheme.displayLarge),
    displayMedium: style(textTheme.displayMedium),
    displaySmall: style(textTheme.displaySmall),
    headlineLarge: style(textTheme.headlineLarge),
    headlineMedium: style(textTheme.headlineMedium),
    headlineSmall: style(textTheme.headlineSmall),
    titleLarge: style(textTheme.titleLarge),
    titleMedium: style(textTheme.titleMedium),
    titleSmall: style(textTheme.titleSmall),
    bodyLarge: style(textTheme.bodyLarge),
    bodyMedium: style(textTheme.bodyMedium),
    bodySmall: style(textTheme.bodySmall),
    labelLarge: style(textTheme.labelLarge),
    labelMedium: style(textTheme.labelMedium),
    labelSmall: style(textTheme.labelSmall),
  );
}
