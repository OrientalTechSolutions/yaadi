import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/demo/application/demo_providers.dart';
import 'features/demo/presentation/demo_badge.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/today/presentation/today_screen.dart';
import 'l10n/app_localizations.dart';

/// The top-level destinations. Each keeps its state while another is shown.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final showingNotice = ref.watch(showingDemoProvider);

    return Scaffold(
      body: Column(
        children: [
          const WebDemoNotice(),
          Expanded(
            // The notice already sits below the status bar.
            child: MediaQuery.removePadding(
              context: context,
              removeTop: showingNotice,
              child: IndexedStack(
                index: _index,
                children: const [TodayScreen(), SettingsScreen()],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.today_outlined),
            selectedIcon: const Icon(Icons.today),
            label: l10n.navToday,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
