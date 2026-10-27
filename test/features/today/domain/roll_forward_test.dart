import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/money/money.dart';
import 'package:yaadi/core/time/local_date.dart';
import 'package:yaadi/features/items/domain/completion.dart';
import 'package:yaadi/features/items/domain/item.dart';
import 'package:yaadi/features/items/domain/item_category.dart';
import 'package:yaadi/features/items/domain/item_kind.dart';
import 'package:yaadi/features/items/domain/item_status.dart';
import 'package:yaadi/features/items/domain/recurrence.dart';
import 'package:yaadi/features/today/domain/roll_forward.dart';
import 'package:yaadi/features/today/domain/schedule.dart';

import '../../../support/items.dart';

LocalDate d(int year, int month, int day) => LocalDate(year, month, day);

final now = DateTime.utc(2026, 11, 2, 9);

CompletionPlan complete(
  Item item, {
  required LocalDate today,
  CompletionOutcome outcome = CompletionOutcome.done,
}) {
  var next = 0;
  return planCompletion(
    item,
    outcome: outcome,
    today: today,
    now: now,
    newId: () => 'c${++next}',
  );
}

Item monthlyBill(
  LocalDate due, {
  int? day,
  LocalDate? until,
  bool fixed = false,
  Money? amount,
}) => item(
  'bill',
  kind: ItemKind.bill,
  category: fixed ? ItemCategory.school : ItemCategory.electricity,
  due: due,
  recurrence: MonthlyRepeat(day ?? due.day, until: until),
  amount: amount ?? Money(425000, 'PKR'),
);

