import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../vault/app_storage.dart';
import '../../demo/application/demo_providers.dart';
import '../data/item_repository.dart';
import '../domain/completion.dart';
import '../domain/item.dart';

/// The active item repository: the vault, a demo household in memory, or
/// the web demo's browser session. Only read below the vault gate, where
/// storage is known to be open.
final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  final storage = ref.watch(storageProvider).requireValue;
  if (storage.kind == StorageKind.vault) {
    if (ref.watch(phoneDemoItemsProvider) case final demo?) return demo;
  }
  return storage.items;
});

/// Every item, in due order, kept current by the repository's stream.
final itemsProvider = StreamProvider<List<Item>>(
  (ref) => ref.watch(itemRepositoryProvider).watchAll(),
);

/// One item by id; null once it has been deleted.
final itemProvider = Provider.family<AsyncValue<Item?>, String>(
  (ref, id) => ref
      .watch(itemsProvider)
      .whenData((items) => items.where((item) => item.id == id).firstOrNull),
);

/// An item's history, newest first, read again whenever the item changes.
final completionsProvider = FutureProvider.autoDispose
    .family<List<Completion>, String>((ref, id) async {
      ref.watch(itemProvider(id).select((item) => item.value?.revision));
      final history = await ref.watch(itemRepositoryProvider).completionsOf(id);
      return history.reversed.toList();
    });
