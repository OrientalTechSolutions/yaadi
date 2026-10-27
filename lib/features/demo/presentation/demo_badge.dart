import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../application/demo_providers.dart';

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

/// The web demo's privacy notice, shown above every screen.
class WebDemoNotice extends ConsumerWidget {
  const WebDemoNotice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(showingDemoProvider)) return const SizedBox.shrink();
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerHighest,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: colors.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).webDemoNotice,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
