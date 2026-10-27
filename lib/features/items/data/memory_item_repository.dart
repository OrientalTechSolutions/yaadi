import 'dart:async';

import '../../../core/time/local_date.dart';
import '../domain/completion.dart';
import '../domain/item.dart';
import '../domain/item_change.dart';
import 'item_repository.dart';

/// Called after every successful write with the full contents.
typedef MemoryItemsListener = void Function(
  List<Item> items,
  List<Completion> completions,
);

/// Items held in memory: the demo households, and the web demo once its
/// contents are saved to the browser session after each write.
///
/// Follows the same contract as the vault, including revision checks and
/// one completion per occurrence.
final class MemoryItemRepository implements ItemRepository {
  MemoryItemRepository({
    Iterable<Item> items = const [],
    Iterable<Completion> completions = const [],
    this.onChanged,
  }) {
    for (final item in items) {
      _items[item.id] = item;
    }
    for (final completion in completions) {
      _completions[completion.id] = completion;
    }
  }

  final MemoryItemsListener? onChanged;

  final _items = <String, Item>{};
  final _completions = <String, Completion>{};
  final _changes = StreamController<void>.broadcast();

  @override
  Stream<List<Item>> watchAll() => _watch(_sortedItems);

  @override
  Future<List<Item>> readAll() async => _sortedItems();

  @override
  Future<Item?> find(String id) async => _items[id];

  @override
  Future<List<Completion>> completionsOf(String itemId) async =>
      _completionsOf(itemId);

  @override
  Stream<List<Completion>> watchCompletionsOn(LocalDate day) => _watch(
    () => [
      for (final completion in _completions.values)
        if (completion.occurrenceOn == day) completion,
    ]..sort(compareCompletions),
  );

  @override
  Future<WriteResult> apply(ItemChange change) async {
    checkChange(change);
    final result = _applyNow(change);
    if (result is Written) {
      _changes.add(null);
      onChanged?.call(_sortedItems(), _completions.values.toList());
    }
    return result;
  }

  /// Checks everything before changing anything, so a refused change leaves
  /// no trace, just like a rolled-back transaction.
  WriteResult _applyNow(ItemChange change) {
    final current = _items[change.itemId];
    if (current?.revision != change.expectedRevision) return const Stale();

    final after = change.after;
    if (after == null) {
      final removed = _completionsOf(change.itemId);
      _items.remove(change.itemId);
      for (final completion in removed) {
        _completions.remove(completion.id);
      }
      return Written(
        UndoSnapshot(
          origin: this,
          itemId: change.itemId,
          before: current,
          writtenRevision: null,
          removed: removed,
        ),
      );
    }

    final removed = <Completion>[];
    for (final id in change.removeCompletionIds) {
      final completion = _completions[id];
      if (completion == null || completion.itemId != change.itemId) {
        return const Stale();
      }
      removed.add(completion);
    }

    final removedIds = {for (final completion in removed) completion.id};
    final remaining = [
      for (final completion in _completions.values)
        if (!removedIds.contains(completion.id)) completion,
    ];
    final takenIds = {for (final completion in remaining) completion.id};
    final takenOccurrences = {
      for (final completion in remaining) completion.occurrenceKey,
    };
    for (final completion in change.addCompletions) {
      if (!takenIds.add(completion.id) ||
          !takenOccurrences.add(completion.occurrenceKey)) {
        return const Stale();
      }
    }

    final revision = nextRevision(change);
    _items[change.itemId] = after.copyWith(revision: revision);
    for (final id in removedIds) {
      _completions.remove(id);
    }
    for (final completion in change.addCompletions) {
      _completions[completion.id] = completion;
    }
    return Written(
      UndoSnapshot(
        origin: this,
        itemId: change.itemId,
        before: current,
        writtenRevision: revision,
        added: change.addCompletions,
        removed: removed,
      ),
    );
  }

  List<Item> _sortedItems() => _items.values.toList()..sort(compareByDue);

  List<Completion> _completionsOf(String itemId) => [
    for (final completion in _completions.values)
      if (completion.itemId == itemId) completion,
  ]..sort(compareCompletions);

  /// Emits [read] on listen and after every write, like a Drift query.
  Stream<T> _watch<T>(T Function() read) {
    late final StreamController<T> controller;
    StreamSubscription<void>? changes;
    controller = StreamController<T>(
      onListen: () {
        controller.add(read());
        changes = _changes.stream.listen((_) => controller.add(read()));
      },
      onCancel: () => changes?.cancel(),
    );
    return controller.stream;
  }
}
