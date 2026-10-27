@Tags(['sqlcipher'])
library;

import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/platform/backup_exclusion.dart';
import 'package:yaadi/features/settings/data/settings_repository.dart';
import 'package:yaadi/vault/open_vault_native.dart';
import 'package:yaadi/vault/vault_database.dart';
import 'package:yaadi/vault/vault_files.dart';
import 'package:yaadi/vault/vault_keys.dart';
import 'package:yaadi/vault/vault_opener.dart';

import '../support/fake_key_store.dart';

/// The open path phones use, end to end on the SQLCipher build: drift_flutter's
/// background isolate, the key handed to `setup`, the vault directory and the
/// backup exclusion. A build without SQLCipher is refused in
/// vault_setup_test.dart; encryption itself is in sqlcipher_test.dart.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late Directory temp;
  late VaultFiles files;
  late _RecordingExclusion exclusion;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('yaadi_open_');
    files = VaultFiles(temp.path);
    exclusion = _RecordingExclusion();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => temp.path,
        );
  });

  tearDown(() async {
    try {
      await temp.delete(recursive: true);
    } on FileSystemException {
      // Windows may still hold the file for a moment.
    }
  });

  Future<Object?> pragma(VaultDatabase db, String name) async =>
      (await db.customSelect('PRAGMA $name').getSingle()).data.values.single;

  test('the production open applies every vault setting', () async {
    final db = openSqlCipherVault(files, 'ab' * 32, backupExclusion: exclusion);
    try {
      expect(await pragma(db, 'cipher_version'), startsWith('4.'));
      expect(await pragma(db, 'journal_mode'), 'wal');
      expect(await pragma(db, 'foreign_keys'), 1);
      expect(await pragma(db, 'secure_delete'), 1);
      expect(await pragma(db, 'temp_store'), 2);
      expect(await pragma(db, 'busy_timeout'), 5000);
    } finally {
      await db.close();
    }

    // The vault directory was set up, and kept out of backups, first.
    expect(exclusion.directories, [files.directory.path]);
    expect(await files.hasPlaintextHeader(), isFalse);
  });

  test(
    'startup creates the vault, then opens it with the stored key',
    () async {
      final keys = FakeVaultKeyStore();
      final connected = <String>[];
      final opener = VaultOpener(
        keys: keys,
        files: files,
        connect: (key) async {
          connected.add(key);
          return openSqlCipherVault(files, key, backupExclusion: exclusion);
        },
      );

      final created = await opener.open();
      await DriftSettingsRepository(created).write('language', 'ur');
      await created.close();
      expect(keys.writes, 1);
      expect(await files.hasPlaintextHeader(), isFalse);

      final reopened = await opener.open();
      try {
        expect(await DriftSettingsRepository(reopened).readAll(), {
          'language': 'ur',
        });
      } finally {
        await reopened.close();
      }
      expect(keys.writes, 1);
      expect(connected, [
        deriveDatabaseKey(keys.stored!),
        deriveDatabaseKey(keys.stored!),
      ]);
    },
  );
}

final class _RecordingExclusion implements BackupExclusion {
  final directories = <String>[];

  @override
  Future<void> exclude(String directoryPath) async =>
      directories.add(directoryPath);
}
