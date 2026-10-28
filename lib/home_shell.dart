import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/time/clock.dart';
import 'features/demo/application/demo_providers.dart';
import 'features/demo/presentation/demo_badge.dart';
import 'features/items/application/item_filter.dart';
import 'features/items/application/items_providers.dart';
import 'features/items/presentation/item_routes.dart';
import 'features/items/presentation/items_screen.dart';
import 'features/search/application/search_providers.dart';
import 'features/search/presentation/search_screen.dart';
import 'features/settings/application/settings_controller.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/today/presentation/today_screen.dart';
import 'l10n/app_localizations.dart';

/// Windows at least this wide get a navigation rail instead of a bottom bar.
const railBreakpoint = 640.0;

enum _Destination { today, items, search, settings }

/// The top-level destinations. Each keeps its state while another is shown.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  var _selected = _Destination.today;

  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // A phone left on the table overnight comes back on a new day.
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.read(todayProvider.notifier).refresh(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  /// A message belongs to the screen it was shown on. Screen reader users
  /// keep an Undo until they dismiss it, so without this it would follow
  /// them to every other tab.
  void _select(int index) {
    if (_Destination.values[index] != _selected) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
    setState(() => _selected = _Destination.values[index]);
  }

  /// An Undo belongs to the items it was offered on. Once another household
  /// or the user's own items are shown it would act on the wrong ones.
  void _dropStaleUndo() => ScaffoldMessenger.of(context).clearSnackBars();

  /// Another household starts with an empty search and no filters, like
  /// the user's own items after Delete all. The web demo keeps the same
  /// repository across households, so its switch is caught here.
  void _startAfresh() {
    _dropStaleUndo();
    ref
      ..invalidate(searchQueryProvider)
      ..invalidate(itemFilterProvider);
  }

  @override
  Widget build(BuildContext context) {
    ref
      ..listen(itemRepositoryProvider, (_, _) => _dropStaleUndo())
      ..listen(demoHouseholdProvider, (_, _) => _startAfresh())
      // A message in the old language would stay on screen otherwise.
      ..listen(
        appSettingsProvider.select((settings) => settings.language),
        (_, _) => _dropStaleUndo(),
      );
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.sizeOf(context);
    final wide = size.width >= railBreakpoint;
    final canAdd =
        _selected == _Destination.today || _selected == _Destination.items;
    // On a narrow phone or with large text the labelled button would cover
    // most of a card's buttons; the round one covers less.
    final compactAdd =
        size.width < 380 || MediaQuery.textScalerOf(context).scale(10) >= 13;

    final destinations = [
      (Icons.today_outlined, Icons.today, l10n.navToday),
      (Icons.inventory_2_outlined, Icons.inventory_2, l10n.navItems),
      (Icons.search_outlined, Icons.search, l10n.navSearch),
      (Icons.settings_outlined, Icons.settings, l10n.navSettings),
    ];

    final pages = Column(
      children: [
        const DemoNotice(compact: true),
        Expanded(
          // The notice already sits below the status bar.
          child: MediaQuery.removePadding(
            context: context,
            removeTop: ref.watch(showingDemoProvider),
            child: IndexedStack(
              index: _selected.index,
              children: const [
                TodayScreen(),
                ItemsScreen(),
                SearchScreen(),
                SettingsScreen(),
              ],
            ),
          ),
        ),
      ],
    );

    final addButton = compactAdd
        ? FloatingActionButton(
            heroTag: null,
            tooltip: l10n.addItem,
            onPressed: () => openItemEditor(context),
            child: const Icon(Icons.add),
          )
        : FloatingActionButton.extended(
            heroTag: null,
            onPressed: () => openItemEditor(context),
            icon: const Icon(Icons.add),
            label: Text(l10n.addItem),
          );

    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                selectedIndex: _selected.index,
                onDestinationSelected: _select,
                labelType: NavigationRailLabelType.all,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      // The rail is the only place the name would show.
                      ExcludeSemantics(
                        child: Text(
                          l10n.appTitle,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FloatingActionButton(
                        heroTag: null,
                        tooltip: l10n.addItem,
                        onPressed: () => openItemEditor(context),
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
                destinations: [
                  for (final (icon, selectedIcon, label) in destinations)
                    NavigationRailDestination(
                      icon: Icon(icon),
                      selectedIcon: Icon(selectedIcon),
                      label: Text(label),
                    ),
                ],
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: pages),
          ],
        ),
      );
    }

    return Scaffold(
      body: pages,
      floatingActionButton: canAdd ? addButton : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selected.index,
        onDestinationSelected: _select,
        destinations: [
          for (final (icon, selectedIcon, label) in destinations)
            NavigationDestination(
              icon: Icon(icon),
              selectedIcon: Icon(selectedIcon),
              label: label,
            ),
        ],
      ),
    );
  }
}
