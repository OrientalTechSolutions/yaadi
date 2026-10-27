import 'dart:convert';
import 'dart:math' as math;

import 'package:meta/meta.dart';

import '../../../core/time/local_date.dart';

/// The choices offered by the editor's Repeat field.
enum RepeatRule { none, daily, weekly, monthly, yearly, doses }

/// How an item repeats. Stored as typed JSON in a single column, so new
/// rules need no schema change (ARCHITECTURE.md section 4).
@immutable
sealed class Recurrence {
  const Recurrence({this.until});

  static const none = NoRepeat();

  /// A rule whose anchor (weekday, day of month, month) is taken from [due].
  ///
  /// This is the only place an anchor is derived, and the editor calls it
  /// only when the user changes the Repeat field. Editing anything else
  /// keeps the anchor, so the 28 February instance of a "31st" bill still
  /// rolls forward to 31 March.
  factory Recurrence.anchored(
    RepeatRule rule,
    LocalDate due, {
    LocalDate? until,
    Iterable<int> doseMinutes = const [],
  }) => switch (rule) {
    RepeatRule.none => none,
    RepeatRule.daily => DailyRepeat(until: until),
    RepeatRule.weekly => WeeklyRepeat(due.weekday, until: until),
    RepeatRule.monthly => MonthlyRepeat(due.day, until: until),
    RepeatRule.yearly => YearlyRepeat(due.month, due.day, until: until),
    RepeatRule.doses => DoseTimes(doseMinutes, until: until),
  };

  /// Never throws. An unknown type or an invalid value becomes an
  /// [UnsupportedRepeat] that keeps the original JSON, so one row written by
  /// a newer version cannot break the item list.
  factory Recurrence.decode(String raw) {
    try {
      final json = jsonDecode(raw);
      if (json is Map<String, Object?>) {
        return _fromJson(json) ?? UnsupportedRepeat(raw);
      }
    } on FormatException {
      // Falls through to unsupported.
    } on ArgumentError {
      // A constructor rejected a value; falls through to unsupported.
    }
    return UnsupportedRepeat(raw);
  }

  /// The last date the rule may produce, inclusive. Rolling past it
  /// completes the item: a five-day course, a school year, ten council tax
  /// instalments.
  final LocalDate? until;

  /// Null for a rule this version does not understand.
  RepeatRule? get rule;

  bool get repeats => true;

  /// False for a rule from a newer version. Such items take no edits and no
  /// quick actions, because this version cannot know their next date.
  bool get isSupported => true;

  /// The first date after [scheduled] that the rule produces, or null when
  /// the rule does not step through dates or that date is past [until].
  LocalDate? nextAfter(LocalDate scheduled);

  String encode() => jsonEncode({
    ..._fields(),
    if (until case final until?) 'until': until.toIso(),
  });

  Map<String, Object> _fields();

  LocalDate? _withinUntil(LocalDate next) {
    final last = until;
    return last != null && next.isAfter(last) ? null : next;
  }

  static Recurrence? _fromJson(Map<String, Object?> json) {
    // A newer version may repeat every N periods. Reading that as every
    // period would remind on the wrong dates, so such rules stay read-only.
    final interval = json['interval'];
    if (interval != null && interval != 1) return null;

    LocalDate? until;
    switch (json['until']) {
      case null:
        break;
      case final String text:
        until = LocalDate.tryParse(text);
        if (until == null) return null;
      default:
        return null;
    }

    return switch (json['type']) {
      'none' => none,
      'daily' => DailyRepeat(until: until),
      'weekly' => switch (json['weekday']) {
        final int weekday => WeeklyRepeat(weekday, until: until),
        _ => null,
      },
      'monthly' => switch (json['day']) {
        final int day => MonthlyRepeat(day, until: until),
        _ => null,
      },
      'yearly' => switch ((json['month'], json['day'])) {
        (final int month, final int day) => YearlyRepeat(
          month,
          day,
          until: until,
        ),
        _ => null,
      },
      'doses' => switch (json['minutes']) {
        final List<Object?> minutes when minutes.every((m) => m is int) =>
          DoseTimes(minutes.cast<int>(), until: until),
        _ => null,
      },
      _ => null,
    };
  }
}

final class NoRepeat extends Recurrence {
  const NoRepeat();

  @override
  RepeatRule get rule => RepeatRule.none;

  @override
  bool get repeats => false;

  @override
  LocalDate? nextAfter(LocalDate scheduled) => null;

  @override
  Map<String, Object> _fields() => const {'type': 'none'};

  @override
  bool operator ==(Object other) => other is NoRepeat;

  @override
  int get hashCode => (NoRepeat).hashCode;

  @override
  String toString() => 'NoRepeat()';
}

final class DailyRepeat extends Recurrence {
  const DailyRepeat({super.until});

  @override
  RepeatRule get rule => RepeatRule.daily;

  @override
  LocalDate? nextAfter(LocalDate scheduled) =>
      _withinUntil(scheduled.addDays(1));

  @override
  Map<String, Object> _fields() => const {'type': 'daily'};

  @override
  bool operator ==(Object other) =>
      other is DailyRepeat && other.until == until;

  @override
  int get hashCode => Object.hash(DailyRepeat, until);

  @override
  String toString() => 'DailyRepeat(until: $until)';
}

final class WeeklyRepeat extends Recurrence {
  /// [weekday] is ISO: 1 is Monday, 7 is Sunday.
  WeeklyRepeat(this.weekday, {super.until}) {
    RangeError.checkValueInInterval(weekday, 1, 7, 'weekday');
  }

