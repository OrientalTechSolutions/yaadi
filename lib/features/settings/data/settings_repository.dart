import 'dart:convert';

import '../../../core/platform/session_store.dart';
import '../../../core/storage/storage_failure.dart';
import '../../../vault/vault_database.dart';

/// String settings by key: in the vault on phones, in the browser session on
/// the web demo, in memory when neither is available.
abstract interface class SettingsRepository {
  Future<Map<String, String>> readAll();

  /// Stores [value] under [key], or removes the key when [value] is null.
  Future<void> write(String key, String? value);
}

final class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._db);

  final VaultDatabase _db;

  @override
  Future<Map<String, String>> readAll() async {
    try {
      final rows = await _db.select(_db.settingsEntries).get();
      return {for (final row in rows) row.key: row.value};
    } on Exception catch (error) {
      throw storageFailureFrom(error);
    }
  }

  @override
  Future<void> write(String key, String? value) async {
    try {
      if (value == null) {
        await (_db.delete(
          _db.settingsEntries,
        )..where((s) => s.key.equals(key))).go();
      } else {
        await _db
            .into(_db.settingsEntries)
            .insertOnConflictUpdate(
              SettingsEntriesCompanion.insert(key: key, value: value),
            );
      }
    } on Exception catch (error) {
      throw storageFailureFrom(error);
    }
  }
}

final class MemorySettingsRepository implements SettingsRepository {
  MemorySettingsRepository({
    Map<String, String> initial = const {},
    this.onChanged,
  }) : _values = {...initial};

  final Map<String, String> _values;

  /// Called after every write with all settings.
  final void Function(Map<String, String> values)? onChanged;

  @override
  Future<Map<String, String>> readAll() async => {..._values};

  @override
  Future<void> write(String key, String? value) async {
    if (value == null) {
      _values.remove(key);
    } else {
      _values[key] = value;
    }
    onChanged?.call({..._values});
  }
}

/// Where the web demo keeps its settings in the browser session.
const sessionSettingsKey = 'yaadi.demo.settings.v1';

/// The web demo's settings, written to `sessionStorage` after every change.
MemorySettingsRepository sessionSettingsRepository(SessionStore store) =>
    MemorySettingsRepository(
      initial: _loadSessionSettings(store.read(sessionSettingsKey)),
      onChanged: (values) =>
          store.write(sessionSettingsKey, jsonEncode(values)),
    );

Map<String, String> _loadSessionSettings(String? saved) {
  if (saved == null) return const {};
  try {
    final json = jsonDecode(saved);
    if (json is! Map<String, Object?>) return const {};
    return {
      for (final MapEntry(:key, :value) in json.entries)
        if (value is String) key: value,
    };
  } on FormatException {
    return const {};
  }
}
