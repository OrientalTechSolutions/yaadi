import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../demo/presentation/demo_badge.dart';
import '../../items/application/items_providers.dart';
import '../../items/domain/item.dart';
import '../../items/presentation/item_tile.dart';

/// Open items in due order.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final items = ref.watch(itemsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navToday), actions: const [DemoBadge()]),
      body: switch (items) {
        AsyncData(:final value) => _OpenItems(
          items: [
            for (final item in value)
              if (item.isOpen) item,
          ],
        ),
        AsyncError() => _Message(
          icon: Icons.error_outline,
          title: l10n.itemsLoadFailed,
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _OpenItems extends StatelessWidget {
  const _OpenItems({required this.items});

  final List<Item> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      final l10n = AppLocalizations.of(context);
      return _Message(
        icon: Icons.inbox_outlined,
        title: l10n.todayEmptyTitle,
        body: l10n.todayEmptyBody,
      );
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => ItemTile(item: items[index]),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.title, this.body});

  final IconData icon;
  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = this.body;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (body != null) ...[
              const SizedBox(height: 8),
              Text(
                body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
