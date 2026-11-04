import 'package:meta/meta.dart';

import '../../../core/time/local_date.dart';
import '../../items/domain/completion.dart';
import '../../items/domain/item.dart';
import '../../items/domain/item_kind.dart';
import '../../today/domain/doses.dart';
import '../../today/domain/morning_summary.dart';
import '../../today/domain/today_view.dart';

/// What the user chose about reminders in Settings.
@immutable
final class ReminderPrefs {
  const ReminderPrefs({
    this.enabled = true,
    this.remindMinute = 9 * 60,
    this.morningSummary = true,
    this.summaryMinute = 8 * 60,
    this.showTitles = false,
    this.promptHidden = false,
  });

  /// Off schedules nothing at all.
  final bool enabled;

  /// When on the day a reminder without a time of its own goes off: a bill,
  /// an expiry date, an untimed task. Minutes after local midnight.
  final int remindMinute;

  final bool morningSummary;
  final int summaryMinute;

  /// Scheduled notifications are stored by the phone outside the vault, so
  /// by default they say "A bill is due today" rather than its title
  /// (ARCHITECTURE.md section 18).
  final bool showTitles;

  /// "Not now" on the Today card that offers to turn reminders on. It is
  /// shown once; Settings stays the way back.
  final bool promptHidden;

  ReminderPrefs copyWith({
    bool? enabled,
    int? remindMinute,
    bool? morningSummary,
    int? summaryMinute,
    bool? showTitles,
    bool? promptHidden,
  }) => ReminderPrefs(
    enabled: enabled ?? this.enabled,
    remindMinute: remindMinute ?? this.remindMinute,
    morningSummary: morningSummary ?? this.morningSummary,
    summaryMinute: summaryMinute ?? this.summaryMinute,
    showTitles: showTitles ?? this.showTitles,
    promptHidden: promptHidden ?? this.promptHidden,
  );

  @override
  bool operator ==(Object other) =>
      other is ReminderPrefs &&
      other.enabled == enabled &&
      other.remindMinute == remindMinute &&
      other.morningSummary == morningSummary &&
      other.summaryMinute == summaryMinute &&
      other.showTitles == showTitles &&
      other.promptHidden == promptHidden;

  @override
  int get hashCode => Object.hash(
    enabled,
    remindMinute,
    morningSummary,
    summaryMinute,
    showTitles,
    promptHidden,
  );

  @override
  String toString() =>
      'ReminderPrefs(enabled: $enabled, at: $remindMinute, '
      'summary: $morningSummary at $summaryMinute, titles: $showTitles)';
}

/// Why a reminder goes off.
enum ReminderReason {
  /// The item is due on the day: a bill, a task, an untimed appointment.
  dueToday,

  /// The evening-before warning for bills and appointments, which need
  /// money or travel arranged.
  dueTomorrow,

  /// A timed appointment, an hour before.
  startsSoon,

  /// An expiry date some days ahead, because renewals take weeks.
  expiresIn,

  /// A medicine time the user typed, or a one-off medicine time.
  dose,

  /// The day's summary, at the summary time.
  morningSummary,
}

/// One notification to schedule, at a wall-clock time.
@immutable
final class PlannedReminder {
  const PlannedReminder({
    required this.on,
    required this.minute,
    required this.reason,
    this.item,
    this.daysAhead = 0,
    this.summary,
  });

  /// The local date and minute it goes off. A wall-clock value: turning it
  /// into an instant happens at the very end, in the phone's time zone.
  final LocalDate on;
  final int minute;

  final ReminderReason reason;

  /// The item it is about; null for the morning summary.
  final Item? item;

  /// For [ReminderReason.expiresIn], how many days are left.
  final int daysAhead;

  /// For [ReminderReason.morningSummary], what the day holds.
  final MorningSummary? summary;

  /// Stable across planning passes while nothing about the reminder
  /// changes, so the same reminder keeps the same notification id.
  String get key =>
      '${item?.id ?? 'summary'}|${on.toIso()}|$minute|${reason.name}';

  @override
  bool operator ==(Object other) =>
      other is PlannedReminder &&
      other.key == key &&
      other.item == item &&
      other.daysAhead == daysAhead &&
      other.summary == summary;

  @override
  int get hashCode => Object.hash(key, item, daysAhead, summary);

  @override
  String toString() => 'PlannedReminder($key)';
}

abstract final class ReminderRules {
  /// How long before a timed appointment the "starts soon" reminder goes.
  static const startsSoonMinutes = 60;

  /// Expiry reminders, in days before the date.
  static const expiryLeads = [30, 7, 1, 0];

  /// Days of medicine times scheduled ahead. Planning runs whenever the app
  /// opens or anything changes, so a few days is plenty.
  static const doseDays = 3;

  /// Days of morning summaries scheduled ahead.
  static const summaryDays = 7;

  /// Nothing is scheduled further ahead than this.
  static const horizonDays = 31;

  /// The most reminders scheduled at once, soonest first. Some Android
  /// phones refuse more than 500 alarms per app, and iOS keeps only 64.
  static const maxAndroid = 150;
  static const maxIos = 60;
}

