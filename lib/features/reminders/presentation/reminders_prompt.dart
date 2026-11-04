import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../demo/application/demo_providers.dart';
import '../../items/application/items_providers.dart';
import '../../settings/application/settings_controller.dart';
import '../application/reminder_providers.dart';
import 'reminders_section.dart';

/// A card at the top of Today while the phone does not allow Yaadi's
/// notifications yet: reminders are on in Settings but cannot show. It
/// asks once; "Not now" hides it for good, and Settings stays the way in.
class RemindersPrompt extends ConsumerWidget {
  const RemindersPrompt({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(reminderPrefsProvider);
    final hasItems = ref.watch(
      itemsProvider.select((items) => items.value?.isNotEmpty ?? false),
    );
    final blocked =
        ref.watch(reminderHealthProvider).value?.notificationsOff ?? false;
    if (!ref.watch(remindersAvailableProvider) ||
        ref.watch(showingDemoProvider) ||
        !prefs.enabled ||
        prefs.promptHidden ||
        !hasItems ||
        !blocked) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card.filled(
      margin: const EdgeInsetsDirectional.only(top: 4, bottom: 8),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 8, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications_none,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.remindersOffTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 4, end: 8),
              child: Text(l10n.remindersOffBody),
            ),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () => ref
                      .read(settingsProvider.notifier)
                      .setReminders(prefs.copyWith(promptHidden: true)),
                  child: Text(l10n.remindersNotNow),
                ),
                FilledButton.tonal(
                  onPressed: () => askReminderPermission(context, ref),
                  child: Text(l10n.remindersTurnOn),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
