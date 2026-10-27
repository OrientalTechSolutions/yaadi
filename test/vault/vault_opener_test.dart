import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/vault/vault_database.dart';
import 'package:yaadi/vault/vault_failure.dart';
import 'package:yaadi/vault/vault_files.dart';
import 'package:yaadi/vault/vault_key_store.dart';
import 'package:yaadi/vault/vault_keys.dart';
import 'package:yaadi/vault/vault_opener.dart';

import '../support/fake_key_store.dart';

/// Stands in for SQLCipher: writes a file whose header is not plaintext, as
/// an encrypted file's is, and hands back an in-memory database.
final class FakeConnector {
  final keys = <String>[];
  final opened = <VaultDatabase>[];
  Object? failure;

  late VaultFiles files;

  Future<VaultDatabase> call(String databaseKey) async {
    keys.add(databaseKey);
    final failure = this.failure;
    if (failure != null) throw failure;
    await files.ensureDirectory();
    if (!await files.database.exists()) {
      await files.database.writeAsBytes(List.generate(64, (i) => 255 - i));
    }
    final db = VaultDatabase(NativeDatabase.memory());
    opened.add(db);
    return db;
  }
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late Directory support;
  late VaultFiles files;
  late FakeVaultKeyStore keys;
  late FakeConnector connector;
  late VaultOpener opener;

  setUp(() async {
    support = await Directory.systemTemp.createTemp('yaadi_vault_');
    files = VaultFiles(support.path);
    keys = FakeVaultKeyStore();
    connector = FakeConnector()..files = files;
    opener = VaultOpener(
      keys: keys,
      files: files,
      connect: connector.call,
      random: Random(1),
    );
  });

  tearDown(() async {
    for (final db in connector.opened) {
      await db.close();
    }
    await support.delete(recursive: true);
  });

  Future<void> givenDatabaseFile() async {
    await files.ensureDirectory();
    await files.database.writeAsBytes(List.filled(64, 7));
    await File('${files.database.path}-wal').writeAsBytes([1, 2, 3]);
  }

  Future<VaultFailureKind> failureOf(Future<Object?> open) async {
    try {
      await open;
    } on VaultOpenFailure catch (failure) {
      return failure.kind;
    }
    fail('Expected the vault not to open');
  }

  final existing = VaultKeyRecord(List.filled(32, 9));

  group('startup states (ARCHITECTURE.md section 5.3)', () {
    test('first run: generate, store, read back, then create', () async {
      await opener.open();

      final stored = keys.stored;
      expect(stored, isNotNull);
      expect(connector.keys, [deriveDatabaseKey(stored!)]);
      expect(await files.databaseExists(), isTrue);
    });

    test(
      'key and database: open with the stored key, change nothing',
      () async {
        keys.stored = existing;
        await givenDatabaseFile();

        await opener.open();

        expect(connector.keys, [deriveDatabaseKey(existing)]);
        expect(keys.stored, existing);
        expect(keys.writes, 0);
        expect(keys.deletes, 0);
      },
    );

    test('key without database: replace the stale key, then create', () async {
      keys.stored = existing;

      await opener.open();

      expect(keys.deletes, 1);
      expect(keys.stored, isNot(existing));
      expect(connector.keys, [deriveDatabaseKey(keys.stored!)]);
    });

    test('database without key: Recovery, and nothing is touched', () async {
      await givenDatabaseFile();

      expect(await failureOf(opener.open()), VaultFailureKind.keyMissing);
      expect(await files.databaseExists(), isTrue);
      expect(keys.writes, 0);
      expect(connector.keys, isEmpty);
    });

    for (final withDatabase in [true, false]) {
      test(
        'keystore unavailable (database ${withDatabase ? 'present' : 'absent'}): '
        'Try again, never a new vault',
        () async {
          keys.readFails = true;
          if (withDatabase) await givenDatabaseFile();

          expect(
            await failureOf(opener.open()),
            VaultFailureKind.keyUnavailable,
          );
          expect(keys.writes, 0);
          expect(connector.keys, isEmpty);
          expect(await files.databaseExists(), withDatabase);
        },
      );
    }

    test('a key from a newer version asks for an update', () async {
      keys.newerVersion = true;
      await givenDatabaseFile();

      expect(await failureOf(opener.open()), VaultFailureKind.schemaTooNew);
      expect(await files.databaseExists(), isTrue);
      expect(keys.deletes, 0);
    });

    test('a key that did not persist never encrypts a file', () async {
      keys.dropsWrites = true;

      expect(await failureOf(opener.open()), VaultFailureKind.keyUnavailable);
      expect(connector.keys, isEmpty);
      expect(await files.databaseExists(), isFalse);
    });

    test('a keystore that refuses the write is a Try again', () async {
      keys.writeFails = true;
      expect(await failureOf(opener.open()), VaultFailureKind.keyUnavailable);
      expect(connector.keys, isEmpty);
    });
  });

