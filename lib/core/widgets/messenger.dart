import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// How long an Undo stays on screen. Screen reader users keep it until they
/// dismiss it, because reaching the button takes them longer.
const undoDuration = Duration(seconds: 6);

/// Snack bars for code that awaits a write.
///
/// The widget that started a write may be gone when it lands: a paid
/// one-off bill leaves Today, a deleted item's page closes. So the messenger,
/// the words and the accessibility setting are read from the context before
/// the write starts.
final class Messenger {
  Messenger.of(BuildContext context)
    : _messenger = ScaffoldMessenger.of(context),
      l10n = AppLocalizations.of(context),
      _keepActions = MediaQuery.accessibleNavigationOf(context);

  final ScaffoldMessengerState _messenger;
  final AppLocalizations l10n;
  final bool _keepActions;

  /// Shows [message], replacing any message already shown.
  void show(String message, {SnackBarAction? action}) {
    _messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: action == null ? const Duration(seconds: 4) : undoDuration,
          persist: action != null && _keepActions,
          action: action,
        ),
      );
  }

  /// Shows [message] with an Undo button.
  void showUndo(String message, VoidCallback onUndo) => show(
    message,
    action: SnackBarAction(label: l10n.undo, onPressed: onUndo),
  );
}
