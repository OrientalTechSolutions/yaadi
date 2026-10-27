import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/money/money.dart';
import 'package:yaadi/core/time/local_date.dart';
import 'package:yaadi/features/items/domain/item.dart';
import 'package:yaadi/features/items/domain/item_category.dart';
import 'package:yaadi/features/items/domain/item_kind.dart';
import 'package:yaadi/features/items/domain/item_status.dart';
import 'package:yaadi/features/items/domain/recurrence.dart';

import '../../../support/items.dart';

void main() {
  group('defaults', () {
    test('a valid item breaks no rule', () {
      expect(bill().violations, isEmpty);
      expect(task().violations, isEmpty);
      expect(medicine().violations, isEmpty);
    });

    test('the scheduled date starts as the due date', () {
      final item = bill(dueOn: LocalDate(2026, 11, 10));
      expect(item.scheduledOn, LocalDate(2026, 11, 10));
      expect(task().scheduledOn, isNull);
    });

    test('utility bills vary, everything else is fixed', () {
      for (final category in ItemCategory.values) {
        final expected = switch (category) {
          ItemCategory.electricity ||
          ItemCategory.gas ||
          ItemCategory.water ||
          ItemCategory.phone => false,
          _ => true,
        };
        expect(
          bill(category: category).amountIsFixed,
          expected,
          reason: '$category',
        );
      }
    });

    test('instants are kept in UTC to the millisecond', () {
      final item = Item(
        id: 'x',
        kind: ItemKind.task,
        title: 'Task',
        category: ItemCategory.other,
        createdAt: DateTime.fromMicrosecondsSinceEpoch(1761557400123456),
        updatedAt: DateTime.utc(2026),
      );
      expect(item.createdAt.isUtc, isTrue);
      expect(item.createdAt.microsecond, 0);
      expect(item.createdAt.millisecondsSinceEpoch, 1761557400123);
    });
  });

  group('violations', () {
    final cases = <(String, Item, ItemViolation)>[
      ('empty title', bill().copyWith(title: ''), ItemViolation.titleEmpty),
      (
        'long title',
        bill().copyWith(title: 'x' * 121),
        ItemViolation.titleTooLong,
      ),
      (
        'untrimmed title',
        bill().copyWith(title: ' LESCO '),
        ItemViolation.titleNotTrimmed,
      ),
      ('long notes', bill(notes: 'n' * 1001), ItemViolation.notesTooLong),
      (
        'long reference',
        bill(reference: '1' * 41),
        ItemViolation.referenceTooLong,
      ),
      ('empty notes', bill(notes: ''), ItemViolation.emptyOptionalText),
      ('empty reference', bill(reference: ''), ItemViolation.emptyOptionalText),
      (
        'undated bill',
        bill().copyWith(dueOn: null, scheduledOn: null),
        ItemViolation.missingDueDate,
      ),
      (
        'schedule without due date',
        task().copyWith(scheduledOn: LocalDate(2026, 1, 1)),
        ItemViolation.scheduleMismatch,
      ),
      (
        'time without date',
        task().copyWith(dueMinute: 600),
        ItemViolation.timeWithoutDate,
      ),
      ('minute 1440', bill(dueMinute: 1440), ItemViolation.dueMinuteOutOfRange),
      (
        'repeating undated task',
        task().copyWith(recurrence: const DailyRepeat()),
        ItemViolation.repeatWithoutDate,
      ),
      (
        'doses on a bill',
        bill(recurrence: DoseTimes([480])),
        ItemViolation.dosesNotMedicine,
      ),
      (
        'paid without completion time',
        bill().copyWith(status: ItemStatus.paid),
        ItemViolation.completionMismatch,
      ),
      (
        'open with completion time',
        bill().copyWith(completedAt: DateTime.utc(2026)),
        ItemViolation.completionMismatch,
      ),
      (
        'snoozed after it was paid',
        bill().copyWith(
          status: ItemStatus.paid,
          completedAt: DateTime.utc(2026),
          snoozedUntil: LocalDate(2026, 11, 12),
        ),
        ItemViolation.snoozedWhileClosed,
      ),
      (
        'revision 0',
        bill().copyWith(revision: 0),
        ItemViolation.revisionNotPositive,
      ),
    ];
    for (final (name, item, violation) in cases) {
      test(name, () => expect(item.violations, contains(violation)));
    }

    test('limits are inclusive', () {
      expect(bill().copyWith(title: 'x' * 120).violations, isEmpty);
      expect(bill(notes: 'n' * 1000, reference: '1' * 40).violations, isEmpty);
      expect(bill(dueMinute: 0).violations, isEmpty);
      expect(bill(dueMinute: 1439).violations, isEmpty);
    });
  });

  group('copyWith', () {
    test('keeps fields that are left out and clears fields passed as null', () {
      final original = bill(
        notes: 'Pay at the bank',
        reference: '12345678901234',
      );
      final edited = original.copyWith(title: 'LESCO November');
      expect(edited.notes, original.notes);
      expect(edited.reference, original.reference);
      expect(edited.amount, original.amount);

      final cleared = original.copyWith(notes: null, amount: null);
      expect(cleared.notes, isNull);
      expect(cleared.amount, isNull);
      expect(cleared.reference, original.reference);
    });

    test('moving the due date leaves the scheduled date alone', () {
      final moved = bill(dueOn: LocalDate(2026, 11, 10))
          .copyWith(dueOn: LocalDate(2026, 11, 13));
      expect(moved.dueOn, LocalDate(2026, 11, 13));
      expect(moved.scheduledOn, LocalDate(2026, 11, 10));
    });

    test('equal fields make equal items', () {
      expect(bill(), bill());
      expect(bill().hashCode, bill().hashCode);
      expect(bill(), isNot(bill().copyWith(revision: 2)));
      expect(bill(), isNot(bill(amount: Money(1, 'PKR'))));
    });
  });

  test('toString leaves out notes and the reference', () {
    final text = bill(
      notes: 'Ammi CNIC copy',
      reference: '35202-1234567-1',
    ).toString();
    expect(text, isNot(contains('35202')));
    expect(text, isNot(contains('Ammi CNIC')));
    expect(text, contains('<redacted>'));
  });

  test(
    'due order: date, then timed before untimed, then title, undated last',
    () {
      final items = [
        task(id: 't', title: 'Undated'),
        bill(id: 'c', title: 'b untimed', dueOn: LocalDate(2026, 11, 10)),
        bill(
          id: 'd',
          title: 'Z timed late',
          dueOn: LocalDate(2026, 11, 10),
          dueMinute: 900,
        ),
        bill(id: 'e', title: 'a untimed', dueOn: LocalDate(2026, 11, 10)),
        bill(
          id: 'f',
          title: 'Timed early',
          dueOn: LocalDate(2026, 11, 10),
          dueMinute: 540,
        ),
        bill(id: 'g', title: 'Earlier day', dueOn: LocalDate(2026, 11, 9)),
      ]..sort(compareByDue);
      expect(items.map((item) => item.id), ['g', 'f', 'd', 'e', 'c', 't']);
    },
  );
}
