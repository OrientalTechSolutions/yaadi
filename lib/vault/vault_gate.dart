import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/widgets/heading.dart';
import '../features/settings/application/settings_controller.dart';
import '../l10n/app_localizations.dart';
import 'app_storage.dart';
import 'vault_failure.dart';

/// Shows [child] once storage is open, and a screen of its own for each way
/// opening can fail (ARCHITECTURE.md section 5.5).
///
/// Nothing here deletes data without the user confirming first, and a
/// keystore that is merely slow never gets a reset button until it has
/// failed three times.
class VaultGate extends ConsumerStatefulWidget {
  const VaultGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<VaultGate> createState() => _VaultGateState();
}

class _VaultGateState extends ConsumerState<VaultGate> {
  static const _attemptsBeforeReset = 3;

  var _failedAttempts = 0;

  @override
  Widget build(BuildContext context) {
    ref.listen(storageProvider, (previous, next) {
      if (next.hasError && !next.isLoading) _failedAttempts++;
    });

    final storage = ref.watch(storageProvider);
    if (storage.isLoading) return const _OpeningScreen();
    if (storage.hasError) {
      final error = storage.error;
      final kind = error is VaultOpenFailure
          ? error.kind
          : VaultFailureKind.unexpected;
      return _FailureScreen(
        kind: kind,
        offerReset: _failedAttempts >= _attemptsBeforeReset,
      );
    }
    // Saved settings decide the language, so the app is not shown in the
    // phone's language for a frame first.
    if (ref.watch(settingsProvider).isLoading) return const _OpeningScreen();
    return widget.child;
  }
}

class _OpeningScreen extends StatelessWidget {
  const _OpeningScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          semanticsLabel: AppLocalizations.of(context).vaultOpening,
        ),
      ),
    );
  }
}

class _FailureScreen extends ConsumerWidget {
  const _FailureScreen({required this.kind, required this.offerReset});

  final VaultFailureKind kind;

  /// Only consulted when the keystore did not answer, which is usually
  /// temporary.
  final bool offerReset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(storageProvider.notifier);
    final tryAgain = FilledButton(
      onPressed: controller.retry,
      child: Text(l10n.vaultTryAgain),
    );
    final reset = OutlinedButton(
      onPressed: () => _confirmReset(context, controller),
      child: Text(l10n.vaultReset),
    );

    final (icon, title, body, actions) = switch (kind) {
      VaultFailureKind.keyUnavailable => (
        Icons.lock_clock_outlined,
        l10n.vaultTryAgainTitle,
        l10n.vaultKeyUnavailableBody,
        [tryAgain, if (offerReset) reset],
      ),
      // A full or failing disk lands here too. Erasing a vault that is
      // probably healthy would fix none of that, so there is no reset.
      VaultFailureKind.unexpected => (
        Icons.error_outline,
        l10n.vaultTryAgainTitle,
        l10n.vaultUnexpectedBody,
        [tryAgain],
      ),
      VaultFailureKind.keyMissing => (
        Icons.key_off_outlined,
        l10n.vaultRecoveryTitle,
        l10n.vaultKeyMissingBody,
        [reset],
      ),
      VaultFailureKind.wrongKeyOrCorrupt => (
        Icons.no_encryption_gmailerrorred_outlined,
        l10n.vaultRecoveryTitle,
        l10n.vaultWrongKeyBody,
        [reset],
      ),
      VaultFailureKind.schemaTooNew => (
        Icons.system_update_outlined,
        l10n.vaultUpdateTitle,
        l10n.vaultUpdateBody,
        <Widget>[],
      ),
      VaultFailureKind.cipherMissing => (
        Icons.gpp_bad_outlined,
        l10n.vaultBuildErrorTitle,
        l10n.vaultBuildErrorBody,
        <Widget>[],
      ),
    };

    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(icon, size: 56, color: theme.colorScheme.primary),
                  const SizedBox(height: 24),
                  Heading(
                    title,
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    body,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  for (final action in actions) ...[
                    const SizedBox(height: 16),
                    action,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmReset(
    BuildContext context,
    StorageController controller,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.vaultResetConfirmTitle),
        content: Text(l10n.vaultResetConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.vaultResetConfirm),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await controller.eraseAndReopen();
  }
}
