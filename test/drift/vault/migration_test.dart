import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:yaadi/features/items/domain/completion.dart';
import 'package:yaadi/features/items/domain/item_category.dart';
import 'package:yaadi/features/items/domain/item_kind.dart';
import 'package:yaadi/features/items/domain/item_status.dart';
import 'package:yaadi/vault/vault_database.dart';
import 'package:yaadi/vault/vault_failure.dart';

import 'generated/schema.dart';

/// Schema snapshots live in drift_schemas/vault/ and the test schemas in
/// generated/, both written by `dart run drift_dev make-migrations`. When a
/// version is added, every older version is migrated to every newer one
/// below; migrations that change existing data also get a data test here.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('the app creates exactly the latest snapshot', () async {
    final latest = GeneratedHelper.versions.last;
    final app = VaultDatabase(NativeDatabase.memory());
    addTearDown(app.close);
    expect(app.schemaVersion, latest);

    final schema = await verifier.schemaAt(latest);
    final db = VaultDatabase(schema.newConnection());
    addTearDown(db.close);
    await db.validateDatabaseSchema();
  });

  test('stored enum names change only with the schema version', () {
    // Rows keep these names, and an older build cannot read one it does not
    // know. A new value needs a new schema version, so that build stops at
    // "Update Yaadi" instead of failing to list any item.
    expect(
      GeneratedHelper.versions.last,
      1,
      reason: 'Pin the names below again for the new version',
    );
    expect(ItemKind.values.map((value) => value.name), [
      'bill',
      'appointment',
      'expiry',
      'medicine',
      'task',
    ]);
    expect(ItemCategory.values.map((value) => value.name), [
      'electricity',
      'gas',
      'water',
      'internet',
      'phone',
      'school',
      'rent',
      'health',
      'idDocument',
      'warranty',
      'other',
    ]);
    expect(ItemStatus.values.map((value) => value.name), [
      'open',
      'done',
      'paid',
    ]);
    expect(CompletionOutcome.values.map((value) => value.name), [
      'paid',
      'done',
      'skipped',
    ]);
  });

  group('upgrades', () {
    const versions = GeneratedHelper.versions;
    for (final (index, from) in versions.indexed) {
      for (final to in versions.skip(index + 1)) {
        test('from v$from to v$to', () async {
          final schema = await verifier.schemaAt(from);
          final db = VaultDatabase(schema.newConnection());
          addTearDown(db.close);
          await verifier.migrateAndValidate(db, to);
        });
      }
    }
  });

  test('a vault from a newer version is refused and left untouched', () async {
    final directory = await Directory.systemTemp.createTemp('yaadi_schema_');
    addTearDown(() => directory.delete(recursive: true));
    final file = File(p.join(directory.path, 'vault.sqlite'));

    final current = VaultDatabase(NativeDatabase(file));
    await current.customStatement(
      "INSERT INTO settings (key, value) VALUES ('language', 'ur')",
    );
    await current.customStatement('PRAGMA user_version = 99');
    await current.close();

    final old = VaultDatabase(NativeDatabase(file));
    Object? error;
    try {
      await old.customSelect('SELECT 1').get();
    } on Exception catch (caught) {
      error = caught;
    }
    await old.close();

    expect(vaultFailureFrom(error!).kind, VaultFailureKind.schemaTooNew);
    final raw = sqlite3.open(file.path);
    addTearDown(raw.close);
    expect(raw.select('PRAGMA user_version').single.values.single, 99);
    expect(raw.select('SELECT value FROM settings').single['value'], 'ur');
  });
}
