@Tags(['sqlcipher'])
library;

import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:yaadi/core/platform/backup_exclusion.dart';
import 'package:yaadi/features/items/data/drift_item_repository.dart';
import 'package:yaadi/features/settings/data/settings_repository.dart';
import 'package:yaadi/vault/open_vault_native.dart';
import 'package:yaadi/vault/vault_database.dart';
import 'package:yaadi/vault/vault_failure.dart';
import 'package:yaadi/vault/vault_files.dart';
import 'package:yaadi/vault/vault_key_store.dart';
import 'package:yaadi/vault/vault_keys.dart';
import 'package:yaadi/vault/vault_opener.dart';

import '../fixtures/vault_fixture.dart';
import '../support/fake_key_store.dart';

/// Encryption at rest, on the SQLCipher build the sqlite3 hook fetches for
/// tests and phones alike (ARCHITECTURE.md section 5.1). Nothing here skips:
/// without SQLCipher every test fails, and CI runs this tag on its own.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('the sqlite3 hook loaded SQLCipher 4', () {
    final db = sqlite3.openInMemory();
    addTearDown(db.close);
    expect(_single(db, 'PRAGMA cipher_version'), startsWith('4.'));
    db.execute("PRAGMA key = \"x'${'55' * 32}'\"");
    // The Windows, Linux and Android builds link OpenSSL.
    expect(_single(db, 'PRAGMA cipher_provider'), 'openssl');
  });

  late Directory directory;
  late VaultFiles files;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('yaadi_cipher_');
    files = VaultFiles(directory.path);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => directory.path,
        );
  });

  tearDown(() async {
    try {
      await directory.delete(recursive: true);
    } on FileSystemException {
      // Windows may still hold the file for a moment.
    }
  });

  VaultDatabase open(String key) =>
      openSqlCipherVault(files, key, backupExclusion: const _NoExclusion());

  group('SQLCipher vault', () {
    test('the file and its WAL are never plaintext', () async {
      final key = '11' * 32;
      final db = open(key);
      await db.customStatement(
        "INSERT INTO settings (key, value) VALUES ('probe', 'visible?')",
      );
      // While open, the row sits in the WAL.
      final wal = File('${files.database.path}-wal');
      expect(wal.existsSync(), isTrue);
      expect(_contains(wal, 'visible?'), isFalse);
      await db.close();

      expect(await files.hasPlaintextHeader(), isFalse);
      for (final text in ['SQLite format 3', 'visible?', 'CREATE TABLE', key]) {
        expect(_contains(files.database, text), isFalse, reason: text);
      }
    });

    test('without the key the file is not a database', () async {
      final db = open('44' * 32);
      await db.customStatement(
        "INSERT INTO settings (key, value) VALUES ('language', 'ur')",
      );
      await db.close();

      final raw = sqlite3.open(files.database.path);
      addTearDown(raw.close);
      expect(
        () => raw.select('SELECT count(*) FROM sqlite_master'),
        throwsA(
          isA<SqliteException>().having(
            (error) => error.resultCode,
            'resultCode',
            26,
          ),
        ),
      );
    });

    test('the same key opens it again; another key goes to Recovery', () async {
      final first = open('22' * 32);
      await first.customStatement(
        "INSERT INTO settings (key, value) VALUES ('language', 'ur')",
      );
      final version = await first
          .customSelect('PRAGMA cipher_version')
          .getSingle();
      expect(version.data.values.single.toString(), startsWith('4.'));
      await first.close();

      final again = open('22' * 32);
      expect(await again.select(again.settingsEntries).get(), hasLength(1));
      await again.close();

      final wrongKey = '33' * 32;
      final failure = await _openFailure(open(wrongKey));
      expect(failure.kind, VaultFailureKind.wrongKeyOrCorrupt);
      expect(failure.resultCode! & 0xFF, 26);
      expect(failure.toString(), isNot(contains(wrongKey)));
    });

    test(
      'a plaintext file at the vault path goes to Recovery, untouched',
      () async {
        await files.ensureDirectory();
        sqlite3.open(files.database.path)
          ..execute('CREATE TABLE notes (body TEXT)')
          ..execute("INSERT INTO notes VALUES ('plain')")
          ..close();
        final before = files.database.readAsBytesSync();

        final failure = await _openFailure(open('66' * 32));

        // SQLITE_NOTADB covers a wrong key, a damaged file and plaintext.
        expect(failure.kind, VaultFailureKind.wrongKeyOrCorrupt);
        expect(files.database.readAsBytesSync(), before);
      },
    );
  });

  group('committed fixture (ARCHITECTURE.md section 5.4)', () {
    Future<void> copyFixture() async {
      await files.ensureDirectory();
      File(vaultFixtureV1).copySync(files.database.path);
    }

    test('is ciphertext from its first byte', () {
      final fixture = File(vaultFixtureV1);
      expect(fixture.lengthSync() % 4096, 0);
      for (final text in vaultFixturePlaintext) {
        expect(_contains(fixture, text), isFalse, reason: text);
      }
    });

    test('opens through the startup path with its stored key', () async {
      await copyFixture();
      final keys = FakeVaultKeyStore(vaultFixtureKey);
      final opener = VaultOpener(
        keys: keys,
        files: files,
        connect: (key) async => open(key),
      );

      final db = await opener.open();
      try {
        final version = await db
            .customSelect('PRAGMA user_version')
            .getSingle();
        expect(version.data.values.single, vaultFixtureSchemaVersion);
        final items = DriftItemRepository(db);
        expect(await items.readAll(), unorderedEquals(vaultFixtureItems));
        expect(await items.completionsOf(vaultFixtureBill.id), [
          vaultFixtureBillPayment,
        ]);
        expect(
          await DriftSettingsRepository(db).readAll(),
          vaultFixtureSettings,
        );
      } finally {
        await db.close();
      }
      expect(keys.writes, 0);
      expect(keys.deletes, 0);
    });

    test('without its key or with another, it goes to Recovery', () async {
      await copyFixture();
      final before = files.database.readAsBytesSync();
      final keys = FakeVaultKeyStore();
      final opener = VaultOpener(
        keys: keys,
        files: files,
        connect: (key) async => open(key),
      );

      expect(
        (await _startupFailure(opener.open())).kind,
        VaultFailureKind.keyMissing,
      );

      final other = VaultKeyRecord(List.filled(32, 7));
      keys.stored = other;
      final failure = await _startupFailure(opener.open());
      expect(failure.kind, VaultFailureKind.wrongKeyOrCorrupt);
      expect(failure.toString(), isNot(contains(deriveDatabaseKey(other))));

      // Neither path rewrites or deletes the vault or the stored key.
      expect(files.database.readAsBytesSync(), before);
      expect(keys.stored, other);
      expect(keys.deletes, 0);
    });
  });
}

final class _NoExclusion implements BackupExclusion {
  const _NoExclusion();

  @override
  Future<void> exclude(String directoryPath) async {}
}

Object? _single(Database db, String sql) => db.select(sql).single.values.single;

bool _contains(File file, String text) =>
    file.existsSync() &&
    String.fromCharCodes(file.readAsBytesSync()).contains(text);

/// What a direct open of [db] fails with; Drift opens lazily, on the first
/// statement.
Future<VaultOpenFailure> _openFailure(VaultDatabase db) async {
  try {
    await db.customSelect('SELECT 1').get();
  } on Exception catch (error) {
    return vaultFailureFrom(error);
  } finally {
    try {
      await db.close();
    } on Exception {
      // The connection never opened.
    }
  }
  fail('Expected the vault not to open');
}

/// What a startup through [VaultOpener.open] fails with.
Future<VaultOpenFailure> _startupFailure(Future<VaultDatabase> open) async {
  try {
    final db = await open;
    await db.close();
  } on VaultOpenFailure catch (failure) {
    return failure;
  }
  fail('Expected the vault not to open');
}
