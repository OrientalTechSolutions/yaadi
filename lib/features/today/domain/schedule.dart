import '../../../core/time/local_date.dart';
import '../../items/domain/item.dart';

/// How far Snooze moves an item, counted from today rather than from the
/// due date, so an overdue bill never snoozes into the past.
enum SnoozeFor {
  oneDay(1),
  threeDays(3),
  oneWeek(7);

  const SnoozeFor(this.days);

  final int days;
}

extension ItemSchedule on Item {
  /// This item shown again on today + [snooze]. The due date is untouched,
  /// so the card can keep showing it next to "snoozed to".
  Item snoozed(
    SnoozeFor snooze, {
    required LocalDate today,
    required DateTime now,
  }) => copyWith(snoozedUntil: today.addDays(snooze.days), updatedAt: now);

  /// This item with its current occurrence due on [date] instead.
  ///
  /// A repeating item keeps its rule's date in `scheduledOn`, so the move
  /// applies to this occurrence only and the next one is still on the
  /// anchor: a bill moved from the 10th to the 13th is due on the 10th again
  /// next month. A one-off item and a medicine course have no rule date to
  /// keep. Any snooze is cleared, because it was relative to the old date.
  Item movedTo(LocalDate date, {required DateTime now}) {
    final keepsRuleDate = recurrence.repeats && doseTimes == null;
    return copyWith(
      dueOn: date,
      scheduledOn: keepsRuleDate ? scheduledOn : date,
      snoozedUntil: null,
      updatedAt: now,
    );
  }
}
