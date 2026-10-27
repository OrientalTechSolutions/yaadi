import 'package:sqlite3/common.dart';

import 'vault_failure.dart';

/// Prepares a freshly opened SQLCipher connection, in the order given by
/// ARCHITECTURE.md section 5.4.
///
/// Runs inside Drift's background isolate. Every failure becomes a
/// [VaultOpenFailure] that holds a result code only, because
/// `SqliteException.toString()` would include the statement, and with it
/// the key.
void applyVaultSetup(CommonDatabase db, String databaseKey) {
  // SQLCipher treats anything but a raw key as a passphrase and silently
  // derives a different key from it.
  if (!isRawDatabaseKey(databaseKey)) {
    throw const VaultOpenFailure(VaultFailureKind.unexpected);
  }
  try {
    // The raw-key form skips PBKDF2, which costs seconds on budget phones
    // and adds nothing for a random key.
    db.execute("PRAGMA key = \"x'$databaseKey'\"");
    // Plain SQLite ignores PRAGMA key without an error; only SQLCipher
    // answers this, so a build without it refuses to open.
    if (db.select('PRAGMA cipher_version').isEmpty) {
      throw const VaultOpenFailure(VaultFailureKind.cipherMissing);
    }
    // Keeps a future SQLCipher 5 default from changing how files are read.
    db.execute('PRAGMA cipher_compatibility = 4');
    db.select('SELECT count(*) FROM sqlite_master');
    db.execute('PRAGMA temp_store = MEMORY');
    db.execute('PRAGMA secure_delete = ON');
    db.execute('PRAGMA foreign_keys = ON');
    db.execute('PRAGMA busy_timeout = 5000');
    db.select('PRAGMA journal_mode = WAL');
  } on SqliteException catch (error) {
    throw VaultOpenFailure(
      error.resultCode == sqliteNotADatabase
          ? VaultFailureKind.wrongKeyOrCorrupt
          : VaultFailureKind.unexpected,
      resultCode: error.extendedResultCode,
    );
  }
}

bool isRawDatabaseKey(String key) => _rawKey.hasMatch(key);

final _rawKey = RegExp(r'^[0-9a-f]{64}$');
