import '../../../core/time/local_date.dart';
import '../domain/completion.dart';
import '../domain/item.dart';
import '../domain/item_change.dart';

/// Where items and their completions are kept: the encrypted vault on
/// phones, memory for the demo households, the browser session on the web.
///
/// Every implementation runs the same contract tests. Writes go through
/// [apply], which checks the caller's revision and applies the whole change
/// or nothing.
abstract interface class ItemRepository {
  /// Every item in [compareByDue] order, again after each write.
  Stream<List<Item>> watchAll();

  Future<Item?> find(String id);

  /// The item's history in [compareCompletions] order.
  Future<List<Completion>> completionsOf(String itemId);

  /// Completions for occurrences on [day], such as today's dose marks.
  Stream<List<Completion>> watchCompletionsOn(LocalDate day);

  /// Applies [change] if the stored item is still at
  /// `change.expectedRevision`, otherwise returns [Stale].
  ///
  /// Throws [ItemRejected] when `change.after` breaks an item rule.
  Future<WriteResult> apply(ItemChange change);
}

extension ItemRepositoryWrites on ItemRepository {
  Future<WriteResult> create(Item item) => apply(ItemChange.create(item));

  Future<WriteResult> update(Item edited) => apply(ItemChange.update(edited));

  Future<WriteResult> delete(Item item) => apply(ItemChange.delete(item));

  /// Reverses the write [snapshot] came from, unless the item has changed
  /// since.
  Future<WriteResult> undo(UndoSnapshot snapshot) => apply(snapshot.reversal);
}

/// Checks the parts of [change] every implementation must refuse before
/// touching storage.
void checkChange(ItemChange change) {
  final after = change.after;
  if (after != null) {
    if (after.id != change.itemId) {
      throw ArgumentError.value(after.id, 'change.after.id', 'Wrong item');
    }
    final violations = after.violations;
    if (violations.isNotEmpty) throw ItemRejected(violations);
  }
  for (final completion in change.addCompletions) {
    if (completion.itemId != change.itemId) {
      throw ArgumentError.value(
        completion.itemId,
        'change.addCompletions',
        'Completion belongs to another item',
      );
    }
  }
}

/// The revision [apply] writes for [change].
int nextRevision(ItemChange change) => switch (change.expectedRevision) {
  null => change.after!.revision,
  final expected => expected + 1,
};
