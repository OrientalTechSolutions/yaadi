import 'package:sqlite3/common.dart' show SqliteException;

import '../core/storage/storage_failure.dart';
import 'vault_database.dart';

/// Why the vault did not open. Each kind has its own screen.
enum VaultFailureKind {
  /// The keystore read failed. Try again; never a new key.
  keyUnavailable,

  /// No key, but a database file exists. Recovery.
  keyMissing,

  /// SQLCipher returns the same code for a wrong key, a corrupt file and a
  /// plaintext file, so the Recovery screen does not pretend to know which.
  wrongKeyOrCorrupt,

  /// Written by a newer version. "Update Yaadi", never a reset.
  schemaTooNew,

  /// The build has no SQLCipher, or a file was written without it.
  cipherMissing,

  unexpected,
}

/// Carries a kind and SQLite's result code, never SQL text or key material
/// (ARCHITECTURE.md section 9).
final class VaultOpenFailure implements Exception {
  const VaultOpenFailure(this.kind, {this.resultCode});

  final VaultFailureKind kind;
  final int? resultCode;

  @override
  String toString() =>
      'VaultOpenFailure(${kind.name}'
      '${resultCode == null ? '' : ', code: $resultCode'})';
}

/// Maps anything thrown while opening the vault to one failure kind.
VaultOpenFailure vaultFailureFrom(Object error) => switch (unwrapDatabaseError(
  error,
)) {
  final VaultOpenFailure failure => failure,
  VaultSchemaTooNew() => const VaultOpenFailure(VaultFailureKind.schemaTooNew),
  SqliteException(:final extendedResultCode)
      when extendedResultCode & 0xFF == sqliteNotADatabase =>
    VaultOpenFailure(
      VaultFailureKind.wrongKeyOrCorrupt,
      resultCode: extendedResultCode,
    ),
  SqliteException(:final extendedResultCode) => VaultOpenFailure(
    VaultFailureKind.unexpected,
    resultCode: extendedResultCode,
  ),
  _ => const VaultOpenFailure(VaultFailureKind.unexpected),
};

/// `SQLITE_NOTADB`.
const sqliteNotADatabase = 26;
