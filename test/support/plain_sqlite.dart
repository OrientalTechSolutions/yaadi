import 'package:sqlite3/common.dart';

/// Shows a connection to `applyVaultSetup` the way a build without SQLCipher
/// would: `PRAGMA key` and the other cipher pragmas are ignored without an
/// error, and `PRAGMA cipher_version` returns no row.
///
/// Tests load the SQLCipher build of the sqlite3 hook, so plain SQLite cannot
/// be loaded next to it; this keeps the fail-closed path tested. Everything
/// else goes to the real connection underneath.
final class PlainSqliteView implements CommonDatabase {
  PlainSqliteView(this._inner);

  final CommonDatabase _inner;

  static final _cipherPragma = RegExp(
    r'^\s*PRAGMA\s+(key|rekey|cipher_\w+)\b',
    caseSensitive: false,
  );

  @override
  void execute(String sql, [List<Object?> parameters = const []]) {
    if (_cipherPragma.hasMatch(sql)) return;
    _inner.execute(sql, parameters);
  }

  @override
  ResultSet select(String sql, [List<Object?> parameters = const []]) {
    if (_cipherPragma.hasMatch(sql)) return ResultSet(const [], const [], []);
    return _inner.select(sql, parameters);
  }

  @override
  Object? noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('PlainSqliteView: ${invocation.memberName}');
}
