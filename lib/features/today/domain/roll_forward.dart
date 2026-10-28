import 'package:meta/meta.dart';

import '../../../core/time/local_date.dart';
import '../../items/domain/completion.dart';
import '../../items/domain/item.dart';
import '../../items/domain/item_change.dart';
import '../../items/domain/item_kind.dart';
import '../../items/domain/item_status.dart';

/// What happens to the occurrences that fell between the one just completed
/// and today.
enum CatchUpMode {
  /// Move on one period; the missed occurrences are still owed. The default
  /// for fixed instalments, where each one is a real amount.
  step,

  /// Record the missed occurrences as paid and move to the current one. The
  /// default for variable bills, without amounts: Pakistani utilities carry
  /// arrears into the next bill, so stepping would invent debts.
  markPaid,

  /// Record the missed occurrences as skipped and move to the current one.
  skip,

  /// Move to the current occurrence and record nothing. Tasks, appointments
  /// and expiry dates have nothing to settle.
  jump,
}

/// The write for one Paid or Done: the item as it will be stored and the
/// completions to record with it.
@immutable
final class CompletionPlan {
  const CompletionPlan({
    required this.after,
    required this.added,
    this.catchUp,
  });

  /// The item rolled forward to its next occurrence, or closed.
  final Item after;

  /// The completion for the occurrence first, then any the catch-up
  /// recorded.
  final List<Completion> added;

  /// Set when occurrences were missed, so the snackbar can say what was done
  /// with them and offer the alternatives.
  final CatchUp? catchUp;
}

@immutable
final class CatchUp {
  const CatchUp({
    required this.missedOn,
    required this.mode,
    required this.options,
  });

  /// The occurrences after the completed one that were already past today,
  /// oldest first; at most [maxCatchUp] of them.
  final List<LocalDate> missedOn;

  int get missed => missedOn.length;

  /// How they were handled.
  final CatchUpMode mode;

  /// The other ways to handle them.
  final List<CatchUpOption> options;
}

/// Another way to handle the missed occurrences, expressed as a change on
/// top of the plan once it has been written: replace the item with [after],
/// remove the completions the plan's catch-up recorded and add [add].
@immutable
final class CatchUpOption {
  const CatchUpOption({
    required this.mode,
    required this.after,
    required this.add,
    required this.removeIds,
  });

  final CatchUpMode mode;
  final Item after;
  final List<Completion> add;
  final List<String> removeIds;
}

/// The most missed occurrences one Paid settles one by one: a year of a
/// daily bill. Older ones are passed over, recording nothing, as for a task;
/// a daily bill dated decades back would otherwise write thousands of rows
/// in one go.
const maxCatchUp = 400;

/// The catch-up applied when nothing else is chosen.
CatchUpMode defaultCatchUp(Item item) => switch (item.kind) {
  ItemKind.bill when item.amountIsFixed => CatchUpMode.step,
  ItemKind.bill => CatchUpMode.markPaid,
  _ => CatchUpMode.jump,
};

List<CatchUpMode> _alternatives(Item item) => switch (item.kind) {
  ItemKind.bill when item.amountIsFixed => const [
    CatchUpMode.markPaid,
    CatchUpMode.skip,
  ],
  ItemKind.bill => const [CatchUpMode.step],
  _ => const [],
};

