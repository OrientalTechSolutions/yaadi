import 'dart:async';

import 'package:drift/drift.dart';

import '../../../core/money/money.dart';
import '../../../core/storage/storage_failure.dart';
import '../../../core/time/local_date.dart';
import '../../../vault/vault_database.dart';
import '../domain/completion.dart';
import '../domain/item.dart';
import '../domain/item_change.dart';
import 'item_repository.dart';

/// Items in the encrypted vault.
///
/// Errors leave as [StorageFailure], which keeps SQLite's result code and
/// nothing else (ARCHITECTURE.md section 9).
final class DriftItemRepository implements ItemRepository {
  DriftItemRepository(this._db);

  final VaultDatabase _db;

  @override
  Stream<List<Item>> watchAll() => _db
      .select(_db.items)
      .watch()
      .map((rows) => rows.map(_toItem).toList()..sort(compareByDue))
      .transform(_asStorageFailures());

  @override
  Future<List<Item>> readAll() => _guard(() async {
    final rows = await _db.select(_db.items).get();
    return rows.map(_toItem).toList()..sort(compareByDue);
  });

  @override
  Future<Item?> find(String id) => _guard(() async {
    final row = await _findRow(id);
    return row == null ? null : _toItem(row);
  });

  @override
  Future<List<Completion>> completionsOf(String itemId) =>
      _guard(() => _completionsOf(itemId));

  @override
  Stream<List<Completion>> watchCompletionsOn(LocalDate day) {
    final query = _db.select(_db.completions)
      ..where((c) => c.occurrenceOn.equalsValue(day));
    return query
        .watch()
        .map(
          (rows) => rows.map(_toCompletion).toList()..sort(compareCompletions),
        )
        .transform(_asStorageFailures());
  }

  @override
  Future<WriteResult> apply(ItemChange change) async {
    checkChange(change);
    final WriteResult result;
    try {
      result = await _db.transaction(() => _applyInTransaction(change));
    } on _StaleWrite {
      return const Stale();
    } on Exception catch (error) {
      // The unique completions index backs up the explicit check below.
      if (isUniqueViolation(error)) return const Stale();
      throw storageFailureFrom(error);
    }
    if (result is Written && change.after == null) await _truncateWal();
    return result;
  }

  /// `secure_delete` clears freed pages, but the WAL still holds the deleted
  /// rows until a checkpoint copies it back and truncates it. Undo restores
  /// from the snapshot in memory, so there is no reason to wait.
  Future<void> _truncateWal() async {
    try {
      await _db.customSelect('PRAGMA wal_checkpoint(TRUNCATE)').get();
    } on Exception {
      // A reader still holds old frames; the next checkpoint removes them.
    }
  }

