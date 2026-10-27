import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/user_text.dart';
import '../../../l10n/app_localizations.dart';
import '../application/morning_summary_text.dart';
import '../application/today_providers.dart';

/// The day at a glance, worked out on the phone from the items alone. The
/// same items always give the same lines.
class MorningSummaryCard extends ConsumerWidget {
  const MorningSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(morningSummaryProvider).value;
    if (summary == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final ink = theme.colorScheme.onPrimaryContainer;

    return Card(
      color: theme.colorScheme.primaryContainer,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wb_sunny_outlined, color: ink),
                const SizedBox(width: 8),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      l10n.morningSummaryTitle,
                      style: theme.textTheme.titleMedium?.copyWith(color: ink),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final line in morningSummaryLines(summary, l10n))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: SizedBox(
                  width: double.infinity,
                  child: UserText(
                    line,
                    style: theme.textTheme.bodyMedium?.copyWith(color: ink),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
