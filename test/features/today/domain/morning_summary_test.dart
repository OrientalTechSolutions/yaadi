import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/money/money.dart';
import 'package:yaadi/core/time/local_date.dart';
import 'package:yaadi/features/items/domain/item.dart';
import 'package:yaadi/features/items/domain/item_category.dart';
import 'package:yaadi/features/items/domain/item_kind.dart';
import 'package:yaadi/features/items/domain/recurrence.dart';
import 'package:yaadi/features/today/domain/morning_summary.dart';
import 'package:yaadi/features/today/domain/today_view.dart';

import '../../../support/households.dart';
import '../../../support/items.dart';

MorningSummary summarize(Iterable<Item> items) =>
    MorningSummary.of(TodayView.build(items, today: fixtureToday));

void main() {
  test('the Khan household on a Monday morning', () {
    final summary = summarize(khanHousehold);

    expect(summary.overdue, 1);
    expect(summary.firstOverdue, 'مکان کا کرایہ');
    expect(summary.toConfirm, 0);
    expect(summary.today, [
      SummaryItem(title: 'Jazz mobile package', on: fixtureToday, minute: 1080),
      SummaryItem(
        title: 'پانی کا بل',
        on: fixtureToday,
        amount: Money(90000, 'PKR'),
      ),
    ]);
    expect(summary.moreToday, 0);
    expect(summary.dosesToday, 3);
    expect(summary.comingUp?.title, 'Bilal school fee');
    expect(summary.comingUp?.on, fixtureToday.addDays(3));
    expect(summary.payBy, fixtureToday.addDays(7));
    // Rent, water and the school fee; the gas and Jazz amounts are unknown.
    expect(summary.totals, [Money(5790000, 'PKR')]);
    expect(summary.unknownAmounts, 2);
    expect(summary.isQuietToday, isFalse);
  });

  test('the Taylor household counts in pounds', () {
    final summary = summarize(taylorHousehold);
    expect(summary.firstOverdue, 'Council tax');
    expect(summary.today, isEmpty);
    expect(summary.dosesToday, 2);
    expect(summary.comingUp?.title, 'Tesco delivery slot');
    expect(summary.totals, [Money(15600, 'GBP')]);
    expect(summary.unknownAmounts, 0);
  });

  test('the same items always give the same facts', () {
    expect(summarize(khanHousehold), summarize(khanHousehold.reversed));
    expect(
      summarize(khanHousehold).hashCode,
      summarize(khanHousehold.reversed).hashCode,
    );
  });

  test('a quiet day', () {
    final summary = summarize([item('later', due: fixtureToday.addDays(20))]);
    expect(summary.isQuietToday, isTrue);
    expect(summary.comingUp, isNull);
    expect(summary.totals, isEmpty);
  });

  test('names three items for today and counts the rest', () {
    final summary = summarize([
      for (var i = 0; i < 5; i++)
        item('task-$i', due: fixtureToday, minute: 600 + i),
    ]);
    expect(summary.today.map((s) => s.title), ['task-0', 'task-1', 'task-2']);
    expect(summary.moreToday, 2);
  });

  test('totals keep currencies apart and leave unknown amounts out', () {
    final summary = summarize([
      item(
        'pkr',
        kind: ItemKind.bill,
        due: fixtureToday,
        amount: Money(100000, 'PKR'),
      ),
      item(
        'gbp',
        kind: ItemKind.bill,
        due: fixtureToday.addDays(-2),
        amount: Money(4000, 'GBP'),
      ),
      item(
        'more-gbp',
        kind: ItemKind.bill,
        due: fixtureToday.addDays(7),
        amount: Money(1050, 'GBP'),
      ),
      item('unknown', kind: ItemKind.bill, due: fixtureToday.addDays(1)),
      item(
        'too-late',
        kind: ItemKind.bill,
        due: fixtureToday.addDays(8),
        amount: Money(999999, 'PKR'),
      ),
      item('not-a-bill', due: fixtureToday, amount: Money(500, 'PKR')),
    ]);
    expect(summary.totals, [Money(5050, 'GBP'), Money(100000, 'PKR')]);
    expect(summary.unknownAmounts, 1);
  });

  test('a fixed instalment paid late counts every one still owed', () {
    // Paid for August late, the fee stepped to 5 September; 5 October is
    // owed as well before 3 November, while 5 November is not due yet.
    final today = LocalDate(2026, 10, 27);
    final fee = item(
      'fee',
      kind: ItemKind.bill,
      category: ItemCategory.school,
      due: LocalDate(2026, 9, 5),
      recurrence: MonthlyRepeat(5),
      amount: Money(1200000, 'PKR'),
    );
    final summary = MorningSummary.of(TodayView.build([fee], today: today));
    expect(summary.payBy, LocalDate(2026, 11, 3));
    expect(summary.totals, [Money(2400000, 'PKR')]);

    // A variable bill carries its arrears in the next paper instead.
    final bill = item(
      'lesco',
      kind: ItemKind.bill,
      category: ItemCategory.electricity,
      due: LocalDate(2026, 9, 5),
      recurrence: MonthlyRepeat(5),
      amount: Money(425000, 'PKR'),
    );
    expect(MorningSummary.of(TodayView.build([bill], today: today)).totals, [
      Money(425000, 'PKR'),
    ]);
  });

  test('past appointments are counted for confirmation', () {
    final summary = summarize([
      item(
        'dentist',
        kind: ItemKind.appointment,
        due: fixtureToday.addDays(-1),
      ),
    ]);
    expect(summary.toConfirm, 1);
    expect(summary.overdue, 0);
    expect(summary.isQuietToday, isFalse);
  });

  test('an expiry date weeks away is not "coming up" this week', () {
    final summary = summarize([
      item('cnic', kind: ItemKind.expiry, due: fixtureToday.addDays(20)),
    ]);
    expect(summary.comingUp, isNull);
  });
}
