import '../../../core/money/money.dart';
import '../../../core/time/local_date.dart';
import '../domain/completion.dart';
import '../domain/item.dart';
import '../domain/item_category.dart';
import '../domain/item_kind.dart';
import '../domain/item_status.dart';
import '../domain/recurrence.dart';

/// JSON for the web demo's session copy. Field names follow the vault's
/// columns so both stores read the same way.
Map<String, Object?> itemToJson(Item item) => {
  'id': item.id,
  'kind': item.kind.name,
  'title': item.title,
  'category': item.category.name,
  'amount_minor': item.amount?.minorUnits,
  'currency': item.amount?.currency,
  'amount_is_fixed': item.amountIsFixed,
  'scheduled_on': item.scheduledOn?.toIso(),
  'due_on': item.dueOn?.toIso(),
  'due_minute': item.dueMinute,
  'recurrence': item.recurrence.encode(),
  'notes': item.notes,
  'reference': item.reference,
  'status': item.status.name,
  'snoozed_until': item.snoozedUntil?.toIso(),
  'completed_at': item.completedAt?.millisecondsSinceEpoch,
  'revision': item.revision,
  'created_at': item.createdAt.millisecondsSinceEpoch,
  'updated_at': item.updatedAt.millisecondsSinceEpoch,
};

/// Throws a [FormatException] or a [TypeError] when [json] is not an item.
Item itemFromJson(Map<String, Object?> json) => Item(
  id: json['id'] as String,
  kind: ItemKind.values.byName(json['kind'] as String),
  title: json['title'] as String,
  category: ItemCategory.values.byName(json['category'] as String),
  amount: _money(json['amount_minor'], json['currency']),
  amountIsFixed: json['amount_is_fixed'] as bool,
  scheduledOn: _date(json['scheduled_on']),
  dueOn: _date(json['due_on']),
  dueMinute: json['due_minute'] as int?,
  recurrence: Recurrence.decode(json['recurrence'] as String),
  notes: json['notes'] as String?,
  reference: json['reference'] as String?,
  status: ItemStatus.values.byName(json['status'] as String),
  snoozedUntil: _date(json['snoozed_until']),
  completedAt: _instant(json['completed_at']),
  revision: json['revision'] as int,
  createdAt: _instant(json['created_at'])!,
  updatedAt: _instant(json['updated_at'])!,
);

Map<String, Object?> completionToJson(Completion completion) => {
  'id': completion.id,
  'item_id': completion.itemId,
  'occurrence_on': completion.occurrenceOn.toIso(),
  'occurrence_minute': completion.occurrenceMinute,
  'outcome': completion.outcome.name,
  'amount_minor': completion.amount?.minorUnits,
  'currency': completion.amount?.currency,
  'recorded_at': completion.recordedAt.millisecondsSinceEpoch,
};

Completion completionFromJson(Map<String, Object?> json) => Completion(
  id: json['id'] as String,
  itemId: json['item_id'] as String,
  occurrenceOn: LocalDate.parse(json['occurrence_on'] as String),
  occurrenceMinute: json['occurrence_minute'] as int?,
  outcome: CompletionOutcome.values.byName(json['outcome'] as String),
  amount: _money(json['amount_minor'], json['currency']),
  recordedAt: _instant(json['recorded_at'])!,
);

Money? _money(Object? minorUnits, Object? currency) =>
    minorUnits == null ? null : Money(minorUnits as int, currency as String);

LocalDate? _date(Object? value) =>
    value == null ? null : LocalDate.parse(value as String);

DateTime? _instant(Object? value) => value == null
    ? null
    : DateTime.fromMillisecondsSinceEpoch(value as int, isUtc: true);
