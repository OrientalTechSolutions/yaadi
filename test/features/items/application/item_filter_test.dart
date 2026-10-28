import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/time/clock.dart';
import 'package:yaadi/core/time/local_date.dart';
import 'package:yaadi/features/items/application/item_filter.dart';
import 'package:yaadi/features/items/application/items_providers.dart';
import 'package:yaadi/features/items/data/item_repository.dart';
import 'package:yaadi/features/items/data/memory_item_repository.dart';
import 'package:yaadi/features/items/domain/item_kind.dart';
import 'package:yaadi/features/items/domain/item_status.dart';

import '../../../support/households.dart';
import '../../../support/items.dart';

void main() {
  final paidWater = khanHousehold
      .firstWhere((item) => item.id == 'water')
      .copyWith(
        status: ItemStatus.paid,
        completedAt: DateTime.utc(2026, 11, 1),
        updatedAt: DateTime.utc(2026, 11, 1),
      );
  final doneTask = task().copyWith(
    status: ItemStatus.done,
    completedAt: DateTime.utc(2026, 11, 2),
    updatedAt: DateTime.utc(2026, 11, 2),
  );
  final items = [
    for (final item in khanHousehold)
      if (item.id != 'water') item,
    paidWater,
    doneTask,
  ];

  test('matches by status and kind', () {
    const open = ItemFilter();
    const closedBills = ItemFilter(
      status: StatusFilter.closed,
      kind: ItemKind.bill,
    );
    expect(open.matches(paidWater, fixtureToday), isFalse);
    expect(open.matches(khanHousehold.first, fixtureToday), isTrue);
    expect(closedBills.matches(paidWater, fixtureToday), isTrue);
    expect(closedBills.matches(doneTask, fixtureToday), isFalse);
    expect(
      const ItemFilter(status: StatusFilter.all)
          .matches(doneTask, fixtureToday),
      isTrue,
    );
  });

  test('a medicine course past its last day counts as finished', () {
    // The course runs from Oct 27 to Nov 3.
    final course = medicine();
    const open = ItemFilter();
    const finished = ItemFilter(status: StatusFilter.closed);
    expect(open.matches(course, fixtureToday), isTrue);
    expect(open.matches(course, LocalDate(2026, 11, 3)), isTrue);
    expect(open.matches(course, LocalDate(2026, 11, 4)), isFalse);
    expect(finished.matches(course, LocalDate(2026, 11, 4)), isTrue);
    expect(isActive(course, LocalDate(2026, 11, 4)), isFalse);
  });

  test('the filter starts afresh when other items are shown', () {
    // A demo household on a phone, or the vault again after Delete all.
    final repository = StateProvider<ItemRepository>(
      (ref) => MemoryItemRepository(items: items),
    );
    final container = ProviderContainer.test(
      overrides: [
        itemRepositoryProvider.overrideWith((ref) => ref.watch(repository)),
      ],
    );
    container.read(itemFilterProvider.notifier)
      ..showStatus(StatusFilter.closed)
      ..showKind(ItemKind.bill);
    expect(container.read(itemFilterProvider), isNot(const ItemFilter()));

    container.read(repository.notifier).state = MemoryItemRepository();
    expect(container.read(itemFilterProvider), const ItemFilter());
  });

  test(
    'lists open items by due date, then finished ones newest first',
    () async {
      final container = ProviderContainer.test(
        overrides: [
          itemRepositoryProvider.overrideWithValue(
            MemoryItemRepository(items: items),
          ),
          clockProvider.overrideWithValue(() => DateTime(2026, 11, 2, 9)),
        ],
      );
      container.listen(filteredItemsProvider, (_, _) {});
      await pumpEventQueue();
      final filter = container.read(itemFilterProvider.notifier);

      List<String> ids() => [
        for (final item in container.read(filteredItemsProvider).requireValue)
          item.id,
      ];

      expect(ids(), isNot(contains('water')));
      expect(ids().first, 'ammi');

      filter.showStatus(StatusFilter.closed);
      expect(ids(), ['task-1', 'water']);

      filter.showStatus(StatusFilter.all);
      filter.showKind(ItemKind.medicine);
      expect(ids(), ['ammi']);

      filter.showKind(null);
      expect(ids(), hasLength(items.length));
      expect(ids().sublist(ids().length - 2), ['task-1', 'water']);
    },
  );
}
