import 'package:meta/meta.dart';

import '../../../core/money/money.dart';
import '../../../core/time/local_date.dart';
import '../../items/domain/item.dart';
import '../../items/domain/item_kind.dart';
import 'today_view.dart';

/// One item as the summary mentions it. References and notes are never
/// part of it (ARCHITECTURE.md section 7).
@immutable
final class SummaryItem {
  const SummaryItem({
    required this.title,
    required this.on,
    this.minute,
    this.amount,
  });

  final String title;
  final LocalDate on;
  final int? minute;
  final Money? amount;

  @override
  bool operator ==(Object other) =>
      other is SummaryItem &&
      other.title == title &&
      other.on == on &&
      other.minute == minute &&
      other.amount == amount;

  @override
  int get hashCode => Object.hash(title, on, minute, amount);

  @override
  String toString() => 'SummaryItem("$title", $on, $minute, $amount)';
}

/// The facts behind the morning summary card.
///
/// It is computed from the Today view alone, with no clock and no locale, so
/// the same items always give the same facts; turning them into English or
/// Urdu sentences is a separate step.
@immutable
final class MorningSummary {
  const MorningSummary({
    required this.payBy,
    this.toConfirm = 0,
    this.overdue = 0,
    this.firstOverdue,
    this.today = const [],
    this.moreToday = 0,
    this.dosesToday = 0,
    this.dosesMarked = 0,
    this.comingUp,
    this.totals = const [],
    this.unknownAmounts = 0,
  });

  factory MorningSummary.of(TodayView view) {
    final overdue = view[TodaySection.overdue];
    final dueToday = [
      for (final entry in view[TodaySection.today])
        if (entry.doses.isEmpty) entry,
    ];
    final thisWeek = view[TodaySection.nextWeek];
    final payBy = view.today.addDays(TodayRules.nextDays);

    final totals = <String, int>{};
    var unknownAmounts = 0;
    for (final entry in [...overdue, ...dueToday, ...thisWeek]) {
      final item = entry.item;
      if (item.kind != ItemKind.bill) continue;
      final amount = item.amount;
      if (amount == null) {
        unknownAmounts++;
        continue;
      }
      // A fixed instalment is owed once for its current occurrence and again
      // for every later one due by then: an overdue one steps one period at
      // a time when paid, and a weekly one due today is due again within
      // the week. Counted from the rule's own date, so a snooze, which only
      // hides the bill for a few days, never lowers what is owed.
      final times = item.amountIsFixed && item.scheduledOn != null
          ? _occurrencesUntil(item, payBy)
          : 1;
      totals.update(
        amount.currency,
        (sum) => sum + amount.minorUnits * times,
        ifAbsent: () => amount.minorUnits * times,
      );
    }

    return MorningSummary(
      payBy: payBy,
      toConfirm: view[TodaySection.toConfirm].length,
      overdue: overdue.length,
      firstOverdue: overdue.isEmpty ? null : overdue.first.item.title,
      today: [for (final entry in dueToday.take(maxToday)) _mention(entry)],
      moreToday: dueToday.length > maxToday ? dueToday.length - maxToday : 0,
      dosesToday: view[TodaySection.today].fold(
        0,
        (count, entry) => count + entry.doses.length,
      ),
      dosesMarked: view[TodaySection.today].fold(
        0,
        (count, entry) => count + entry.doses.where((d) => d.marked).length,
      ),
      comingUp: thisWeek.isEmpty ? null : _mention(thisWeek.first),
      totals: [
        for (final currency in totals.keys.toList()..sort())
          Money(totals[currency]!, currency),
      ],
      unknownAmounts: unknownAmounts,
    );
  }

  /// Items for today named one by one; the rest are counted.
  static const maxToday = 3;

  /// The last day the totals cover: today plus the next 7 days.
  final LocalDate payBy;

  /// Past appointments waiting for "did this happen?".
  final int toConfirm;

  final int overdue;

  /// The title of the oldest overdue item.
  final String? firstOverdue;

  /// Up to [maxToday] items due today, in screen order. Medicine courses are
  /// counted in [dosesToday] instead.
  final List<SummaryItem> today;

  /// Items due today beyond [maxToday].
  final int moreToday;

  final int dosesToday;

  /// How many of [dosesToday] are marked, so the line counts what is left
  /// rather than going stale as the day goes on.
  final int dosesMarked;

  /// The first item in the next 7 days.
  final SummaryItem? comingUp;

  /// What overdue bills and bills due by [payBy] add up to, one total per
  /// currency in code order, from known amounts only.
  final List<Money> totals;

  /// Bills in those totals whose amount is not known yet, such as a
  /// variable bill before its paper arrives.
  final int unknownAmounts;

  /// Nothing needs attention today.
  bool get isQuietToday =>
      overdue == 0 &&
      toConfirm == 0 &&
      today.isEmpty &&
      moreToday == 0 &&
      dosesToday == 0;

  @override
  bool operator ==(Object other) =>
      other is MorningSummary &&
      other.payBy == payBy &&
      other.toConfirm == toConfirm &&
      other.overdue == overdue &&
      other.firstOverdue == firstOverdue &&
      _sameList(other.today, today) &&
      other.moreToday == moreToday &&
      other.dosesToday == dosesToday &&
      other.dosesMarked == dosesMarked &&
      other.comingUp == comingUp &&
      _sameList(other.totals, totals) &&
      other.unknownAmounts == unknownAmounts;

  @override
  int get hashCode => Object.hash(
    payBy,
    toConfirm,
    overdue,
    firstOverdue,
    Object.hashAll(today),
    moreToday,
    dosesToday,
    dosesMarked,
    comingUp,
    Object.hashAll(totals),
    unknownAmounts,
  );

  @override
  String toString() =>
      'MorningSummary(overdue: $overdue, toConfirm: $toConfirm, '
      'today: ${today.length}+$moreToday, '
      'doses: $dosesMarked/$dosesToday, '
      'totals: $totals, unknown: $unknownAmounts)';
}

/// The item's current occurrence and every later one on or before [until].
int _occurrencesUntil(Item item, LocalDate until) {
  var count = 1;
  var date = item.scheduledOn;
  while (date != null) {
    date = item.recurrence.nextAfter(date);
    if (date == null || date.isAfter(until)) break;
    count++;
  }
  return count;
}

SummaryItem _mention(TodayEntry entry) => SummaryItem(
  title: entry.item.title,
  on: entry.on!,
  minute: entry.minute,
  amount: entry.item.amount,
);

bool _sameList<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
