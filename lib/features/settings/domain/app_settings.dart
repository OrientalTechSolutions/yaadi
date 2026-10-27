import 'package:meta/meta.dart';

import '../../../core/money/money.dart';
import '../../demo/domain/demo_household.dart';

enum AppLanguage { en, ur }

enum ThemePreference { system, light, dark }

/// Keys in the settings store. Values are plain strings.
abstract final class SettingKeys {
  static const language = 'language';
  static const theme = 'theme';
  static const largeText = 'large_text';
  static const defaultCurrency = 'default_currency';
  static const demoHousehold = 'demo_household';
}

/// The user's preferences.
@immutable
final class AppSettings {
  const AppSettings({
    this.language,
    this.theme = ThemePreference.system,
    this.largeText = false,
    this.defaultCurrency = 'PKR',
    this.demoHousehold,
  });

  /// Reads what the store holds. Unknown or damaged values fall back to the
  /// defaults instead of failing, since a newer version may have written
  /// them.
  factory AppSettings.fromEntries(Map<String, String> entries) {
    final currency = entries[SettingKeys.defaultCurrency];
    return AppSettings(
      language: _byName(AppLanguage.values, entries[SettingKeys.language]),
      theme:
          _byName(ThemePreference.values, entries[SettingKeys.theme]) ??
          ThemePreference.system,
      largeText: entries[SettingKeys.largeText] == 'true',
      defaultCurrency: currency != null && Money.isCurrencyCode(currency)
          ? currency
          : 'PKR',
      demoHousehold: DemoHousehold.byName(entries[SettingKeys.demoHousehold]),
    );
  }

  /// Null follows the phone's language.
  final AppLanguage? language;
  final ThemePreference theme;

  /// Multiplies the phone's text size by 1.3, capped at 2.0 in total.
  final bool largeText;

  /// PKR unless changed. A demo household brings its own currency.
  final String defaultCurrency;

  /// The made-up family shown instead of the user's own items, if any.
  final DemoHousehold? demoHousehold;

  /// The currency new amounts start in, and whose billers search knows.
  String get householdCurrency => demoHousehold?.currency ?? defaultCurrency;

  AppSettings copyWith({
    Object? language = _keep,
    ThemePreference? theme,
    bool? largeText,
    String? defaultCurrency,
    Object? demoHousehold = _keep,
  }) => AppSettings(
    language: identical(language, _keep)
        ? this.language
        : language as AppLanguage?,
    theme: theme ?? this.theme,
    largeText: largeText ?? this.largeText,
    defaultCurrency: defaultCurrency ?? this.defaultCurrency,
    demoHousehold: identical(demoHousehold, _keep)
        ? this.demoHousehold
        : demoHousehold as DemoHousehold?,
  );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.language == language &&
      other.theme == theme &&
      other.largeText == largeText &&
      other.defaultCurrency == defaultCurrency &&
      other.demoHousehold == demoHousehold;

  @override
  int get hashCode =>
      Object.hash(language, theme, largeText, defaultCurrency, demoHousehold);

  @override
  String toString() =>
      'AppSettings(language: ${language?.name ?? 'device'}, '
      'theme: ${theme.name}, largeText: $largeText, '
      'currency: $defaultCurrency, demo: ${demoHousehold?.name ?? 'none'})';
}

const Object _keep = Object();

T? _byName<T extends Enum>(List<T> values, String? name) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return null;
}
