import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/time/clock.dart';
import '../../../vault/app_storage.dart';
import '../../items/application/items_providers.dart';
import '../../items/data/item_repository.dart';
import '../../items/data/memory_item_repository.dart';
import '../../settings/application/settings_controller.dart';
import '../data/demo_seed.dart';
import '../domain/demo_household.dart';

/// The web build, where everything is a demo kept in the browser tab.
final isWebDemoProvider = Provider<bool>(
  (ref) => ref.watch(storageProvider).value?.kind == StorageKind.webDemo,
);

/// The made-up family on screen, if any.
final demoHouseholdProvider = Provider<DemoHousehold?>(
  (ref) => ref.watch(appSettingsProvider.select((s) => s.demoHousehold)),
);

/// Whether the screen shows demo data rather than the user's own vault.
final showingDemoProvider = Provider<bool>(
  (ref) =>
      ref.watch(isWebDemoProvider) || ref.watch(demoHouseholdProvider) != null,
);

/// Whether the browser has refused to keep the web demo, as in some private
/// windows or over quota. Only a write can fail, so it is checked again
/// after every change to items or settings.
final demoNotSavingProvider = Provider<bool>((ref) {
  ref
    ..watch(itemsProvider)
    ..watch(appSettingsProvider);
  return ref.watch(storageProvider).value?.isSavingFailed() ?? false;
});

/// On a phone, the chosen household lives in memory and the vault is never
/// written (ARCHITECTURE.md section 14). It is built from its seed when
/// chosen and on each launch, so changes made in the demo are not kept.
final phoneDemoItemsProvider = Provider<ItemRepository?>((ref) {
  final household = ref.watch(demoHouseholdProvider);
  if (household == null) return null;
  // Read once rather than watched: the demo is seeded when it is chosen and
  // must not be rebuilt, losing the visitor's changes, when midnight passes.
  final seed = demoSeed(
    household,
    today: ref.read(todayProvider),
    now: ref.read(clockProvider)(),
  );
  return MemoryItemRepository(items: seed.items, completions: seed.completions);
});
