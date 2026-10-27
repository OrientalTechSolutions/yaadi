import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:yaadi/core/storage/storage_failure.dart';
import 'package:yaadi/features/items/data/drift_item_repository.dart';
import 'package:yaadi/features/items/data/item_repository.dart';
import 'package:yaadi/vault/vault_database.dart';

import '../../../support/items.dart';
import 'item_repository_contract.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  final databases = <VaultDatabase>[];
  runItemRepositoryContract(
    () async {
      final db = VaultDatabase(NativeDatabase.memory());
      databases.add(db);
      return DriftItemRepository(db);
    },
    tearDown: () async {
      for (final db in databases) {
        await db.close();
      }
    },
  );

  group('vault constraints', () {
    late VaultDatabase db;

    setUp(() => db = VaultDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    Future<void> insertItem(
      String columns,
      String values,
    ) => db.customStatement(
      'INSERT INTO items (id, kind, title, category, amount_is_fixed, status, '
      'created_at, updated_at$columns) '
      "VALUES ('x', 'bill', 'Bill', 'electricity', 0, 'open', 0, 0$values)",
    );

    const checkFailure = 275; // SQLITE_CONSTRAINT_CHECK

    Future<int?> codeOf(Future<void> statement) async {
      try {
        await statement;
        return null;
      } on Exception catch (error) {
        return sqliteResultCode(error);
      }
    }

    const dated = ', due_on, scheduled_on';
    const datedValues = ", '2026-11-10', '2026-11-10'";

    test('a valid minimal row is accepted', () async {
      await insertItem(dated, datedValues);
      expect(await db.select(db.items).get(), hasLength(1));
    });

    final rejected = {
      'amount without currency': ('$dated, amount_minor', '$datedValues, 100'),
      'negative amount': (
        '$dated, amount_minor, currency',
        "$datedValues, -1, 'PKR'",
      ),
      'lowercase currency': (
        '$dated, amount_minor, currency',
        "$datedValues, 1, 'pkr'",
      ),
      'bill without a date': ('', ''),
      'due date without schedule': (', due_on', ", '2026-11-10'"),
      'date in another format': (dated, ", '10/11/2026', '10/11/2026'"),
      'minute out of range': ('$dated, due_minute', '$datedValues, 1440'),
      'open with a completion time': (
        '$dated, completed_at',
        '$datedValues, 5',
      ),
      'revision zero': ('$dated, revision', '$datedValues, 0'),
      'empty notes': ('$dated, notes', "$datedValues, ''"),
    };
    for (final MapEntry(key: name, value: (columns, values))
        in rejected.entries) {
      test('rejects $name', () async {
        expect(await codeOf(insertItem(columns, values)), checkFailure);
      });
    }

    test(
      'rejects a repeat without a date and doses on anything else',
      () async {
        Future<void> insert(String kind, String columns, String values) =>
            db.customStatement(
              'INSERT INTO items (id, kind, title, category, amount_is_fixed, '
              'status, created_at, updated_at$columns) '
              "VALUES ('y', '$kind', 'Item', 'other', 0, 'open', 0, 0$values)",
            );
        const daily = r""", '{"type":"daily"}'""";
        const doses = r""", '{"type":"doses","minutes":[480]}'""";

        expect(
          await codeOf(insert('task', ', recurrence', daily)),
          checkFailure,
        );
        expect(
          await codeOf(
            insert('task', '$dated, recurrence', '$datedValues$doses'),
          ),
          checkFailure,
        );
        await insert('medicine', '$dated, recurrence', '$datedValues$doses');
        await db.customStatement('DELETE FROM items');
        // An undated one-off task is fine.
        await insert('task', '', '');
        expect(await db.select(db.items).get(), hasLength(1));
      },
    );

    test(
      'one untimed completion per occurrence, despite NULL minutes',
      () async {
        await insertItem(dated, datedValues);
        Future<void> complete(String id) => db.customStatement(
          'INSERT INTO completions (id, item_id, occurrence_on, outcome, recorded_at) '
          "VALUES ('$id', 'x', '2026-11-10', 'paid', 0)",
        );
        await complete('a');
        expect(isUniqueViolation(await _errorOf(complete('b'))), isTrue);
      },
    );

    test('deleting an item deletes its completions', () async {
      await insertItem(dated, datedValues);
      await db.customStatement(
        'INSERT INTO completions (id, item_id, occurrence_on, outcome, recorded_at) '
        "VALUES ('a', 'x', '2026-11-10', 'paid', 0)",
      );
      await db.customStatement("DELETE FROM items WHERE id = 'x'");
      expect(await db.select(db.completions).get(), isEmpty);
    });
  });

  test('a delete leaves nothing of the item in the WAL', () async {
    final directory = await Directory.systemTemp.createTemp('yaadi_wal_');
    addTearDown(() async {
      try {
        await directory.delete(recursive: true);
      } on FileSystemException {
        // Windows may still hold the file for a moment.
      }
    });
    final file = File(p.join(directory.path, 'vault.sqlite'));
    // The vault's own settings, as in applyVaultSetup, minus the cipher.
    final db = VaultDatabase(
      NativeDatabase(
        file,
        setup: (raw) => raw
          ..execute('PRAGMA secure_delete = ON')
          ..execute('PRAGMA journal_mode = WAL'),
      ),
    );
    final repository = DriftItemRepository(db);

    await repository.create(item('gone', notes: 'gone-notes'));
    final wal = File('${file.path}-wal');
    expect(wal.lengthSync(), greaterThan(0));
    await repository.delete((await repository.find('gone'))!);

    expect(wal.existsSync() ? wal.lengthSync() : 0, 0);
    expect(_contains(file, 'gone-notes'), isFalse);
    await db.close();
  });

  test('storage failures keep the result code and drop the statement', () async {
    final db = VaultDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    const reference = '35202-1234567-1';
    final error = await _errorOf(
      db.customStatement(
        'INSERT INTO items (id, kind, title, category, amount_is_fixed, status, '
        'created_at, updated_at, reference) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        ['x', 'bill', 'Bill', 'electricity', 0, 'open', 0, 0, reference],
      ),
    );

    // The driver's own message would leak the bound reference into logs.
    expect(unwrapDatabaseError(error), isA<SqliteException>());
    expect(unwrapDatabaseError(error).toString(), contains(reference));

    final failure = storageFailureFrom(error);
    expect(failure.resultCode, 275);
    expect(failure.toString(), isNot(contains(reference)));
  });
}

bool _contains(File file, String text) =>
    String.fromCharCodes(file.readAsBytesSync()).contains(text);

Future<Object> _errorOf(Future<void> statement) async {
  try {
    await statement;
  } on Exception catch (error) {
    return error;
  }
  fail('Expected the statement to fail');
}
