import 'dart:math' as math;

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
/// height than Latin; the font's own line is 2.5 em. 1.9 is the least that
/// keeps lines from touching, and as a ratio it holds at every text scale,
/// so Large text never squeezes Urdu lines together.
const urduLineHeight = 1.9;

/// At the same nominal size Nastaliq looks about a quarter smaller than
/// Roboto, so Urdu text is set this much larger wherever it appears.
const urduSizeFactor = 1.15;

/// Below this, Nastaliq labels read like 8 or 9 px type.
const _urduMinFontSize = 13.0;

/// [theme] for the Urdu UI: Nastaliq in every Material text style, a size
/// up, with Roboto behind it for Latin runs, and room where labels would
/// clip.
ThemeData urduTheme(ThemeData theme) => theme.copyWith(
  textTheme: _nastaliq(theme.textTheme),
  primaryTextTheme: _nastaliq(theme.primaryTextTheme),
  navigationBarTheme: theme.navigationBarTheme.copyWith(height: 88),
  // 4 dp more above the text than Material's default, so a floating label
  // clears the ascenders of گ and ک below it.
  inputDecorationTheme: theme.inputDecorationTheme.copyWith(
    contentPadding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 8),
  ),
);

TextTheme _nastaliq(TextTheme textTheme) {
  TextStyle? style(TextStyle? base) => base?.copyWith(
    fontFamily: AppFonts.urdu,
    fontFamilyFallback: const [AppFonts.ui],
    fontSize: math.max(
      _urduMinFontSize,
      (base.fontSize ?? 14) * urduSizeFactor,
    ),
    height: urduLineHeight,
  );

  return TextTheme(
    // Material uses the display styles only for numerals, such as the time
    // picker's hour and minute inside fixed 80 dp boxes. They stay in
    // Roboto: a Nastaliq line there is cut in half.
    displayLarge: textTheme.displayLarge,
    displayMedium: textTheme.displayMedium,
    displaySmall: textTheme.displaySmall,
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
