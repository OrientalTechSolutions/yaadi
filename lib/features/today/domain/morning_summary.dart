import 'package:meta/meta.dart';

import '../../../core/money/money.dart';
import '../../../core/time/local_date.dart';
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
    final thisWeek = [
      for (final entry in view[TodaySection.nextWeek])
        if (view.today.daysUntil(entry.on!) <= TodayRules.nextDays) entry,
    ];

    final totals = <String, int>{};
    var unknownAmounts = 0;
    for (final entry in [...overdue, ...dueToday, ...thisWeek]) {
      if (entry.item.kind != ItemKind.bill) continue;
      final amount = entry.item.amount;
      if (amount == null) {
        unknownAmounts++;
      } else {
        totals.update(
          amount.currency,
          (sum) => sum + amount.minorUnits,
          ifAbsent: () => amount.minorUnits,
        );
      }
    }

    return MorningSummary(
      payBy: view.today.addDays(TodayRules.nextDays),
      toConfirm: view[TodaySection.toConfirm].length,
      overdue: overdue.length,
      firstOverdue: overdue.isEmpty ? null : overdue.first.item.title,
      today: [for (final entry in dueToday.take(maxToday)) _mention(entry)],
      moreToday: dueToday.length > maxToday ? dueToday.length - maxToday : 0,
      dosesToday: view[TodaySection.today].fold(
        0,
        (count, entry) => count + entry.doses.length,
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
    comingUp,
    Object.hashAll(totals),
    unknownAmounts,
  );

  @override
  String toString() =>
      'MorningSummary(overdue: $overdue, toConfirm: $toConfirm, '
      'today: ${today.length}+$moreToday, doses: $dosesToday, '
      'totals: $totals, unknown: $unknownAmounts)';
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
