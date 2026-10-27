import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/money/money.dart';
import 'package:yaadi/core/time/local_date.dart';
import 'package:yaadi/features/items/domain/item.dart';
import 'package:yaadi/features/items/domain/item_category.dart';
import 'package:yaadi/features/items/domain/item_draft.dart';
import 'package:yaadi/features/items/domain/item_kind.dart';
import 'package:yaadi/features/items/domain/item_status.dart';
import 'package:yaadi/features/items/domain/recurrence.dart';

import '../../../support/households.dart';
import '../../../support/items.dart';

final now = DateTime.utc(2026, 11, 2, 9);

ItemDraft billDraft({
  String title = 'LESCO bill',
  String amount = '',
  String currency = 'PKR',
  LocalDate? due,
  RepeatRule repeat = RepeatRule.none,
  LocalDate? until,
}) => ItemDraft(
  title: title,
  amountText: amount,
  currency: currency,
  dueOn: due ?? LocalDate(2026, 11, 10),
  repeat: repeat,
  until: until,
);

void main() {
  group('validate', () {
    final cases = <(String, ItemDraft, Map<DraftField, DraftProblem>)>[
      (
        'a blank bill needs a title and a date',
        ItemDraft.blank(currency: 'PKR'),
        {
          DraftField.title: DraftProblem.required,
          DraftField.dueOn: DraftProblem.required,
        },
      ),
      (
        'a title of spaces is empty',
        billDraft(title: '   '),
        {DraftField.title: DraftProblem.required},
      ),
      (
        'a title past the limit',
        billDraft(title: 'x' * 121),
        {DraftField.title: DraftProblem.tooLong},
      ),
      ('an unknown amount is fine', billDraft(), {}),
      ('rupees with grouping', billDraft(amount: '4,250'), {}),
      ('rupees in Urdu digits', billDraft(amount: '۴۲۵۰'), {}),
      (
        'paisa are not typed',
        billDraft(amount: '12.50'),
        {DraftField.amount: DraftProblem.invalidAmount},
      ),
      ('pence are', billDraft(amount: '12.50', currency: 'GBP'), {}),
      (
        'words are not an amount',
        billDraft(amount: 'four'),
        {DraftField.amount: DraftProblem.invalidAmount},
      ),
      (
        'an end before the first date',
        billDraft(repeat: RepeatRule.monthly, until: LocalDate(2026, 11, 9)),
        {DraftField.until: DraftProblem.beforeStart},
      ),
      (
        'an end date on a one-off item is ignored',
        billDraft(until: LocalDate(2026, 1, 1)),
        {},
      ),
      (
        'an undated task',
        const ItemDraft(kind: ItemKind.task, title: 'Call the plumber'),
        {},
      ),
      (
        'a repeating task needs a date',
        const ItemDraft(
          kind: ItemKind.task,
          title: 'Put the bins out',
          repeat: RepeatRule.weekly,
        ),
        {DraftField.dueOn: DraftProblem.required},
      ),
      (
        'medicine needs at least one time',
        ItemDraft(
          kind: ItemKind.medicine,
          title: 'امی کی دوائی',
          dueOn: fixtureToday,
          repeat: RepeatRule.doses,
        ),
        {DraftField.doseTimes: DraftProblem.required},
      ),
      (
        'notes past the limit',
        billDraft().copyWith(notes: 'n' * 1001),
        {DraftField.notes: DraftProblem.tooLong},
      ),
    ];
    for (final (name, draft, problems) in cases) {
      test(name, () => expect(draft.validate('en'), problems));
    }

    test('amounts are read in the Urdu locale too', () {
      expect(billDraft(amount: '4,250').validate('ur'), isEmpty);
    });
  });

  group('a new item', () {
    test('a monthly bill on the 31st keeps day 31 as its anchor', () {
      final item =
          billDraft(
                amount: '4,250',
                due: LocalDate(2027, 1, 31),
                repeat: RepeatRule.monthly,
              )
              .copyWith(notes: '  ', reference: ' 00 00000 0001234 ')
              .toItem(locale: 'en', now: now, id: 'new-1');

      expect(item.id, 'new-1');
      expect(item.amount, Money(425000, 'PKR'));
      expect(item.amountIsFixed, isFalse);
      expect(item.recurrence, MonthlyRepeat(31));
      expect(item.scheduledOn, LocalDate(2027, 1, 31));
      expect(item.notes, isNull);
      expect(item.reference, '00 00000 0001234');
      expect(item.revision, 1);
      expect(item.status, ItemStatus.open);
      expect(item.violations, isEmpty);
    });

    test('medicine gets its times, sorted, and no time of day', () {
      final item = ItemDraft(
        kind: ItemKind.medicine,
        title: 'امی کی دوائی',
        category: ItemCategory.health,
        dueOn: fixtureToday,
        dueMinute: 600,
        repeat: RepeatRule.doses,
        doseMinutes: const [1260, 480],
        until: fixtureToday.addDays(4),
      ).toItem(locale: 'en', now: now, id: 'med');

      expect(
        item.recurrence,
        DoseTimes([480, 1260], until: fixtureToday.addDays(4)),
      );
      expect(item.dueMinute, isNull);
      expect(item.amount, isNull);
    });

    test('only bills keep an amount, and expiry dates have no time', () {
      final item = billDraft(amount: '900')
          .copyWith(kind: ItemKind.expiry, dueMinute: 540)
          .toItem(locale: 'en', now: now, id: 'cnic');
      expect(item.amount, isNull);
      expect(item.dueMinute, isNull);
    });

    test('an invalid draft is refused', () {
      expect(
        () =>
            ItemDraft.blank(currency: 'PKR')
                .toItem(locale: 'en', now: now, id: 'x'),
        throwsStateError,
      );
    });
  });

  group('editing', () {
    final lesco = item(
      'lesco',
      kind: ItemKind.bill,
      title: 'LESCO bill',
      category: ItemCategory.electricity,
      due: LocalDate(2026, 11, 10),
      recurrence: MonthlyRepeat(10),
      amount: Money(425000, 'PKR'),
      snoozedUntil: LocalDate(2026, 11, 12),
    );

    Item edit(Item original, ItemDraft Function(ItemDraft) change) =>
        change(ItemDraft.of(original, currency: 'PKR'))
            .toItem(locale: 'en', now: now, original: original);

    test('changing nothing changes nothing but the time', () {
      for (final original in [...khanHousehold, ...taylorHousehold]) {
        expect(
          edit(original, (draft) => draft),
          original.copyWith(updatedAt: now),
          reason: original.id,
        );
      }
    });

    test('a new date moves this occurrence only', () {
      final moved = edit(
        lesco,
        (draft) => draft.copyWith(dueOn: LocalDate(2026, 11, 13)),
      );
      expect(moved.dueOn, LocalDate(2026, 11, 13));
      expect(moved.scheduledOn, LocalDate(2026, 11, 10));
      expect(moved.recurrence, MonthlyRepeat(10));
      expect(moved.snoozedUntil, isNull);
      expect(moved.revision, lesco.revision);
    });

    test('"Repeat from the new date" moves the anchor too', () {
      final moved = edit(
        lesco,
        (draft) =>
            draft.copyWith(dueOn: LocalDate(2026, 11, 13), moveSeries: true),
      );
      expect(moved.scheduledOn, LocalDate(2026, 11, 13));
      expect(moved.recurrence, MonthlyRepeat(13));
    });

    test('a new Repeat choice takes its anchor from the date', () {
      final weekly = edit(
        lesco,
        (draft) => draft.copyWith(repeat: RepeatRule.weekly),
      );
      expect(weekly.recurrence, WeeklyRepeat(LocalDate(2026, 11, 10).weekday));
    });

    test('notes on the 28 February instance of a 31st bill keep day 31', () {
      final clamped = item(
        'rent',
        kind: ItemKind.bill,
        category: ItemCategory.rent,
        due: LocalDate(2027, 2, 28),
        recurrence: MonthlyRepeat(31),
      );
      final noted = edit(
        clamped,
        (draft) => draft.copyWith(notes: 'Paid by cheque'),
      );
      expect(noted.recurrence, MonthlyRepeat(31));
      expect(
        noted.recurrence.nextAfter(noted.scheduledOn!),
        LocalDate(2027, 3, 31),
      );
    });

    test('a new end date keeps the anchor', () {
      final ending = edit(
        lesco,
        (draft) => draft.copyWith(until: LocalDate(2027, 6, 30)),
      );
      expect(
        ending.recurrence,
        MonthlyRepeat(10, until: LocalDate(2027, 6, 30)),
      );
      expect(ending.snoozedUntil, lesco.snoozedUntil);
    });

    test('a closed item stays closed', () {
      final paid = lesco.copyWith(
        status: ItemStatus.paid,
        completedAt: now,
        snoozedUntil: null,
      );
      final edited = edit(
        paid,
        (draft) => draft.copyWith(title: 'LESCO (old)'),
      );
      expect(edited.status, ItemStatus.paid);
      expect(edited.completedAt, paid.completedAt);
      expect(edited.violations, isEmpty);
    });

    test('kinds offer only the Repeat choices that fit them', () {
      final draft = billDraft(repeat: RepeatRule.monthly);
      expect(
        draft.copyWith(kind: ItemKind.expiry).effectiveRepeat,
        RepeatRule.none,
      );
      expect(
        draft.copyWith(kind: ItemKind.medicine).effectiveRepeat,
        RepeatRule.doses,
      );
      expect(
        draft.copyWith(kind: ItemKind.task).effectiveRepeat,
        RepeatRule.monthly,
      );
    });

    test('the editor can describe the rule before saving', () {
      expect(
        billDraft(repeat: RepeatRule.monthly).recurrenceFor(null),
        MonthlyRepeat(10),
      );
      expect(
        ItemDraft.of(
          lesco,
          currency: 'PKR',
        ).copyWith(dueOn: LocalDate(2026, 11, 13)).recurrenceFor(lesco),
        MonthlyRepeat(10),
      );
      expect(
        const ItemDraft(kind: ItemKind.medicine).recurrenceFor(null),
        isNull,
      );
    });
  });

  test('toString leaves out what was typed', () {
    final draft = billDraft().copyWith(
      reference: '12345-6789012-3',
      notes: 'secret',
    );
    expect(draft.toString(), isNot(contains('12345')));
    expect(draft.toString(), isNot(contains('secret')));
    expect(draft.toString(), isNot(contains('LESCO')));
  });
}
