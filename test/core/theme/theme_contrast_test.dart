import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/theme/app_theme.dart';

/// WCAG 2 contrast ratio between two opaque colours.
double contrast(Color a, Color b) {
  final (light, dark) = a.computeLuminance() > b.computeLuminance()
      ? (a, b)
      : (b, a);
  return (light.computeLuminance() + 0.05) / (dark.computeLuminance() + 0.05);
}

/// Every text colour the screens use, against the surface it sits on. The
/// pixel-sampling guideline cannot judge thin Nastaliq strokes, so the
/// colours themselves are checked here, for both themes and both languages
/// alike.
void main() {
  for (final brightness in Brightness.values) {
    group(brightness.name, () {
      final colors = buildAppTheme(brightness).colorScheme;
      final pairs = <String, (Color, Color)>{
        'body text': (colors.onSurface, colors.surface),
        'secondary text': (colors.onSurfaceVariant, colors.surface),
        'section headers': (colors.primary, colors.surface),
        'overdue labels': (colors.error, colors.surface),
        'card text': (colors.onSurface, colors.surfaceContainerLow),
        'card secondary text': (
          colors.onSurfaceVariant,
          colors.surfaceContainerLow,
        ),
        'morning summary': (colors.onPrimaryContainer, colors.primaryContainer),
        'demo badge and search highlights': (
          colors.onTertiaryContainer,
          colors.tertiaryContainer,
        ),
        'kind icons': (colors.onSecondaryContainer, colors.secondaryContainer),
        'overdue icons': (colors.onErrorContainer, colors.errorContainer),
        'demo notice and status badges': (
          colors.onSurfaceVariant,
          colors.surfaceContainerHighest,
        ),
        'snack bars': (colors.onInverseSurface, colors.inverseSurface),
        'filled buttons': (colors.onPrimary, colors.primary),
        'tonal buttons': (
          colors.onSecondaryContainer,
          colors.secondaryContainer,
        ),
      };
      pairs.forEach((name, pair) {
        test('$name reach 4.5:1', () {
          expect(contrast(pair.$1, pair.$2), greaterThanOrEqualTo(4.5));
        });
      });
    });
  }
}
