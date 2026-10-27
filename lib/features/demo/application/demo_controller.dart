import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/time/clock.dart';
import '../../items/application/items_providers.dart';
import '../../items/data/item_repository.dart';
import '../../items/domain/item_change.dart';
import '../../settings/application/settings_controller.dart';
import '../data/demo_seed.dart';
import '../domain/demo_household.dart';
import 'demo_providers.dart';

final demoControllerProvider = NotifierProvider<DemoController, bool>(
  DemoController.new,
);

/// Shows a demo household or goes back to the user's own items. The state is
/// true while a switch is under way, so its buttons can wait.
class DemoController extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> show(DemoHousehold household) => _switchTo(household);

  /// One tap back: to the vault on a phone, to the household picker on the
  /// web, with the tab's demo items removed.
  Future<void> clear() => _switchTo(null);

  Future<void> _switchTo(DemoHousehold? household) async {
    if (state) return;
    state = true;
    try {
      if (ref.read(isWebDemoProvider)) await _replaceWebItems(household);
      await ref.read(settingsProvider.notifier).setDemoHousehold(household);
    } finally {
      if (ref.mounted) state = false;
    }
  }

  /// The web demo keeps its household in the tab's session so the visitor's
  /// changes survive a reload. Switching starts the tab afresh. The items
  /// are replaced before the setting changes, so the screen never shows one
  /// family's items under the other's name.
  Future<void> _replaceWebItems(DemoHousehold? household) async {
    final items = ref.read(itemRepositoryProvider);
    for (final item in await items.readAll()) {
      await items.delete(item);
    }
    if (household == null) return;
    final seed = demoSeed(
      household,
      today: ref.read(todayProvider),
      now: ref.read(clockProvider)(),
    );
    for (final item in seed.items) {
      await items.apply(
        ItemChange(
          itemId: item.id,
          expectedRevision: null,
          after: item,
          addCompletions: [
            for (final completion in seed.completions)
              if (completion.itemId == item.id) completion,
          ],
        ),
      );
    }
  }
}
