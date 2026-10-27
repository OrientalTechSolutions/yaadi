import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/money/money.dart';
import 'package:yaadi/core/time/local_date.dart';
import 'package:yaadi/features/items/domain/completion.dart';
import 'package:yaadi/features/items/domain/item.dart';
import 'package:yaadi/features/items/domain/item_category.dart';
import 'package:yaadi/features/items/domain/item_kind.dart';
import 'package:yaadi/features/items/domain/item_status.dart';
import 'package:yaadi/features/items/domain/recurrence.dart';
import 'package:yaadi/features/today/domain/doses.dart';
import 'package:yaadi/features/today/domain/schedule.dart';
import 'package:yaadi/features/today/domain/today_view.dart';

import '../../../support/items.dart';

final today = LocalDate(2026, 11, 2);
final now = DateTime.utc(2026, 11, 2, 9);

LocalDate inDays(int days) => today.addDays(days);

Item course({
  String id = 'ammi',
  int startsIn = -6,
  int? endsIn = 28,
  List<int> minutes = const [480, 840, 1200],
}) => item(
  id,
  kind: ItemKind.medicine,
  title: 'امی کی دوائی',
  category: ItemCategory.health,
  due: inDays(startsIn),
  recurrence: DoseTimes(minutes, until: endsIn == null ? null : inDays(endsIn)),
);

Completion mark(String itemId, int minute, {LocalDate? on}) => Completion(
  id: '$itemId-$minute-${on ?? today}',
  itemId: itemId,
  occurrenceOn: on ?? today,
  occurrenceMinute: minute,
  outcome: CompletionOutcome.done,
  recordedAt: now,
);

