import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/user_text.dart';
import '../../../l10n/app_localizations.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navSettings),
        actions: const [DemoBadge()],
      ),
      body: ListView(
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
            child: Column(
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
            child: Column(
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
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.settingsLicenses),
            onTap: () => showLicensePage(
              context: context,
              applicationName: l10n.appTitle,
            ),
          ),
        ],
      ),
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
      child: Semantics(
        header: true,
        child: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
