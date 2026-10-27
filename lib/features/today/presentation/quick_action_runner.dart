import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/snack_bars.dart';
import '../../../l10n/app_localizations.dart';
import '../application/quick_actions.dart';
import '../domain/roll_forward.dart';

/// Runs a quick action and reports it: [message] with Undo, the missed
/// occurrences and their alternatives after a catch-up, or why nothing
/// happened.
///
/// Everything needed afterwards is taken from [context] first, because the
/// card that started the action is often gone by the time it lands.
Future<void> runQuickAction(
  BuildContext context, {
  required Future<ActionResult> Function(QuickActionsController actions) action,
  required String message,
}) async {
  final reporter = _Reporter(
    Messenger.of(context),
    Navigator.of(context),
    ProviderScope.containerOf(
      context,
      listen: false,
    ).read(quickActionsProvider.notifier),
  );
  reporter.report(await action(reporter.actions), message);
}

final class _Reporter {
  _Reporter(this.messenger, this.navigator, this.actions);

  final Messenger messenger;
  final NavigatorState navigator;
  final QuickActionsController actions;

  AppLocalizations get l10n => messenger.l10n;

  void report(ActionResult result, String message) {
    switch (result) {
      case ActionApplied(:final catchUp?) when catchUp.options.isNotEmpty:
        messenger.show(
          '$message ${_catchUpDone(catchUp)}',
          action: SnackBarAction(
            label: l10n.catchUpChange,
            onPressed: () => _offerAlternatives(result, catchUp),
          ),
        );
      case ActionApplied(:final undo):
        messenger.showUndo(message, () async {
          if (await actions.undo(undo) case AlreadyApplied()) {
            messenger.show(l10n.undoRefused);
          }
        });
      case AlreadyApplied():
        break;
      case ActionNotSaved():
        messenger.show(l10n.notSaved);
    }
  }

  String _catchUpDone(CatchUp catchUp) => switch (catchUp.mode) {
    CatchUpMode.markPaid => l10n.catchUpMarkedPaid(catchUp.missed),
    CatchUpMode.skip => l10n.catchUpSkipped(catchUp.missed),
    CatchUpMode.step => l10n.catchUpStillOwed(catchUp.missed),
    CatchUpMode.jump => '',
  };

  String _optionLabel(CatchUpMode mode, int missed) => switch (mode) {
    CatchUpMode.step => l10n.catchUpKeepUnpaid(missed),
    CatchUpMode.markPaid => l10n.catchUpMarkEarlierPaid(missed),
    CatchUpMode.skip => l10n.catchUpSkipToCurrent,
    CatchUpMode.jump => l10n.catchUpSkipToCurrent,
  };

  Future<void> _offerAlternatives(ActionApplied applied, CatchUp catchUp) =>
      showModalBottomSheet<void>(
        context: navigator.context,
        showDragHandle: true,
        builder: (sheet) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsetsDirectional.only(bottom: 16),
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 8),
                child: Semantics(
                  header: true,
                  child: Text(
                    l10n.catchUpQuestion(catchUp.missed),
                    style: Theme.of(sheet).textTheme.titleMedium,
                  ),
                ),
              ),
              for (final option in catchUp.options)
                ListTile(
                  leading: const Icon(Icons.rule_outlined),
                  title: Text(_optionLabel(option.mode, catchUp.missed)),
                  onTap: () async {
                    Navigator.pop(sheet);
                    report(
                      await actions.chooseCatchUp(applied, option),
                      l10n.catchUpUpdated,
                    );
                  },
                ),
              ListTile(
                leading: const Icon(Icons.undo),
                title: Text(l10n.undo),
                onTap: () async {
                  Navigator.pop(sheet);
                  if (await actions.undo(applied.undo) case AlreadyApplied()) {
                    messenger.show(l10n.undoRefused);
                  }
                },
              ),
            ],
          ),
        ),
      );
}
