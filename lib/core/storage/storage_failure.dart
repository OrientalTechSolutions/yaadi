import 'package:drift/drift.dart'
    show CouldNotRollBackException, DriftWrappedException;
// Errors from Drift's background isolate arrive only as this type. The other
// library that exports it, drift/isolate.dart, pulls dart:isolate into code
// the web demo shares.
// ignore: experimental_member_use
import 'package:drift/remote.dart' show DriftRemoteException;
import 'package:sqlite3/common.dart' show SqliteException;

/// A database operation failed.
///
/// Only SQLite's result code is kept. `SqliteException.toString()` appends
/// the failing statement and its parameters, which would put titles, notes
/// or references into any log that prints the error (ARCHITECTURE.md
/// section 9).
final class StorageFailure implements Exception {
  const StorageFailure([this.resultCode]);

  final int? resultCode;

  @override
  String toString() => 'StorageFailure(code: ${resultCode ?? 'unknown'})';
}

/// The error underneath Drift's wrappers. Errors raised in the background
/// isolate arrive inside a [DriftRemoteException].
Object unwrapDatabaseError(Object error) {
  var current = error;
  while (true) {
    switch (current) {
      case DriftRemoteException(:final remoteCause):
        current = remoteCause;
      case DriftWrappedException(:final Object cause):
        current = cause;
      case CouldNotRollBackException(:final cause):
        current = cause;
      default:
        return current;
    }
  }
}

/// SQLite's extended result code for [error], if it came from SQLite.
int? sqliteResultCode(Object error) => switch (unwrapDatabaseError(error)) {
  SqliteException(:final extendedResultCode) => extendedResultCode,
  _ => null,
};

/// [error] as a [StorageFailure], keeping nothing but the result code.
StorageFailure storageFailureFrom(Object error) =>
    StorageFailure(sqliteResultCode(error));

/// `SQLITE_CONSTRAINT_UNIQUE` and `SQLITE_CONSTRAINT_PRIMARYKEY`.
bool isUniqueViolation(Object error) {
  final code = sqliteResultCode(error);
  return code == 2067 || code == 1555;
}
