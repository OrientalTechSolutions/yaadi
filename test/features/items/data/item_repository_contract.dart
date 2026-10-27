import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/money/money.dart';
import 'package:yaadi/core/time/local_date.dart';
import 'package:yaadi/features/items/data/item_repository.dart';
import 'package:yaadi/features/items/domain/completion.dart';
import 'package:yaadi/features/items/domain/item.dart';
import 'package:yaadi/features/items/domain/item_change.dart';
import 'package:yaadi/features/items/domain/item_status.dart';
import 'package:yaadi/features/items/domain/recurrence.dart';

import '../../../support/items.dart';

/// The behaviour every [ItemRepository] shares. Each implementation's test
/// file calls this with a factory for a fresh, empty repository.
void runItemRepositoryContract(
  Future<ItemRepository> Function() create, {
  Future<void> Function()? tearDown,
}) {
  late ItemRepository repository;

  setUp(() async => repository = await create());
  if (tearDown != null) tearDownAll(tearDown);

  Future<UndoSnapshot> write(Future<WriteResult> result) async {
    final written = await result;
    expect(written, isA<Written>());
    return (written as Written).undo;
  }

  Item paid(Item item) => item.copyWith(
    status: ItemStatus.paid,
    completedAt: DateTime.utc(2026, 11, 10, 8),
    updatedAt: DateTime.utc(2026, 11, 10, 8),
  );

  group('reading and writing', () {
    test('starts empty', () async {
      expect(await repository.watchAll().first, isEmpty);
      expect(await repository.find('nothing'), isNull);
    });

    test('keeps every field exactly', () async {
      final item = bill(
        dueMinute: 570,
        recurrence: MonthlyRepeat(31, until: LocalDate(2027, 6, 30)),
        notes: 'Pay at the HBL branch',
        reference: '07 11112 2223334',
      ).copyWith(snoozedUntil: LocalDate(2026, 11, 12), amountIsFixed: true);
      await write(repository.create(item));

      expect(await repository.find(item.id), item);
      expect(await repository.watchAll().first, [item]);
    });

    test('keeps a rule from a newer version byte for byte', () async {
      const raw = '{"type":"monthly","day":10,"interval":3}';
      await write(repository.create(bill(recurrence: Recurrence.decode(raw))));
      final stored = await repository.find('bill-1');
      expect(stored?.recurrence.encode(), raw);
    });

    test('keeps medicine and undated tasks', () async {
      await write(repository.create(medicine()));
      await write(repository.create(task()));
      expect(await repository.find('med-1'), medicine());
      expect(await repository.find('task-1'), task());
    });

    test('lists items in due order', () async {
      await write(repository.create(task(id: 'undated', title: 'Undated')));
      await write(
        repository.create(
          bill(id: 'late', title: 'Late', dueOn: LocalDate(2026, 12, 1)),
        ),
      );
      await write(
        repository.create(
          bill(
            id: 'timed',
            title: 'Timed',
            dueOn: LocalDate(2026, 11, 10),
            dueMinute: 600,
          ),
        ),
      );
      await write(
        repository.create(
          bill(id: 'untimed', title: 'Untimed', dueOn: LocalDate(2026, 11, 10)),
        ),
      );

      final ids = (await repository.watchAll().first).map((item) => item.id);
      expect(ids, ['timed', 'untimed', 'late', 'undated']);
      expect(await repository.readAll(), await repository.watchAll().first);
    });

    test('emits again after each write', () async {
      final emissions = <List<Item>>[];
      final subscription = repository.watchAll().listen(emissions.add);
      addTearDown(subscription.cancel);

      await pumpEventQueue();
      await write(repository.create(bill()));
      await pumpEventQueue();
      await write(repository.update(bill().copyWith(title: 'LESCO November')));
      await pumpEventQueue();

      expect(emissions.first, isEmpty);
      expect(emissions.last.single.title, 'LESCO November');
      expect(emissions.last.single.revision, 2);
    });
  });

  group('revisions', () {
    test(
      'an update writes the next revision and reports what it replaced',
      () async {
        await write(repository.create(bill()));
        final undo = await write(
          repository.update(bill().copyWith(title: 'LESCO Nov')),
        );

        final stored = await repository.find('bill-1');
        expect(stored?.revision, 2);
        expect(stored?.title, 'LESCO Nov');
        expect(undo.before, bill());
        expect(undo.writtenRevision, 2);
      },
    );

    test('a stale update writes nothing', () async {
      await write(repository.create(bill()));
      await write(repository.update(bill().copyWith(title: 'First')));

      final result = await repository.update(bill().copyWith(title: 'Second'));
      expect(result, isA<Stale>());
      expect((await repository.find('bill-1'))?.title, 'First');
    });

    test('creating an existing item is stale', () async {
      await write(repository.create(bill()));
      expect(await repository.create(bill(title: 'Duplicate')), isA<Stale>());
      expect((await repository.find('bill-1'))?.title, 'LESCO bill');
    });

    test('updating or deleting a missing item is stale', () async {
      expect(await repository.update(bill()), isA<Stale>());
      expect(await repository.delete(bill()), isA<Stale>());
    });
  });

  group('status updates', () {
    test(
      'Paid on a one-off bill records the payment with its amount',
      () async {
        await write(repository.create(bill()));
        final payment = completed(
          'bill-1',
          id: 'pay-1',
          outcome: CompletionOutcome.paid,
          amount: Money(425000, 'PKR'),
        );
        await write(
          repository.apply(
            ItemChange.update(paid(bill()), addCompletions: [payment]),
          ),
        );

        final stored = await repository.find('bill-1');
        expect(stored?.status, ItemStatus.paid);
        expect(stored?.isOpen, isFalse);
        expect(stored?.completedAt, DateTime.utc(2026, 11, 10, 8));
        expect(await repository.completionsOf('bill-1'), [payment]);
        expect(
          await repository.watchCompletionsOn(LocalDate(2026, 11, 10)).first,
          [payment],
        );
        expect(
          await repository.watchCompletionsOn(LocalDate(2026, 11, 11)).first,
          isEmpty,
        );
      },
    );

    test('a double tap on Paid applies once', () async {
      await write(repository.create(bill()));
      ItemChange markPaid(String id) => ItemChange.update(
        paid(bill()),
        addCompletions: [
          completed('bill-1', id: id, outcome: CompletionOutcome.paid),
        ],
      );

      final results = await Future.wait([
        repository.apply(markPaid('tap-1')),
        repository.apply(markPaid('tap-2')),
      ]);

      expect(results.whereType<Written>(), hasLength(1));
      expect(results.whereType<Stale>(), hasLength(1));
      expect(await repository.completionsOf('bill-1'), hasLength(1));
      expect((await repository.find('bill-1'))?.revision, 2);
    });

    test(
      'one completion per occurrence, and a refused change leaves no trace',
      () async {
        await write(repository.create(bill()));
        await write(
          repository.apply(
            ItemChange.update(
              bill().copyWith(notes: 'first'),
              addCompletions: [completed('bill-1', id: 'a')],
            ),
          ),
        );

        final again = ItemChange.update(
          bill().copyWith(revision: 2, notes: 'second'),
          addCompletions: [completed('bill-1', id: 'b')],
        );
        expect(await repository.apply(again), isA<Stale>());

        final stored = await repository.find('bill-1');
        expect(stored?.revision, 2);
        expect(stored?.notes, 'first');
        expect((await repository.completionsOf('bill-1')).map((c) => c.id), [
          'a',
        ]);
      },
    );

    test(
      'doses on the same day are marked separately, each only once',
      () async {
        await write(repository.create(medicine()));
        final day = LocalDate(2026, 10, 27);
        await write(
          repository.apply(
            ItemChange.update(
              medicine(),
              addCompletions: [
                completed('med-1', id: 'evening', on: day, minute: 1200),
              ],
            ),
          ),
        );
        await write(
          repository.apply(
            ItemChange.update(
              medicine().copyWith(revision: 2),
              addCompletions: [
                completed('med-1', id: 'morning', on: day, minute: 480),
              ],
            ),
          ),
        );
        final twice = ItemChange.update(
          medicine().copyWith(revision: 3),
          addCompletions: [
            completed('med-1', id: 'evening-again', on: day, minute: 1200),
          ],
        );
        expect(await repository.apply(twice), isA<Stale>());

        final marks = await repository.watchCompletionsOn(day).first;
        expect(marks.map((c) => c.occurrenceMinute), [480, 1200]);
      },
    );

    test('removing a completion that is not there is stale', () async {
      await write(repository.create(bill()));
      final change = ItemChange.update(
        bill().copyWith(notes: 'x'),
        removeCompletionIds: ['ghost'],
      );
      expect(await repository.apply(change), isA<Stale>());
      expect((await repository.find('bill-1'))?.notes, isNull);
    });

    test('snoozing is stored as a date on an open item', () async {
      await write(repository.create(bill()));
      await write(
        repository.update(
          bill().copyWith(snoozedUntil: LocalDate(2026, 11, 13)),
        ),
      );
      final stored = await repository.find('bill-1');
      expect(stored?.snoozedUntil, LocalDate(2026, 11, 13));
      expect(stored?.isOpen, isTrue);
    });
  });

  group('rules', () {
    test(
      'an item that breaks a rule is rejected before anything is written',
      () async {
        await expectLater(
          repository.create(bill().copyWith(title: '')),
          throwsA(isA<ItemRejected>()),
        );
        await expectLater(
          repository.create(bill().copyWith(status: ItemStatus.done)),
          throwsA(isA<ItemRejected>()),
        );
        expect(await repository.watchAll().first, isEmpty);
      },
    );

    test('a completion for another item is refused', () async {
      await write(repository.create(bill()));
      final change = ItemChange.update(
        bill(),
        addCompletions: [completed('someone-else')],
      );
      await expectLater(repository.apply(change), throwsArgumentError);
    });
  });

  group('delete and undo', () {
    test(
      'delete removes the item and its history, and undo brings both back',
      () async {
        await write(repository.create(bill()));
        final payment = completed(
          'bill-1',
          id: 'pay-1',
          outcome: CompletionOutcome.paid,
        );
        await write(
          repository.apply(
            ItemChange.update(paid(bill()), addCompletions: [payment]),
          ),
        );

        final deleted = await write(
          repository.delete((await repository.find('bill-1'))!),
        );
        expect(await repository.find('bill-1'), isNull);
        expect(await repository.completionsOf('bill-1'), isEmpty);
        expect(deleted.removed, [payment]);

        await write(repository.undo(deleted));
        final restored = await repository.find('bill-1');
        expect(restored?.status, ItemStatus.paid);
        expect(restored?.revision, 3);
        expect(await repository.completionsOf('bill-1'), [payment]);
      },
    );

    test('a stale delete keeps the item', () async {
      await write(repository.create(bill()));
      await write(repository.update(bill().copyWith(title: 'Edited')));
      expect(await repository.delete(bill()), isA<Stale>());
      expect(await repository.find('bill-1'), isNotNull);
    });

    test(
      'undo of Paid restores the open bill and removes the payment',
      () async {
        await write(repository.create(bill()));
        final undo = await write(
          repository.apply(
            ItemChange.update(
              paid(bill()),
              addCompletions: [completed('bill-1', id: 'pay-1')],
            ),
          ),
        );

        await write(repository.undo(undo));
        final stored = await repository.find('bill-1');
        expect(stored?.isOpen, isTrue);
        expect(stored?.completedAt, isNull);
        expect(stored?.revision, 3);
        expect(await repository.completionsOf('bill-1'), isEmpty);
      },
    );

    test('undo is refused once something else has written', () async {
      await write(repository.create(bill()));
      final undo = await write(
        repository.update(bill().copyWith(title: 'Edited')),
      );
      await write(
        repository.update(bill().copyWith(revision: 2, title: 'Edited again')),
      );

      expect(await repository.undo(undo), isA<Stale>());
      expect((await repository.find('bill-1'))?.title, 'Edited again');
    });

    test('Paid racing Undo ends in one consistent state', () async {
      await write(repository.create(bill()));
      final edit = await write(
        repository.update(bill().copyWith(title: 'Edited')),
      );
      final markPaid = ItemChange.update(
        paid(bill().copyWith(revision: 2, title: 'Edited')),
        addCompletions: [completed('bill-1', id: 'pay-1')],
      );

      final results = await Future.wait([
        repository.undo(edit),
        repository.apply(markPaid),
      ]);
      expect(results.whereType<Written>(), hasLength(1));

      final stored = (await repository.find('bill-1'))!;
      final completions = await repository.completionsOf('bill-1');
      if (stored.isOpen) {
        expect(stored.title, 'LESCO bill');
        expect(completions, isEmpty);
      } else {
        expect(stored.title, 'Edited');
        expect(completions, hasLength(1));
      }
      expect(stored.revision, 3);
    });

    test('undo of a create deletes the item', () async {
      final created = await write(repository.create(bill()));
      await write(repository.undo(created));
      expect(await repository.find('bill-1'), isNull);
    });
  });
}
