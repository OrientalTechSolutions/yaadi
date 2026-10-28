import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ids.dart';
import '../../../core/storage/storage_failure.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/local_date.dart';
import '../../items/application/items_providers.dart';
import '../../items/data/item_repository.dart';
import '../../items/domain/completion.dart';
import '../../items/domain/item.dart';
import '../../items/domain/item_change.dart';
import '../../items/domain/recurrence.dart';
import '../domain/doses.dart';
import '../domain/roll_forward.dart';
import '../domain/schedule.dart';
import '../domain/today_view.dart';

/// What became of a quick action.
sealed class ActionResult {
  const ActionResult();
}

final class ActionApplied extends ActionResult {
  const ActionApplied(this.undo, {this.catchUp, this.after});

  /// Puts the item back as it was, while nothing else has changed it.
  final UndoSnapshot undo;

  /// Occurrences that were missed, for the runner to ask about and explain.
  final CatchUp? catchUp;

  /// The item as written, so the confirmation can say when it is due next.
  final Item? after;
}

/// Nothing was written because the same action is still in flight: a double
/// tap. Nothing needs saying.
final class AlreadyApplied extends ActionResult {
  const AlreadyApplied();
}

/// Nothing was written because the item changed since the screen showed
/// it: another action, an edit or a delete got there first, or the undo
/// belongs to storage that is no longer shown. The user is told.
final class ActionStale extends ActionResult {
  const ActionStale();
}

/// Storage refused the write; nothing changed.
final class ActionNotSaved extends ActionResult {
  const ActionNotSaved();
}

/// A write in flight: the item, and the dose time for a dose mark.
typedef PendingAction = (String itemId, int? doseMinute);

final quickActionsProvider =
    NotifierProvider<QuickActionsController, Set<PendingAction>>(
      QuickActionsController.new,
    );

/// Paid, Done, dose marks, Snooze, Reschedule, taking a completion back,
/// and Undo.
///
/// Each intent names the occurrence the user saw. A repeat while the first
/// write is in flight is [AlreadyApplied]; a repeat after it landed finds
/// the item moved on and is [ActionStale], so a double tap rolls a bill
/// forward once either way. The state lists the writes in flight so their
/// buttons can stay disabled until each one lands.
class QuickActionsController extends Notifier<Set<PendingAction>> {
  @override
  Set<PendingAction> build() => const {};

  DateTime _now() => ref.read(clockProvider)();

  bool isPending(String itemId, {int? doseMinute}) =>
      state.contains((itemId, doseMinute));

  /// Records the bill's current occurrence as paid, with its amount, then
  /// rolls it forward or closes it.
  Future<ActionResult> markPaid(String itemId, LocalDate? scheduledOn) =>
      _complete(itemId, scheduledOn, CompletionOutcome.paid);

  /// Records the current occurrence as done, then rolls the item forward or
  /// closes it.
  Future<ActionResult> markDone(String itemId, LocalDate? scheduledOn) =>
      _complete(itemId, scheduledOn, CompletionOutcome.done);

  /// Today, read from the clock again: the date is otherwise checked once a
  /// minute, and a snooze or payment just after midnight must not plan with
  /// yesterday.
  LocalDate _today() {
    ref.read(todayProvider.notifier).refresh();
    return ref.read(todayProvider);
  }

  /// Shows the item again on today + [snooze]. Refused unless it is overdue
  /// or due today.
  Future<ActionResult> snooze(String itemId, SnoozeFor snooze) =>
      _write(itemId, (items) async {
        final item = await items.find(itemId);
        final today = _today();
        if (item == null || !canSnooze(item, today)) return null;
        return (
          change: ItemChange.update(
            item.snoozed(snooze, today: today, now: _now()),
          ),
          catchUp: null,
        );
      });

  /// Moves the current occurrence to [date]: a past appointment that is
  /// happening another day. A repeating item keeps its rule's date, so only
  /// this occurrence moves.
  Future<ActionResult> reschedule(String itemId, LocalDate date) =>
      _write(itemId, (items) async {
        final item = await items.find(itemId);
        if (item == null ||
            !item.isOpen ||
            item.doseTimes != null ||
            !item.recurrence.isSupported) {
          return null;
        }
        return (
          change: ItemChange.update(item.movedTo(date, now: _now())),
          catchUp: null,
        );
      });

  /// Marks one dose of a medicine course. Doses of the same course can be
  /// marked in any order and in quick succession: a write that lost the
  /// race to another dose of the course is retried, while the same dose
  /// twice is not.
  Future<ActionResult> markDose(String itemId, LocalDate on, int minute) =>
      _guard((itemId, minute), () async {
        final items = ref.read(itemRepositoryProvider);
        // One retry for every other dose that may be racing this one.
        for (var attempt = 0; attempt < DoseTimes.maxDoses; attempt++) {
          final item = await items.find(itemId);
          if (item == null || !item.canMarkDose(on, minute)) {
            return const ActionStale();
          }
          final marks = await items.completionsOf(itemId);
          if (marks.any(
            (m) => m.occurrenceOn == on && m.occurrenceMinute == minute,
          )) {
            return const AlreadyApplied();
          }
          final now = _now();
          final mark = item.doseMark(
            on,
            minute,
            id: ref.read(idGeneratorProvider)(),
            now: now,
          );
          final change = ItemChange.update(
            item.copyWith(updatedAt: now),
            addCompletions: [mark],
          );
          if (await items.apply(change) case Written(:final undo)) {
            return ActionApplied(undo);
          }
        }
        return const ActionStale();
      });

