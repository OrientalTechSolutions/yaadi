import 'package:drift/drift.dart';

import '../../../core/time/local_date.dart';
import '../domain/completion.dart';
import '../domain/item_category.dart';
import '../domain/item_kind.dart';
import '../domain/item_status.dart';
import '../domain/recurrence.dart';

/// One row per reminder series (ARCHITECTURE.md section 4).
///
/// Every rule in `Item.violations` has a CHECK here too, so a bad row fails
/// at the database boundary rather than in the UI. Enums are stored by name
/// without a CHECK, but an older build cannot read a name it does not know,
/// so adding a value is a schema version bump; a test pins the names
/// against the schema version.
@DataClassName('ItemRow')
@TableIndex(name: 'items_status_due', columns: {#status, #dueOn})
class Items extends Table {
  TextColumn get id => text()();
  TextColumn get kind => textEnum<ItemKind>()();
  TextColumn get title => text().withLength(min: 1, max: 120)();
  TextColumn get category => textEnum<ItemCategory>()();
  IntColumn get amountMinor => integer().nullable()();
  TextColumn get currency => text().nullable()();
  BoolColumn get amountIsFixed => boolean()();
  TextColumn get scheduledOn =>
      text().map(const LocalDateConverter()).nullable()();
  TextColumn get dueOn => text().map(const LocalDateConverter()).nullable()();
  IntColumn get dueMinute => integer().nullable()();
  TextColumn get recurrence => text()
      .map(const RecurrenceConverter())
      .withDefault(const Constant('{"type":"none"}'))();
  TextColumn get notes => text().withLength(max: 1000).nullable()();
  TextColumn get reference => text().withLength(max: 40).nullable()();
  TextColumn get status => textEnum<ItemStatus>()();
  TextColumn get snoozedUntil =>
      text().map(const LocalDateConverter()).nullable()();
  IntColumn get completedAt => integer().nullable()();
  IntColumn get revision => integer().withDefault(const Constant(1))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (length(title) BETWEEN 1 AND 120 AND title = trim(title))',
    'CHECK (notes IS NULL OR length(notes) BETWEEN 1 AND 1000)',
    'CHECK (reference IS NULL OR length(reference) BETWEEN 1 AND 40)',
    'CHECK ((amount_minor IS NULL) = (currency IS NULL))',
    'CHECK (amount_minor IS NULL OR amount_minor >= 0)',
    "CHECK (currency IS NULL OR currency GLOB '[A-Z][A-Z][A-Z]')",
    "CHECK (scheduled_on IS NULL OR scheduled_on GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]')",
    "CHECK (due_on IS NULL OR due_on GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]')",
    "CHECK (snoozed_until IS NULL OR snoozed_until GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]')",
    'CHECK ((scheduled_on IS NULL) = (due_on IS NULL))',
    "CHECK (due_on IS NOT NULL OR kind = 'task')",
    'CHECK (due_minute IS NULL OR (due_on IS NOT NULL '
        'AND due_minute BETWEEN 0 AND 1439))',
    'CHECK (due_on IS NOT NULL OR recurrence = \'{"type":"none"}\')',
    "CHECK (kind = 'medicine' OR recurrence NOT LIKE '{\"type\":\"doses\"%')",
    "CHECK ((status = 'open') = (completed_at IS NULL))",
    "CHECK (snoozed_until IS NULL OR status = 'open')",
    'CHECK (revision >= 1)',
  ];
}

/// One row per Paid, Done or skipped occurrence.
///
/// The unique index uses `coalesce` because SQLite treats NULLs in a UNIQUE
/// constraint as distinct: a plain constraint would let an untimed
/// occurrence be completed twice.
@DataClassName('CompletionRow')
@TableIndex.sql(
  'CREATE UNIQUE INDEX completions_occurrence ON completions '
  '(item_id, occurrence_on, coalesce(occurrence_minute, -1))',
)
class Completions extends Table {
  TextColumn get id => text()();
  TextColumn get itemId =>
      text().references(Items, #id, onDelete: KeyAction.cascade)();
  TextColumn get occurrenceOn => text().map(const LocalDateConverter())();
  IntColumn get occurrenceMinute => integer().nullable()();
  TextColumn get outcome => textEnum<CompletionOutcome>()();
  IntColumn get amountMinor => integer().nullable()();
  TextColumn get currency => text().nullable()();
  IntColumn get recordedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (occurrence_on GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]')",
    'CHECK (occurrence_minute IS NULL OR occurrence_minute BETWEEN 0 AND 1439)',
    'CHECK ((amount_minor IS NULL) = (currency IS NULL))',
    'CHECK (amount_minor IS NULL OR amount_minor >= 0)',
    "CHECK (currency IS NULL OR currency GLOB '[A-Z][A-Z][A-Z]')",
  ];
}

/// Stores a [LocalDate] as `YYYY-MM-DD`, which also sorts correctly as text.
class LocalDateConverter extends TypeConverter<LocalDate, String> {
  const LocalDateConverter();

  @override
  LocalDate fromSql(String fromDb) => LocalDate.parse(fromDb);

  @override
  String toSql(LocalDate value) => value.toIso();
}

/// Reads recurrence JSON tolerantly; see [Recurrence.decode].
class RecurrenceConverter extends TypeConverter<Recurrence, String> {
  const RecurrenceConverter();

  @override
  Recurrence fromSql(String fromDb) => Recurrence.decode(fromDb);

  @override
  String toSql(Recurrence value) => value.encode();
}
