import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/time/local_date.dart';
import 'package:yaadi/features/items/domain/item.dart';
import 'package:yaadi/features/items/domain/item_kind.dart';
import 'package:yaadi/features/items/domain/item_status.dart';
import 'package:yaadi/features/items/domain/recurrence.dart';
import 'package:yaadi/features/reminders/domain/reminder_plan.dart';

import '../../../support/items.dart';

/// Monday 2 November 2026, as everywhere else in the tests.
final today = LocalDate(2026, 11, 2);

/// Items only: the morning summary has tests of its own below.
const itemsOnly = ReminderPrefs(morningSummary: false);

List<PlannedReminder> plan(
  Iterable<Item> items, {
  int nowMinute = 7 * 60,
  ReminderPrefs prefs = itemsOnly,
  int limit = ReminderRules.maxAndroid,
}) => planReminders(
  items,
  today: today,
  nowMinute: nowMinute,
  prefs: prefs,
  limit: limit,
);

/// Each reminder as "date minute reason", for compact expectations.
List<String> describe(List<PlannedReminder> reminders) => [
  for (final r in reminders) '${r.on} ${r.minute} ${r.reason.name}',
];

void main() {
  group('bills', () {
    test('the day before and on the day, at the reminder time', () {
      expect(describe(plan([bill(dueOn: LocalDate(2026, 11, 10))])), [
        '2026-11-09 540 dueTomorrow',
        '2026-11-10 540 dueToday',
      ]);
    });

    test('a bill with a time is reminded at that time on the day', () {
      final timed = bill(dueOn: LocalDate(2026, 11, 10), dueMinute: 17 * 60);
      expect(describe(plan([timed])), [
        '2026-11-09 540 dueTomorrow',
        '2026-11-10 1020 dueToday',
      ]);
    });

    test('due today: only what is still ahead of now', () {
      expect(describe(plan([bill(dueOn: today)], nowMinute: 8 * 60)), [
        '2026-11-02 540 dueToday',
      ]);
      expect(plan([bill(dueOn: today)], nowMinute: 9 * 60), isEmpty);
    });

    test('an overdue bill is never reminded on its own', () {
      expect(plan([bill(dueOn: LocalDate(2026, 10, 30))]), isEmpty);
    });

    test('a snoozed bill is reminded on the snooze date', () {
      final snoozed = bill(dueOn: LocalDate(2026, 10, 30))
          .copyWith(snoozedUntil: LocalDate(2026, 11, 3));
      expect(describe(plan([snoozed])), [
        '2026-11-02 540 dueTomorrow',
        '2026-11-03 540 dueToday',
      ]);
    });

    test('the reminder time comes from Settings', () {
      final prefs = itemsOnly.copyWith(remindMinute: 19 * 60 + 30);
      expect(
        describe(plan([bill(dueOn: LocalDate(2026, 11, 4))], prefs: prefs)),
        ['2026-11-03 1170 dueTomorrow', '2026-11-04 1170 dueToday'],
      );
    });
  });

  test('closed items are never reminded', () {
    final paid = bill(
      dueOn: LocalDate(2026, 11, 10),
    ).copyWith(status: ItemStatus.paid, completedAt: DateTime.utc(2026, 11, 1));
    expect(plan([paid]), isEmpty);
  });

  test('an undated task is never reminded', () {
    expect(plan([task()]), isEmpty);
  });

  test('a dated task: on the day only', () {
    final dated = item('t', due: LocalDate(2026, 11, 5), minute: 14 * 60);
    expect(describe(plan([dated])), ['2026-11-05 840 dueToday']);
  });

  group('appointments', () {
    test('timed: the evening before and an hour before', () {
      final dentist = item(
        'a',
        kind: ItemKind.appointment,
        due: LocalDate(2026, 11, 5),
        minute: 17 * 60,
      );
      expect(describe(plan([dentist])), [
        '2026-11-04 540 dueTomorrow',
        '2026-11-05 960 startsSoon',
      ]);
    });

    test('just after midnight: reminded at midnight, not the day before', () {
      final early = item(
        'a',
        kind: ItemKind.appointment,
        due: LocalDate(2026, 11, 5),
        minute: 30,
      );
      expect(describe(plan([early])), [
        '2026-11-04 540 dueTomorrow',
        '2026-11-05 0 startsSoon',
      ]);
    });

    test('untimed: the day before and on the day', () {
      final untimed = item(
        'a',
        kind: ItemKind.appointment,
        due: LocalDate(2026, 11, 5),
      );
      expect(describe(plan([untimed])), [
        '2026-11-04 540 dueTomorrow',
        '2026-11-05 540 dueToday',
      ]);
    });
  });

  test('expiry dates: 30, 7 and 1 days before, and on the day', () {
    final cnic = item('e', kind: ItemKind.expiry, due: LocalDate(2026, 12, 2));
    final reminders = plan([cnic]);
    expect(describe(reminders), [
      '2026-11-02 540 expiresIn',
      '2026-11-25 540 expiresIn',
      '2026-12-01 540 expiresIn',
      '2026-12-02 540 expiresIn',
    ]);
    expect([for (final r in reminders) r.daysAhead], [30, 7, 1, 0]);
  });

  test('nothing further ahead than the horizon', () {
    final far = item('e', kind: ItemKind.expiry, due: LocalDate(2027, 3, 1));
    expect(plan([far]), isEmpty);
  });

  group('medicine', () {
    test('each typed time from now on, nothing invented', () {
      // The fixture course runs until 3 November.
      final course = medicine(minutes: [480, 1200]);
      expect(describe(plan([course], nowMinute: 9 * 60)), [
        '2026-11-02 1200 dose',
        '2026-11-03 480 dose',
        '2026-11-03 1200 dose',
      ]);
    });

    test('at most three days of times ahead', () {
      final long = medicine(minutes: [480])
          .copyWith(recurrence: DoseTimes([480]));
      expect(plan([long], nowMinute: 0).map((r) => r.on), [
        today,
        LocalDate(2026, 11, 3),
        LocalDate(2026, 11, 4),
      ]);
    });

    test('a course stops on its last day', () {
      // The fixture course runs until 3 November.
      final reminders = plan([medicine()], nowMinute: 0);
      expect(reminders.map((r) => r.on).toSet(), {
        today,
        LocalDate(2026, 11, 3),
      });
    });

    test('a time marked today is not reminded again', () {
      final course = medicine(minutes: [600, 1200]);
      final marked = planReminders(
        [course],
        today: today,
        nowMinute: 0,
        prefs: itemsOnly,
        todayMarks: [completed(course.id, on: today, minute: 600)],
      );
      expect(describe(marked).where((line) => line.startsWith('2026-11-02')), [
        '2026-11-02 1200 dose',
      ]);
    });

    test('a one-off medicine time is reminded at its time', () {
      final once = item(
        'm',
        kind: ItemKind.medicine,
        due: LocalDate(2026, 11, 3),
        minute: 21 * 60,
      );
      expect(describe(plan([once])), ['2026-11-03 1260 dose']);
    });
  });

  group('morning summary', () {
    const summaryOnly = ReminderPrefs();

    test('on days with something to say, at the summary time', () {
      final reminders = plan(
        [bill(dueOn: LocalDate(2026, 11, 4))],
        prefs: summaryOnly,
      ).where((r) => r.reason == ReminderReason.morningSummary);
      // Quiet until it is due on the 4th, then overdue every morning after.
      // Something merely coming up does not make a morning worth a
      // notification.
      expect(reminders.map((r) => '${r.on} ${r.minute}'), [
        '2026-11-04 480',
        '2026-11-05 480',
        '2026-11-06 480',
        '2026-11-07 480',
        '2026-11-08 480',
      ]);
    });

    test('quiet days get no summary', () {
      final reminders = plan([
        item('e', kind: ItemKind.expiry, due: LocalDate(2027, 1, 30)),
      ], prefs: summaryOnly);
      expect(
        reminders.where((r) => r.reason == ReminderReason.morningSummary),
        isEmpty,
      );
    });

    test('today\'s summary is skipped once its time has passed', () {
      final reminders = plan(
        [bill(dueOn: today)],
        prefs: summaryOnly,
        nowMinute: 8 * 60,
      ).where((r) => r.reason == ReminderReason.morningSummary);
      expect(reminders.first.on, LocalDate(2026, 11, 3));
    });

    test('turned off in Settings', () {
      expect(
        plan(
          [bill(dueOn: today)],
          prefs: summaryOnly.copyWith(morningSummary: false),
          nowMinute: 0,
        ).where((r) => r.reason == ReminderReason.morningSummary),
        isEmpty,
      );
    });
  });

  test('reminders off schedules nothing at all', () {
    expect(plan([bill()], prefs: const ReminderPrefs(enabled: false)), isEmpty);
  });

  test('soonest first, at most the limit', () {
    final bills = [
      for (var day = 3; day <= 20; day++)
        bill(id: 'b$day', dueOn: LocalDate(2026, 11, day)),
    ];
    final reminders = plan(bills, limit: 5);
    expect(reminders, hasLength(5));
    expect(describe(reminders).first, '2026-11-02 540 dueTomorrow');
    final sorted = [...reminders]
      ..sort((a, b) {
        final byDate = a.on.compareTo(b.on);
        return byDate != 0 ? byDate : a.minute.compareTo(b.minute);
      });
    expect(reminders, sorted);
  });

  test('a repeating bill is reminded for its current occurrence', () {
    final monthly = bill(
      dueOn: LocalDate(2026, 11, 10),
      recurrence: MonthlyRepeat(10),
    );
    expect(plan([monthly]).map((r) => r.on).toSet(), {
      LocalDate(2026, 11, 9),
      LocalDate(2026, 11, 10),
    });
  });

  group('notification ids', () {
    test('stable for the same reminder, positive, and never the test id', () {
      final reminders = plan([
        bill(dueOn: LocalDate(2026, 11, 10)),
        medicine(),
      ], nowMinute: 0);
      final first = notificationIds(reminders);
      final again = notificationIds(
        plan([medicine(), bill(dueOn: LocalDate(2026, 11, 10))], nowMinute: 0),
      );
      expect(again, first);
      expect(first.values.every((id) => id > testReminderId), isTrue);
      expect(first.values.every((id) => id <= 0x7FFFFFFF), isTrue);
    });

    test('unique within one plan', () {
      final many = plan([
        for (var day = 3; day <= 30; day++)
          bill(id: 'b$day', dueOn: LocalDate(2026, 11, day)),
        for (var n = 0; n < 8; n++) medicine(id: 'm$n'),
      ], nowMinute: 0);
      final ids = notificationIds(many);
      expect(ids.values.toSet(), hasLength(ids.length));
    });
  });
}
