import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/storage/storage_failure.dart';
import 'package:yaadi/core/time/local_date.dart';
import 'package:yaadi/features/items/application/items_controller.dart';
import 'package:yaadi/features/items/application/items_providers.dart';
import 'package:yaadi/features/items/data/item_repository.dart';
import 'package:yaadi/features/items/data/memory_item_repository.dart';
import 'package:yaadi/features/items/domain/completion.dart';
import 'package:yaadi/features/items/domain/item.dart';
import 'package:yaadi/features/items/domain/item_change.dart';

import '../../../support/items.dart';

/// Refuses every write, like a full disk.
final class _FailingRepository implements ItemRepository {
  @override
  Stream<List<Item>> watchAll() => const Stream.empty();

  @override
  Future<List<Item>> readAll() async => const [];

  @override
  Future<Item?> find(String id) async => null;

  @override
  Future<List<Completion>> completionsOf(String itemId) async => const [];

  @override
  Stream<List<Completion>> watchCompletionsOn(LocalDate day) =>
      const Stream.empty();

  @override
  Future<WriteResult> apply(ItemChange change) async =>
      throw const StorageFailure(13);
}

void main() {
  late MemoryItemRepository repository;
  late ProviderContainer container;
  late ItemsController controller;

  setUp(() {
    repository = MemoryItemRepository(
      items: [bill()],
      completions: [completed('bill-1', outcome: CompletionOutcome.paid)],
    );
    container = ProviderContainer.test(
      overrides: [itemRepositoryProvider.overrideWithValue(repository)],
    );
    controller = container.read(itemsControllerProvider.notifier);
  });

  test('a new item is added, and undo takes it away again', () async {
    final result = await controller.save(task(), isNew: true);
    expect(result, isA<ItemWritten>());
    expect(await repository.find('task-1'), isNotNull);

    await controller.undo((result as ItemWritten).undo);
    expect(await repository.find('task-1'), isNull);
  });

  test('an edit is refused once someone else has changed the item', () async {
    final stored = (await repository.find('bill-1'))!;
    await repository.update(stored.copyWith(title: 'Changed elsewhere'));

    final result = await controller.save(
      stored.copyWith(title: 'My edit'),
      isNew: false,
    );
    expect(result, isA<ItemStale>());
    expect((await repository.find('bill-1'))?.title, 'Changed elsewhere');
  });

  test('delete removes the history too, and undo puts both back', () async {
    final stored = (await repository.find('bill-1'))!;
    final result = await controller.delete(stored) as ItemWritten;
    expect(await repository.find('bill-1'), isNull);
    expect(await repository.completionsOf('bill-1'), isEmpty);

    expect(await controller.undo(result.undo), isA<ItemWritten>());
    expect(await repository.find('bill-1'), isNotNull);
    expect(await repository.completionsOf('bill-1'), hasLength(1));
    expect(await controller.undo(result.undo), isA<ItemStale>());
  });

  test(
    'a write in flight is pending, and a second one waits its turn',
    () async {
      final first = controller.save(task(), isNew: true);
      expect(controller.isPending('task-1'), isTrue);
      expect(await controller.save(task(), isNew: true), isA<ItemStale>());
      await first;
      expect(controller.isPending('task-1'), isFalse);
    },
  );

  test('a storage failure is reported without its details', () async {
    final failing = ProviderContainer.test(
      overrides: [
        itemRepositoryProvider.overrideWithValue(_FailingRepository()),
      ],
    );
    final result = await failing
        .read(itemsControllerProvider.notifier)
        .save(task(), isNew: true);
    expect(result, isA<ItemNotWritten>());
    expect(failing.read(itemsControllerProvider), isEmpty);
  });
}
