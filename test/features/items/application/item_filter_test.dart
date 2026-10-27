import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/features/items/application/item_filter.dart';
import 'package:yaadi/features/items/application/items_providers.dart';
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
    expect(open.matches(paidWater), isFalse);
    expect(open.matches(khanHousehold.first), isTrue);
    expect(closedBills.matches(paidWater), isTrue);
    expect(closedBills.matches(doneTask), isFalse);
    expect(
      const ItemFilter(status: StatusFilter.all).matches(doneTask),
      isTrue,
    );
  });

  test(
    'lists open items by due date, then finished ones newest first',
    () async {
      final container = ProviderContainer.test(
        overrides: [
          itemRepositoryProvider.overrideWithValue(
            MemoryItemRepository(items: items),
          ),
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
