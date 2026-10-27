import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';
import 'features/settings/application/settings_controller.dart';
import 'features/settings/domain/app_settings.dart';
import 'home_shell.dart';
import 'l10n/app_localizations.dart';
import 'vault/vault_gate.dart';

/// The app shell: locale, themes and text scale from Settings, then the vault
/// gate in front of everything else.
class YaadiApp extends ConsumerWidget {
  const YaadiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      // Null lets Flutter pick Urdu on an Urdu phone and English otherwise.
      locale: switch (settings.language) {
        null => null,
        final language => Locale(language.name),
      },
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: switch (settings.theme) {
        ThemePreference.system => ThemeMode.system,
        ThemePreference.light => ThemeMode.light,
        ThemePreference.dark => ThemeMode.dark,
      },
      builder: (context, child) =>
          AppTypography(largeText: settings.largeText, child: child!),
      home: const VaultGate(child: HomeShell()),
    );
  }
}
