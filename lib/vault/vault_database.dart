import 'package:drift/drift.dart';

import '../core/time/local_date.dart';
import '../features/items/data/item_tables.dart';
import '../features/items/domain/completion.dart';
import '../features/items/domain/item_category.dart';
import '../features/items/domain/item_kind.dart';
import '../features/items/domain/item_status.dart';
import '../features/items/domain/recurrence.dart';
import '../features/settings/data/settings_table.dart';

part 'vault_database.g.dart';

/// The encrypted vault: items, their completions and phone settings.
///
/// Schema changes go through `drift_dev make-migrations`, which snapshots
/// every version under `drift_schemas/` and generates the migration tests.
@DriftDatabase(tables: [Items, Completions, SettingsEntries])
class VaultDatabase extends _$VaultDatabase {
  VaultDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // Drift reports a downgrade as an upgrade with from > to. The vault is
      // healthy and the app is old, so stop before anything is touched.
      if (from > to) throw VaultSchemaTooNew(found: from, supported: to);
    },
    beforeOpen: (details) async {
      // Also set by the SQLCipher setup; repeated here so in-memory test
      // databases enforce the same cascades.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

/// The vault was written by a newer version of Yaadi.
final class VaultSchemaTooNew implements Exception {
  const VaultSchemaTooNew({required this.found, required this.supported});

  final int found;
  final int supported;

  @override
  String toString() =>
      'VaultSchemaTooNew(found: $found, supported: $supported)';
}
