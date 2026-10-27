@Tags(['sqlcipher'])
library;

import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:yaadi/vault/vault_database.dart';
import 'package:yaadi/vault/vault_failure.dart';
import 'package:yaadi/vault/vault_files.dart';
import 'package:yaadi/vault/vault_setup.dart';

/// These run against the SQLCipher build the phones use. Until
/// ARCHITECTURE.md section 5.1 is approved the test host uses the operating
/// system's SQLite and they are skipped; CI sets YAADI_REQUIRE_SQLCIPHER=1
/// afterwards, which turns the skip into a failure.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('SQLCipher vault', () {
    late Directory directory;
    late VaultFiles files;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('yaadi_cipher_');
      files = VaultFiles(directory.path);
      await files.ensureDirectory();
    });

    tearDown(() => directory.delete(recursive: true));

    VaultDatabase open(String key) => VaultDatabase(
      NativeDatabase.createInBackground(
        files.database,
        setup: (raw) => applyVaultSetup(raw, key),
      ),
    );

    test('the file on disk is not plaintext', () async {
      final db = open('11' * 32);
      await db.customStatement(
        "INSERT INTO settings (key, value) VALUES ('probe', 'visible?')",
      );
      await db.close();

      expect(await files.hasPlaintextHeader(), isFalse);
      final bytes = await files.database.readAsBytes();
      expect(String.fromCharCodes(bytes).contains('visible?'), isFalse);
    });

    test('the same key opens it again; another key goes to Recovery', () async {
      final first = open('22' * 32);
      await first.customStatement(
        "INSERT INTO settings (key, value) VALUES ('language', 'ur')",
      );
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
  return 'needs the SQLCipher test library (ARCHITECTURE.md section 5.1)';
}
