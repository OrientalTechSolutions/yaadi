import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/content_list_view.dart';
import '../../../core/widgets/message_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../demo/presentation/demo_badge.dart';
import '../application/item_filter.dart';
import '../domain/item_kind.dart';
import 'item_labels.dart';
import 'item_tile.dart';

/// Everything in the vault, open or finished, filtered by status and kind.
class ItemsScreen extends ConsumerWidget {
  const ItemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final items = ref.watch(filteredItemsProvider);
    final filtered = ref.watch(itemFilterProvider) != const ItemFilter();

    return Scaffold(
      appBar: ContentAppBar(
        title: Text(l10n.navItems),
        actions: const [DemoBadge()],
      ),
      body: Column(
        children: [
          const _Filters(),
          Expanded(
            child: switch (items) {
              AsyncData(:final value) when value.isEmpty => MessageView(
                icon: Icons.inbox_outlined,
                title: filtered ? l10n.itemsNoMatch : l10n.itemsEmpty,
              ),
              AsyncData(:final value) => LayoutBuilder(
                builder: (context, constraints) {
                  final gutter = contentGutter(constraints.maxWidth);
                  return ListView.builder(
                    padding: EdgeInsets.fromLTRB(gutter, 0, gutter, 96),
                    itemCount: value.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsetsDirectional.only(
                            top: 4,
                            bottom: 4,
                          ),
                          child: Text(
                            l10n.itemCount(value.length),
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        );
                      }
                      final item = value[index - 1];
                      return ItemTile(key: ValueKey(item.id), item: item);
                    },
                  );
                },
              ),
              AsyncError() => MessageView(
                icon: Icons.error_outline,
                title: l10n.itemsLoadFailed,
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
    );
  }
}

class _Filters extends ConsumerWidget {
  const _Filters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filter = ref.watch(itemFilterProvider);
    final controller = ref.read(itemFilterProvider.notifier);

    Widget row(List<Widget> chips) => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final chip in chips)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: chip,
            ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final gutter = contentGutter(constraints.maxWidth);
        return Padding(
          padding: EdgeInsets.fromLTRB(gutter, 4, gutter, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              row([
                for (final (status, label) in [
                  (StatusFilter.open, l10n.filterOpen),
                  (StatusFilter.closed, l10n.filterClosed),
                  (StatusFilter.all, l10n.filterAll),
                ])
                  ChoiceChip(
                    label: Text(label),
                    selected: filter.status == status,
                    onSelected: (_) => controller.showStatus(status),
                  ),
              ]),
              const SizedBox(height: 4),
              row([
                ChoiceChip(
                  label: Text(l10n.filterAllKinds),
                  selected: filter.kind == null,
                  onSelected: (_) => controller.showKind(null),
                ),
                for (final kind in ItemKind.values)
                  ChoiceChip(
                    // The fill shows the choice; a checkmark would cover the icon.
                    showCheckmark: false,
                    avatar: Icon(kindIcon(kind)),
                    label: Text(l10n.kindLabel(kind)),
                    selected: filter.kind == kind,
                    onSelected: (_) => controller.showKind(kind),
                  ),
              ]),
            ],
          ),
        );
      },
    );
  }
}
