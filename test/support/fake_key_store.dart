import 'package:yaadi/vault/vault_key_store.dart';

/// An in-memory key store that can fail each way the platform can.
final class FakeVaultKeyStore implements VaultKeyStore {
  FakeVaultKeyStore([this.stored]);

  VaultKeyRecord? stored;
  var readFails = false;
  var writeFails = false;
  var deleteFails = false;
  var newerVersion = false;

  /// Accepts writes without keeping them, like a keystore that lost the
  /// entry between write and read.
  var dropsWrites = false;

  var writes = 0;
  var deletes = 0;

  @override
  Future<KeyRead> read() async {
    if (readFails) return const KeyUnavailable();
    if (newerVersion) return const KeyFromNewerVersion();
    final record = stored;
    return record == null ? const KeyMissing() : KeyFound(record);
  }

  @override
  Future<void> write(VaultKeyRecord record) async {
    if (writeFails) throw const VaultKeyStoreException();
    writes++;
    if (!dropsWrites) stored = record;
  }

  @override
  Future<void> delete() async {
    if (deleteFails) throw const VaultKeyStoreException();
    deletes++;
    stored = null;
  }
}
