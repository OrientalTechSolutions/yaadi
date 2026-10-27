import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Applies the Large text setting and the Urdu type metrics below the
/// MaterialApp, where the locale, the theme and the phone's text scale are
/// all known.
class AppTypography extends StatelessWidget {
  const AppTypography({
    super.key,
    required this.largeText,
    required this.child,
  });

  final bool largeText;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final scaler = appTextScaler(mediaQuery.textScaler, largeText: largeText);
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';
    final theme = Theme.of(context);

    return MediaQuery(
      data: mediaQuery.copyWith(textScaler: scaler),
      child: isUrdu ? Theme(data: urduTheme(theme), child: child) : child,
    );
  }
}

/// Key screens are tested up to 2.0x, so the total never goes beyond it.
const maxTextScale = 2.0;

/// The Large text setting multiplies the phone's own scale.
const largeTextFactor = 1.3;

TextScaler appTextScaler(TextScaler system, {required bool largeText}) {
  final capped = system.clamp(maxScaleFactor: maxTextScale);
  return largeText ? _LargeTextScaler(capped) : capped;
}

/// Keeps the phone's (possibly nonlinear) scaling and multiplies it, rather
/// than flattening it into one linear factor.
@immutable
class _LargeTextScaler extends TextScaler {
  const _LargeTextScaler(this.base);

  final TextScaler base;

  @override
  double scale(double fontSize) =>
      math.min(base.scale(fontSize) * largeTextFactor, fontSize * maxTextScale);

  @override
  double get textScaleFactor => scale(14) / 14;

  @override
  bool operator ==(Object other) =>
      other is _LargeTextScaler && other.base == base;

  @override
  int get hashCode => Object.hash(_LargeTextScaler, base);
}
