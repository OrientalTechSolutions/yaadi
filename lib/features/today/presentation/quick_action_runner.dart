import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../core/text/bidi.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/local_date.dart';
import '../../../core/widgets/heading.dart';
import '../../../core/widgets/messenger.dart';
import '../../../l10n/app_localizations.dart';
import '../../items/domain/item.dart';
import '../../items/domain/item_change.dart';
import '../application/quick_actions.dart';
import '../domain/roll_forward.dart';

/// Runs a quick action and reports it: [message] with Undo, or why nothing
/// happened. With [sayNextDue], the message goes on to say when a repeating
/// item is due next. A bill paid months late first asks what happened to
/// the bills missed in between, then says what was recorded.
///
/// Everything needed afterwards is taken from [context] first, because the
/// card that started the action is often gone by the time it lands.
Future<void> runQuickAction(
  BuildContext context, {
  required Future<ActionResult> Function(QuickActionsController actions) action,
  required String message,
  bool sayNextDue = false,
}) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final reporter = _Reporter(
    Messenger.of(context),
    Navigator.of(context),
    container.read(quickActionsProvider.notifier),
    container.read(todayProvider),
  );
  await reporter.report(
    await action(reporter.actions),
    message,
    sayNextDue: sayNextDue,
  );
}

/// Picked in the sheet: take the payment back altogether.
const _undoAll = #undo;

/// Picked in the sheet, or the sheet dismissed: keep what was recorded.
const _keep = #keep;

final class _Reporter {
  _Reporter(this.messenger, this.navigator, this.actions, this.today);

  final Messenger messenger;
  final NavigatorState navigator;
  final QuickActionsController actions;
  final LocalDate today;

  AppLocalizations get l10n => messenger.l10n;

  Future<void> report(
    ActionResult result,
    String message, {
    bool sayNextDue = false,
  }) async {
    switch (result) {
      case ActionApplied(:final catchUp?) when catchUp.options.isNotEmpty:
        await _askAboutMissed(result, catchUp, message);
      case ActionApplied(:final undo, :final after):
        messenger.showUndo(
          sayNextDue ? _withNextDue(message, after) : message,
          () => _undo(undo),
        );
      case AlreadyApplied():
        break;
      case ActionStale():
        messenger.show(l10n.actionStale);
      case ActionNotSaved():
        messenger.show(l10n.notSaved);
    }
  }

  Future<void> _undo(UndoSnapshot undo) async {
    switch (await actions.undo(undo)) {
      case ActionStale():
        messenger.show(l10n.undoRefused);
      case ActionNotSaved():
        messenger.show(l10n.notSaved);
      case ActionApplied() || AlreadyApplied():
        break;
    }
  }

  /// A date that never breaks across lines, with the year when it is not
  /// this year's.
  String _day(LocalDate date) {
    final format = date.year == today.year
        ? DateFormat.MMMd(l10n.localeName)
        : DateFormat.yMMMd(l10n.localeName);
    return isolate(unbreakable(format.format(date.toDateTime())));
  }

  String _withNextDue(String message, Item? after) {
    final due = after?.dueOn;
    if (after == null || !after.isOpen || due == null) return message;
    final date = DateFormat.MMMEd(l10n.localeName).format(due.toDateTime());
    return l10n.withNextDue(message, isolate(unbreakable(date)));
  }

  String _optionLabel(CatchUpMode mode, int missed) => switch (mode) {
    CatchUpMode.markPaid => l10n.catchUpOptionPaid(missed),
    CatchUpMode.step => l10n.catchUpOptionUnpaid(missed),
    CatchUpMode.skip || CatchUpMode.jump => l10n.catchUpOptionSkip(missed),
  };

  /// The confirmation once the missed bills are settled: the payment, when
  /// the bill is due next, and on a second line what became of them.
  String _settled(String message, Item? after, CatchUpMode mode, CatchUp up) {
    final (count, first, last) = (
      up.missed,
      _day(up.missedOn.first),
      _day(up.missedOn.last),
    );
    final missed = switch (mode) {
      CatchUpMode.markPaid => l10n.catchUpMarkedPaid(count, first, last),
      CatchUpMode.skip => l10n.catchUpSkipped(count, first, last),
      CatchUpMode.step => l10n.catchUpStillOwed(count, first, last),
      CatchUpMode.jump => '',
    };
    final paid = _withNextDue(message, after);
    return missed.isEmpty ? paid : '$paid\n$missed';
  }

  /// Asks what happened to the bills missed between the one just paid and
  /// today, with the usual answer for this kind of bill already recorded
  /// and chosen, then confirms with an Undo that takes everything back.
  Future<void> _askAboutMissed(
    ActionApplied applied,
    CatchUp catchUp,
    String message,
  ) async {
    final count = catchUp.missed;
    final options = {for (final option in catchUp.options) option.mode: option};
    final picked = await showModalBottomSheet<Object>(
      context: navigator.context,
      showDragHandle: true,
      builder: (sheet) {
        final theme = Theme.of(sheet);
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsetsDirectional.only(bottom: 16),
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 4),
                child: Heading(message, style: theme.textTheme.titleMedium),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 8),
                child: Text(
                  l10n.catchUpQuestion(
                    count,
                    _day(catchUp.missedOn.first),
                    _day(catchUp.missedOn.last),
                  ),
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              RadioGroup<CatchUpMode>(
                groupValue: catchUp.mode,
                onChanged: (mode) =>
                    Navigator.pop(sheet, options[mode] ?? _keep),
                child: Column(
                  children: [
                    for (final mode in [catchUp.mode, ...options.keys])
                      RadioListTile(
                        value: mode,
                        title: Text(_optionLabel(mode, count)),
                      ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.undo),
                title: Text(l10n.undo),
                onTap: () => Navigator.pop(sheet, _undoAll),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 0),
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(sheet, _keep),
                    child: Text(MaterialLocalizations.of(sheet).okButtonLabel),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    switch (picked) {
      case _undoAll:
        await _undo(applied.undo);
      case final CatchUpOption option:
        final chosen = await actions.chooseCatchUp(applied, option);
        if (chosen case ActionApplied(:final undo, :final after)) {
          messenger.showUndo(
            _settled(message, after, option.mode, catchUp),
            () => _undo(undo),
          );
        } else {
          await report(chosen, message);
        }
      default:
        messenger.showUndo(
          _settled(message, applied.after, catchUp.mode, catchUp),
          () => _undo(applied.undo),
        );
    }
  }
}
