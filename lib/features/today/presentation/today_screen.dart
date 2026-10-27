import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../core/widgets/content_list_view.dart';
import '../../../core/widgets/heading.dart';
import '../../../core/widgets/message_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../demo/application/demo_providers.dart';
import '../../demo/presentation/demo_badge.dart';
import '../../demo/presentation/demo_picker.dart';
import '../../items/application/items_providers.dart';
import '../../items/presentation/item_routes.dart';
import '../application/today_providers.dart';
import '../domain/today_view.dart';
import 'morning_summary_card.dart';
import 'today_entry_card.dart';

/// What needs attention: the morning summary, then past appointments to
/// confirm, overdue items, today, the next 7 days, expiry dates coming up
/// and later.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final view = ref.watch(todayViewProvider);

    return Scaffold(
      appBar: ContentAppBar(
        title: Text(l10n.navToday),
        actions: const [DemoBadge()],
      ),
      body: switch (view) {
        AsyncData(:final value) when value.isEmpty => const _NothingToday(),
        AsyncData(:final value) => _TodayList(view: value),
        AsyncError() => MessageView(
          icon: Icons.error_outline,
          title: l10n.itemsLoadFailed,
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _TodayList extends StatelessWidget {
  const _TodayList({required this.view});

  final TodayView view;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ContentListView(
      // Room for the Add button.
      bottom: 96,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(top: 4, bottom: 4),
          child: Text(
            DateFormat.MMMMEEEEd(l10n.localeName)
                .format(view.today.toDateTime()),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const MorningSummaryCard(),
        for (final section in TodaySection.values)
          if (view[section].isNotEmpty) ...[
            _SectionHeader(section: section, count: view[section].length),
            for (final entry in view[section])
              TodayEntryCard(
                key: ValueKey(entry.item.id),
                entry: entry,
                today: view.today,
              ),
          ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.section, required this.count});

  final TodaySection section;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final title = switch (section) {
      TodaySection.toConfirm => l10n.sectionToConfirm,
      TodaySection.overdue => l10n.sectionOverdue,
      TodaySection.today => l10n.sectionToday,
      TodaySection.nextWeek => l10n.sectionNextWeek,
      TodaySection.expiringSoon => l10n.sectionExpiringSoon,
      TodaySection.later => l10n.sectionLater,
    };
    final color = section == TodaySection.overdue
        ? theme.colorScheme.error
        : theme.colorScheme.primary;
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 20, bottom: 4),
      child: Heading(
        '$title · $count',
        semanticsLabel: l10n.sectionLabel(title, count),
        style: theme.textTheme.titleSmall?.copyWith(color: color),
      ),
    );
  }
}

/// Nothing open: either no items at all, with a way to start, or everything
/// is paid and done.
class _NothingToday extends ConsumerWidget {
  const _NothingToday();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final hasItems = ref.watch(
      itemsProvider.select((items) => items.value?.isNotEmpty ?? false),
    );
    if (hasItems) {
      return MessageView(
        icon: Icons.done_all,
        title: l10n.todayAllDoneTitle,
        body: l10n.todayAllDoneBody,
      );
    }
    return MessageView(
      icon: Icons.inbox_outlined,
      title: l10n.todayEmptyTitle,
      body: l10n.todayEmptyBody,
      actions: [
        FilledButton.icon(
          onPressed: () => openItemEditor(context),
          icon: const Icon(Icons.add),
          label: Text(l10n.addItem),
        ),
        if (!ref.watch(showingDemoProvider))
          OutlinedButton.icon(
            onPressed: () => showDemoPicker(context),
            icon: const Icon(Icons.family_restroom_outlined),
            label: Text(l10n.tryDemo),
          ),
      ],
    );
  }
}
