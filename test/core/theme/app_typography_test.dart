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

  test(
    'the Urdu theme sets text in Nastaliq, a size up, with Roboto behind it',
    () {
      // The theme widget adds sizes to the bare theme; AppTypography sees them.
      final base = ThemeData.localize(
        buildAppTheme(Brightness.light),
        Typography.material2021().englishLike,
      );
      final theme = urduTheme(base);
      final pairs = [
        (base.textTheme.titleMedium, theme.textTheme.titleMedium),
        (base.textTheme.bodyMedium, theme.textTheme.bodyMedium),
        (base.textTheme.bodyLarge, theme.textTheme.bodyLarge),
      ];
      for (final (before, after) in pairs) {
        expect(after?.fontFamily, AppFonts.urdu);
        expect(after?.fontFamilyFallback, [AppFonts.ui]);
        expect(after?.height, urduLineHeight);
        expect(after?.fontSize, closeTo(before!.fontSize! * 1.15, 1e-9));
      }
      // 11 sp labels would read like 8 px type in Nastaliq.
      expect(theme.textTheme.labelSmall?.fontSize, 13);
    },
  );

  test('the time picker numerals stay in Roboto in Urdu', () {
    final base = buildAppTheme(Brightness.light);
    final theme = urduTheme(base);
    expect(theme.textTheme.displayLarge, base.textTheme.displayLarge);
    expect(theme.textTheme.displayLarge?.fontFamily, AppFonts.ui);
  });

  for (final scale in [1.0, 1.3, 2.0]) {
    testWidgets('Nastaliq lines keep their height at ${scale}x', (
      tester,
    ) async {
      const style = TextStyle(
        fontFamily: AppFonts.urdu,
        fontSize: 16,
        height: urduLineHeight,
      );
      final painter = TextPainter(
        text: const TextSpan(
          text: 'سمجھتی ہے اور بجلی کا بل اور امی کی دوائی',
          style: style,
        ),
        textDirection: TextDirection.rtl,
        textScaler: TextScaler.linear(scale),
      )..layout(maxWidth: 120 * scale);
      addTearDown(painter.dispose);

      final lines = painter.computeLineMetrics();
      expect(lines.length, greaterThan(1));
      for (final line in lines) {
        expect(line.height, greaterThanOrEqualTo(1.85 * 16 * scale));
      }
    });
  }

  test('both themes use the bundled UI font and padded tap targets', () {
    for (final brightness in Brightness.values) {
      final theme = buildAppTheme(brightness);
      expect(theme.textTheme.bodyMedium?.fontFamily, AppFonts.ui);
      expect(theme.materialTapTargetSize, MaterialTapTargetSize.padded);
      expect(theme.colorScheme.brightness, brightness);
    }
  });
}
