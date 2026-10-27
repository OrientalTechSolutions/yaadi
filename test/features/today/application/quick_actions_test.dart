import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/ids.dart';
import 'package:yaadi/core/money/money.dart';
import 'package:yaadi/core/time/clock.dart';
import 'package:yaadi/core/time/local_date.dart';
import 'package:yaadi/features/items/application/items_providers.dart';
import 'package:yaadi/features/items/data/memory_item_repository.dart';
import 'package:yaadi/features/items/domain/completion.dart';
import 'package:yaadi/features/items/domain/item_category.dart';
import 'package:yaadi/features/items/domain/item_kind.dart';
import 'package:yaadi/features/items/domain/item_status.dart';
import 'package:yaadi/features/items/domain/recurrence.dart';
import 'package:yaadi/features/today/application/quick_actions.dart';
import 'package:yaadi/features/today/domain/roll_forward.dart';
import 'package:yaadi/features/today/domain/schedule.dart';

import '../../../support/items.dart';

final today = LocalDate(2026, 11, 2);

void main() {
  late MemoryItemRepository repository;
  late ProviderContainer container;
  late QuickActionsController actions;

  setUp(() {
    repository = MemoryItemRepository(
      items: [
        item(
          'lesco',
          kind: ItemKind.bill,
          title: 'LESCO bill',
          category: ItemCategory.electricity,
          due: LocalDate(2026, 11, 10),
          recurrence: MonthlyRepeat(10),
          amount: Money(425000, 'PKR'),
        ),
        item(
          'old-lesco',
          kind: ItemKind.bill,
          category: ItemCategory.electricity,
          due: LocalDate(2026, 8, 10),
          recurrence: MonthlyRepeat(10),
          amount: Money(425000, 'PKR'),
        ),
        item('overdue', due: LocalDate(2026, 10, 30)),
        item('soon', due: LocalDate(2026, 11, 5)),
        item(
          'ammi',
          kind: ItemKind.medicine,
          due: LocalDate(2026, 10, 27),
          recurrence: DoseTimes([480, 840, 1200]),
        ),
      ],
    );
    var nextId = 0;
    container = ProviderContainer.test(
      overrides: [
        itemRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(() => DateTime(2026, 11, 2, 9)),
        idGeneratorProvider.overrideWithValue(() => 'id-${++nextId}'),
      ],
    );
    actions = container.read(quickActionsProvider.notifier);
  });

  test('Paid records the payment and rolls the bill to next month', () async {
    final result = await actions.markPaid('lesco', LocalDate(2026, 11, 10));

    expect(result, isA<ActionApplied>());
    final stored = await repository.find('lesco');
    expect(stored?.dueOn, LocalDate(2026, 12, 10));
    expect(stored?.amount, isNull);
    final payment = (await repository.completionsOf('lesco')).single;
    expect(payment.outcome, CompletionOutcome.paid);
    expect(payment.amount, Money(425000, 'PKR'));
    expect(payment.id, 'id-1');
  });

  test('a double tap on Paid rolls forward once', () async {
    final results = await Future.wait([
      actions.markPaid('lesco', LocalDate(2026, 11, 10)),
      actions.markPaid('lesco', LocalDate(2026, 11, 10)),
    ]);
    expect(results.whereType<ActionApplied>(), hasLength(1));
    expect(results.whereType<AlreadyApplied>(), hasLength(1));
    expect((await repository.find('lesco'))?.dueOn, LocalDate(2026, 12, 10));
    expect(await repository.completionsOf('lesco'), hasLength(1));
  });

  test('Paid for an occurrence that has moved on does nothing', () async {
    await actions.markPaid('lesco', LocalDate(2026, 11, 10));
    final again = await actions.markPaid('lesco', LocalDate(2026, 11, 10));
    expect(again, isA<AlreadyApplied>());
    expect(await repository.completionsOf('lesco'), hasLength(1));
    expect(
      await actions.markDone('missing', LocalDate(2026, 11, 10)),
      isA<AlreadyApplied>(),
    );
  });

  test('undo puts the bill back and removes the payment', () async {
    final paid = await actions.markPaid(
      'lesco',
      LocalDate(2026, 11, 10),
    ) as ActionApplied;
    expect(await actions.undo(paid.undo), isA<ActionApplied>());

    final stored = await repository.find('lesco');
    expect(stored?.dueOn, LocalDate(2026, 11, 10));
    expect(stored?.amount, Money(425000, 'PKR'));
    expect(await repository.completionsOf('lesco'), isEmpty);
    expect(await actions.undo(paid.undo), isA<AlreadyApplied>());
  });

  test('missed months can be kept unpaid instead', () async {
    final paid = await actions.markPaid(
      'old-lesco',
      LocalDate(2026, 8, 10),
    ) as ActionApplied;
    final catchUp = paid.catchUp!;
    expect(catchUp.missed, 2);
    expect(catchUp.mode, CatchUpMode.markPaid);
    expect(
      (await repository.find('old-lesco'))?.dueOn,
      LocalDate(2026, 11, 10),
    );
    expect(await repository.completionsOf('old-lesco'), hasLength(3));

    final kept = await actions.chooseCatchUp(paid, catchUp.options.single);
    expect(kept, isA<ActionApplied>());
    expect((await repository.find('old-lesco'))?.dueOn, LocalDate(2026, 9, 10));
    final history = await repository.completionsOf('old-lesco');
    expect(history.map((c) => c.occurrenceOn), [LocalDate(2026, 8, 10)]);

    expect(
      await actions.chooseCatchUp(paid, catchUp.options.single),
      isA<AlreadyApplied>(),
    );
  });

  test('Snooze works on what is due now and nothing else', () async {
    expect(
      await actions.snooze('overdue', SnoozeFor.threeDays),
      isA<ActionApplied>(),
    );
    expect((await repository.find('overdue'))?.snoozedUntil, today.addDays(3));
    expect(
      await actions.snooze('soon', SnoozeFor.oneDay),
      isA<AlreadyApplied>(),
    );
    expect((await repository.find('soon'))?.snoozedUntil, isNull);
  });

  test('doses tapped in quick succession are all marked', () async {
    final results = await Future.wait([
      actions.markDose('ammi', today, 480),
      actions.markDose('ammi', today, 840),
      actions.markDose('ammi', today, 1200),
    ]);
    expect(results, everyElement(isA<ActionApplied>()));
    final marks = await repository.watchCompletionsOn(today).first;
    expect(marks.map((mark) => mark.occurrenceMinute), [480, 840, 1200]);
  });

  test('the same dose is marked once', () async {
    final results = await Future.wait([
      actions.markDose('ammi', today, 840),
      actions.markDose('ammi', today, 840),
    ]);
    expect(results.whereType<ActionApplied>(), hasLength(1));
    expect(await actions.markDose('ammi', today, 840), isA<AlreadyApplied>());
    expect(await actions.markDose('ammi', today, 900), isA<AlreadyApplied>());
    expect(await repository.completionsOf('ammi'), hasLength(1));
  });

  test('Done is refused on a medicine course', () async {
    expect(
      await actions.markDone('ammi', LocalDate(2026, 10, 27)),
      isA<AlreadyApplied>(),
    );
    expect((await repository.find('ammi'))?.status, ItemStatus.open);
  });

  test('a write in flight is listed as pending until it lands', () async {
    final seen = <Set<PendingAction>>[];
    container.listen(quickActionsProvider, (_, next) => seen.add(next));

    final write = actions.markPaid('lesco', LocalDate(2026, 11, 10));
    expect(actions.isPending('lesco'), isTrue);
    expect(actions.isPending('ammi'), isFalse);
    await write;

    expect(actions.isPending('lesco'), isFalse);
    expect(seen, [
      {('lesco', null)},
      <PendingAction>{},
    ]);
  });
}
