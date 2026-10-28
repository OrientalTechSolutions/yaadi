import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';
import 'features/demo/presentation/demo_picker.dart';
import 'features/settings/application/settings_controller.dart';
import 'features/settings/domain/app_settings.dart';
import 'home_shell.dart';
import 'l10n/app_localizations.dart';
import 'l10n/urdu_material_localizations.dart';
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
      scaffoldMessengerKey: _messengerKey,
      navigatorObservers: [_HideMessagesOnPush(_messengerKey)],
      // Null follows the phone; English still takes the phone's country so
      // dates are written the way that country writes them.
      locale: switch (settings.language) {
        null => null,
        AppLanguage.ur => const Locale('ur'),
        AppLanguage.en => Locale(
          'en',
          WidgetsBinding.instance.platformDispatcher.locale.countryCode,
        ),
      },
      localeResolutionCallback: (requested, _) => resolveAppLocale(requested),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        UrduMaterialLocalizations.delegate,
        ...AppLocalizations.localizationsDelegates,
      ],
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: switch (settings.theme) {
        ThemePreference.system => ThemeMode.system,
        ThemePreference.light => ThemeMode.light,
        ThemePreference.dark => ThemeMode.dark,
      },
      builder: (context, child) =>
          AppTypography(largeText: settings.largeText, child: child!),
      home: const VaultGate(child: DemoGate(child: HomeShell())),
    );
  }
}

final _messengerKey = GlobalKey<ScaffoldMessengerState>();

/// Hides the message on screen when a screen or dialog opens on top. A
/// message with Undo stays until dismissed for screen reader users, and
/// would otherwise sit over the editor, an item's page or a date picker,
/// where its Undo no longer belongs. Closing a screen keeps it: Delete and
/// Save show theirs on the screen underneath.
final class _HideMessagesOnPush extends NavigatorObserver {
  _HideMessagesOnPush(this.messenger);

  final GlobalKey<ScaffoldMessengerState> messenger;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) messenger.currentState?.hideCurrentSnackBar();
  }
}

/// Urdu on an Urdu phone, otherwise English. English dates are written day
/// first (`en_GB`) everywhere except the US: Pakistan and the UK both write
/// 2 November 2026, not November 2, 2026.
Locale resolveAppLocale(Locale? requested) {
  if (requested?.languageCode == 'ur') return const Locale('ur');
  return requested?.countryCode == 'US'
      ? const Locale('en')
      : const Locale('en', 'GB');
}
