import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/features/items/data/memory_item_repository.dart';
import 'package:yaadi/features/items/data/item_repository.dart';

import '../../../support/items.dart';
import 'item_repository_contract.dart';

void main() {
  runItemRepositoryContract(() async => MemoryItemRepository());

  test('reports every successful write with the full contents', () async {
    final snapshots = <int>[];
    final repository = MemoryItemRepository(
      onChanged: (items, completions) => snapshots.add(items.length),
    );
    await repository.create(bill());
    await repository.create(bill()); // stale: not reported
    await repository.create(task());
    expect(snapshots, [1, 2]);
  });

  test('starts from seed items', () async {
    final repository = MemoryItemRepository(items: [bill(), task()]);
    expect(await repository.watchAll().first, hasLength(2));
  });
}