/// Every reminder due after now, soonest first, at most [limit].
///
/// A pure function of the items, the date and Settings: the app runs it
/// again after every change, on every launch and after a time-zone change,
/// and replaces whatever was scheduled before. That is what lets reminders
/// repair themselves (ARCHITECTURE.md section 18). Past dates are never
/// reminded again: an overdue bill appears in the morning summary instead
/// of nagging on its own.
List<PlannedReminder> planReminders(
  Iterable<Item> items, {
  required LocalDate today,
  required int nowMinute,
  required ReminderPrefs prefs,
  Iterable<Completion> todayMarks = const [],
  int limit = ReminderRules.maxAndroid,
}) {
  if (!prefs.enabled) return const [];
  final itemList = items.toList(growable: false);
  final last = today.addDays(ReminderRules.horizonDays);
  final planned = <PlannedReminder>[];

  void add(PlannedReminder reminder) {
    final days = today.daysUntil(reminder.on);
    if (days < 0 || reminder.on.isAfter(last)) return;
    if (days == 0 && reminder.minute <= nowMinute) return;
    planned.add(reminder);
  }

  for (final item in itemList) {
    if (!item.isOpen || item.courseEndedBefore(today)) continue;

    if (item.doseTimes case final course?) {
      final marked = {
        for (final mark in todayMarks)
          if (mark.itemId == item.id && mark.occurrenceOn == today)
            ?mark.occurrenceMinute,
      };
      for (var offset = 0; offset < ReminderRules.doseDays; offset++) {
        final day = today.addDays(offset);
        if (!item.takesDosesOn(day)) continue;
        for (final minute in course.minutes) {
          if (offset == 0 && marked.contains(minute)) continue;
          add(
            PlannedReminder(
              on: day,
              minute: minute,
              reason: ReminderReason.dose,
              item: item,
            ),
          );
        }
      }
      continue;
    }

    final on = item.effectiveOn(today);
    if (on == null) continue;
    final time = item.dueMinute;

    PlannedReminder at(
      LocalDate day,
      int minute,
      ReminderReason reason, {
      int daysAhead = 0,
    }) => PlannedReminder(
      on: day,
      minute: minute,
      reason: reason,
      item: item,
      daysAhead: daysAhead,
    );

    switch (item.kind) {
      case ItemKind.bill:
        add(at(on.addDays(-1), prefs.remindMinute, ReminderReason.dueTomorrow));
        add(at(on, time ?? prefs.remindMinute, ReminderReason.dueToday));
      case ItemKind.task:
        add(at(on, time ?? prefs.remindMinute, ReminderReason.dueToday));
      case ItemKind.appointment:
        add(at(on.addDays(-1), prefs.remindMinute, ReminderReason.dueTomorrow));
        if (time == null) {
          add(at(on, prefs.remindMinute, ReminderReason.dueToday));
        } else {
          // An appointment just after midnight is reminded at midnight.
          final soon = time - ReminderRules.startsSoonMinutes;
          add(at(on, soon < 0 ? 0 : soon, ReminderReason.startsSoon));
        }
      case ItemKind.medicine:
        add(at(on, time ?? prefs.remindMinute, ReminderReason.dose));
      case ItemKind.expiry:
        for (final lead in ReminderRules.expiryLeads) {
          add(
            at(
              on.addDays(-lead),
              prefs.remindMinute,
              ReminderReason.expiresIn,
              daysAhead: lead,
            ),
          );
        }
    }
  }

  if (prefs.morningSummary) {
    for (var offset = 0; offset < ReminderRules.summaryDays; offset++) {
      final day = today.addDays(offset);
      // Later days start with nothing marked, like the Today screen will.
      final summary = MorningSummary.of(
        TodayView.build(
          itemList,
          today: day,
          marks: offset == 0 ? todayMarks : const [],
        ),
      );
      if (summary.isQuietToday) continue;
      add(
        PlannedReminder(
          on: day,
          minute: prefs.summaryMinute,
          reason: ReminderReason.morningSummary,
          summary: summary,
        ),
      );
    }
  }

  planned.sort(_bySoonest);
  return planned.length > limit
      ? List.unmodifiable(planned.take(limit))
      : List.unmodifiable(planned);
}

int _bySoonest(PlannedReminder a, PlannedReminder b) {
  final byDate = a.on.compareTo(b.on);
  if (byDate != 0) return byDate;
  final byMinute = a.minute.compareTo(b.minute);
  return byMinute != 0 ? byMinute : a.key.compareTo(b.key);
}

/// A notification id for each reminder: stable for the same key, never
/// shared within one plan. Android and iOS take 32-bit signed ids; this
/// stays positive.
Map<String, int> notificationIds(Iterable<PlannedReminder> plan) {
  final taken = <int>{};
  return {
    for (final reminder in plan)
      reminder.key: () {
        var id = _fnv1a31(reminder.key);
        // Collisions are rare; step to the next free id when one happens.
        while (!taken.add(id)) {
          id = id == _max31 ? testReminderId + 1 : id + 1;
        }
        return id;
      }(),
  };
}

/// The id of the one-off test reminder, which no planned reminder uses.
const testReminderId = 1;

const _max31 = 0x7FFFFFFF;

int _fnv1a31(String text) {
  var hash = 0x811C9DC5;
  for (final unit in text.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  final positive = hash & _max31;
  // 0 and the test reminder's id stay free.
  return positive <= testReminderId ? positive + 2 : positive;
}