/// Records [outcome] for the item's current occurrence and moves it on.
///
/// Rolling forward starts from `scheduledOn`, the rule's date, never from a
/// due date the user moved, and the new due date equals the new scheduled
/// date, so a moved date applies to one occurrence only. A rule that has
/// nothing after this occurrence, or whose next date is past `until`,
/// closes the item. A fixed amount is carried forward; a variable bill's
/// amount is cleared until the next paper says what it is.
///
/// Throws an [ArgumentError] for items quick actions are never offered on:
/// closed items, medicine courses (each dose is marked instead) and rules
/// from a newer version of Yaadi.
CompletionPlan planCompletion(
  Item item, {
  required CompletionOutcome outcome,
  required LocalDate today,
  required DateTime now,
  required String Function() newId,
}) {
  if (outcome == CompletionOutcome.skipped) {
    throw ArgumentError.value(outcome, 'outcome', 'Only paid or done');
  }
  if (!item.isOpen || item.doseTimes != null || !item.recurrence.isSupported) {
    // The id only: error text never carries what the user typed.
    throw ArgumentError.value(item.id, 'item', 'Cannot be completed');
  }

  final scheduled = item.scheduledOn;
  final completion = Completion(
    id: newId(),
    itemId: item.id,
    // An undated task is completed on the day it is done.
    occurrenceOn: scheduled ?? today,
    outcome: outcome,
    amount: outcome == CompletionOutcome.paid ? item.amount : null,
    recordedAt: now,
  );

  final next = scheduled == null ? null : item.recurrence.nextAfter(scheduled);
  if (next == null) {
    return CompletionPlan(
      after: _closed(item, outcome, now),
      added: [completion],
    );
  }

  final missed = <LocalDate>[];
  LocalDate? current = next;
  while (current != null && current.isBefore(today)) {
    missed.add(current);
    // Keeps the most recent ones, which are the ones anyone remembers.
    if (missed.length > maxCatchUp) missed.removeAt(0);
    current = item.recurrence.nextAfter(current);
  }
  if (missed.isEmpty) {
    return CompletionPlan(
      after: _rolledTo(item, next, now),
      added: [completion],
    );
  }

  _CatchUpResult resolve(CatchUpMode mode) {
    final settled = switch (mode) {
      CatchUpMode.markPaid => CompletionOutcome.paid,
      CatchUpMode.skip => CompletionOutcome.skipped,
      CatchUpMode.step || CatchUpMode.jump => null,
    };
    final target = mode == CatchUpMode.step ? next : current;
    return (
      after: target == null
          ? _closed(item, outcome, now)
          : _rolledTo(item, target, now),
      recorded: [
        if (settled != null)
          for (final date in missed)
            Completion(
              id: newId(),
              itemId: item.id,
              occurrenceOn: date,
              outcome: settled,
              // A variable bill's earlier amounts were never on a paper.
              amount: settled == CompletionOutcome.paid && item.amountIsFixed
                  ? item.amount
                  : null,
              recordedAt: now,
            ),
      ],
    );
  }

  final mode = defaultCatchUp(item);
  final chosen = resolve(mode);
  final chosenIds = [for (final completion in chosen.recorded) completion.id];

  CatchUpOption optionFor(CatchUpMode alternative) {
    final result = resolve(alternative);
    return CatchUpOption(
      mode: alternative,
      after: result.after,
      add: result.recorded,
      removeIds: chosenIds,
    );
  }

  return CompletionPlan(
    after: chosen.after,
    added: [completion, ...chosen.recorded],
    catchUp: CatchUp(
      missedOn: List.unmodifiable(missed),
      mode: mode,
      options: [
        for (final alternative in _alternatives(item)) optionFor(alternative),
      ],
    ),
  );
}

typedef _CatchUpResult = ({Item after, List<Completion> recorded});

/// The completion "Mark as not paid" or "Mark as not done" can take back:
/// the newest by occurrence. Only that one, so the history never has a gap
/// in the middle. Dose marks and rules from a newer version are left alone.
Completion? reopenable(Item item, Iterable<Completion> history) {
  if (item.doseTimes != null || !item.recurrence.isSupported) return null;
  Completion? newest;
  for (final completion in history) {
    if (completion.occurrenceMinute != null) continue;
    if (newest == null ||
        completion.occurrenceOn.isAfter(newest.occurrenceOn)) {
      newest = completion;
    }
  }
  return newest;
}

/// Takes back [last], the item's newest completion (see [reopenable]): its
/// occurrence is due again and a closed item is open again. This is how a
/// mistaken Paid is corrected once its Undo has gone; editing the date
/// instead would leave the payment recorded against the wrong month.
ItemChange planReopen(Item item, Completion last, {required DateTime now}) {
  // A one-off item closed on this occurrence keeps its dates, including a
  // due date the user had moved.
  final sameOccurrence =
      !item.isOpen &&
      (item.scheduledOn == null || item.scheduledOn == last.occurrenceOn);
  return ItemChange.update(
    item.copyWith(
      status: ItemStatus.open,
      completedAt: null,
      snoozedUntil: null,
      scheduledOn: sameOccurrence ? item.scheduledOn : last.occurrenceOn,
      dueOn: sameOccurrence ? item.dueOn : last.occurrenceOn,
      // Rolling forward cleared a variable bill's amount; the payment kept it.
      amount: sameOccurrence || item.amountIsFixed ? item.amount : last.amount,
      updatedAt: now,
    ),
    removeCompletionIds: [last.id],
  );
}

Item _rolledTo(Item item, LocalDate date, DateTime now) => item.copyWith(
  scheduledOn: date,
  dueOn: date,
  snoozedUntil: null,
  amount: item.amountIsFixed ? item.amount : null,
  updatedAt: now,
);

Item _closed(Item item, CompletionOutcome outcome, DateTime now) =>
    item.copyWith(
      status: outcome == CompletionOutcome.paid
          ? ItemStatus.paid
          : ItemStatus.done,
      completedAt: now,
      snoozedUntil: null,
      updatedAt: now,
    );