  /// Takes the mark off one dose, so a time tapped by mistake can still be
  /// corrected after its Undo has gone. Retried like [markDose] when another
  /// dose of the course wins the race; a dose that is not marked is
  /// [AlreadyApplied].
  Future<ActionResult> unmarkDose(String itemId, LocalDate on, int minute) =>
      _guard((itemId, minute), () async {
        final items = ref.read(itemRepositoryProvider);
        for (var attempt = 0; attempt < DoseTimes.maxDoses; attempt++) {
          final item = await items.find(itemId);
          if (item == null || !item.canMarkDose(on, minute)) {
            return const ActionStale();
          }
          final mark = (await items.completionsOf(itemId))
              .where(
                (m) => m.occurrenceOn == on && m.occurrenceMinute == minute,
              )
              .firstOrNull;
          if (mark == null) return const AlreadyApplied();
          final change = ItemChange.update(
            item.copyWith(updatedAt: _now()),
            removeCompletionIds: [mark.id],
          );
          if (await items.apply(change) case Written(:final undo)) {
            return ActionApplied(undo);
          }
        }
        return const ActionStale();
      });

  /// Handles missed occurrences another way than the default, on top of the
  /// write [applied] came from. The Undo it returns takes back both writes,
  /// the payment and the choice.
  Future<ActionResult> chooseCatchUp(
    ActionApplied applied,
    CatchUpOption option,
  ) async {
    final written = applied.undo.writtenRevision;
    final result = await _write(applied.undo.itemId, (items) async {
      if (written == null || !identical(items, applied.undo.origin)) {
        return null;
      }
      return (
        change: ItemChange.update(
          option.after.copyWith(revision: written),
          addCompletions: option.add,
          removeCompletionIds: option.removeIds,
        ),
        catchUp: null,
      );
    });
    return switch (result) {
      ActionApplied(:final undo, :final after) => ActionApplied(
        applied.undo.then(undo),
        after: after,
      ),
      _ => result,
    };
  }

  /// Takes back the item's newest Paid or Done, [completionId], so that a
  /// mistaken tap can still be corrected after its Undo has gone.
  Future<ActionResult> reopen(String itemId, String completionId) =>
      _write(itemId, (items) async {
        final item = await items.find(itemId);
        if (item == null) return null;
        final last = reopenable(item, await items.completionsOf(itemId));
        if (last == null || last.id != completionId) return null;
        return (change: planReopen(item, last, now: _now()), catchUp: null);
      });

  /// Reverses the write [snapshot] came from, unless something else has
  /// changed the item since. A write made in other storage, such as a demo
  /// household the user has since left, is never undone here.
  Future<ActionResult> undo(UndoSnapshot snapshot) =>
      _write(snapshot.itemId, (items) async {
        if (!identical(items, snapshot.origin)) return null;
        return (change: snapshot.reversal, catchUp: null);
      });

  Future<ActionResult> _complete(
    String itemId,
    LocalDate? scheduledOn,
    CompletionOutcome outcome,
  ) => _write(itemId, (items) async {
    final item = await items.find(itemId);
    if (item == null ||
        !item.isOpen ||
        item.scheduledOn != scheduledOn ||
        item.doseTimes != null ||
        !item.recurrence.isSupported) {
      return null;
    }
    final plan = planCompletion(
      item,
      outcome: outcome,
      today: _today(),
      now: _now(),
      newId: ref.read(idGeneratorProvider),
    );
    return (
      change: ItemChange.update(plan.after, addCompletions: plan.added),
      catchUp: plan.catchUp,
    );
  });

  /// Plans and applies one change against one repository, read once so a
  /// switch to or from a demo household mid-write cannot split the two. A
  /// null plan means the item is no longer as the screen showed it.
  Future<ActionResult> _write(
    String itemId,
    Future<({ItemChange change, CatchUp? catchUp})?> Function(
      ItemRepository items,
    )
    plan,
  ) => _guard((itemId, null), () async {
    final items = ref.read(itemRepositoryProvider);
    final planned = await plan(items);
    if (planned == null) return const ActionStale();
    return switch (await items.apply(planned.change)) {
      Written(:final undo) => ActionApplied(
        undo,
        catchUp: planned.catchUp,
        after: planned.change.after,
      ),
      Stale() => const ActionStale(),
    };
  });

  /// Runs [action] unless the same one is already in flight, and keeps it
  /// listed as pending until it finishes.
  Future<ActionResult> _guard(
    PendingAction pending,
    Future<ActionResult> Function() action,
  ) async {
    if (state.contains(pending)) return const AlreadyApplied();
    state = {...state, pending};
    try {
      return await action();
    } on StorageFailure {
      return const ActionNotSaved();
    } finally {
      if (ref.mounted) state = {...state}..remove(pending);
    }
  }
}
