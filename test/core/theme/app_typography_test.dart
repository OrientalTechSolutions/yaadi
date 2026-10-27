import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/theme/app_theme.dart';
import 'package:yaadi/core/theme/app_typography.dart';

void main() {
  group('text scale', () {
    const cases = [
      (1.0, false, 1.0),
      (1.0, true, 1.3),
      (1.4, true, 1.82),
      (1.8, true, 2.0),
      (2.5, false, 2.0),
      (0.85, true, 1.105),
    ];
    for (final (system, large, expected) in cases) {
      test(
        'phone ${system}x with Large text ${large ? 'on' : 'off'} is ${expected}x',
        () {
          final scaler = appTextScaler(
            TextScaler.linear(system),
            largeText: large,
          );
          expect(scaler.scale(10), closeTo(10 * expected, 1e-9));
        },
      );
    }
  });

  test('Nastaliq line height eases from 1.9 to 1.55 by 1.3x', () {
    expect(urduLineHeight(1.0), 1.9);
    expect(urduLineHeight(0.9), 1.9);
    expect(urduLineHeight(1.15), closeTo(1.725, 1e-9));
    expect(urduLineHeight(1.3), 1.55);
    expect(urduLineHeight(2.0), 1.55);
  });

  test(
    'the Urdu theme sets every text style in Nastaliq with Roboto behind it',
    () {
      final theme = urduTheme(buildAppTheme(Brightness.light), textScale: 1);
      final styles = [
        theme.textTheme.displayLarge,
        theme.textTheme.titleMedium,
        theme.textTheme.bodyMedium,
        theme.textTheme.labelSmall,
      ];
      for (final style in styles) {
        expect(style?.fontFamily, AppFonts.urdu);
        expect(style?.fontFamilyFallback, [AppFonts.ui]);
        expect(style?.height, 1.9);
      }
    },
  );

  test('both themes use the bundled UI font and padded tap targets', () {
    for (final brightness in Brightness.values) {
      final theme = buildAppTheme(brightness);
      expect(theme.textTheme.bodyMedium?.fontFamily, AppFonts.ui);
      expect(theme.materialTapTargetSize, MaterialTapTargetSize.padded);
      expect(theme.colorScheme.brightness, brightness);
    }
  });
}
