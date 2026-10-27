import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_info.dart';
import '../../../core/widgets/content_list_view.dart';
import '../../../core/widgets/heading.dart';
import '../../../core/widgets/messenger.dart';
import '../../../core/widgets/user_text.dart';
import '../../../l10n/app_localizations.dart';
import '../../../vault/app_storage.dart';
import '../../demo/application/demo_controller.dart';
import '../../demo/application/demo_providers.dart';
import '../../demo/domain/demo_household.dart';
import '../../demo/presentation/demo_badge.dart';
import '../application/settings_controller.dart';
import '../domain/app_settings.dart';

/// A radio group cannot select null, so "follow the phone" is a choice of
/// its own here.
enum _LanguageChoice { device, en, ur }

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(appSettingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final web = ref.watch(isWebDemoProvider);

    return Scaffold(
      appBar: ContentAppBar(
        title: Text(l10n.navSettings),
        actions: const [DemoBadge()],
      ),
      body: ContentListView(
        top: 0,
        children: [
          _SectionHeader(l10n.settingsLanguage),
          RadioGroup<_LanguageChoice>(
            groupValue: switch (settings.language) {
              null => _LanguageChoice.device,
              AppLanguage.en => _LanguageChoice.en,
              AppLanguage.ur => _LanguageChoice.ur,
            },
            onChanged: (choice) => controller.setLanguage(switch (choice) {
              _LanguageChoice.en => AppLanguage.en,
              _LanguageChoice.ur => AppLanguage.ur,
              _LanguageChoice.device || null => null,
            }),
            child: _NamedGroup(
              name: l10n.settingsLanguage,
              children: [
                RadioListTile(
                  value: _LanguageChoice.device,
                  title: Text(l10n.languageDevice),
                ),
                // Each language is named in its own script, so these go
                // through UserText for the right font and direction.
                RadioListTile(
                  value: _LanguageChoice.en,
                  title: UserText(l10n.languageEnglish),
                ),
                RadioListTile(
                  value: _LanguageChoice.ur,
                  title: UserText(l10n.languageUrdu),
                ),
              ],
            ),
          ),
          const Divider(),
          _SectionHeader(l10n.settingsTheme),
          RadioGroup<ThemePreference>(
            groupValue: settings.theme,
            onChanged: (theme) {
              if (theme != null) controller.setTheme(theme);
            },
            child: _NamedGroup(
              name: l10n.settingsTheme,
              children: [
                for (final (theme, label) in [
                  (ThemePreference.system, l10n.themeSystem),
                  (ThemePreference.light, l10n.themeLight),
                  (ThemePreference.dark, l10n.themeDark),
                ])
                  RadioListTile(value: theme, title: Text(label)),
              ],
            ),
          ),
          const Divider(),
          SwitchListTile(
            value: settings.largeText,
            onChanged: controller.setLargeText,
            title: Text(l10n.settingsLargeText),
            subtitle: Text(l10n.settingsLargeTextHint),
          ),
          const Divider(),
          const _DemoSection(),
          if (!web && settings.demoHousehold == null) ...[
            const Divider(),
            _SectionHeader(l10n.settingsYourData),
            ListTile(
              leading: Icon(
                Icons.delete_forever_outlined,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(l10n.deleteAll),
              subtitle: Text(l10n.deleteAllHint),
              onTap: () => _confirmDeleteAll(context, ref),
            ),
          ],
          const Divider(),
          const _AboutSection(),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAll(BuildContext context, WidgetRef ref) async {
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
    if (confirmed ?? false) {
      await ref.read(storageProvider.notifier).eraseAndReopen();
    }
  }
}

/// A radio group cannot select null either: "my own items" is a choice too.
enum _DemoChoice { own, khan, taylor }

class _DemoSection extends ConsumerWidget {
  const _DemoSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final web = ref.watch(isWebDemoProvider);
    final household = ref.watch(demoHouseholdProvider);
    final busy = ref.watch(demoControllerProvider);
    final demo = ref.read(demoControllerProvider.notifier);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(l10n.settingsDemo),
        for (final paragraph in [
          if (web) ...[
            l10n.webDemoExplain,
            webDemoNoticeText(
              l10n,
              notSaving: ref.watch(demoNotSavingProvider),
            ),
          ] else
            l10n.demoExplain,
        ])
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
            child: Text(
              paragraph,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        RadioGroup<_DemoChoice>(
          groupValue: switch (household) {
            null => _DemoChoice.own,
            DemoHousehold.khan => _DemoChoice.khan,
            DemoHousehold.taylor => _DemoChoice.taylor,
          },
          onChanged: (choice) {
            if (busy) return;
            switch (choice) {
              case _DemoChoice.khan:
                demo.show(DemoHousehold.khan);
              case _DemoChoice.taylor:
                demo.show(DemoHousehold.taylor);
              case _DemoChoice.own || null:
                demo.clear();
            }
          },
          child: Column(
            children: [
              if (!web)
                RadioListTile(
                  value: _DemoChoice.own,
                  title: Text(l10n.demoOwnItems),
                ),
              for (final (choice, option) in [
                (_DemoChoice.khan, DemoHousehold.khan),
                (_DemoChoice.taylor, DemoHousehold.taylor),
              ])
                RadioListTile(
                  value: choice,
                  title: Text(householdName(l10n, option)),
                  subtitle: Text(householdDescription(l10n, option)),
                ),
            ],
          ),
        ),
        if (web || household != null)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 8),
            child: FilledButton.tonalIcon(
              onPressed: busy ? null : demo.clear,
              icon: const Icon(Icons.cleaning_services_outlined),
              label: Text(l10n.clearDemo),
            ),
          ),
      ],
    );
  }
}

class _AboutSection extends ConsumerWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    Future<void> open(Uri uri) async {
      final messenger = Messenger.of(context);
      if (!await ref.read(linkOpenerProvider)(uri)) {
        messenger.show(l10n.linkFailed);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(l10n.settingsAbout),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(l10n.aboutVersion(AppInfo.version)),
          subtitle: Text(l10n.aboutBody),
        ),
        ListTile(
          leading: const Icon(Icons.business_outlined),
          title: Text(l10n.aboutMaker(AppInfo.maker)),
          subtitle: const Text('github.com/OrientalTechSolutions'),
          trailing: const Icon(Icons.open_in_new),
          onTap: () => open(AppInfo.github),
        ),
        ListTile(
          leading: const Icon(Icons.work_outline),
          title: Text(l10n.aboutHire),
          subtitle: const Text('upwork.com/freelancers/attaullahhazarvi'),
          trailing: const Icon(Icons.open_in_new),
          onTap: () => open(AppInfo.upwork),
        ),
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: Text(l10n.settingsLicenses),
          onTap: () => showLicensePage(
            context: context,
            applicationName: l10n.appTitle,
            applicationVersion: AppInfo.version,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 4),
      child: Heading(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

/// Radio choices announced with the group's name, so two groups that both
/// start with "Same as phone" can be told apart.
class _NamedGroup extends StatelessWidget {
  const _NamedGroup({required this.name, required this.children});

  final String name;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: name,
      child: Column(children: children),
    );
  }
}
