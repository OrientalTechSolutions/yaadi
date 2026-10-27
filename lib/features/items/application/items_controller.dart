import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/storage_failure.dart';
import '../data/item_repository.dart';
import '../domain/item.dart';
import '../domain/item_change.dart';
import 'items_providers.dart';

/// What became of a save, a delete or an undo.
sealed class ItemWriteResult {
  const ItemWriteResult();
}

final class ItemWritten extends ItemWriteResult {
  const ItemWritten(this.undo);

  final UndoSnapshot undo;
}

/// Nothing was written: the item changed, appeared or went away since the
/// screen read it.
final class ItemStale extends ItemWriteResult {
  const ItemStale();
}

/// Storage refused the write. Only the result code is known, and none of it
/// reaches the screen (ARCHITECTURE.md section 9).
final class ItemNotWritten extends ItemWriteResult {
  const ItemNotWritten();
}

final itemsControllerProvider = NotifierProvider<ItemsController, Set<String>>(
  ItemsController.new,
);

/// Saves, deletes and undoes for the editor and the details screen. The
/// state lists items with a write in flight, so their buttons can wait.
class ItemsController extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  bool isPending(String itemId) => state.contains(itemId);

  /// Adds [item], or replaces the stored one if it is still at
  /// `item.revision`.
  Future<ItemWriteResult> save(Item item, {required bool isNew}) => _write(
    item.id,
    (items) => isNew ? items.create(item) : items.update(item),
  );

  /// Deletes [item] and its history; [undo] puts both back.
  Future<ItemWriteResult> delete(Item item) =>
      _write(item.id, (items) => items.delete(item));

  /// Refused when the write came from another repository, such as a demo
  /// household the user has since left.
  Future<ItemWriteResult> undo(UndoSnapshot snapshot) =>
      _write(snapshot.itemId, (items) async {
        if (!identical(items, snapshot.origin)) return const Stale();
        return items.undo(snapshot);
      });

  Future<ItemWriteResult> _write(
    String itemId,
    Future<WriteResult> Function(ItemRepository items) write,
  ) async {
    if (state.contains(itemId)) return const ItemStale();
    state = {...state, itemId};
    try {
      return switch (await write(ref.read(itemRepositoryProvider))) {
        Written(:final undo) => ItemWritten(undo),
        Stale() => const ItemStale(),
      };
    } on StorageFailure {
      return const ItemNotWritten();
    } finally {
      if (ref.mounted) state = {...state}..remove(itemId);
    }
  }
}
