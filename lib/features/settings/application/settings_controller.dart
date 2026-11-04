import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../vault/app_storage.dart';
import '../../demo/domain/demo_household.dart';
import '../../reminders/domain/reminder_plan.dart';
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

  /// The currency new bills start in, and whose country's billers search
  /// knows (ARCHITECTURE.md section 12).
  Future<void> setDefaultCurrency(String code) => _save(
    (settings) => settings.copyWith(defaultCurrency: code),
    SettingKeys.defaultCurrency,
    code,
  );

  /// Null goes back to the user's own items. Only the demo controller calls
  /// this, because the web demo must replace its items first.
  Future<void> setDemoHousehold(DemoHousehold? household) => _save(
    (settings) => settings.copyWith(demoHousehold: household),
    SettingKeys.demoHousehold,
    household?.name,
  );

  /// Stores the reminder choices. Only the keys that changed are written.
  Future<void> setReminders(ReminderPrefs reminders) async {
    final previous = state.value ?? const AppSettings();
    final before = previous.reminders;
    state = AsyncData(previous.copyWith(reminders: reminders));
    final writes = {
      if (reminders.enabled != before.enabled)
        SettingKeys.remindersEnabled: '${reminders.enabled}',
      if (reminders.remindMinute != before.remindMinute)
        SettingKeys.reminderMinute: '${reminders.remindMinute}',
      if (reminders.morningSummary != before.morningSummary)
        SettingKeys.summaryEnabled: '${reminders.morningSummary}',
      if (reminders.summaryMinute != before.summaryMinute)
        SettingKeys.summaryMinute: '${reminders.summaryMinute}',
      if (reminders.showTitles != before.showTitles)
        SettingKeys.reminderTitles: '${reminders.showTitles}',
      if (reminders.promptHidden != before.promptHidden)
        SettingKeys.reminderPromptHidden: '${reminders.promptHidden}',
    };
    try {
      final repository = ref.read(settingsRepositoryProvider);
      for (final MapEntry(:key, :value) in writes.entries) {
        await repository.write(key, value);
      }
    } on Exception {
      state = AsyncData(previous);
    }
  }

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
