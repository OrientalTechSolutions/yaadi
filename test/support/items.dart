import 'package:yaadi/core/money/money.dart';
import 'package:yaadi/core/time/local_date.dart';
import 'package:yaadi/features/items/domain/completion.dart';
import 'package:yaadi/features/items/domain/item.dart';
import 'package:yaadi/features/items/domain/item_category.dart';
import 'package:yaadi/features/items/domain/item_kind.dart';
import 'package:yaadi/features/items/domain/recurrence.dart';

final createdAt = DateTime.utc(2026, 10, 27, 9, 30);

/// Any valid open item; every field a test may care about can be set.
Item item(
  String id, {
  ItemKind kind = ItemKind.task,
  String? title,
  ItemCategory category = ItemCategory.other,
  LocalDate? due,
  LocalDate? scheduled,
  int? minute,
  Recurrence recurrence = Recurrence.none,
  Money? amount,
  bool? amountIsFixed,
  String? notes,
  LocalDate? snoozedUntil,
}) => Item(
  id: id,
  kind: kind,
  title: title ?? id,
  category: category,
  amount: amount,
  amountIsFixed: amountIsFixed,
  scheduledOn: scheduled,
  dueOn: due,
  dueMinute: minute,
  recurrence: recurrence,
  notes: notes,
  snoozedUntil: snoozedUntil,
  createdAt: createdAt,
  updatedAt: createdAt,
);

/// A valid open bill; override what a test cares about.
Item bill({
  String id = 'bill-1',
  String title = 'LESCO bill',
  ItemCategory category = ItemCategory.electricity,
  LocalDate? dueOn,
  int? dueMinute,
  Money? amount,
  Recurrence recurrence = Recurrence.none,
  String? notes,
  String? reference,
}) => Item(
  id: id,
  kind: ItemKind.bill,
  title: title,
  category: category,
  amount: amount ?? Money(425000, 'PKR'),
  dueOn: dueOn ?? LocalDate(2026, 11, 10),
  dueMinute: dueMinute,
  recurrence: recurrence,
  notes: notes,
  reference: reference,
  createdAt: createdAt,
  updatedAt: createdAt,
);

Item task({String id = 'task-1', String title = 'Renew library card'}) => Item(
  id: id,
  kind: ItemKind.task,
  title: title,
  category: ItemCategory.other,
  createdAt: createdAt,
  updatedAt: createdAt,
);

Item medicine({String id = 'med-1', List<int> minutes = const [480, 1200]}) =>
    Item(
      id: id,
      kind: ItemKind.medicine,
      title: 'امی کی دوائی',
      category: ItemCategory.health,
      dueOn: LocalDate(2026, 10, 27),
      recurrence: DoseTimes(minutes, until: LocalDate(2026, 11, 3)),
      createdAt: createdAt,
      updatedAt: createdAt,
    );

Completion completed(
  String itemId, {
  String id = 'done-1',
  LocalDate? on,
  int? minute,
  CompletionOutcome outcome = CompletionOutcome.done,
  Money? amount,
}) => Completion(
  id: id,
  itemId: itemId,
  occurrenceOn: on ?? LocalDate(2026, 11, 10),
  occurrenceMinute: minute,
  outcome: outcome,
  amount: amount,
  recordedAt: DateTime.utc(2026, 11, 10, 8),
);
