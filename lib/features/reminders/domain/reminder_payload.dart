import 'dart:convert';

import 'package:meta/meta.dart';

import '../../../core/time/local_date.dart';
import '../../items/domain/item_kind.dart';
import 'reminder_plan.dart';

/// A button on a reminder. Each one opens Yaadi and acts there, through the
/// same quick actions as the Today screen, so the vault is only ever written
/// by the app in the foreground (ARCHITECTURE.md section 18).
enum ReminderAction {
  paid,
  done,

  /// Shows the item again tomorrow, like Snooze for one day.
  snoozeTomorrow,

  /// Marks one medicine time of a course.
  taken;

  static ReminderAction? byName(String? name) {
    for (final action in values) {
      if (action.name == name) return action;
    }
    return null;
  }
}

/// What a reminder carries back when it is tapped: which item and
/// occurrence it was about, never its title or reference.
@immutable
final class ReminderTap {
  const ReminderTap({
    this.itemId,
    this.scheduledOn,
    this.doseOn,
    this.doseMinute,
    this.action,
  });

  /// Null for the morning summary and the test reminder, which open Today.
  final String? itemId;

  /// The occurrence the reminder was about, so a Paid tapped after the
  /// bill was already paid in the app is refused as stale.
  final LocalDate? scheduledOn;

  /// For a medicine time: the day and minute to mark.
  final LocalDate? doseOn;
  final int? doseMinute;

  /// Null when the notification itself was tapped.
  final ReminderAction? action;

  ReminderTap withAction(ReminderAction? action) => ReminderTap(
    itemId: itemId,
    scheduledOn: scheduledOn,
    doseOn: doseOn,
    doseMinute: doseMinute,
    action: action,
  );

  @override
  bool operator ==(Object other) =>
      other is ReminderTap &&
      other.itemId == itemId &&
      other.scheduledOn == scheduledOn &&
      other.doseOn == doseOn &&
      other.doseMinute == doseMinute &&
      other.action == action;

  @override
  int get hashCode =>
      Object.hash(itemId, scheduledOn, doseOn, doseMinute, action);

  @override
  String toString() =>
      'ReminderTap($itemId, $scheduledOn, dose: $doseOn $doseMinute, '
      '${action?.name ?? 'open'})';
}

/// The payload stored with the notification. The phone keeps it outside
/// the vault, so it holds ids and dates only.
String reminderPayload(PlannedReminder reminder) {
  final item = reminder.item;
  if (item == null) return '{}';
  final dose = reminder.reason == ReminderReason.dose && item.doseTimes != null;
  return jsonEncode({
    'i': item.id,
    if (item.scheduledOn case final on?) 's': on.toIso(),
    if (dose) 'd': reminder.on.toIso(),
    if (dose) 'm': reminder.minute,
  });
}

/// Reads a payload back, with the button the user pressed. A payload from
/// another version or a damaged one opens Today rather than failing.
ReminderTap readReminderTap(String? payload, {String? actionId}) {
  final action = ReminderAction.byName(actionId);
  if (payload == null || payload.isEmpty) return ReminderTap(action: action);
  try {
    final json = jsonDecode(payload);
    if (json is! Map<String, Object?>) return ReminderTap(action: action);
    final minute = json['m'];
    return ReminderTap(
      itemId: json['i'] is String ? json['i']! as String : null,
      scheduledOn: _date(json['s']),
      doseOn: _date(json['d']),
      doseMinute: minute is int && minute >= 0 && minute < 1440 ? minute : null,
      action: action,
    );
  } on FormatException {
    return ReminderTap(action: action);
  }
}

LocalDate? _date(Object? value) =>
    value is String ? LocalDate.tryParse(value) : null;

/// The buttons a reminder offers, at most two. Only what the Today screen
/// would also offer on that day: Snooze only on the day itself, because
/// pushing a bill past a date that has not come yet is how late fees
/// happen (ARCHITECTURE.md section 11).
List<ReminderAction> reminderActions(PlannedReminder reminder) {
  final item = reminder.item;
  if (item == null || !item.recurrence.isSupported) return const [];
  if (item.doseTimes != null) {
    return reminder.reason == ReminderReason.dose
        ? const [ReminderAction.taken]
        : const [];
  }
  final complete = item.kind == ItemKind.bill
      ? ReminderAction.paid
      : ReminderAction.done;
  return switch (reminder.reason) {
    ReminderReason.dueToday => [complete, ReminderAction.snoozeTomorrow],
    ReminderReason.dueTomorrow when item.kind == ItemKind.bill => [complete],
    ReminderReason.dose => [complete],
    ReminderReason.dueTomorrow ||
    ReminderReason.startsSoon ||
    ReminderReason.expiresIn ||
    ReminderReason.morningSummary => const [],
  };
}
