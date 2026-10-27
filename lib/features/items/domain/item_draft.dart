import 'package:meta/meta.dart';

import '../../../core/money/money_format.dart';
import '../../../core/time/local_date.dart';
import 'item.dart';
import 'item_category.dart';
import 'item_kind.dart';
import 'recurrence.dart';

/// An editor field that can be wrong.
enum DraftField { title, amount, dueOn, until, doseTimes, notes, reference }

enum DraftProblem {
  required,
  tooLong,

  /// Not an amount in the chosen currency.
  invalidAmount,

  /// An end date before the first date.
  beforeStart,
}

/// The category a new item of [kind] starts with.
ItemCategory defaultCategoryFor(ItemKind kind) => switch (kind) {
  ItemKind.bill => ItemCategory.electricity,
  ItemKind.appointment || ItemKind.medicine => ItemCategory.health,
  ItemKind.expiry => ItemCategory.idDocument,
  ItemKind.task => ItemCategory.other,
};

/// The Repeat choices the editor offers for [kind]. Medicine always repeats
/// on the times the user types; something that expires comes back yearly
/// at most.
List<RepeatRule> repeatRulesFor(ItemKind kind) => switch (kind) {
  ItemKind.medicine => const [RepeatRule.doses],
  ItemKind.expiry => const [RepeatRule.none, RepeatRule.yearly],
  _ => const [
    RepeatRule.none,
    RepeatRule.daily,
    RepeatRule.weekly,
    RepeatRule.monthly,
    RepeatRule.yearly,
  ],
};

/// Whether [kind] has a time of day besides its date. Medicine has its dose
/// times instead, and an expiry date is a whole day.
bool takesTimeOfDay(ItemKind kind) =>
    kind != ItemKind.medicine && kind != ItemKind.expiry;

/// What the editor holds while the user types: text as typed, before it is
/// checked and turned into an [Item].
@immutable
final class ItemDraft {
  const ItemDraft({
    this.kind = ItemKind.bill,
    this.title = '',
    this.category = ItemCategory.electricity,
    this.amountText = '',
    this.currency = 'PKR',
    this.amountIsFixed,
    this.dueOn,
    this.dueMinute,
    this.repeat = RepeatRule.none,
    this.until,
    this.doseMinutes = const [],
    this.notes = '',
    this.reference = '',
    this.moveSeries = false,
  });

  factory ItemDraft.blank({
    required String currency,
    ItemKind kind = ItemKind.bill,
  }) => ItemDraft(
    kind: kind,
    category: defaultCategoryFor(kind),
    currency: currency,
    repeat: kind == ItemKind.medicine ? RepeatRule.doses : RepeatRule.none,
  );

  /// [item] ready for editing. [currency] is used when the item has no
  /// amount yet.
  factory ItemDraft.of(Item item, {required String currency}) {
    final amount = item.amount;
    final minute = item.dueMinute;
    return ItemDraft(
      kind: item.kind,
      title: item.title,
      category: item.category,
      amountText: amount == null ? '' : formatMoneyInput(amount),
      currency: amount?.currency ?? currency,
      amountIsFixed: item.amountIsFixed,
      dueOn: item.dueOn,
      dueMinute: minute,
      repeat: item.kind == ItemKind.medicine
          ? RepeatRule.doses
          : item.recurrence.rule ?? RepeatRule.none,
      until: item.recurrence.until,
      doseMinutes:
          item.doseTimes?.minutes ??
          [if (item.kind == ItemKind.medicine && minute != null) minute],
      notes: item.notes ?? '',
      reference: item.reference ?? '',
    );
  }

  final ItemKind kind;
  final String title;
  final ItemCategory category;

  /// The amount as typed, in [currency]. Only bills have one.
  final String amountText;
  final String currency;

  /// Null follows the category: utility bills change, rent and fees do not.
  final bool? amountIsFixed;

  final LocalDate? dueOn;
  final int? dueMinute;
  final RepeatRule repeat;
  final LocalDate? until;

  /// Medicine times in minutes after midnight, as the user typed them.
  final List<int> doseMinutes;

  final String notes;
  final String reference;

  /// When editing a repeating item whose date changed: true repeats from
  /// the new date from now on, false moves this occurrence only.
  final bool moveSeries;

  bool get isFixedAmount => amountIsFixed ?? category.hasFixedAmountByDefault;

  /// [repeat], or the nearest choice [kind] offers.
  RepeatRule get effectiveRepeat {
    final rules = repeatRulesFor(kind);
    return rules.contains(repeat) ? repeat : rules.first;
  }

  bool get repeats => effectiveRepeat != RepeatRule.none;

  /// What is wrong, by field; empty when the draft can be saved.
  Map<DraftField, DraftProblem> validate(String locale) {
    final title = this.title.trim();
    final due = dueOn;
    final until = this.until;
    return {
      if (title.isEmpty)
        DraftField.title: DraftProblem.required
      else if (title.length > ItemLimits.titleMax)
        DraftField.title: DraftProblem.tooLong,
      if (kind == ItemKind.bill &&
          amountText.trim().isNotEmpty &&
          parseMoney(amountText, currency, locale) == null)
        DraftField.amount: DraftProblem.invalidAmount,
      if (due == null && (kind.requiresDate || repeats))
        DraftField.dueOn: DraftProblem.required,
      if (due != null && until != null && repeats && until.isBefore(due))
        DraftField.until: DraftProblem.beforeStart,
      if (kind == ItemKind.medicine && doseMinutes.isEmpty)
        DraftField.doseTimes: DraftProblem.required,
      if (notes.trim().length > ItemLimits.notesMax)
        DraftField.notes: DraftProblem.tooLong,
      if (reference.trim().length > ItemLimits.referenceMax)
        DraftField.reference: DraftProblem.tooLong,
    };
  }

