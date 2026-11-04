import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/time/local_date.dart';
import 'package:yaadi/features/items/domain/item_kind.dart';
import 'package:yaadi/features/reminders/domain/reminder_payload.dart';
import 'package:yaadi/features/reminders/domain/reminder_plan.dart';

import '../../../support/items.dart';

void main() {
  final day = LocalDate(2026, 11, 10);

  test('a bill reminder carries its id and occurrence, nothing else', () {
    final reminder = PlannedReminder(
      on: day,
      minute: 540,
      reason: ReminderReason.dueToday,
      item: bill(dueOn: day, reference: '35202-1234567-1', notes: 'meter 7'),
    );
    final payload = reminderPayload(reminder);
    expect(payload, isNot(contains('LESCO')));
    expect(payload, isNot(contains('35202')));
    expect(payload, isNot(contains('meter')));
    expect(
      readReminderTap(payload, actionId: 'paid'),
      ReminderTap(
        itemId: 'bill-1',
        scheduledOn: day,
        action: ReminderAction.paid,
      ),
    );
  });

  test('a medicine time carries the day and minute to mark', () {
    final course = medicine();
    final reminder = PlannedReminder(
      on: LocalDate(2026, 11, 3),
      minute: 1200,
      reason: ReminderReason.dose,
      item: course,
    );
    final tap = readReminderTap(reminderPayload(reminder), actionId: 'taken');
    expect(tap.doseOn, LocalDate(2026, 11, 3));
    expect(tap.doseMinute, 1200);
    expect(tap.action, ReminderAction.taken);
  });

  test('a damaged or foreign payload opens Today instead of failing', () {
    for (final payload in [null, '', 'not json', '[1,2]', '{"i":7}']) {
      final tap = readReminderTap(payload);
      expect(tap.itemId, isNull, reason: '$payload');
    }
    expect(readReminderTap('{"i":"x","m":5000}').doseMinute, isNull);
    expect(readReminderTap('{}', actionId: 'unknown').action, isNull);
  });

  group('buttons match what Today offers that day', () {
    List<ReminderAction> actions(
      ReminderReason reason, {
      ItemKind kind = ItemKind.bill,
    }) => reminderActions(
      PlannedReminder(
        on: day,
        minute: 540,
        reason: reason,
        item: kind == ItemKind.bill
            ? bill(dueOn: day)
            : item('x', kind: kind, due: day),
      ),
    );

    test('a bill due today: Paid and Tomorrow', () {
      expect(actions(ReminderReason.dueToday), [
        ReminderAction.paid,
        ReminderAction.snoozeTomorrow,
      ]);
    });

    test('a bill due tomorrow: Paid, but no snooze before the day', () {
      expect(actions(ReminderReason.dueTomorrow), [ReminderAction.paid]);
    });

    test('a task due today: Done and Tomorrow', () {
      expect(actions(ReminderReason.dueToday, kind: ItemKind.task), [
        ReminderAction.done,
        ReminderAction.snoozeTomorrow,
      ]);
    });

    test('upcoming appointments and expiry dates only open the item', () {
      expect(
        actions(ReminderReason.startsSoon, kind: ItemKind.appointment),
        isEmpty,
      );
      expect(
        actions(ReminderReason.dueTomorrow, kind: ItemKind.appointment),
        isEmpty,
      );
      expect(actions(ReminderReason.expiresIn, kind: ItemKind.expiry), isEmpty);
    });

    test('a medicine course: Taken', () {
      expect(
        reminderActions(
          PlannedReminder(
            on: day,
            minute: 480,
            reason: ReminderReason.dose,
            item: medicine(),
          ),
        ),
        [ReminderAction.taken],
      );
    });

    test('the morning summary has no buttons', () {
      expect(
        reminderActions(
          PlannedReminder(
            on: day,
            minute: 480,
            reason: ReminderReason.morningSummary,
          ),
        ),
        isEmpty,
      );
    });
  });
}
