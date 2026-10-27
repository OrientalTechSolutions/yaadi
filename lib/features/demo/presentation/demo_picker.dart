import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/user_text.dart';
import '../../../l10n/app_localizations.dart';
import '../../settings/application/settings_controller.dart';
import '../../settings/domain/app_settings.dart';
import '../application/demo_controller.dart';
import '../application/demo_providers.dart';
import '../domain/demo_household.dart';
import 'demo_badge.dart';

/// On the web, where everything is a demo, a household must be chosen
/// before anything else is shown.
class DemoGate extends ConsumerWidget {
  const DemoGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final choosing =
        ref.watch(isWebDemoProvider) &&
        ref.watch(demoHouseholdProvider) == null;
    return choosing ? const DemoPickerScreen() : child;
  }
}

/// The web demo's first screen.
class DemoPickerScreen extends ConsumerWidget {
  const DemoPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final urdu = l10n.localeName == 'ur';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          // Offered in the other language's own script, so a visitor who
          // cannot read this one can still find it.
          TextButton(
            onPressed: () => ref
                .read(settingsProvider.notifier)
                .setLanguage(urdu ? AppLanguage.en : AppLanguage.ur),
            child: UserText(urdu ? l10n.languageEnglish : l10n.languageUrdu),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const DemoNotice(),
          Expanded(
            child: ContentListView(
              maxWidth: 640,
              top: 24,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    l10n.pickerTitle,
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 8),
                Text(l10n.pickerBody, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 16),
                const DemoHouseholdCards(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One card per household; tapping one opens it.
class DemoHouseholdCards extends ConsumerWidget {
  const DemoHouseholdCards({super.key, this.onChosen});

  /// Called after the household is shown, such as to close a sheet.
  final VoidCallback? onChosen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final busy = ref.watch(demoControllerProvider);
    return Column(
      children: [
        for (final household in DemoHousehold.values)
          Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              enabled: !busy,
              contentPadding: const EdgeInsetsDirectional.fromSTEB(
                16,
                8,
                12,
                8,
              ),
              leading: const Icon(Icons.family_restroom_outlined),
              title: Text(
                householdName(l10n, household),
                style: theme.textTheme.titleMedium,
              ),
              subtitle: Text(householdDescription(l10n, household)),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () async {
                await ref.read(demoControllerProvider.notifier).show(household);
                onChosen?.call();
              },
            ),
          ),
      ],
    );
  }
}

/// Lets a phone user look at a made-up household; their own items stay as
/// they are.
Future<void> showDemoPicker(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (sheet) {
    final l10n = AppLocalizations.of(sheet);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                l10n.tryDemo,
                style: Theme.of(sheet).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            Text(l10n.demoExplain),
            const SizedBox(height: 8),
            DemoHouseholdCards(
              onChosen: () {
                if (sheet.mounted) Navigator.pop(sheet);
              },
            ),
          ],
        ),
      ),
    );
  },
);
