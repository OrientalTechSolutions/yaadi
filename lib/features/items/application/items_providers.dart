import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../vault/app_storage.dart';
import '../data/item_repository.dart';
import '../domain/item.dart';

/// The active item repository. Only read below the vault gate, where
/// storage is known to be open.
final itemRepositoryProvider = Provider<ItemRepository>(
  (ref) => ref.watch(storageProvider).requireValue.items,
);

/// Every item, in due order, kept current by the repository's stream.
final itemsProvider = StreamProvider<List<Item>>(
  (ref) => ref.watch(itemRepositoryProvider).watchAll(),
);
