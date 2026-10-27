import 'package:meta/meta.dart';

import '../../../core/money/money.dart';
import '../../../core/time/instant.dart';
import '../../../core/time/local_date.dart';
import 'item_category.dart';
import 'item_kind.dart';
import 'item_status.dart';
import 'recurrence.dart';

/// Length limits shared by the editor, the repositories and the vault's
/// CHECK constraints.
abstract final class ItemLimits {
  static const titleMax = 120;
  static const notesMax = 1000;
  static const referenceMax = 40;
}

/// A rule an [Item] breaks. The vault enforces the same rules with CHECK
/// constraints; the other repositories check [Item.violations].
enum ItemViolation {
  titleEmpty,
  titleTooLong,
  titleNotTrimmed,
  notesTooLong,
  referenceTooLong,

  /// Notes and references are null when absent, never empty strings.
  emptyOptionalText,
  missingDueDate,
  scheduleMismatch,
  timeWithoutDate,
  dueMinuteOutOfRange,
  repeatWithoutDate,
  dosesNotMedicine,
  completionMismatch,
  snoozedWhileClosed,
  revisionNotPositive,
}

/// One reminder series: a bill, an appointment, an expiry date, a medicine
/// schedule or a task.
///
/// Dates are wall-clock values (ARCHITECTURE.md section 1); instants are UTC
/// with millisecond precision.
@immutable
final class Item {
  Item({
    required this.id,
    required this.kind,
    required this.title,
    required this.category,
    this.amount,
    bool? amountIsFixed,
    LocalDate? scheduledOn,
    this.dueOn,
    this.dueMinute,
    this.recurrence = Recurrence.none,
    this.notes,
    this.reference,
    this.status = ItemStatus.open,
    this.snoozedUntil,
    DateTime? completedAt,
    this.revision = 1,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : amountIsFixed = amountIsFixed ?? category.hasFixedAmountByDefault,
       scheduledOn = scheduledOn ?? dueOn,
       completedAt = completedAt == null ? null : utcMillis(completedAt),
       createdAt = utcMillis(createdAt),
       updatedAt = utcMillis(updatedAt);

  /// UUIDv7: made offline and sorted by creation time.
  final String id;
  final ItemKind kind;
  final String title;
  final ItemCategory category;

  /// For a variable bill, only the current bill's amount once it is known.
  final Money? amount;

  /// Decides whether rolling forward keeps the amount and how missed
  /// occurrences are caught up. Defaults by category.
  final bool amountIsFixed;

  /// The rule's date for the current occurrence. Completions and
  /// roll-forward key off it, never off a moved [dueOn].
  final LocalDate? scheduledOn;

  /// The date the user sees. Equal to [scheduledOn] unless the user moved
  /// this occurrence; null only for undated tasks.
  final LocalDate? dueOn;

  /// Minutes after local midnight, 0 to 1439.
  final int? dueMinute;

  final Recurrence recurrence;
  final String? notes;

  /// A consumer number, CNIC or similar. Masked in the UI and kept out of
  /// search, summaries, notifications and share text.
  final String? reference;

  final ItemStatus status;
  final LocalDate? snoozedUntil;
  final DateTime? completedAt;

  /// Incremented by every write. Quick actions and undo compare it before
  /// writing; [updatedAt] is for display only.
  final int revision;

  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isOpen => status == ItemStatus.open;

  /// The date the item is shown under: the snooze date while it is today or
  /// later, otherwise the due date. Null for an undated task.
  LocalDate? effectiveOn(LocalDate today) {
    final snoozed = snoozedUntil;
    if (snoozed != null && !snoozed.isBefore(today)) return snoozed;
    return dueOn;
  }

  /// The times of a medicine course, whose doses are derived day by day
  /// instead of rolling forward; null for everything else.
  DoseTimes? get doseTimes => switch (recurrence) {
    final DoseTimes doses => doses,
    _ => null,
  };

  /// Every rule this item breaks; empty for a valid item.
  Set<ItemViolation> get violations {
    final notes = this.notes;
    final reference = this.reference;
    final dueMinute = this.dueMinute;
    return {
      if (title.isEmpty) ItemViolation.titleEmpty,
      if (title.length > ItemLimits.titleMax) ItemViolation.titleTooLong,
      if (title.trim() != title) ItemViolation.titleNotTrimmed,
      if (notes != null && notes.length > ItemLimits.notesMax)
        ItemViolation.notesTooLong,
      if (reference != null && reference.length > ItemLimits.referenceMax)
        ItemViolation.referenceTooLong,
      if (notes == '' || reference == '') ItemViolation.emptyOptionalText,
      if (dueOn == null && kind.requiresDate) ItemViolation.missingDueDate,
      if ((scheduledOn == null) != (dueOn == null))
        ItemViolation.scheduleMismatch,
      if (dueMinute != null && dueOn == null) ItemViolation.timeWithoutDate,
      if (dueMinute != null && (dueMinute < 0 || dueMinute > 1439))
        ItemViolation.dueMinuteOutOfRange,
      if (recurrence.repeats && dueOn == null) ItemViolation.repeatWithoutDate,
      if (recurrence is DoseTimes && kind != ItemKind.medicine)
        ItemViolation.dosesNotMedicine,
      if ((status == ItemStatus.open) != (completedAt == null))
        ItemViolation.completionMismatch,
      if (snoozedUntil != null && status != ItemStatus.open)
        ItemViolation.snoozedWhileClosed,
      if (revision < 1) ItemViolation.revisionNotPositive,
    };
  }

  /// Pass `null` to clear a nullable field; leave it out to keep it.
  Item copyWith({
    ItemKind? kind,
    String? title,
    ItemCategory? category,
    Object? amount = _keep,
    bool? amountIsFixed,
    Object? scheduledOn = _keep,
    Object? dueOn = _keep,
    Object? dueMinute = _keep,
    Recurrence? recurrence,
    Object? notes = _keep,
    Object? reference = _keep,
    ItemStatus? status,
    Object? snoozedUntil = _keep,
    Object? completedAt = _keep,
    int? revision,
    DateTime? updatedAt,
  }) {
    T? pick<T>(Object? value, T? current) =>
        identical(value, _keep) ? current : value as T?;

    return Item(
      id: id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: pick(amount, this.amount),
      amountIsFixed: amountIsFixed ?? this.amountIsFixed,
      scheduledOn: pick(scheduledOn, this.scheduledOn),
      dueOn: pick(dueOn, this.dueOn),
      dueMinute: pick(dueMinute, this.dueMinute),
      recurrence: recurrence ?? this.recurrence,
      notes: pick(notes, this.notes),
      reference: pick(reference, this.reference),
      status: status ?? this.status,
      snoozedUntil: pick(snoozedUntil, this.snoozedUntil),
      completedAt: pick(completedAt, this.completedAt),
      revision: revision ?? this.revision,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Item &&
      other.id == id &&
      other.kind == kind &&
      other.title == title &&
      other.category == category &&
      other.amount == amount &&
      other.amountIsFixed == amountIsFixed &&
      other.scheduledOn == scheduledOn &&
      other.dueOn == dueOn &&
      other.dueMinute == dueMinute &&
      other.recurrence == recurrence &&
      other.notes == notes &&
      other.reference == reference &&
      other.status == status &&
      other.snoozedUntil == snoozedUntil &&
      other.completedAt == completedAt &&
      other.revision == revision &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hashAll([
    id,
    kind,
    title,
    category,
    amount,
    amountIsFixed,
    scheduledOn,
    dueOn,
    dueMinute,
    recurrence,
    notes,
    reference,
    status,
    snoozedUntil,
    completedAt,
    revision,
    createdAt,
    updatedAt,
  ]);

  /// Leaves out notes and the reference, which may hold personal details,
  /// in case this ever reaches a log or a bug report.
  @override
  String toString() =>
      'Item($id, ${kind.name}, "$title", due: $dueOn, '
      '${status.name}, revision: $revision'
      '${notes == null ? '' : ', notes: <redacted>'}'
      '${reference == null ? '' : ', reference: <redacted>'})';
}

const Object _keep = Object();

/// The order lists start from: by due date, timed before untimed on the
/// same day, then by title. Undated items come last.
int compareByDue(Item a, Item b) {
  final aDue = a.dueOn;
  final bDue = b.dueOn;
  if (aDue == null || bDue == null) {
    if (aDue != bDue) return aDue == null ? 1 : -1;
  } else {
    final byDate = aDue.compareTo(bDue);
    if (byDate != 0) return byDate;
  }
  final aMinute = a.dueMinute;
  final bMinute = b.dueMinute;
  if (aMinute != bMinute) {
    if (aMinute == null) return 1;
    if (bMinute == null) return -1;
    return aMinute.compareTo(bMinute);
  }
  final byTitle = a.title.toLowerCase().compareTo(b.title.toLowerCase());
  return byTitle != 0 ? byTitle : a.id.compareTo(b.id);
}
