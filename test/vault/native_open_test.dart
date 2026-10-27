import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/platform/backup_exclusion.dart';
import 'package:yaadi/vault/open_vault_native.dart';
import 'package:yaadi/vault/vault_failure.dart';
import 'package:yaadi/vault/vault_files.dart';
import 'package:yaadi/vault/vault_opener.dart';

import '../support/fake_key_store.dart';

/// The open path phones use, end to end: drift_flutter's background
/// isolate, the key handed to `setup`, the vault directory and the backup
/// exclusion. The test host has plain SQLite, so it must refuse to open, and
/// leave neither data nor the key in the file or the error. The encrypted
/// side of the same path is in sqlcipher_test.dart.
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

  int fileLength() =>
      files.database.existsSync() ? files.database.lengthSync() : 0;

  test('the production open refuses plain SQLite and writes nothing', () async {
    final key = 'ab' * 32;
    final db = openSqlCipherVault(files, key, backupExclusion: exclusion);
    Object? error;
    try {
      await db.customSelect('SELECT 1').get();
    } on Exception catch (caught) {
      error = caught;
    }
    try {
      await db.close();
    } on Exception {
      // The connection never opened.
    }

    expect(error, isNotNull);
    final failure = vaultFailureFrom(error!);
    expect(failure.kind, VaultFailureKind.cipherMissing);
    expect(failure.toString(), isNot(contains(key)));
    expect(fileLength(), 0);
    // The vault directory was set up, and kept out of backups, first.
    expect(exclusion.directories, [files.directory.path]);
  });

  test('startup with the production connector fails closed', () async {
    final keys = FakeVaultKeyStore();
    final opener = VaultOpener(
      keys: keys,
      files: files,
      connect: (key) async =>
          openSqlCipherVault(files, key, backupExclusion: exclusion),
    );

    await expectLater(
      opener.open(),
      throwsA(
        isA<VaultOpenFailure>().having(
          (failure) => failure.kind,
          'kind',
          VaultFailureKind.cipherMissing,
        ),
      ),
    );
    expect(fileLength(), 0);
  });
}

final class _RecordingExclusion implements BackupExclusion {
  final directories = <String>[];

  @override
  Future<void> exclude(String directoryPath) async =>
      directories.add(directoryPath);
}