  /// The item this draft describes: a new one with [id], or [original] as
  /// edited. Call only once [validate] is empty.
  ///
  /// Editing keeps a repeating item's anchor (ARCHITECTURE.md section 4).
  /// A new date moves this occurrence only, unless [moveSeries] is set or
  /// the Repeat choice changed, which derive the anchor from the new date.
  /// A changed date also clears any snooze, which was relative to the old
  /// one.
  Item toItem({
    required String locale,
    required DateTime now,
    Item? original,
    String? id,
  }) {
    if (validate(locale).isNotEmpty) {
      throw StateError('The draft has problems; validate it first');
    }
    final due = dueOn;
    final amount = kind == ItemKind.bill && amountText.trim().isNotEmpty
        ? parseMoney(amountText, currency, locale)
        : null;
    final minute = due != null && takesTimeOfDay(kind) ? dueMinute : null;
    final notes = _orNull(this.notes);
    final reference = _orNull(this.reference);
    final (recurrence, scheduled) = _schedule(original, due);

    if (original == null) {
      return Item(
        id: id ?? (throw ArgumentError.notNull('id')),
        kind: kind,
        title: title.trim(),
        category: category,
        amount: amount,
        amountIsFixed: isFixedAmount,
        scheduledOn: scheduled,
        dueOn: due,
        dueMinute: minute,
        recurrence: recurrence,
        notes: notes,
        reference: reference,
        createdAt: now,
        updatedAt: now,
      );
    }
    return original.copyWith(
      kind: kind,
      title: title.trim(),
      category: category,
      amount: amount,
      amountIsFixed: isFixedAmount,
      scheduledOn: scheduled,
      dueOn: due,
      dueMinute: minute,
      recurrence: recurrence,
      notes: notes,
      reference: reference,
      snoozedUntil: due == original.dueOn ? original.snoozedUntil : null,
      updatedAt: now,
    );
  }

  /// The rule this draft would save when editing [original] (or creating,
  /// when null), for the editor to put into words. Null while there is no
  /// date or no medicine time yet.
  Recurrence? recurrenceFor(Item? original) {
    final due = dueOn;
    if (due == null) return null;
    if (effectiveRepeat == RepeatRule.doses && doseMinutes.isEmpty) {
      return null;
    }
    return _schedule(original, due).$1;
  }

  (Recurrence, LocalDate?) _schedule(Item? original, LocalDate? due) {
    if (due == null) return (Recurrence.none, null);
    final rule = effectiveRepeat;
    switch (rule) {
      case RepeatRule.none:
        return (Recurrence.none, due);
      case RepeatRule.doses:
        return (DoseTimes(doseMinutes, until: until), due);
      case RepeatRule.daily ||
          RepeatRule.weekly ||
          RepeatRule.monthly ||
          RepeatRule.yearly:
        final current = original?.recurrence;
        final scheduled = original?.scheduledOn;
        if (current != null &&
            scheduled != null &&
            current.rule == rule &&
            !moveSeries) {
          return (current.withUntil(until), scheduled);
        }
        return (Recurrence.anchored(rule, due, until: until), due);
    }
  }

  ItemDraft copyWith({
    ItemKind? kind,
    String? title,
    ItemCategory? category,
    String? amountText,
    String? currency,
    Object? amountIsFixed = _keep,
    Object? dueOn = _keep,
    Object? dueMinute = _keep,
    RepeatRule? repeat,
    Object? until = _keep,
    List<int>? doseMinutes,
    String? notes,
    String? reference,
    bool? moveSeries,
  }) {
    T? pick<T>(Object? value, T? current) =>
        identical(value, _keep) ? current : value as T?;

    return ItemDraft(
      kind: kind ?? this.kind,
      title: title ?? this.title,
      category: category ?? this.category,
      amountText: amountText ?? this.amountText,
      currency: currency ?? this.currency,
      amountIsFixed: pick(amountIsFixed, this.amountIsFixed),
      dueOn: pick(dueOn, this.dueOn),
      dueMinute: pick(dueMinute, this.dueMinute),
      repeat: repeat ?? this.repeat,
      until: pick(until, this.until),
      doseMinutes: doseMinutes ?? this.doseMinutes,
      notes: notes ?? this.notes,
      reference: reference ?? this.reference,
      moveSeries: moveSeries ?? this.moveSeries,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ItemDraft &&
      other.kind == kind &&
      other.title == title &&
      other.category == category &&
      other.amountText == amountText &&
      other.currency == currency &&
      other.amountIsFixed == amountIsFixed &&
      other.dueOn == dueOn &&
      other.dueMinute == dueMinute &&
      other.repeat == repeat &&
      other.until == until &&
      _sameInts(other.doseMinutes, doseMinutes) &&
      other.notes == notes &&
      other.reference == reference &&
      other.moveSeries == moveSeries;

  @override
  int get hashCode => Object.hash(
    kind,
    title,
    category,
    amountText,
    currency,
    amountIsFixed,
    dueOn,
    dueMinute,
    repeat,
    until,
    Object.hashAll(doseMinutes),
    notes,
    reference,
    moveSeries,
  );

  /// Leaves out what the user typed, like [Item.toString].
  @override
  String toString() => 'ItemDraft(${kind.name}, due: $dueOn, ${repeat.name})';
}

const Object _keep = Object();

String? _orNull(String text) {
  final trimmed = text.trim();
  return trimmed.isEmpty ? null : trimmed;
}

bool _sameInts(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
