import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/time/clock.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/app_localizations.dart';
import '../../demo/application/demo_providers.dart';
import '../../items/application/items_providers.dart';
import '../../items/domain/completion.dart';
import '../../items/domain/item.dart';
import '../../settings/application/settings_controller.dart';
import '../../today/application/today_providers.dart';
import '../data/reminder_gateway.dart';
import '../domain/reminder_payload.dart';
import '../domain/reminder_plan.dart';
import 'reminder_text.dart';

/// The phone's notifications. `main.dart` puts the real one in on Android
/// and iOS; the web demo and tests keep [NoReminders].
final reminderGatewayProvider = Provider<ReminderGateway>(
  (ref) => const NoReminders(),
);

/// Whether this build can remind at all: phones, not the web demo.
final remindersAvailableProvider = Provider<bool>(
  (ref) => ref.watch(reminderGatewayProvider) is! NoReminders,
);

/// The reminder choices from Settings.
final reminderPrefsProvider = Provider<ReminderPrefs>(
  (ref) => ref.watch(appSettingsProvider.select((s) => s.reminders)),
);

/// What the phone currently says about notifications, battery and exact
/// times. Invalidated when the app comes back from the phone's settings.
final reminderHealthProvider = FutureProvider<ReminderHealth>(
  (ref) => ref.watch(reminderGatewayProvider).health(),
);

/// Everything planning reads, or null while items are still loading. A
/// demo household pauses reminders: its items are made up, and the user's
/// own are not on screen (ARCHITECTURE.md section 14).
typedef ReminderInputs = ({
  List<Item> items,
  List<Completion> marks,
  ReminderPrefs prefs,
  bool paused,
});

final reminderInputsProvider = Provider<ReminderInputs?>((ref) {
  final items = ref.watch(itemsProvider).value;
  final marks = ref.watch(todayMarksProvider).value;
  if (items == null || marks == null) return null;
  ref.watch(todayProvider);
  return (
    items: items,
    marks: marks,
    prefs: ref.watch(reminderPrefsProvider),
    paused: ref.watch(showingDemoProvider),
  );
});

/// Plans from [inputs] at the current minute and replaces what the phone
/// has scheduled. Run after every change and on every resume, so the
/// schedule follows edits, completions, midnight and time-zone changes.
Future<void> syncReminders(
  ReminderGateway gateway,
  ReminderInputs inputs,
  AppLocalizations l10n, {
  required DateTime now,
}) async {
  if (inputs.paused || !inputs.prefs.enabled) {
    await gateway.replaceAll(const []);
    return;
  }
  final plan = planReminders(
    inputs.items,
    today: LocalDate.fromDateTime(now),
    nowMinute: now.hour * 60 + now.minute,
    prefs: inputs.prefs,
    todayMarks: inputs.marks,
  );
  await gateway.replaceAll(
    scheduledReminders(plan, l10n, showTitles: inputs.prefs.showTitles),
  );
}

/// Taps on reminders, in order, until the home screen handles them.
final reminderTapsProvider =
    NotifierProvider<ReminderTapsController, List<ReminderTap>>(
      ReminderTapsController.new,
    );

class ReminderTapsController extends Notifier<List<ReminderTap>> {
  @override
  List<ReminderTap> build() => const [];

  void add(ReminderTap tap) => state = [...state, tap];

  /// The oldest tap, removed from the queue.
  ReminderTap? take() {
    if (state.isEmpty) return null;
    final first = state.first;
    state = state.sublist(1);
    return first;
  }
}