void main() {
  group('sections', () {
    final cases = <(String, Item, TodaySection?)>[
      (
        'a bill due yesterday is overdue',
        item('bill', kind: ItemKind.bill, due: inDays(-1)),
        TodaySection.overdue,
      ),
      (
        'an expired CNIC is overdue',
        item('cnic', kind: ItemKind.expiry, due: inDays(-3)),
        TodaySection.overdue,
      ),
      (
        'a past appointment asks whether it happened',
        item('dentist', kind: ItemKind.appointment, due: inDays(-1)),
        TodaySection.toConfirm,
      ),
      (
        'a past one-off medicine time is never overdue',
        item('refill', kind: ItemKind.medicine, due: inDays(-2)),
        TodaySection.toConfirm,
      ),
      ('due today', item('task', due: today), TodaySection.today),
      (
        'an appointment earlier today is still today',
        item('gp', kind: ItemKind.appointment, due: today, minute: 600),
        TodaySection.today,
      ),
      (
        'snoozed to today',
        item('bill', due: inDays(-4), snoozedUntil: today),
        TodaySection.today,
      ),
      (
        'snoozed three days ahead',
        item('bill', due: inDays(-1), snoozedUntil: inDays(3)),
        TodaySection.nextWeek,
      ),
      (
        'a snooze that has run out is overdue again',
        item('bill', due: inDays(-5), snoozedUntil: inDays(-1)),
        TodaySection.overdue,
      ),
      ('tomorrow', item('task', due: inDays(1)), TodaySection.nextWeek),
      ('in seven days', item('task', due: inDays(7)), TodaySection.nextWeek),
      ('in eight days', item('task', due: inDays(8)), TodaySection.later),
      (
        'an expiry date within the week',
        item('passport', kind: ItemKind.expiry, due: inDays(7)),
        TodaySection.nextWeek,
      ),
      (
        'an expiry date after the week, within 30 days',
        item('passport', kind: ItemKind.expiry, due: inDays(8)),
        TodaySection.expiringSoon,
      ),
      (
        'an expiry date 30 days away',
        item('passport', kind: ItemKind.expiry, due: inDays(30)),
        TodaySection.expiringSoon,
      ),
      (
        'an expiry date after 30 days',
        item('passport', kind: ItemKind.expiry, due: inDays(31)),
        TodaySection.later,
      ),
      ('an undated task', item('task'), TodaySection.later),
      ('a running medicine course', course(), TodaySection.today),
      ('a course on its first day', course(startsIn: 0), TodaySection.today),
      (
        'a course on its last day',
        course(startsIn: -10, endsIn: 0),
        TodaySection.today,
      ),
      (
        'a course that starts in three days',
        course(startsIn: 3),
        TodaySection.nextWeek,
      ),
      ('a finished course', course(startsIn: -10, endsIn: -1), null),
      (
        'a closed item',
        item(
          'done',
          due: today,
        ).copyWith(status: ItemStatus.done, completedAt: now),
        null,
      ),
    ];
    for (final (name, subject, expected) in cases) {
      test(name, () {
        expect(sectionOf(subject, today), expected);
        final entries = TodayView.build([subject], today: today).entries;
        expect(entries.map((entry) => entry.section), [?expected]);
      });
    }
  });

  group('entries', () {
    test('sort by date, then time with untimed last, then title', () {
      final view = TodayView.build([
        item('b-untimed', due: today, title: 'b'),
        item('a-untimed', due: today, title: 'A'),
        item('evening', due: today, minute: 1200),
        item('morning', due: today, minute: 480),
        course(id: 'doses', minutes: [540, 1260]),
      ], today: today);
      expect(view[TodaySection.today].map((entry) => entry.item.id), [
        'morning',
        'doses',
        'evening',
        'a-untimed',
        'b-untimed',
      ]);
    });

    test('undated tasks come after dated items in Later', () {
      final view = TodayView.build([
        item('undated'),
        item('next-month', due: inDays(30)),
      ], today: today);
      expect(view[TodaySection.later].map((entry) => entry.item.id), [
        'next-month',
        'undated',
      ]);
    });

    test('a snoozed card keeps its real due date beside the snooze', () {
      final snoozed = item('bill', due: inDays(-1), snoozedUntil: inDays(3));
      final entry = TodayView.build([snoozed], today: today).entries.single;
      expect(entry.on, inDays(3));
      expect(entry.snoozedFrom, inDays(-1));

      final plain = TodayView.build([
        item('bill', due: inDays(3)),
      ], today: today).entries.single;
      expect(plain.snoozedFrom, isNull);
    });

    test('the view lists sections in screen order', () {
      final view = TodayView.build([
        item('later', due: inDays(20)),
        item('today', due: today),
        item('overdue', due: inDays(-1)),
        item('past', kind: ItemKind.appointment, due: inDays(-1)),
        item('soon', due: inDays(2)),
      ], today: today);
      expect(view.entries.map((entry) => entry.item.id), [
        'past',
        'overdue',
        'today',
        'soon',
        'later',
      ]);
      expect(view.isEmpty, isFalse);
      expect(TodayView.build(const [], today: today).isEmpty, isTrue);
    });
  });

  group('quick actions', () {
    Set<QuickAction> actionsOf(Item subject) =>
        TodayView.build([subject], today: today).entries.single.actions;

    test('bills offer Paid, everything else Done', () {
      expect(actionsOf(item('bill', kind: ItemKind.bill, due: inDays(3))), {
        QuickAction.paid,
      });
      expect(actionsOf(item('task', due: inDays(3))), {QuickAction.done});
    });

    test('Snooze only on what is overdue or due today', () {
      expect(actionsOf(item('bill', kind: ItemKind.bill, due: inDays(-1))), {
        QuickAction.paid,
        QuickAction.snooze,
      });
      expect(actionsOf(item('task', due: today)), {
        QuickAction.done,
        QuickAction.snooze,
      });
      expect(actionsOf(item('task', due: inDays(1))), {QuickAction.done});
      expect(canSnooze(item('task', due: inDays(1)), today), isFalse);
      expect(canSnooze(item('task', due: today), today), isTrue);
    });

    test('past appointments offer Done and Reschedule', () {
      final past = item('dentist', kind: ItemKind.appointment, due: inDays(-1));
      expect(actionsOf(past), {QuickAction.done, QuickAction.reschedule});
      expect(canSnooze(past, today), isFalse);
    });

    test('medicine courses and rules from a newer version offer none', () {
      expect(actionsOf(course()), isEmpty);
      expect(canSnooze(course(), today), isFalse);
      final newer = item(
        'newer',
        due: today,
        recurrence: Recurrence.decode('{"type":"fortnightly"}'),
      );
      expect(actionsOf(newer), isEmpty);
      expect(canSnooze(newer, today), isFalse);
    });
  });

  group('doses', () {
    test('a running course lists today\'s doses with their marks', () {
      final entry = TodayView.build(
        [course()],
        today: today,
        marks: [mark('ammi', 840)],
      ).entries.single;
      expect(entry.on, today);
      expect(entry.doses, const [
        Dose(480, marked: false),
        Dose(840, marked: true),
        Dose(1200, marked: false),
      ]);
    });

    test('doses are marked in any order', () {
      final entry = TodayView.build(
        [course()],
        today: today,
        marks: [mark('ammi', 1200), mark('ammi', 480)],
      ).entries.single;
      expect(entry.doses.map((dose) => dose.marked), [true, false, true]);
    });

    test('marks from another day or another item do not count', () {
      final entry = TodayView.build(
        [course()],
        today: today,
        marks: [
          mark('ammi', 480, on: inDays(-1)),
          mark('abbu', 840),
        ],
      ).entries.single;
      expect(entry.doses.map((dose) => dose.marked), everyElement(isFalse));
    });

    test('yesterday\'s doses never show up anywhere', () {
      final view = TodayView.build([course()], today: today);
      expect(view[TodaySection.overdue], isEmpty);
      expect(view[TodaySection.toConfirm], isEmpty);
    });

    test('a course that has not started shows its start date, no doses', () {
      final entry = TodayView.build([
        course(startsIn: 3),
      ], today: today).entries.single;
      expect(entry.on, inDays(3));
      expect(entry.doses, isEmpty);
    });

    test('the course runs from its first day through until', () {
      final subject = course(startsIn: 0, endsIn: 4);
      expect(subject.takesDosesOn(inDays(-1)), isFalse);
      expect(subject.takesDosesOn(today), isTrue);
      expect(subject.takesDosesOn(inDays(4)), isTrue);
      expect(subject.takesDosesOn(inDays(5)), isFalse);
      expect(subject.courseEndedBefore(inDays(4)), isFalse);
      expect(subject.courseEndedBefore(inDays(5)), isTrue);
      expect(course(endsIn: null).courseEndedBefore(inDays(900)), isFalse);
    });

    test('only an existing dose on a course day can be marked', () {
      final subject = course();
      expect(subject.canMarkDose(today, 840), isTrue);
      expect(subject.canMarkDose(today, 900), isFalse);
      expect(subject.canMarkDose(inDays(29), 840), isFalse);
      expect(item('task', due: today).canMarkDose(today, 480), isFalse);

      final completion = subject.doseMark(today, 840, id: 'm1', now: now);
      expect(completion.occurrenceOn, today);
      expect(completion.occurrenceMinute, 840);
      expect(completion.outcome, CompletionOutcome.done);
      expect(
        () => subject.doseMark(today, 900, id: 'm2', now: now),
        throwsArgumentError,
      );
    });
  });

  group('schedule', () {
    test('Snooze counts from today and leaves the due date alone', () {
      final overdue = item('bill', due: inDays(-4));
      for (final (snooze, days) in [
        (SnoozeFor.oneDay, 1),
        (SnoozeFor.threeDays, 3),
        (SnoozeFor.oneWeek, 7),
      ]) {
        final snoozed = overdue.snoozed(snooze, today: today, now: now);
        expect(snoozed.snoozedUntil, inDays(days));
        expect(snoozed.dueOn, inDays(-4));
        expect(snoozed.updatedAt, now);
        expect(snoozed.effectiveOn(today), inDays(days));
      }
    });

    test('moving a date clears the snooze', () {
      final snoozed = item('bill', due: inDays(-1), snoozedUntil: inDays(2));
      final moved = snoozed.movedTo(inDays(5), now: now);
      expect(moved.dueOn, inDays(5));
      expect(moved.scheduledOn, inDays(5));
      expect(moved.snoozedUntil, isNull);
      expect(moved.violations, isEmpty);
    });

    test('moving a repeating item keeps the rule date, a course moves', () {
      final monthly = item(
        'bill',
        due: LocalDate(2026, 11, 10),
        recurrence: MonthlyRepeat(10),
        amount: Money(100, 'PKR'),
      );
      final moved = monthly.movedTo(LocalDate(2026, 11, 13), now: now);
      expect(moved.scheduledOn, LocalDate(2026, 11, 10));
      expect(moved.dueOn, LocalDate(2026, 11, 13));

      final restarted = course().movedTo(inDays(1), now: now);
      expect(restarted.scheduledOn, inDays(1));
      expect(restarted.dueOn, inDays(1));
    });
  });
}