  Future<WriteResult> _applyInTransaction(ItemChange change) async {
    final currentRow = await _findRow(change.itemId);
    final current = currentRow == null ? null : _toItem(currentRow);
    if (current?.revision != change.expectedRevision) return const Stale();

    final after = change.after;
    if (after == null) {
      final removed = await _completionsOf(change.itemId);
      await (_db.delete(
        _db.items,
      )..where((t) => t.id.equals(change.itemId))).go();
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

    final revision = nextRevision(change);
    final row = _toCompanion(after.copyWith(revision: revision));
    if (current == null) {
      await _db.into(_db.items).insert(row);
    } else {
      await _db.update(_db.items).replace(row);
    }

    final removed = <Completion>[];
    for (final id in change.removeCompletionIds) {
      final query = _db.select(_db.completions)
        ..where((c) => c.id.equals(id) & c.itemId.equals(change.itemId));
      final completion = await query.getSingleOrNull();
      if (completion == null) throw const _StaleWrite();
      removed.add(_toCompletion(completion));
      await (_db.delete(_db.completions)..where((c) => c.id.equals(id))).go();
    }

    for (final completion in change.addCompletions) {
      if (await _occurrenceRecorded(completion)) throw const _StaleWrite();
      await _db
          .into(_db.completions)
          .insert(_toCompletionCompanion(completion));
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

  Future<ItemRow?> _findRow(String id) =>
      (_db.select(_db.items)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<Completion>> _completionsOf(String itemId) async {
    final query = _db.select(_db.completions)
      ..where((c) => c.itemId.equals(itemId));
    final rows = await query.get();
    return rows.map(_toCompletion).toList()..sort(compareCompletions);
  }

  Future<bool> _occurrenceRecorded(Completion completion) async {
    final minute = completion.occurrenceMinute;
    final query = _db.selectOnly(_db.completions)
      ..addColumns([_db.completions.id])
      ..where(
        _db.completions.itemId.equals(completion.itemId) &
            _db.completions.occurrenceOn.equalsValue(completion.occurrenceOn) &
            (minute == null
                ? _db.completions.occurrenceMinute.isNull()
                : _db.completions.occurrenceMinute.equals(minute)),
      )
      ..limit(1);
    return (await query.get()).isNotEmpty;
  }

  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on Exception catch (error) {
      throw storageFailureFrom(error);
    }
  }
}

/// Rolls back a transaction that found the item or an occurrence changed.
final class _StaleWrite implements Exception {
  const _StaleWrite();
}

StreamTransformer<T, T> _asStorageFailures<T>() =>
    StreamTransformer.fromHandlers(
      handleError: (error, stackTrace, sink) =>
          sink.addError(storageFailureFrom(error), stackTrace),
    );

Item _toItem(ItemRow row) => Item(
  id: row.id,
  kind: row.kind,
  title: row.title,
  category: row.category,
  amount: _money(row.amountMinor, row.currency),
  amountIsFixed: row.amountIsFixed,
  scheduledOn: row.scheduledOn,
  dueOn: row.dueOn,
  dueMinute: row.dueMinute,
  recurrence: row.recurrence,
  notes: row.notes,
  reference: row.reference,
  status: row.status,
  snoozedUntil: row.snoozedUntil,
  completedAt: _instantOrNull(row.completedAt),
  revision: row.revision,
  createdAt: _instant(row.createdAt),
  updatedAt: _instant(row.updatedAt),
);

ItemsCompanion _toCompanion(Item item) => ItemsCompanion.insert(
  id: item.id,
  kind: item.kind,
  title: item.title,
  category: item.category,
  amountMinor: Value(item.amount?.minorUnits),
  currency: Value(item.amount?.currency),
  amountIsFixed: item.amountIsFixed,
  scheduledOn: Value(item.scheduledOn),
  dueOn: Value(item.dueOn),
  dueMinute: Value(item.dueMinute),
  recurrence: Value(item.recurrence),
  notes: Value(item.notes),
  reference: Value(item.reference),
  status: item.status,
  snoozedUntil: Value(item.snoozedUntil),
  completedAt: Value(item.completedAt?.millisecondsSinceEpoch),
  revision: Value(item.revision),
  createdAt: item.createdAt.millisecondsSinceEpoch,
  updatedAt: item.updatedAt.millisecondsSinceEpoch,
);

Completion _toCompletion(CompletionRow row) => Completion(
  id: row.id,
  itemId: row.itemId,
  occurrenceOn: row.occurrenceOn,
  occurrenceMinute: row.occurrenceMinute,
  outcome: row.outcome,
  amount: _money(row.amountMinor, row.currency),
  recordedAt: _instant(row.recordedAt),
);

CompletionsCompanion _toCompletionCompanion(Completion completion) =>
    CompletionsCompanion.insert(
      id: completion.id,
      itemId: completion.itemId,
      occurrenceOn: completion.occurrenceOn,
      occurrenceMinute: Value(completion.occurrenceMinute),
      outcome: completion.outcome,
      amountMinor: Value(completion.amount?.minorUnits),
      currency: Value(completion.amount?.currency),
      recordedAt: completion.recordedAt.millisecondsSinceEpoch,
    );

Money? _money(int? minorUnits, String? currency) =>
    minorUnits == null || currency == null ? null : Money(minorUnits, currency);

DateTime _instant(int millis) =>
    DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);

DateTime? _instantOrNull(int? millis) =>
    millis == null ? null : _instant(millis);