  group('open failures', () {
    test('a wrong key or a damaged file goes to Recovery', () async {
      keys.stored = existing;
      await givenDatabaseFile();
      connector.failure = SqliteException(
        extendedResultCode: 26,
        message: 'file is not a database',
        causingStatement: "PRAGMA key = \"x'${deriveDatabaseKey(existing)}'\"",
      );

      try {
        await opener.open();
        fail('Expected the vault not to open');
      } on VaultOpenFailure catch (failure) {
        expect(failure.kind, VaultFailureKind.wrongKeyOrCorrupt);
        expect(failure.resultCode, 26);
        expect(
          failure.toString(),
          isNot(contains(deriveDatabaseKey(existing))),
        );
      }
    });

    test('a new file with a plaintext header is refused', () async {
      final plain = VaultOpener(
        keys: keys,
        files: files,
        // The opener closes this database itself when it refuses the file.
        connect: (_) async {
          await files.ensureDirectory();
          return VaultDatabase(NativeDatabase(files.database));
        },
      );

      expect(await failureOf(plain.open()), VaultFailureKind.cipherMissing);
    });
  });

  group('crypto-erase (ARCHITECTURE.md section 5.6)', () {
    test('wipe deletes the key, then the files, then the marker', () async {
      keys.stored = existing;
      await givenDatabaseFile();
      var markerWhenClosing = false;

      await opener.wipe(
        closeDatabase: () async =>
            markerWhenClosing = await files.wipeMarker.exists(),
      );

      expect(markerWhenClosing, isTrue);
      expect(keys.stored, isNull);
      for (final file in files.databaseFiles) {
        expect(await file.exists(), isFalse, reason: file.path);
      }
      expect(await files.wipeMarker.exists(), isFalse);
    });

    final crashes = {
      'after the marker was written': (deleteKey: false, deleteFiles: false),
      'after the key was deleted': (deleteKey: true, deleteFiles: false),
      'after the files were deleted': (deleteKey: true, deleteFiles: true),
    };
    for (final MapEntry(key: moment, value: state) in crashes.entries) {
      test('a crash $moment is finished quietly on the next start', () async {
        keys.stored = state.deleteKey ? null : existing;
        if (!state.deleteFiles) await givenDatabaseFile();
        await files.wipeMarker.create(recursive: true);

        await opener.open();

        expect(await files.wipeMarker.exists(), isFalse);
        expect(keys.stored, isNot(existing));
        expect(connector.keys, [deriveDatabaseKey(keys.stored!)]);
      });
    }

    test(
      'a keystore error mid-wipe keeps the marker for the next start',
      () async {
        keys
          ..stored = existing
          ..deleteFails = true;
        await givenDatabaseFile();
        await files.wipeMarker.create(recursive: true);

        expect(await failureOf(opener.open()), VaultFailureKind.keyUnavailable);
        expect(await files.wipeMarker.exists(), isTrue);
        expect(await files.databaseExists(), isTrue);
      },
    );
  });

  test('vault paths match what drift_flutter derives from the name', () {
    expect(
      files.database.path,
      endsWith(
        '${Platform.pathSeparator}vault${Platform.pathSeparator}vault.sqlite',
      ),
    );
    expect(files.wipeMarker.parent.path, support.path);
  });
}
