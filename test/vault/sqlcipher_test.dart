@Tags(['sqlcipher'])
library;

import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:yaadi/core/platform/backup_exclusion.dart';
import 'package:yaadi/vault/open_vault_native.dart';
import 'package:yaadi/vault/vault_database.dart';
import 'package:yaadi/vault/vault_failure.dart';
import 'package:yaadi/vault/vault_files.dart';

/// The production open path against the SQLCipher build phones use. M1
/// tests run on the system SQLite, where these skip; once the hook builds
/// SQLCipher (ARCHITECTURE.md section 5.1) CI sets YAADI_REQUIRE_SQLCIPHER=1
/// and a skip becomes a failure.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('SQLCipher vault', () {
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

    tearDown(() => directory.delete(recursive: true));

    VaultDatabase open(String key) =>
        openSqlCipherVault(files, key, backupExclusion: _NoExclusion());

    bool contains(File file, String text) =>
        file.existsSync() &&
        String.fromCharCodes(file.readAsBytesSync()).contains(text);

    test('the file and its WAL are never plaintext', () async {
      final db = open('11' * 32);
      await db.customStatement(
        "INSERT INTO settings (key, value) VALUES ('probe', 'visible?')",
      );
      // While open, the row sits in the WAL.
      expect(contains(File('${files.database.path}-wal'), 'visible?'), isFalse);
      await db.close();

      expect(await files.hasPlaintextHeader(), isFalse);
      expect(contains(files.database, 'visible?'), isFalse);
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

      final wrong = open('33' * 32);
      Object? error;
      try {
        await wrong.customSelect('SELECT 1').get();
      } on Exception catch (caught) {
        error = caught;
      }
      try {
        await wrong.close();
      } on Exception {
        // The connection never opened.
      }
      expect(vaultFailureFrom(error!).kind, VaultFailureKind.wrongKeyOrCorrupt);
    });
  }, skip: _skipReason());
}

final class _NoExclusion implements BackupExclusion {
  @override
  Future<void> exclude(String directoryPath) async {}
}

final _requireCipher = Platform.environment['YAADI_REQUIRE_SQLCIPHER'] == '1';

final bool _cipherAvailable = () {
  final db = sqlite3.openInMemory();
  try {
    return db.select('PRAGMA cipher_version').isNotEmpty;
  } finally {
    db.close();
  }
}();

Object? _skipReason() {
  if (_cipherAvailable || _requireCipher) return false;
  return 'runs on the SQLCipher build of the sqlite3 hook '
      '(ARCHITECTURE.md section 5.1)';
}
