import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/time/clock.dart';
import 'package:yaadi/features/items/application/items_providers.dart';
import 'package:yaadi/features/items/data/item_repository.dart';
import 'package:yaadi/features/items/data/memory_item_repository.dart';
import 'package:yaadi/features/items/domain/item_category.dart';
import 'package:yaadi/features/items/domain/item_kind.dart';
import 'package:yaadi/features/search/application/search_providers.dart';
import 'package:yaadi/features/search/domain/region.dart';

import '../../../support/households.dart';
import '../../../support/items.dart';

void main() {
  late MemoryItemRepository repository;

  ProviderContainer containerFor(Region region) {
    final container = ProviderContainer.test(
      overrides: [
        itemRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(() => DateTime(2026, 11, 2, 9)),
        searchRegionProvider.overrideWithValue(region),
      ],
    );
    container.listen(searchResultsProvider, (_, _) {});
    return container;
  }

  List<String> resultIds(ProviderContainer container) => [
    for (final result in container.read(searchResultsProvider)) result.item.id,
  ];

  setUp(() => repository = MemoryItemRepository(items: khanHousehold));

  test('nothing typed, nothing shown', () async {
    final container = containerFor(Region.pk);
    await pumpEventQueue();
    expect(resultIds(container), isEmpty);
    container.read(searchQueryProvider.notifier).update('   ');
    expect(resultIds(container), isEmpty);
  });

  test('results follow the query and the items', () async {
    final container = containerFor(Region.pk);
    await pumpEventQueue();

    container.read(searchQueryProvider.notifier).update('bijli ka bill');
    expect(resultIds(container).first, 'lesco');

    await repository.create(
      item(
        'k-electric',
        kind: ItemKind.bill,
        category: ItemCategory.electricity,
        title: 'K-Electric bill',
        due: fixtureToday,
      ),
    );
    await pumpEventQueue();
    expect(resultIds(container).first, 'k-electric');

    container.read(searchQueryProvider.notifier).clear();
    expect(resultIds(container), isEmpty);
  });

  test('the region decides which billers are understood', () async {
    repository = MemoryItemRepository(items: taylorHousehold);
    final britain = containerFor(Region.uk);
    await pumpEventQueue();
    britain.read(searchQueryProvider.notifier).update('bijli');
    expect(resultIds(britain), ['energy']);

    britain.read(searchQueryProvider.notifier).update('tesco');
    expect(resultIds(britain), ['tesco']);
  });

  test('the query is forgotten when other items are shown', () {
    // The vault reopened after Delete all, or a demo household on a phone:
    // last time's query ("CNIC", say) must not come back.
    final shown = StateProvider<ItemRepository>((ref) => repository);
    final container = ProviderContainer.test(
      overrides: [
        itemRepositoryProvider.overrideWith((ref) => ref.watch(shown)),
        clockProvider.overrideWithValue(() => DateTime(2026, 11, 2, 9)),
        searchRegionProvider.overrideWithValue(Region.pk),
      ],
    );
    container.read(searchQueryProvider.notifier).update('cnic');
    container.read(shown.notifier).state = MemoryItemRepository();
    expect(container.read(searchQueryProvider), isEmpty);
  });

  test('the region follows the household currency', () {
    expect(Region.forCurrency('PKR'), Region.pk);
    expect(Region.forCurrency('GBP'), Region.uk);
    expect(Region.forCurrency('USD'), Region.us);
    expect(Region.forCurrency('EUR'), Region.pk);
  });
}
