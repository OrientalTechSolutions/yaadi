import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meta/meta.dart';

import 'vault_keys.dart';

/// The stored vault secret and how to use it.
///
/// The version, cipher and KDF fields let a later cipher or custody change
/// migrate deliberately instead of guessing (ARCHITECTURE.md section 5.2).
@immutable
final class VaultKeyRecord {
  VaultKeyRecord(List<int> secret) : secret = List.unmodifiable(secret) {
    if (secret.length != secretLength) {
      throw ArgumentError.value(secret.length, 'secret.length');
    }
  }

  /// 32 random bytes from [random], which defaults to [Random.secure].
  factory VaultKeyRecord.generate([Random? random]) {
    final source = random ?? Random.secure();
    return VaultKeyRecord([
      for (var i = 0; i < secretLength; i++) source.nextInt(256),
    ]);
  }

  /// Throws [UnsupportedKeyRecord] for a record from a newer version and a
  /// [FormatException] for anything else that is not a record.
  factory VaultKeyRecord.decode(String stored) {
    final json = jsonDecode(stored);
    if (json is! Map<String, Object?>) {
      throw const FormatException('Not a vault key record');
    }
    final version = json['v'];
    if (version is int && version > _version) {
      throw const UnsupportedKeyRecord();
    }
    if (version != _version ||
        json['cipher'] != _cipher ||
        json['kdf'] != _kdf) {
      throw const FormatException('Not a vault key record');
    }
    final secret = json['secret'];
    if (secret is! String || secret.length != secretLength * 2) {
      throw const FormatException('Not a vault key record');
    }
    return VaultKeyRecord(hexDecode(secret));
  }

  static const secretLength = 32;
  static const _version = 1;
  static const _cipher = 'sqlcipher4';
  static const _kdf = 'hkdf-sha256';

  final List<int> secret;

  String encode() => jsonEncode({
    'v': _version,
    'cipher': _cipher,
    'kdf': _kdf,
    'secret': hexEncode(secret),
  });

  @override
  bool operator ==(Object other) {
    if (other is! VaultKeyRecord) return false;
    for (var i = 0; i < secretLength; i++) {
      if (other.secret[i] != secret[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(secret);

  @override
  String toString() => 'VaultKeyRecord(v$_version, $_cipher)';
}

/// The stored record was written by a newer version of Yaadi.
final class UnsupportedKeyRecord implements Exception {
  const UnsupportedKeyRecord();
}

/// What reading the key store found.
sealed class KeyRead {
  const KeyRead();
}

final class KeyFound extends KeyRead {
  const KeyFound(this.record);

  final VaultKeyRecord record;
}

/// The read succeeded and there is no key.
final class KeyMissing extends KeyRead {
  const KeyMissing();
}

/// The read failed. Usually temporary; never a reason to create a new key.
final class KeyUnavailable extends KeyRead {
  const KeyUnavailable();
}

final class KeyFromNewerVersion extends KeyRead {
  const KeyFromNewerVersion();
}

/// The platform refused to store or delete the key.
final class VaultKeyStoreException implements Exception {
  const VaultKeyStoreException();
}

/// Holds the single vault key entry. Tests use an in-memory fake; only
/// [SecureVaultKeyStore] touches the platform keystore.
abstract interface class VaultKeyStore {
  /// Never throws.
  Future<KeyRead> read();

  /// Throws [VaultKeyStoreException] when the platform refuses.
  Future<void> write(VaultKeyRecord record);

  /// Deletes the vault entry by name. Throws [VaultKeyStoreException] when
  /// the platform refuses.
  Future<void> delete();
}

/// Android options, set explicitly and pinned by a test.
///
/// The plugin's default `resetOnError: true` erases every entry on any
/// decrypt failure, so a transient Keystore error would destroy the only copy
/// of the key. Pinned algorithms stop a plugin release from migrating the key
/// on its own, and the namespace keeps later secrets from touching it.
const vaultAndroidOptions = AndroidOptions(
  resetOnError: false,
  migrateWithBackup: true,
  keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
  storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
  storageNamespace: 'yaadi_vault',
);

/// Readable by M2 background work after the first unlock following a
/// reboot; never synced to or restored on another device.
const vaultIosOptions = IOSOptions(
  accessibility: KeychainAccessibility.first_unlock_this_device,
);

final class SecureVaultKeyStore implements VaultKeyStore {
  SecureVaultKeyStore([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: vaultAndroidOptions,
            iOptions: vaultIosOptions,
          );

  static const entryName = 'vault_key';

  final FlutterSecureStorage _storage;

  @override
  Future<KeyRead> read() async {
    final String? stored;
    try {
      stored = await _storage.read(key: entryName);
    } on Exception {
      return const KeyUnavailable();
    }
    if (stored == null) return const KeyMissing();
    try {
      return KeyFound(VaultKeyRecord.decode(stored));
    } on UnsupportedKeyRecord {
      return const KeyFromNewerVersion();
    } on FormatException {
      return const KeyUnavailable();
    }
  }

  @override
  Future<void> write(VaultKeyRecord record) async {
    try {
      await _storage.write(key: entryName, value: record.encode());
    } on Exception {
      throw const VaultKeyStoreException();
    }
  }

  @override
  Future<void> delete() async {
    try {
      await _storage.delete(key: entryName);
    } on Exception {
      throw const VaultKeyStoreException();
    }
  }
}
