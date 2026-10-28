import 'package:meta/meta.dart';

import 'completion.dart';
import 'item.dart';

/// One atomic write to a single item and its completions.
///
/// The caller states the revision it read. If the stored item has moved on
/// since (another tap, an undo, an edit), the repository writes nothing and
/// returns [Stale]. This is what makes quick actions safe to double-tap.
@immutable
final class ItemChange {
  const ItemChange({
    required this.itemId,
    required this.expectedRevision,
    required this.after,
    this.addCompletions = const [],
    this.removeCompletionIds = const [],
  });

  /// Adds [item], which must not exist yet. Its revision is kept as given.
  factory ItemChange.create(Item item) =>
      ItemChange(itemId: item.id, expectedRevision: null, after: item);

  /// Replaces the stored item with [edited], provided the stored revision
  /// still equals `edited.revision`. The repository writes revision + 1.
  factory ItemChange.update(
    Item edited, {
    List<Completion> addCompletions = const [],
    List<String> removeCompletionIds = const [],
  }) => ItemChange(
    itemId: edited.id,
    expectedRevision: edited.revision,
    after: edited,
    addCompletions: addCompletions,
    removeCompletionIds: removeCompletionIds,
  );

  /// Deletes [item] and its completions if it is still at the revision the
  /// caller saw.
  factory ItemChange.delete(Item item) =>
      ItemChange(itemId: item.id, expectedRevision: item.revision, after: null);

  final String itemId;

  /// The revision the caller read, or null when the item must not exist.
  final int? expectedRevision;

  /// The item after the write, or null to delete it.
  final Item? after;

  final List<Completion> addCompletions;
  final List<String> removeCompletionIds;
}

/// Everything needed to put an item back the way it was before one write.
///
/// Undo applies [reversal], which only succeeds while the item is still at
/// [writtenRevision]; after any other write it is refused as [Stale].
@immutable
final class UndoSnapshot {
  const UndoSnapshot({
    required this.origin,
    required this.itemId,
    required this.before,
    required this.writtenRevision,
    this.added = const [],
    this.removed = const [],
  });

  /// The repository that made the write. An undo is only ever applied there:
  /// a demo item must not reappear in the vault because the user left the
  /// demo while its Undo was still on screen.
  final Object origin;

  final String itemId;

  /// The item before the write; null when the write created it.
  final Item? before;

  /// The revision the write produced; null when the write deleted the item.
  final int? writtenRevision;

  final List<Completion> added;
  final List<Completion> removed;

  /// One snapshot that undoes this write and [next], made on top of it,
  /// together: the item goes back to [before] and every completion either
  /// write added or removed is put back as it was.
  UndoSnapshot then(UndoSnapshot next) {
    if (!identical(next.origin, origin) || next.itemId != itemId) {
      throw ArgumentError.value(next.itemId, 'next', 'Another write');
    }
    final removedByNext = {for (final c in next.removed) c.id};
    final addedHere = {for (final c in added) c.id};
    return UndoSnapshot(
      origin: origin,
      itemId: itemId,
      before: before,
      writtenRevision: next.writtenRevision,
      added: [
        for (final completion in added)
          if (!removedByNext.contains(completion.id)) completion,
        ...next.added,
      ],
      removed: [
        ...removed,
        for (final completion in next.removed)
          if (!addedHere.contains(completion.id)) completion,
      ],
    );
  }

  ItemChange get reversal {
    final before = this.before;
    return ItemChange(
      itemId: itemId,
      expectedRevision: writtenRevision,
      // A re-inserted item keeps counting up, so snapshots taken before the
      // delete can never match it again.
      after: before != null && writtenRevision == null
          ? before.copyWith(revision: before.revision + 1)
          : before,
      addCompletions: removed,
      removeCompletionIds: [for (final completion in added) completion.id],
    );
  }

  @override
  String toString() =>
      'UndoSnapshot($itemId, before: $before, written: $writtenRevision, '
      '+${added.length}/-${removed.length} completions)';
}

/// The outcome of [ItemChange] or an undo.
sealed class WriteResult {
  const WriteResult();
}

final class Written extends WriteResult {
  const Written(this.undo);

  final UndoSnapshot undo;
}

/// Nothing was written: the item changed, appeared or disappeared since the
/// caller read it, or the occurrence was already completed.
final class Stale extends WriteResult {
  const Stale();
}

/// A write would break an [Item] rule. The editor validates first, so this
/// points at a bug rather than at user input.
final class ItemRejected implements Exception {
  const ItemRejected(this.violations);

  final Set<ItemViolation> violations;

  @override
  String toString() =>
      'ItemRejected(${violations.map((violation) => violation.name).join(', ')})';
}
