import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/ids.dart';
import 'package:yaadi/core/money/money.dart';
import 'package:yaadi/core/time/clock.dart';
import 'package:yaadi/core/time/local_date.dart';
import 'package:yaadi/features/items/application/items_providers.dart';
import 'package:yaadi/features/items/data/item_repository.dart';
import 'package:yaadi/features/items/data/memory_item_repository.dart';
import 'package:yaadi/features/items/domain/completion.dart';
import 'package:yaadi/features/items/domain/item.dart';
import 'package:yaadi/features/items/domain/item_category.dart';
import 'package:yaadi/features/items/domain/item_change.dart';
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
        item(
          'checkup',
          kind: ItemKind.appointment,
          due: LocalDate(2026, 11, 1),
          minute: 1020,
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
    expect(again, isA<ActionStale>());
    expect(await repository.completionsOf('lesco'), hasLength(1));
    expect(
      await actions.markDone('missing', LocalDate(2026, 11, 10)),
      isA<ActionStale>(),
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
    expect(await actions.undo(paid.undo), isA<ActionStale>());
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
      isA<ActionStale>(),
    );
  });

  test('Snooze works on what is due now and nothing else', () async {
    expect(
      await actions.snooze('overdue', SnoozeFor.threeDays),
      isA<ActionApplied>(),
    );
    expect((await repository.find('overdue'))?.snoozedUntil, today.addDays(3));
    expect(await actions.snooze('soon', SnoozeFor.oneDay), isA<ActionStale>());
    expect((await repository.find('soon'))?.snoozedUntil, isNull);
  });

  test('Reschedule moves a past appointment to another day', () async {
    final moved = await actions.reschedule('checkup', LocalDate(2026, 11, 6));
    expect(moved, isA<ActionApplied>());
    final stored = await repository.find('checkup');
    expect(stored?.dueOn, LocalDate(2026, 11, 6));
    expect(stored?.scheduledOn, LocalDate(2026, 11, 6));
    expect(stored?.dueMinute, 1020);

    expect(
      await actions.reschedule('ammi', LocalDate(2026, 11, 6)),
      isA<ActionStale>(),
    );
    await actions.undo((moved as ActionApplied).undo);
    expect((await repository.find('checkup'))?.dueOn, LocalDate(2026, 11, 1));
  });

  test('a repeating bill rescheduled once keeps its rule date', () async {
    await actions.reschedule('lesco', LocalDate(2026, 11, 13));
    final stored = await repository.find('lesco');
    expect(stored?.dueOn, LocalDate(2026, 11, 13));
    expect(stored?.scheduledOn, LocalDate(2026, 11, 10));
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
    expect(await actions.markDose('ammi', today, 900), isA<ActionStale>());
    expect(await repository.completionsOf('ammi'), hasLength(1));
  });

  test('Done is refused on a medicine course', () async {
    expect(
      await actions.markDone('ammi', LocalDate(2026, 10, 27)),
      isA<ActionStale>(),
    );
    expect((await repository.find('ammi'))?.status, ItemStatus.open);
  });

  test('Paid refused by the repository records nothing and says so', () async {
    // Another write lands between planning the payment and applying it.
    final racing = _RacingRepository(repository);
    final racingContainer = ProviderContainer.test(
      overrides: [
        itemRepositoryProvider.overrideWithValue(racing),
        clockProvider.overrideWithValue(() => DateTime(2026, 11, 2, 9)),
        idGeneratorProvider.overrideWithValue(() => 'race-id'),
      ],
    );
    final racingActions = racingContainer.read(quickActionsProvider.notifier);
    racing.beforeNextApply = () async {
      final lesco = (await repository.find('lesco'))!;
      await repository.apply(
        ItemChange.update(lesco.copyWith(notes: 'Edited elsewhere')),
      );
    };

    final result = await racingActions.markPaid(
      'lesco',
      LocalDate(2026, 11, 10),
    );

    expect(result, isA<ActionStale>());
    expect(await repository.completionsOf('lesco'), isEmpty);
    final stored = await repository.find('lesco');
    expect(stored?.dueOn, LocalDate(2026, 11, 10));
    expect(stored?.notes, 'Edited elsewhere');
  });

  group('taking a completion back', () {
    test(
      'Paid, taken back, then Paid records the month exactly once',
      () async {
        await actions.markPaid('lesco', LocalDate(2026, 11, 10));
        final payment = (await repository.completionsOf('lesco')).single;

        final reopened = await actions.reopen('lesco', payment.id);
        expect(reopened, isA<ActionApplied>());
        final open = await repository.find('lesco');
        expect(open?.dueOn, LocalDate(2026, 11, 10));
        expect(open?.scheduledOn, LocalDate(2026, 11, 10));
        // The variable bill's amount comes back from the payment.
        expect(open?.amount, Money(425000, 'PKR'));
        expect(await repository.completionsOf('lesco'), isEmpty);

        expect(
          await actions.markPaid('lesco', LocalDate(2026, 11, 10)),
          isA<ActionApplied>(),
        );
        final history = await repository.completionsOf('lesco');
        expect(history.map((c) => c.occurrenceOn), [LocalDate(2026, 11, 10)]);
        expect(
          (await repository.find('lesco'))?.dueOn,
          LocalDate(2026, 12, 10),
        );
      },
    );

    test('a closed one-off item opens again on its own date', () async {
      await actions.markDone('overdue', LocalDate(2026, 10, 30));
      expect((await repository.find('overdue'))?.status, ItemStatus.done);
      final done = (await repository.completionsOf('overdue')).single;

      expect(await actions.reopen('overdue', done.id), isA<ActionApplied>());
      final stored = await repository.find('overdue');
      expect(stored?.status, ItemStatus.open);
      expect(stored?.completedAt, isNull);
      expect(stored?.dueOn, LocalDate(2026, 10, 30));
    });

    test('only the newest completion can be taken back', () async {
      final paid = await actions.markPaid(
        'old-lesco',
        LocalDate(2026, 8, 10),
      ) as ActionApplied;
      expect(paid.catchUp?.missed, 2);
      final history = await repository.completionsOf('old-lesco');
      final oldest = history.firstWhere(
        (c) => c.occurrenceOn == LocalDate(2026, 8, 10),
      );
      expect(await actions.reopen('old-lesco', oldest.id), isA<ActionStale>());
      expect(await repository.completionsOf('old-lesco'), hasLength(3));

      final newest = reopenable(
        (await repository.find('old-lesco'))!,
        history,
      )!;
      expect(newest.occurrenceOn, LocalDate(2026, 10, 10));
      expect(
        await actions.reopen('old-lesco', newest.id),
        isA<ActionApplied>(),
      );
      expect(
        (await repository.find('old-lesco'))?.dueOn,
        LocalDate(2026, 10, 10),
      );
    });

    test('undo of a take-back records the payment again', () async {
      await actions.markPaid('lesco', LocalDate(2026, 11, 10));
      final payment = (await repository.completionsOf('lesco')).single;
      final reopened =
          await actions.reopen('lesco', payment.id) as ActionApplied;
      expect(await actions.undo(reopened.undo), isA<ActionApplied>());
      expect((await repository.find('lesco'))?.dueOn, LocalDate(2026, 12, 10));
      expect(await repository.completionsOf('lesco'), [payment]);
    });
  });

  test('an undo or catch-up choice from other storage is refused', () async {
    final paid = await actions.markPaid(
      'old-lesco',
      LocalDate(2026, 8, 10),
    ) as ActionApplied;
    final elsewhere = MemoryItemRepository(
      items: [(await repository.find('old-lesco'))!],
    );
    final otherContainer = ProviderContainer.test(
      overrides: [
        itemRepositoryProvider.overrideWithValue(elsewhere),
        clockProvider.overrideWithValue(() => DateTime(2026, 11, 2, 9)),
      ],
    );
    final otherActions = otherContainer.read(quickActionsProvider.notifier);

    expect(await otherActions.undo(paid.undo), isA<ActionStale>());
    expect(
      await otherActions.chooseCatchUp(paid, paid.catchUp!.options.single),
      isA<ActionStale>(),
    );
    expect(await elsewhere.completionsOf('old-lesco'), isEmpty);
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

/// Runs [beforeNextApply] once, just before the next write reaches the
/// repository: another write that lands between planning and applying.
final class _RacingRepository implements ItemRepository {
  _RacingRepository(this._inner);

  final MemoryItemRepository _inner;
  Future<void> Function()? beforeNextApply;

  @override
  Future<WriteResult> apply(ItemChange change) async {
    final race = beforeNextApply;
    beforeNextApply = null;
    await race?.call();
    return _inner.apply(change);
  }

  @override
  Stream<List<Item>> watchAll() => _inner.watchAll();

  @override
  Future<List<Item>> readAll() => _inner.readAll();

  @override
  Future<Item?> find(String id) => _inner.find(id);

  @override
  Future<List<Completion>> completionsOf(String itemId) =>
      _inner.completionsOf(itemId);

  @override
  Stream<List<Completion>> watchCompletionsOn(LocalDate day) =>
      _inner.watchCompletionsOn(day);
}
