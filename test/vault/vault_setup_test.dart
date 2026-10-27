import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:yaadi/core/storage/storage_failure.dart';
import 'package:yaadi/vault/vault_database.dart';
import 'package:yaadi/vault/vault_failure.dart';
import 'package:yaadi/vault/vault_setup.dart';

final _key = 'a1' * 32;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('on plain SQLite', () {
    test('the vault refuses to open instead of writing plaintext', () {
      final db = sqlite3.openInMemory();
      addTearDown(db.close);
      expect(
        () => applyVaultSetup(db, _key),
        throwsA(
          isA<VaultOpenFailure>().having(
            (failure) => failure.kind,
            'kind',
            VaultFailureKind.cipherMissing,
          ),
        ),
      );
    });

    test('a key that is not raw hex is refused before SQLite sees it', () {
      final db = sqlite3.openInMemory();
      addTearDown(db.close);
      for (final key in ['passphrase', 'A1' * 32, _key.substring(2)]) {
        expect(
          () => applyVaultSetup(db, key),
          throwsA(isA<VaultOpenFailure>()),
          reason: key,
        );
      }
    });

    test(
      'the refusal crosses the background isolate as a typed failure',
      () async {
        final directory = await Directory.systemTemp.createTemp('yaadi_setup_');
        addTearDown(() => directory.delete(recursive: true));
        final file = File(p.join(directory.path, 'vault.sqlite'));
        final db = VaultDatabase(
          NativeDatabase.createInBackground(
            file,
            setup: (raw) => applyVaultSetup(raw, _key),
          ),
        );

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
        expect(failure.toString(), isNot(contains(_key)));
        expect(file.existsSync() ? file.lengthSync() : 0, 0);
      },
    );
  });

  group('failure mapping', () {
    test('SQLITE_NOTADB means a wrong key or a damaged file', () {
      final failure = vaultFailureFrom(
        SqliteException(
          extendedResultCode: 26,
          message: 'file is not a database',
        ),
      );
      expect(failure.kind, VaultFailureKind.wrongKeyOrCorrupt);
    });

    test('a newer schema asks for an update', () {
      expect(
        vaultFailureFrom(const VaultSchemaTooNew(found: 3, supported: 1)).kind,
        VaultFailureKind.schemaTooNew,
      );
    });

    test('other errors are unexpected and keep only their code', () {
      final failure = vaultFailureFrom(
        SqliteException(
          extendedResultCode: 10,
          message: 'disk I/O error',
          causingStatement: 'SELECT secret',
        ),
      );
      expect(failure.kind, VaultFailureKind.unexpected);
      expect(failure.toString(), 'VaultOpenFailure(unexpected, code: 10)');
      expect(
        vaultFailureFrom(StateError('x')).kind,
        VaultFailureKind.unexpected,
      );
    });

    test('wrapped errors are unwrapped first', () {
      final wrapped = DriftWrappedException(
        message: 'context',
        cause: SqliteException(extendedResultCode: 26, message: 'not a db'),
      );
      expect(
        vaultFailureFrom(wrapped).kind,
        VaultFailureKind.wrongKeyOrCorrupt,
      );
      expect(storageFailureFrom(wrapped).resultCode, 26);
    });
  });
}
