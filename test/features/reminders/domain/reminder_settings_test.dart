import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/features/reminders/domain/reminder_plan.dart';
import 'package:yaadi/features/settings/domain/app_settings.dart';

void main() {
  test('reminders are on by default, at 9:00, with the summary at 8:00', () {
    expect(AppSettings.fromEntries(const {}).reminders, const ReminderPrefs());
    expect(const ReminderPrefs().remindMinute, 540);
    expect(const ReminderPrefs().summaryMinute, 480);
    expect(const ReminderPrefs().showTitles, isFalse);
  });

  test('stored choices are read back', () {
    final prefs = AppSettings.fromEntries(const {
      SettingKeys.remindersEnabled: 'false',
      SettingKeys.reminderMinute: '1170',
      SettingKeys.summaryEnabled: 'false',
      SettingKeys.summaryMinute: '420',
      SettingKeys.reminderTitles: 'true',
      SettingKeys.reminderPromptHidden: 'true',
    }).reminders;
    expect(
      prefs,
      const ReminderPrefs(
        enabled: false,
        remindMinute: 1170,
        morningSummary: false,
        summaryMinute: 420,
        showTitles: true,
        promptHidden: true,
      ),
    );
  });

  test('damaged times fall back to the defaults', () {
    for (final bad in ['-1', '1440', 'nine', '']) {
      final prefs = AppSettings.fromEntries({
        SettingKeys.reminderMinute: bad,
        SettingKeys.summaryMinute: bad,
      }).reminders;
      expect(prefs.remindMinute, 540, reason: bad);
      expect(prefs.summaryMinute, 480, reason: bad);
    }
  });
}
