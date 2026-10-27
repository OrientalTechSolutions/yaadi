import 'dart:math';

import 'vault_database.dart';
import 'vault_failure.dart';
import 'vault_files.dart';
import 'vault_key_store.dart';
import 'vault_keys.dart';

/// Connects to the database file with a derived raw key. On phones this is
/// SQLCipher in Drift's background isolate; tests pass a fake.
typedef VaultConnector = Future<VaultDatabase> Function(String databaseKey);

/// Decides what to do at startup from the wipe marker, the key store and the
/// database file (ARCHITECTURE.md section 5.3), and performs the
/// crypto-erase (section 5.6).
///
/// It never removes a vault or its key except through [wipe], which only the
/// confirmed Reset and Delete all flows call.
final class VaultOpener {
  VaultOpener({
    required this.keys,
    required this.files,
    required this.connect,
    this._random,
  });

  final VaultKeyStore keys;
  final VaultFiles files;
  final VaultConnector connect;
  final Random? _random;

  /// Throws [VaultOpenFailure].
  Future<VaultDatabase> open() async {
    if (await files.wipeMarker.exists()) await _finishWipe();

    final key = await keys.read();
    final hasDatabase = await files.databaseExists();
    return switch (key) {
      KeyUnavailable() => throw const VaultOpenFailure(
        VaultFailureKind.keyUnavailable,
      ),
      KeyFromNewerVersion() => throw const VaultOpenFailure(
        VaultFailureKind.schemaTooNew,
      ),
      KeyMissing() when hasDatabase => throw const VaultOpenFailure(
        VaultFailureKind.keyMissing,
      ),
      KeyMissing() => _createVault(),
      // iOS keeps Keychain items after an uninstall, and a crash can land
      // between writing the key and creating the file. Either way the old
      // key protects nothing, so it is replaced rather than reused.
      KeyFound() when !hasDatabase => _replaceStaleKey(),
      KeyFound(:final record) => _connect(record, creating: false),
    };
  }

  /// Crypto-erases the vault: once the key is gone, leftover pages and any
  /// copies of the file cannot be read. A crash part-way leaves the marker,
  /// and the next [open] finishes the job quietly.
  Future<void> wipe({Future<void> Function()? closeDatabase}) async {
    await files.wipeMarker.create(recursive: true);
    await closeDatabase?.call();
    await _finishWipe();
  }

  Future<void> _finishWipe() async {
    await _deleteKey();
    await files.deleteDatabaseFiles();
    if (await files.wipeMarker.exists()) await files.wipeMarker.delete();
  }

  Future<VaultDatabase> _replaceStaleKey() async {
    await _deleteKey();
    return _createVault();
  }

  Future<VaultDatabase> _createVault() async {
    final record = VaultKeyRecord.generate(_random);
    try {
      await keys.write(record);
    } on VaultKeyStoreException {
      throw const VaultOpenFailure(VaultFailureKind.keyUnavailable);
    }
    // A key that did not persist must never encrypt a file.
    final stored = await keys.read();
    if (stored is! KeyFound || stored.record != record) {
      throw const VaultOpenFailure(VaultFailureKind.keyUnavailable);
    }
    return _connect(record, creating: true);
  }

  Future<VaultDatabase> _connect(
    VaultKeyRecord record, {
    required bool creating,
  }) async {
    final VaultDatabase db;
    try {
      db = await connect(deriveDatabaseKey(record));
    } on Exception catch (error) {
      throw vaultFailureFrom(error);
    }
    try {
      // Opening is lazy; this runs the key setup and any migration now.
      await db.customSelect('SELECT 1').get();
      if (creating && await files.hasPlaintextHeader()) {
        throw const VaultOpenFailure(VaultFailureKind.cipherMissing);
      }
      return db;
    } on Exception catch (error) {
      await _closeQuietly(db);
      throw vaultFailureFrom(error);
    }
  }

  Future<void> _deleteKey() async {
    try {
      await keys.delete();
    } on VaultKeyStoreException {
      throw const VaultOpenFailure(VaultFailureKind.keyUnavailable);
    }
  }
}

Future<void> _closeQuietly(VaultDatabase db) async {
  try {
    await db.close();
  } on Exception {
    // The open already failed; that failure is the one worth reporting.
  }
}