void main() {
  group('one-off items close', () {
    test('Paid records the payment with its amount', () {
      final bill = item(
        'bill',
        kind: ItemKind.bill,
        due: d(2026, 11, 10),
        amount: Money(425000, 'PKR'),
      ).copyWith(snoozedUntil: d(2026, 11, 3));
      final plan = complete(
        bill,
        today: d(2026, 11, 2),
        outcome: CompletionOutcome.paid,
      );

      expect(plan.after.status, ItemStatus.paid);
      expect(plan.after.completedAt, now);
      expect(plan.after.snoozedUntil, isNull);
      expect(plan.after.violations, isEmpty);
      expect(plan.catchUp, isNull);
      final completion = plan.added.single;
      expect(completion.occurrenceOn, d(2026, 11, 10));
      expect(completion.outcome, CompletionOutcome.paid);
      expect(completion.amount, Money(425000, 'PKR'));
    });

    test('Done records no amount', () {
      final task = item('task', due: d(2026, 11, 2), amount: Money(500, 'PKR'));
      final plan = complete(task, today: d(2026, 11, 2));
      expect(plan.after.status, ItemStatus.done);
      expect(plan.added.single.amount, isNull);
    });

    test('an undated task is completed on the day it is done', () {
      final plan = complete(item('task'), today: d(2026, 11, 2));
      expect(plan.after.status, ItemStatus.done);
      expect(plan.added.single.occurrenceOn, d(2026, 11, 2));
    });
  });

  group('repeating items roll forward from the rule date', () {
    final cases = <(String, Recurrence, LocalDate, LocalDate)>[
      (
        '31 January to 28 February',
        MonthlyRepeat(31),
        d(2026, 1, 31),
        d(2026, 2, 28),
      ),
      (
        '31 January to 29 February in a leap year',
        MonthlyRepeat(31),
        d(2028, 1, 31),
        d(2028, 2, 29),
      ),
      (
        'clamped February back to 31 March',
        MonthlyRepeat(31),
        d(2026, 2, 28),
        d(2026, 3, 31),
      ),
      (
        '31 March to 30 April',
        MonthlyRepeat(31),
        d(2026, 3, 31),
        d(2026, 4, 30),
      ),
      (
        'December to January',
        MonthlyRepeat(10),
        d(2026, 12, 10),
        d(2027, 1, 10),
      ),
      (
        'yearly 29 February to 28 February',
        YearlyRepeat(2, 29),
        d(2028, 2, 29),
        d(2029, 2, 28),
      ),
      (
        'weekly keeps the weekday',
        WeeklyRepeat(5),
        d(2026, 11, 6),
        d(2026, 11, 13),
      ),
      (
        'daily over the end of a year',
        const DailyRepeat(),
        d(2026, 12, 31),
        d(2027, 1, 1),
      ),
    ];
    for (final (name, rule, due, next) in cases) {
      test(name, () {
        final repeating = item('item', due: due, recurrence: rule);
        final plan = complete(repeating, today: due);
        expect(plan.after.scheduledOn, next);
        expect(plan.after.dueOn, next);
        expect(plan.after.isOpen, isTrue);
        expect(plan.after.recurrence, rule);
        expect(plan.added.single.occurrenceOn, due);
        expect(plan.catchUp, isNull);
      });
    }

    test('a clamped instance keeps its anchor after its notes are edited', () {
      final february = monthlyBill(
        d(2026, 2, 28),
        day: 31,
      ).copyWith(notes: 'Meter reading on the 25th');
      final plan = complete(
        february,
        today: d(2026, 2, 28),
        outcome: CompletionOutcome.paid,
      );
      expect(plan.after.dueOn, d(2026, 3, 31));
      expect(plan.after.recurrence, MonthlyRepeat(31));
    });

    test('a moved due date applies to one occurrence only', () {
      final moved = monthlyBill(d(2026, 11, 10))
          .movedTo(d(2026, 11, 13), now: now);
      expect(moved.scheduledOn, d(2026, 11, 10));
      expect(moved.dueOn, d(2026, 11, 13));

      final plan = complete(
        moved,
        today: d(2026, 11, 12),
        outcome: CompletionOutcome.paid,
      );
      expect(plan.added.single.occurrenceOn, d(2026, 11, 10));
      expect(plan.after.scheduledOn, d(2026, 12, 10));
      expect(plan.after.dueOn, d(2026, 12, 10));
      expect(plan.after.recurrence, MonthlyRepeat(10));
    });

    test('a fixed amount is carried forward, a variable one is cleared', () {
      final school = monthlyBill(d(2026, 11, 5), fixed: true);
      final electricity = monthlyBill(d(2026, 11, 10));
      expect(
        complete(school, today: d(2026, 11, 5)).after.amount,
        Money(425000, 'PKR'),
      );
      final paid = complete(
        electricity,
        today: d(2026, 11, 10),
        outcome: CompletionOutcome.paid,
      );
      expect(paid.after.amount, isNull);
      expect(paid.added.single.amount, Money(425000, 'PKR'));
    });

    test('completing clears a snooze and keeps the time of day', () {
      final snoozed = monthlyBill(d(2026, 11, 1))
          .copyWith(dueMinute: 570, snoozedUntil: d(2026, 11, 4));
      final plan = complete(snoozed, today: d(2026, 11, 2));
      expect(plan.after.snoozedUntil, isNull);
      expect(plan.after.dueMinute, 570);
    });

    test('paying early moves to the next month without a catch-up', () {
      final plan = complete(
        monthlyBill(d(2026, 11, 10)),
        today: d(2026, 11, 2),
        outcome: CompletionOutcome.paid,
      );
      expect(plan.after.dueOn, d(2026, 12, 10));
      expect(plan.catchUp, isNull);
    });

    test('a next occurrence due today is current, not missed', () {
      final plan = complete(monthlyBill(d(2026, 10, 2)), today: d(2026, 11, 2));
      expect(plan.after.dueOn, d(2026, 11, 2));
      expect(plan.catchUp, isNull);
    });
  });

  group('until', () {
    test('completing the last occurrence closes the item', () {
      final course = item(
        'course',
        due: d(2026, 11, 3),
        recurrence: DailyRepeat(until: d(2026, 11, 3)),
      );
      final plan = complete(course, today: d(2026, 11, 3));
      expect(plan.after.status, ItemStatus.done);
      expect(plan.after.completedAt, now);
    });

    test('council tax closes after ten monthly instalments', () {
      var tax = item(
        'tax',
        kind: ItemKind.bill,
        due: d(2026, 4, 1),
        recurrence: MonthlyRepeat(1, until: d(2027, 1, 1)),
        amount: Money(15600, 'GBP'),
      );
      final paidOn = <LocalDate>[];
      while (tax.isOpen) {
        final plan = complete(
          tax,
          today: tax.dueOn!,
          outcome: CompletionOutcome.paid,
        );
        paidOn.add(plan.added.single.occurrenceOn);
        tax = plan.after;
      }
      expect(paidOn, hasLength(10));
      expect(paidOn.last, d(2027, 1, 1));
      expect(tax.status, ItemStatus.paid);
    });
  });

  group('catching up missed occurrences', () {
    final today = d(2026, 11, 2);

    test('a variable bill marks the missed months paid without amounts', () {
      final plan = complete(
        monthlyBill(d(2026, 8, 10)),
        today: today,
        outcome: CompletionOutcome.paid,
      );

      expect(plan.after.dueOn, d(2026, 11, 10));
      expect(plan.after.amount, isNull);
      expect(
        [for (final c in plan.added) c.occurrenceOn],
        [d(2026, 8, 10), d(2026, 9, 10), d(2026, 10, 10)],
      );
      expect(plan.added.first.amount, Money(425000, 'PKR'));
      expect(plan.added.skip(1).map((c) => c.amount), everyElement(isNull));
      expect(
        plan.added.map((c) => c.outcome),
        everyElement(CompletionOutcome.paid),
      );

      final catchUp = plan.catchUp!;
      expect(catchUp.missed, 2);
      expect(catchUp.mode, CatchUpMode.markPaid);
      final keepUnpaid = catchUp.options.single;
      expect(keepUnpaid.mode, CatchUpMode.step);
      expect(keepUnpaid.after.dueOn, d(2026, 9, 10));
      expect(keepUnpaid.add, isEmpty);
      expect(keepUnpaid.removeIds, ['c2', 'c3']);
    });

    test('a fixed instalment steps one period, each one still owed', () {
      final fee = monthlyBill(
        d(2026, 8, 5),
        fixed: true,
        amount: Money(1200000, 'PKR'),
      );
      final plan = complete(fee, today: today, outcome: CompletionOutcome.paid);

      expect(plan.after.dueOn, d(2026, 9, 5));
      expect(plan.after.amount, Money(1200000, 'PKR'));
      expect(plan.added, hasLength(1));
      final catchUp = plan.catchUp!;
      expect(catchUp.missed, 2);
      expect(catchUp.mode, CatchUpMode.step);
      expect(catchUp.options.map((o) => o.mode), [
        CatchUpMode.markPaid,
        CatchUpMode.skip,
      ]);

      final markPaid = catchUp.options.first;
      expect(markPaid.after.dueOn, d(2026, 11, 5));
      expect(markPaid.removeIds, isEmpty);
      expect(
        [for (final c in markPaid.add) c.occurrenceOn],
        [d(2026, 9, 5), d(2026, 10, 5)],
      );
      expect(
        markPaid.add.map((c) => c.amount),
        everyElement(Money(1200000, 'PKR')),
      );

      final skip = catchUp.options.last;
      expect(skip.after.dueOn, d(2026, 11, 5));
      expect(
        skip.add.map((c) => c.outcome),
        everyElement(CompletionOutcome.skipped),
      );
      expect(skip.add.map((c) => c.amount), everyElement(isNull));
    });

    test('tasks jump to the current occurrence and record nothing', () {
      final weekly = item(
        'bins',
        due: d(2026, 10, 9),
        recurrence: WeeklyRepeat(5),
      );
      final plan = complete(weekly, today: today);
      expect(plan.after.dueOn, d(2026, 11, 6));
      expect(plan.added, hasLength(1));
      expect(plan.catchUp?.mode, CatchUpMode.jump);
      expect(plan.catchUp?.missed, 3);
      expect(plan.catchUp?.options, isEmpty);
    });

    test('a series that ended while missed closes the item', () {
      final ended = monthlyBill(d(2026, 8, 10), until: d(2026, 10, 10));
      final plan = complete(
        ended,
        today: today,
        outcome: CompletionOutcome.paid,
      );
      expect(plan.after.status, ItemStatus.paid);
      expect(plan.added, hasLength(3));
      final keepUnpaid = plan.catchUp!.options.single;
      expect(keepUnpaid.after.isOpen, isTrue);
      expect(keepUnpaid.after.dueOn, d(2026, 9, 10));
    });

    test('every plan and option leaves a valid item', () {
      for (final fixed in [true, false]) {
        final plan = complete(
          monthlyBill(d(2026, 6, 30), fixed: fixed),
          today: today,
          outcome: CompletionOutcome.paid,
        );
        expect(plan.after.violations, isEmpty);
        for (final option in plan.catchUp!.options) {
          expect(option.after.violations, isEmpty);
        }
      }
    });
  });

  group('daylight saving', () {
    // London (29 Mar, 25 Oct 2026) and the US (8 Mar, 1 Nov 2026). Dates and
    // minutes are wall-clock values, so nothing shifts by an hour.
    for (final due in [
      d(2026, 3, 29),
      d(2026, 10, 25),
      d(2026, 3, 8),
      d(2026, 11, 1),
    ]) {
      test('a 01:30 bill on $due keeps its date and time', () {
        final bill = monthlyBill(due).copyWith(dueMinute: 90);
        final plan = complete(bill, today: due);
        expect(plan.after.dueOn, due.addMonths(1));
        expect(plan.after.dueMinute, 90);
      });
    }

    test('each date rolled to survives the trip through a local DateTime', () {
      var daily = item(
        'daily',
        due: d(2026, 1, 1),
        minute: 90,
        recurrence: const DailyRepeat(),
      );
      for (var i = 0; i < 365; i++) {
        daily = complete(daily, today: daily.dueOn!).after;
        // How Today's labels and the date picker see it.
        final due = daily.dueOn!;
        expect(LocalDate.fromDateTime(due.toDateTime()), due);
      }
      expect(daily.dueOn, d(2027, 1, 1));
      expect(daily.dueMinute, 90);
    });
  });

  group('taking a completion back', () {
    test('only the newest by occurrence, and never a dose mark', () {
      final bill = monthlyBill(d(2026, 12, 10));
      final history = [
        completed('bill', id: 'oct', on: d(2026, 10, 10)),
        completed('bill', id: 'nov', on: d(2026, 11, 10)),
      ];
      expect(reopenable(bill, history)?.id, 'nov');
      expect(reopenable(bill, const []), isNull);

      final course = item(
        'course',
        kind: ItemKind.medicine,
        due: d(2026, 11, 1),
        recurrence: DoseTimes([480]),
      );
      expect(reopenable(course, [completed('course', minute: 480)]), isNull);
    });

    test('a rolled bill goes back to the paid month with its amount', () {
      final paid = complete(
        monthlyBill(d(2026, 11, 10)),
        today: d(2026, 11, 2),
        outcome: CompletionOutcome.paid,
      );
      final rolled = paid.after.copyWith(revision: 2);
      final payment = paid.added.single;

      final change = planReopen(rolled, payment, now: now);
      expect(change.expectedRevision, 2);
      expect(change.removeCompletionIds, [payment.id]);
      expect(change.after?.scheduledOn, d(2026, 11, 10));
      expect(change.after?.dueOn, d(2026, 11, 10));
      expect(change.after?.amount, Money(425000, 'PKR'));
      expect(change.after?.violations, isEmpty);
    });

    test('a closed item keeps the date the user had moved it to', () {
      final moved = item(
        'dentist',
        kind: ItemKind.appointment,
        due: d(2026, 11, 13),
        scheduled: d(2026, 11, 10),
      );
      final done = complete(moved, today: d(2026, 11, 13));
      final change = planReopen(done.after, done.added.single, now: now);
      expect(change.after?.status, ItemStatus.open);
      expect(change.after?.completedAt, isNull);
      expect(change.after?.dueOn, d(2026, 11, 13));
      expect(change.after?.scheduledOn, d(2026, 11, 10));
    });
  });

  group('refuses what quick actions never offer', () {
    test('closed items, medicine courses, newer rules, skipped', () {
      final closed = item(
        'done',
        due: d(2026, 11, 2),
      ).copyWith(status: ItemStatus.done, completedAt: now);
      final course = item(
        'course',
        kind: ItemKind.medicine,
        due: d(2026, 11, 1),
        recurrence: DoseTimes([480]),
      );
      final newer = item(
        'newer',
        due: d(2026, 11, 2),
        recurrence: Recurrence.decode('{"type":"fortnightly"}'),
      );
      for (final refused in [closed, course, newer]) {
        expect(
          () => complete(refused, today: d(2026, 11, 2)),
          throwsArgumentError,
          reason: refused.id,
        );
      }
      expect(
        () => complete(
          item('task'),
          today: d(2026, 11, 2),
          outcome: CompletionOutcome.skipped,
        ),
        throwsArgumentError,
      );
    });
  });
}
