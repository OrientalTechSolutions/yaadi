import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/platform/session_store.dart';
import 'package:yaadi/core/platform/session_store_memory.dart';
import 'package:yaadi/features/items/data/item_json.dart';
import 'package:yaadi/features/items/data/item_repository.dart';
import 'package:yaadi/features/items/data/session_item_repository.dart';
import 'package:yaadi/features/items/domain/item_change.dart';

import '../../../support/items.dart';
import 'item_repository_contract.dart';

/// A browser that refuses to store anything: Safari private mode, blocked
/// site data, or a full quota.
final class RefusingSessionStore implements SessionStore {
  var _failed = false;

  @override
  String? read(String key) => null;

  @override
  bool write(String key, String value) {
    _failed = true;
    return false;
  }

  @override
  void remove(String key) {}

  @override
  bool get hasFailedWrites => _failed;
}

void main() {
  group('with a working session', () {
    runItemRepositoryContract(
      () async => sessionItemRepository(MemorySessionStore()),
    );
  });

  group('with a session that refuses writes', () {
    runItemRepositoryContract(
      () async => sessionItemRepository(RefusingSessionStore()),
    );
  });

  test('a reload brings back items and history', () async {
    final store = MemorySessionStore();
    final first = sessionItemRepository(store);
    await first.create(bill(notes: 'Pay online', reference: '0712345678'));
    await first.create(medicine());
    await first.apply(
      ItemChange.update(
        medicine(),
        addCompletions: [completed('med-1', minute: 480)],
      ),
    );

    final reloaded = sessionItemRepository(store);
    expect(
      await reloaded.find('bill-1'),
      bill(notes: 'Pay online', reference: '0712345678'),
    );
    expect((await reloaded.find('med-1'))?.revision, 2);
    expect(await reloaded.completionsOf('med-1'), [
      completed('med-1', minute: 480),
    ]);
  });

  test('a refusing browser keeps the demo working and says so', () async {
    final store = RefusingSessionStore();
    final repository = sessionItemRepository(store);
    await repository.create(bill());
    expect(await repository.find('bill-1'), isNotNull);
    expect(store.hasFailedWrites, isTrue);
  });

  test('damaged session data costs only the damaged entries', () async {
    final store = MemorySessionStore()
      ..write(sessionItemsKey, 'not json at all');
    expect(await sessionItemRepository(store).watchAll().first, isEmpty);

    store.write(
      sessionItemsKey,
      jsonEncode({
        'items': [
          itemToJson(bill()),
          {'id': 7},
          itemToJson(bill(id: 'bad').copyWith(title: '')),
        ],
        'completions': [
          {'id': 'orphan', 'item_id': 'missing'},
          completionToJson(completed('gone-item')),
        ],
      }),
    );
    final reloaded = sessionItemRepository(store);
    expect((await reloaded.watchAll().first).map((item) => item.id), [
      'bill-1',
    ]);
    expect(await reloaded.completionsOf('gone-item'), isEmpty);
  });

  test('item and completion JSON round-trip', () {
    final item = bill(dueMinute: 600, notes: 'n', reference: 'r');
    expect(itemFromJson(itemToJson(item)), item);
    final done = completed('bill-1', minute: 30);
    expect(completionFromJson(completionToJson(done)), done);
  });
}
