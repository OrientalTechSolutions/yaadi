import 'package:meta/meta.dart';

import '../../../core/time/local_date.dart';
import '../../items/domain/completion.dart';
import '../../items/domain/item.dart';
import '../../items/domain/item_kind.dart';
import 'doses.dart';

/// The groups of the Today screen, in screen order.
enum TodaySection {
  /// Appointments whose date has passed. They are asked about, never called
  /// overdue: nobody can be late for yesterday's dentist.
  toConfirm,
  overdue,
  today,
  nextWeek,
  later,
}

enum QuickAction { paid, done, snooze, reschedule }

abstract final class TodayRules {
  /// Days after today that count as "next 7 days".
  static const nextDays = 7;

  /// Expiry dates show this early, because renewing a CNIC or a passport
  /// takes weeks. A per-item lead time arrives with schema v2 in M2.
  static const expiryWindowDays = 30;
}

/// Where [item] belongs on [today], or null when it is not shown: closed
/// items and finished medicine courses.
TodaySection? sectionOf(Item item, LocalDate today) {
  if (!item.isOpen || item.courseEndedBefore(today)) return null;

  final on = item.doseTimes == null ? item.effectiveOn(today) : item.dueOn;
  if (on == null) return TodaySection.later;

  final days = today.daysUntil(on);
  if (days < 0) {
    // A course that has started shows today's doses.
    if (item.doseTimes != null) return TodaySection.today;
    // A past one-off medicine time is asked about like an appointment,
    // never called overdue: Yaadi does not nudge doses (ARCHITECTURE.md
    // section 11).
    return switch (item.kind) {
      ItemKind.appointment || ItemKind.medicine => TodaySection.toConfirm,
      _ => TodaySection.overdue,
    };
  }
  if (days == 0) return TodaySection.today;
  if (days <= TodayRules.nextDays) return TodaySection.nextWeek;
  if (item.kind == ItemKind.expiry && days <= TodayRules.expiryWindowDays) {
    return TodaySection.nextWeek;
  }
  return TodaySection.later;
}

/// Snooze is offered only on what is due now. Pushing a bill past a due
/// date that has not arrived yet is how late fees happen.
bool canSnooze(Item item, LocalDate today) =>
    item.recurrence.isSupported &&
    item.doseTimes == null &&
    switch (sectionOf(item, today)) {
      TodaySection.overdue || TodaySection.today => true,
      _ => false,
    };

/// One card on the Today screen.
@immutable
final class TodayEntry {
  const TodayEntry({
    required this.item,
    required this.section,
    required this.on,
    required this.doses,
    required this.actions,
  });

  final Item item;
  final TodaySection section;

  /// The date the card is shown under: today for a running medicine course,
  /// the snooze date while snoozed, otherwise the due date. Null for an
  /// undated task.
  final LocalDate? on;

  /// Today's doses for a running medicine course, in time order.
  final List<Dose> doses;

  /// The buttons the card offers. Doses are marked one by one instead.
  final Set<QuickAction> actions;

  /// The due date a snooze moved the card away from, shown next to "snoozed
  /// to" so the real date is never hidden.
  LocalDate? get snoozedFrom {
    final due = item.dueOn;
    return on != null && on == item.snoozedUntil && due != on ? due : null;
  }

  /// The time the card sorts by within its day: the first dose, or the due
  /// time.
  int? get minute => doses.isEmpty ? item.dueMinute : doses.first.minute;
}

/// The Today screen's contents for one day.
@immutable
final class TodayView {
  const TodayView._(this.today, this._sections);

  /// Groups the open items. [marks] are completions recorded for [today];
  /// they decide which doses show as marked.
  factory TodayView.build(
    Iterable<Item> items, {
    required LocalDate today,
    Iterable<Completion> marks = const [],
  }) {
    final todaysMarks = [
      for (final mark in marks)
        if (mark.occurrenceOn == today) mark,
    ];
    final sections = {
      for (final section in TodaySection.values) section: <TodayEntry>[],
    };
    for (final item in items) {
      final section = sectionOf(item, today);
      if (section == null) continue;
      final runningCourse =
          section == TodaySection.today && item.doseTimes != null;
      sections[section]!.add(
        TodayEntry(
          item: item,
          section: section,
          on: runningCourse ? today : item.effectiveOn(today),
          doses: runningCourse ? item.dosesOn(today, todaysMarks) : const [],
          actions: _actionsFor(item, section),
        ),
      );
    }
    return TodayView._(today, {
      for (final MapEntry(:key, :value) in sections.entries)
        key: List.unmodifiable(value..sort(_compareEntries)),
    });
  }

  final LocalDate today;
  final Map<TodaySection, List<TodayEntry>> _sections;

  List<TodayEntry> operator [](TodaySection section) => _sections[section]!;

  /// Every card in screen order.
  Iterable<TodayEntry> get entries =>
      TodaySection.values.expand((section) => _sections[section]!);

  bool get isEmpty => _sections.values.every((entries) => entries.isEmpty);
}

Set<QuickAction> _actionsFor(Item item, TodaySection section) {
  if (!item.recurrence.isSupported || item.doseTimes != null) return const {};
  if (section == TodaySection.toConfirm) {
    return const {QuickAction.done, QuickAction.reschedule};
  }
  return {
    item.kind == ItemKind.bill ? QuickAction.paid : QuickAction.done,
    if (section == TodaySection.overdue || section == TodaySection.today)
      QuickAction.snooze,
  };
}

/// By date, then time with untimed cards after timed ones on the same day,
/// then title. Undated tasks come last.
int _compareEntries(TodayEntry a, TodayEntry b) {
  final aOn = a.on;
  final bOn = b.on;
  if (aOn != bOn) {
    if (aOn == null) return 1;
    if (bOn == null) return -1;
    return aOn.compareTo(bOn);
  }
  final aMinute = a.minute;
  final bMinute = b.minute;
  if (aMinute != bMinute) {
    if (aMinute == null) return 1;
    if (bMinute == null) return -1;
    return aMinute.compareTo(bMinute);
  }
  final byTitle = a.item.title.toLowerCase().compareTo(
    b.item.title.toLowerCase(),
  );
  return byTitle != 0 ? byTitle : a.item.id.compareTo(b.item.id);
}
