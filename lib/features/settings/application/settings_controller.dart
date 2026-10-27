import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../vault/app_storage.dart';
import '../../demo/domain/demo_household.dart';
import '../data/settings_repository.dart';
import '../domain/app_settings.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => ref.watch(storageProvider).requireValue.settings,
);

final settingsProvider = AsyncNotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);

/// The settings the app renders with. Screens shown before the vault opens
/// get the defaults, which follow the phone's language and theme.
final appSettingsProvider = Provider<AppSettings>((ref) {
  if (!ref.watch(storageProvider).hasValue) return const AppSettings();
  return ref.watch(settingsProvider).value ?? const AppSettings();
});

class SettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final entries = await ref.watch(settingsRepositoryProvider).readAll();
    return AppSettings.fromEntries(entries);
  }

  /// Null follows the phone's language.
  Future<void> setLanguage(AppLanguage? language) => _save(
    (settings) => settings.copyWith(language: language),
    SettingKeys.language,
    language?.name,
  );

  Future<void> setTheme(ThemePreference theme) => _save(
    (settings) => settings.copyWith(theme: theme),
    SettingKeys.theme,
    theme.name,
  );

  Future<void> setLargeText(bool enabled) => _save(
    (settings) => settings.copyWith(largeText: enabled),
    SettingKeys.largeText,
    '$enabled',
  );

  /// Null goes back to the user's own items. Only the demo controller calls
  /// this, because the web demo must replace its items first.
  Future<void> setDemoHousehold(DemoHousehold? household) => _save(
    (settings) => settings.copyWith(demoHousehold: household),
    SettingKeys.demoHousehold,
    household?.name,
  );

  /// Shows the change at once, then stores it. A failed write puts the
  /// previous settings back.
  Future<void> _save(
    AppSettings Function(AppSettings) change,
    String key,
    String? value,
  ) async {
    final previous = state.value ?? const AppSettings();
    state = AsyncData(change(previous));
    try {
      await ref.read(settingsRepositoryProvider).write(key, value);
    } on Exception {
      state = AsyncData(previous);
    }
  }
}
