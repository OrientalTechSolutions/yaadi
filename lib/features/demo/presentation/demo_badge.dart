import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../application/demo_controller.dart';
import '../application/demo_providers.dart';
import '../domain/demo_household.dart';

/// A permanent "Demo" label for the app bar while demo data is shown.
class DemoBadge extends ConsumerWidget {
  const DemoBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(showingDemoProvider)) return const SizedBox.shrink();
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.tertiaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text(
            AppLocalizations.of(context).demoBadge,
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: colors.onTertiaryContainer),
          ),
        ),
      ),
    );
  }
}

/// The strip above every screen while demo data is shown: the web demo's
/// privacy text, or on a phone which household this is, that changes are
/// not kept, and a way back to the user's own items.
class DemoNotice extends ConsumerWidget {
  const DemoNotice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final household = ref.watch(demoHouseholdProvider);
    final web = ref.watch(isWebDemoProvider);
    if (!web && household == null) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: colors.onSurfaceVariant);
    return Material(
      color: colors.surfaceContainerHighest,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 8, 8),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: colors.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  web
                      ? l10n.webDemoNotice
                      : l10n.phoneDemoNotice(householdName(l10n, household!)),
                  style: style,
                ),
              ),
              if (!web)
                TextButton(
                  onPressed: ref.watch(demoControllerProvider)
                      ? null
                      : ref.read(demoControllerProvider.notifier).clear,
                  child: Text(l10n.leaveDemo),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String householdName(AppLocalizations l10n, DemoHousehold household) =>
    switch (household) {
      DemoHousehold.khan => l10n.householdKhan,
      DemoHousehold.taylor => l10n.householdTaylor,
    };

String householdDescription(AppLocalizations l10n, DemoHousehold household) =>
    switch (household) {
      DemoHousehold.khan => l10n.householdKhanDescription,
      DemoHousehold.taylor => l10n.householdTaylorDescription,
    };
