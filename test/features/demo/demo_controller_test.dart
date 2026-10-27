import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/platform/session_store_memory.dart';
import 'package:yaadi/core/time/clock.dart';
import 'package:yaadi/core/time/local_date.dart';
import 'package:yaadi/features/demo/application/demo_controller.dart';
import 'package:yaadi/features/demo/application/demo_providers.dart';
import 'package:yaadi/features/demo/domain/demo_household.dart';
import 'package:yaadi/features/items/application/items_providers.dart';
import 'package:yaadi/features/items/data/item_repository.dart';
import 'package:yaadi/features/items/data/session_item_repository.dart';
import 'package:yaadi/features/items/domain/item.dart';
import 'package:yaadi/features/search/application/search_providers.dart';
import 'package:yaadi/features/search/domain/region.dart';
import 'package:yaadi/features/settings/application/settings_controller.dart';
import 'package:yaadi/features/settings/domain/app_settings.dart';
import 'package:yaadi/vault/app_storage.dart';
import 'package:yaadi/vault/session_demo_backend.dart';

import '../../support/fake_storage.dart';
import '../../support/items.dart';

void main() {
  late DateTime now;

  Future<ProviderContainer> open(StorageBackend backend) async {
    final container = ProviderContainer.test(
      overrides: [
        storageBackendProvider.overrideWithValue(backend),
        clockProvider.overrideWithValue(() => now),
      ],
    );
    container.listen(itemsProvider, (_, _) {});
    await container.read(storageProvider.future);
    await container.read(settingsProvider.future);
    return container;
  }

  Future<List<Item>> itemsIn(ProviderContainer container) async {
    await pumpEventQueue();
    return container.read(itemsProvider).requireValue;
  }

  setUp(() => now = DateTime(2026, 11, 2, 9));

  group('on a phone', () {
    test(
      'a household is shown from memory and the vault is untouched',
      () async {
        final backend = FakeStorageBackend(items: [task()]);
        final container = await open(backend);
        final demo = container.read(demoControllerProvider.notifier);

        await demo.show(DemoHousehold.khan);
        final shown = await itemsIn(container);
        expect(shown.map((item) => item.id), contains('khan-lesco'));
        expect(container.read(showingDemoProvider), isTrue);
        expect(container.read(searchRegionProvider), Region.pk);

        await container
            .read(itemRepositoryProvider)
            .delete(shown.firstWhere((item) => item.id == 'khan-lesco'));
        expect((await backend.items.watchAll().first).map((item) => item.id), [
          'task-1',
        ]);
        expect(await backend.settings.readAll(), {
          SettingKeys.demoHousehold: 'khan',
        });

        await demo.clear();
        expect((await itemsIn(container)).map((item) => item.id), ['task-1']);
        expect(container.read(showingDemoProvider), isFalse);
        expect(await backend.settings.readAll(), isEmpty);
      },
    );

    test('switching households and the region with them', () async {
      final container = await open(FakeStorageBackend());
      final demo = container.read(demoControllerProvider.notifier);

      await demo.show(DemoHousehold.taylor);
      expect(
        (await itemsIn(container)).map((item) => item.id),
        everyElement(startsWith('taylor-')),
      );
      expect(container.read(searchRegionProvider), Region.uk);

      await demo.show(DemoHousehold.khan);
      expect(
        (await itemsIn(container)).map((item) => item.id),
        everyElement(startsWith('khan-')),
      );
    });

    test('the demo is rebuilt from its seed on the next launch', () async {
      final backend = FakeStorageBackend(
        settings: const {SettingKeys.demoHousehold: 'khan'},
      );
      final first = await open(backend);
      final firstLesco = (await itemsIn(first))
          .firstWhere((item) => item.id == 'khan-lesco');
      await first.read(itemRepositoryProvider).delete(firstLesco);
      first.dispose();

      now = DateTime(2026, 11, 20, 9);
      final second = await open(backend);
      final lesco = (await itemsIn(second))
          .firstWhere((item) => item.id == 'khan-lesco');
      expect(lesco.dueOn, LocalDate(2026, 11, 23));
    });
  });

  group('on the web', () {
    test(
      'choosing a household writes it into the tab, clearing empties it',
      () async {
        final store = MemorySessionStore();
        final container = await open(SessionDemoBackend(store));
        final demo = container.read(demoControllerProvider.notifier);
        expect(container.read(isWebDemoProvider), isTrue);
        expect(container.read(demoHouseholdProvider), isNull);

        await demo.show(DemoHousehold.taylor);
        expect(
          (await itemsIn(container)).map((item) => item.id),
          contains('taylor-council'),
        );
        expect(store.read(sessionItemsKey), contains('Council tax'));

        await demo.show(DemoHousehold.khan);
        final khan = await itemsIn(container);
        expect(khan.map((item) => item.id), everyElement(startsWith('khan-')));
        expect(store.read(sessionItemsKey), isNot(contains('Council tax')));

        await demo.clear();
        expect(await itemsIn(container), isEmpty);
        expect(container.read(demoHouseholdProvider), isNull);
        expect(store.read(sessionItemsKey), isNot(contains('khan-')));
      },
    );

    test("the visitor's changes survive a reload of the tab", () async {
      final store = MemorySessionStore();
      final first = await open(SessionDemoBackend(store));
      await first
          .read(demoControllerProvider.notifier)
          .show(DemoHousehold.khan);
      final school = (await itemsIn(first))
          .firstWhere((item) => item.id == 'khan-school');
      await first.read(itemRepositoryProvider).delete(school);
      first.dispose();

      final reloaded = await open(SessionDemoBackend(store));
      expect(reloaded.read(demoHouseholdProvider), DemoHousehold.khan);
      expect(
        (await itemsIn(reloaded)).map((item) => item.id),
        isNot(contains('khan-school')),
      );
    });
  });
}
