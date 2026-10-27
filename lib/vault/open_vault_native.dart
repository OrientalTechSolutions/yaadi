import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../core/platform/backup_exclusion.dart';
import '../features/items/data/drift_item_repository.dart';
import '../features/settings/data/settings_repository.dart';
import 'app_storage.dart';
import 'vault_database.dart';
import 'vault_failure.dart';
import 'vault_files.dart';
import 'vault_key_store.dart';
import 'vault_opener.dart';
import 'vault_setup.dart';

StorageBackend createStorageBackend() => const NativeVaultBackend();

/// The SQLCipher vault, with its key in Android Keystore or the iOS
/// Keychain.
final class NativeVaultBackend implements StorageBackend {
  const NativeVaultBackend();

  @override
  Future<AppStorage> open() async {
    final opener = await _opener();
    final db = await opener.open();
    late final AppStorage storage;
    storage = AppStorage(
      kind: StorageKind.vault,
      items: DriftItemRepository(db),
      settings: DriftSettingsRepository(db),
      close: db.close,
      eraseAll: () => opener.wipe(closeDatabase: storage.close),
    );
    return storage;
  }

  @override
  Future<void> erase() async => (await _opener()).wipe();

  Future<VaultOpener> _opener() async {
    final String support;
    try {
      support = (await getApplicationSupportDirectory()).path;
    } on Exception {
      throw const VaultOpenFailure(VaultFailureKind.unexpected);
    }
    final files = VaultFiles(support);
    return VaultOpener(
      keys: SecureVaultKeyStore(),
      files: files,
      connect: (key) async => openSqlCipherVault(files, key),
    );
  }
}

/// Opens the vault file in Drift's background isolate with [databaseKey].
///
/// `shareAcrossIsolates` stays off: it finds databases through
/// `IsolateNameServer`, which the separate engines of M2's background
/// callbacks cannot reach.
VaultDatabase openSqlCipherVault(
  VaultFiles files,
  String databaseKey, {
  BackupExclusion backupExclusion = const IosBackupExclusion(),
}) => VaultDatabase(
  driftDatabase(
    name: 'vault',
    native: DriftNativeOptions(
      databaseDirectory: () async {
        final directory = await files.ensureDirectory();
        await backupExclusion.exclude(directory.path);
        return directory;
      },
      setup: (db) => applyVaultSetup(db, databaseKey),
    ),
  ),
);
