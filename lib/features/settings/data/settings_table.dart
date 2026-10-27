import 'package:drift/drift.dart';

/// Phone settings live inside the encrypted vault, not in
/// `shared_preferences`.
@DataClassName('SettingRow')
class SettingsEntries extends Table {
  @override
  String get tableName => 'settings';

  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
