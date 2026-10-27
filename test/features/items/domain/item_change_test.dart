import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/features/items/domain/item_change.dart';

import '../../../support/items.dart';

void main() {
  test('update expects the revision the caller read', () {
    final change = ItemChange.update(bill().copyWith(revision: 4));
    expect(change.expectedRevision, 4);
    expect(change.after?.revision, 4);
  });

  test('create expects no item, delete expects the current revision', () {
    expect(ItemChange.create(bill()).expectedRevision, isNull);
    final delete = ItemChange.delete(bill().copyWith(revision: 3));
    expect(delete.expectedRevision, 3);
    expect(delete.after, isNull);
  });

  group('reversal', () {
    test('of an update restores the old item if nothing wrote since', () {
      final before = bill();
      final paid = completed(before.id);
      final undo = UndoSnapshot(
        origin: _repository,
        itemId: before.id,
        before: before,
        writtenRevision: 2,
        added: [paid],
      );
      final reversal = undo.reversal;
      expect(reversal.expectedRevision, 2);
      expect(reversal.after, before);
      expect(reversal.removeCompletionIds, [paid.id]);
      expect(reversal.addCompletions, isEmpty);
    });

    test('of a delete re-inserts at a higher revision with its history', () {
      final before = bill().copyWith(revision: 5);
      final history = [completed(before.id)];
      final undo = UndoSnapshot(
        origin: _repository,
        itemId: before.id,
        before: before,
        writtenRevision: null,
        removed: history,
      );
      final reversal = undo.reversal;
      expect(reversal.expectedRevision, isNull);
      expect(reversal.after?.revision, 6);
      expect(reversal.addCompletions, history);
    });

    test('of a create deletes the item', () {
      const undo = UndoSnapshot(
        origin: _repository,
        itemId: 'new',
        before: null,
        writtenRevision: 1,
      );
      expect(undo.reversal.after, isNull);
      expect(undo.reversal.expectedRevision, 1);
    });
  });

  test('snapshots and rejections print no personal details', () {
    final undo = UndoSnapshot(
      origin: _repository,
      itemId: 'x',
      before: bill(reference: '35202-1234567-1', notes: 'secret'),
      writtenRevision: 2,
    );
    expect(undo.toString(), isNot(contains('35202')));
    expect(undo.toString(), isNot(contains('secret')));
  });
}

/// Stands in for the repository that made the write.
const _repository = 'repository';