  final int weekday;

  @override
  RepeatRule get rule => RepeatRule.weekly;

  @override
  LocalDate? nextAfter(LocalDate scheduled) {
    final ahead = (weekday - scheduled.weekday) % 7;
    return _withinUntil(scheduled.addDays(ahead == 0 ? 7 : ahead));
  }

  @override
  Map<String, Object> _fields() => {'type': 'weekly', 'weekday': weekday};

  @override
  bool operator ==(Object other) =>
      other is WeeklyRepeat && other.weekday == weekday && other.until == until;

  @override
  int get hashCode => Object.hash(WeeklyRepeat, weekday, until);

  @override
  String toString() => 'WeeklyRepeat(weekday: $weekday, until: $until)';
}

final class MonthlyRepeat extends Recurrence {
  /// [day] may be 29 to 31; shorter months use their last day.
  MonthlyRepeat(this.day, {super.until}) {
    RangeError.checkValueInInterval(day, 1, 31, 'day');
  }

  final int day;

  @override
  RepeatRule get rule => RepeatRule.monthly;

  @override
  LocalDate? nextAfter(LocalDate scheduled) {
    final thisMonth = scheduled.addMonths(0, onDay: day);
    final next = thisMonth.isAfter(scheduled)
        ? thisMonth
        : scheduled.addMonths(1, onDay: day);
    return _withinUntil(next);
  }

  @override
  Map<String, Object> _fields() => {'type': 'monthly', 'day': day};

  @override
  bool operator ==(Object other) =>
      other is MonthlyRepeat && other.day == day && other.until == until;

  @override
  int get hashCode => Object.hash(MonthlyRepeat, day, until);

  @override
  String toString() => 'MonthlyRepeat(day: $day, until: $until)';
}

final class YearlyRepeat extends Recurrence {
  /// 29 February is allowed and falls on 28 February in other years.
  YearlyRepeat(this.month, this.day, {super.until}) {
    RangeError.checkValueInInterval(month, 1, 12, 'month');
    RangeError.checkValueInInterval(
      day,
      1,
      LocalDate.daysInMonth(_leapYear, month),
      'day',
    );
  }

  static const _leapYear = 2000;

  final int month;
  final int day;

  @override
  RepeatRule get rule => RepeatRule.yearly;

  @override
  LocalDate? nextAfter(LocalDate scheduled) {
    LocalDate inYear(int year) => LocalDate(
      year,
      month,
      math.min(day, LocalDate.daysInMonth(year, month)),
    );

    final thisYear = inYear(scheduled.year);
    final next = thisYear.isAfter(scheduled)
        ? thisYear
        : inYear(scheduled.year + 1);
    return _withinUntil(next);
  }

  @override
  Map<String, Object> _fields() => {
    'type': 'yearly',
    'month': month,
    'day': day,
  };

  @override
  bool operator ==(Object other) =>
      other is YearlyRepeat &&
      other.month == month &&
      other.day == day &&
      other.until == until;

  @override
  int get hashCode => Object.hash(YearlyRepeat, month, day, until);

  @override
  String toString() => 'YearlyRepeat(month: $month, day: $day, until: $until)';
}

/// Medicine times the user typed, every day from the item's start date.
///
/// Doses never roll forward: each day's doses are derived from this rule,
/// so they can be marked in any order and never pile up as overdue.
final class DoseTimes extends Recurrence {
  /// Sorts and de-duplicates [minutes]; each is minutes after midnight.
  factory DoseTimes(Iterable<int> minutes, {LocalDate? until}) {
    final sorted = minutes.toSet().toList()..sort();
    if (sorted.isEmpty || sorted.length > maxDoses) {
      throw RangeError.range(sorted.length, 1, maxDoses, 'minutes.length');
    }
    for (final minute in sorted) {
      RangeError.checkValueInInterval(minute, 0, 1439, 'minute');
    }
    return DoseTimes._(List.unmodifiable(sorted), until: until);
  }

  const DoseTimes._(this.minutes, {super.until});

  static const maxDoses = 8;

  final List<int> minutes;

  @override
  RepeatRule get rule => RepeatRule.doses;

  @override
  LocalDate? nextAfter(LocalDate scheduled) => null;

  @override
  Map<String, Object> _fields() => {'type': 'doses', 'minutes': minutes};

  @override
  bool operator ==(Object other) =>
      other is DoseTimes &&
      other.until == until &&
      _sameInts(other.minutes, minutes);

  @override
  int get hashCode => Object.hash(DoseTimes, Object.hashAll(minutes), until);

  @override
  String toString() => 'DoseTimes(minutes: $minutes, until: $until)';
}

bool _sameInts(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// A rule from a newer version of Yaadi. The item is shown read-only and its
/// JSON is written back exactly as it was read.
final class UnsupportedRepeat extends Recurrence {
  const UnsupportedRepeat(this.raw);

  final String raw;

  @override
  RepeatRule? get rule => null;

  @override
  bool get isSupported => false;

  @override
  LocalDate? nextAfter(LocalDate scheduled) => null;

  @override
  String encode() => raw;

  @override
  Map<String, Object> _fields() => const {};

  @override
  bool operator ==(Object other) =>
      other is UnsupportedRepeat && other.raw == raw;

  @override
  int get hashCode => Object.hash(UnsupportedRepeat, raw);

  @override
  String toString() => 'UnsupportedRepeat()';
}
