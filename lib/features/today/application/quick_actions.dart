import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ids.dart';
import '../../../core/storage/storage_failure.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/local_date.dart';
import '../../items/application/items_providers.dart';
import '../../items/data/item_repository.dart';
import '../../items/domain/completion.dart';
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
  const ActionApplied(this.undo, {this.catchUp});

  /// Puts the item back as it was, while nothing else has changed it.
  final UndoSnapshot undo;

  /// Occurrences that were missed, for the snackbar to explain and offer
  /// the alternatives.
  final CatchUp? catchUp;
}

/// Nothing was written: the action was already applied (a double tap), or
/// the item changed since the screen showed it.
final class AlreadyApplied extends ActionResult {
  const AlreadyApplied();
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

/// Paid, Done, dose marks, Snooze and Undo.
///
/// Each intent names the occurrence the user saw, and the repository's
/// revision check turns a repeat into [AlreadyApplied], so a double tap
/// rolls a bill forward once. The state lists the writes in flight so their
/// buttons can stay disabled until each one lands.
class QuickActionsController extends Notifier<Set<PendingAction>> {
  @override
  Set<PendingAction> build() => const {};

  ItemRepository get _items => ref.read(itemRepositoryProvider);

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

  /// Shows the item again on today + [snooze]. Refused unless it is overdue
  /// or due today.
  Future<ActionResult> snooze(String itemId, SnoozeFor snooze) =>
      _write(itemId, () async {
        final item = await _items.find(itemId);
        final today = ref.read(todayProvider);
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
      _write(itemId, () async {
        final item = await _items.find(itemId);
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
        // One retry for every other dose that may be racing this one.
        for (var attempt = 0; attempt < DoseTimes.maxDoses; attempt++) {
          final item = await _items.find(itemId);
          if (item == null || !item.canMarkDose(on, minute)) break;
          final marks = await _items.completionsOf(itemId);
          if (marks.any(
            (m) => m.occurrenceOn == on && m.occurrenceMinute == minute,
          )) {
            break;
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
          if (await _items.apply(change) case Written(:final undo)) {
            return ActionApplied(undo);
          }
        }
        return const AlreadyApplied();
      });

  /// Handles missed occurrences another way than the default, on top of the
  /// write [applied] came from.
  Future<ActionResult> chooseCatchUp(
    ActionApplied applied,
    CatchUpOption option,
  ) => _write(applied.undo.itemId, () async {
    final written = applied.undo.writtenRevision;
    if (written == null) return null;
    return (
      change: ItemChange.update(
        option.after.copyWith(revision: written),
        addCompletions: option.add,
        removeCompletionIds: option.removeIds,
      ),
      catchUp: null,
    );
  });

  /// Reverses the write [snapshot] came from, unless something else has
  /// changed the item since.
  Future<ActionResult> undo(UndoSnapshot snapshot) => _write(
    snapshot.itemId,
    () async => (change: snapshot.reversal, catchUp: null),
  );

  Future<ActionResult> _complete(
    String itemId,
    LocalDate? scheduledOn,
    CompletionOutcome outcome,
  ) => _write(itemId, () async {
    final item = await _items.find(itemId);
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
      today: ref.read(todayProvider),
      now: _now(),
      newId: ref.read(idGeneratorProvider),
    );
    return (
      change: ItemChange.update(plan.after, addCompletions: plan.added),
      catchUp: plan.catchUp,
    );
  });

  /// Plans and applies one change. A null plan means there is nothing to
  /// do any more.
  Future<ActionResult> _write(
    String itemId,
    Future<({ItemChange change, CatchUp? catchUp})?> Function() plan,
  ) => _guard((itemId, null), () async {
    final planned = await plan();
    if (planned == null) return const AlreadyApplied();
    return switch (await _items.apply(planned.change)) {
      Written(:final undo) => ActionApplied(undo, catchUp: planned.catchUp),
      Stale() => const AlreadyApplied(),
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
