import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/platform/backup_exclusion.dart';
import 'package:yaadi/features/items/data/drift_item_repository.dart';
import 'package:yaadi/features/items/data/item_repository.dart';
import 'package:yaadi/features/items/domain/item_change.dart';
import 'package:yaadi/features/settings/data/settings_repository.dart';
import 'package:yaadi/vault/open_vault_native.dart';
import 'package:yaadi/vault/vault_files.dart';
import 'package:yaadi/vault/vault_keys.dart';

import 'vault_fixture.dart';

/// Writes the committed SQLCipher fixture once, through the production open
/// path. It is not a test (the name has no `_test`), so `flutter test` never
/// runs it; run it by hand with the SQLCipher build of the sqlite3 hook:
///
///     flutter test test/fixtures/make_vault_fixture.dart
///
/// It refuses to replace an existing fixture: reading old files is the point.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('write $vaultFixtureV1', () async {
    final target = File(vaultFixtureV1);
    if (target.existsSync()) {
      fail(
        '$vaultFixtureV1 exists. Fixtures are never regenerated; '
        'a new schema version gets a new fixture.',
      );
    }

    final temp = await Directory.systemTemp.createTemp('yaadi_fixture_');
    addTearDown(() => temp.delete(recursive: true));
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => temp.path,
        );
    final files = VaultFiles(temp.path);

    final db = openSqlCipherVault(
      files,
      deriveDatabaseKey(vaultFixtureKey),
      backupExclusion: const _NoExclusion(),
    );
    final items = DriftItemRepository(db);
    await items.create(vaultFixtureBill);
    await items.create(vaultFixtureMedicine);
    await items.create(vaultFixtureTask);
    await items.apply(
      ItemChange.update(
        vaultFixtureBill,
        addCompletions: [vaultFixtureBillPayment],
      ),
    );
    final settings = DriftSettingsRepository(db);
    for (final MapEntry(:key, :value) in vaultFixtureSettings.entries) {
      await settings.write(key, value);
    }
    expect(await items.readAll(), unorderedEquals(vaultFixtureItems));

    // One self-contained file: everything checkpointed out of the WAL.
    await db.customSelect('PRAGMA wal_checkpoint(TRUNCATE)').get();
    await db.close();
    final wal = File('${files.database.path}-wal');
    expect(wal.existsSync() ? wal.lengthSync() : 0, 0);
    expect(await files.hasPlaintextHeader(), isFalse);

    target.parent.createSync(recursive: true);
    files.database.copySync(target.path);
  });
}

final class _NoExclusion implements BackupExclusion {
  const _NoExclusion();

  @override
  Future<void> exclude(String directoryPath) async {}
}
