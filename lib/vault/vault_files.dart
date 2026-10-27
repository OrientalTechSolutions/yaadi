import 'dart:io';

import 'package:path/path.dart' as p;

/// Where the vault lives: `<applicationSupport>/vault/vault.sqlite`.
///
/// The existence checks and the database connection both get their paths
/// from here, so they can never disagree about where the file is.
final class VaultFiles {
  VaultFiles(this.supportDirectory);

  final String supportDirectory;

  /// The directory that is excluded from iOS backups.
  Directory get directory => Directory(p.join(supportDirectory, 'vault'));

  /// Must match the name drift_flutter derives from `name: 'vault'`.
  File get database => File(p.join(directory.path, 'vault.sqlite'));

  /// Sits outside the directory it protects, so deleting the vault never
  /// deletes the marker first.
  File get wipeMarker => File(p.join(supportDirectory, 'vault.wipe'));

  Iterable<File> get databaseFiles => [
    for (final suffix in const ['', '-wal', '-shm', '-journal'])
      File('${database.path}$suffix'),
  ];

  Future<Directory> ensureDirectory() => directory.create(recursive: true);

  Future<bool> databaseExists() => database.exists();

  Future<void> deleteDatabaseFiles() async {
    for (final file in databaseFiles) {
      if (await file.exists()) await file.delete();
    }
  }

  /// Whether the database starts with SQLite's plaintext header, which an
  /// encrypted file never does.
  Future<bool> hasPlaintextHeader() async {
    if (!await database.exists()) return false;
    final handle = await database.open();
    try {
      final header = await handle.read(_plaintextHeader.length);
      if (header.length < _plaintextHeader.length) return false;
      for (var i = 0; i < _plaintextHeader.length; i++) {
        if (header[i] != _plaintextHeader[i]) return false;
      }
      return true;
    } finally {
      await handle.close();
    }
  }
}

/// `SQLite format 3` followed by a NUL byte.
final _plaintextHeader = [...'SQLite format 3'.codeUnits, 0];
