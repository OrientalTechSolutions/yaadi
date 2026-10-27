import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../core/money/money_format.dart';
import '../../../core/text/bidi.dart';
import '../../../core/time/time_format.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/message_view.dart';
import '../../../core/widgets/snack_bars.dart';
import '../../../core/widgets/user_text.dart';
import '../../../l10n/app_localizations.dart';
import '../../demo/presentation/demo_badge.dart';
import '../../today/presentation/quick_action_runner.dart';
import '../application/items_controller.dart';
import '../application/items_providers.dart';
import '../domain/completion.dart';
import '../domain/item.dart';
import '../domain/item_kind.dart';
import 'item_labels.dart';
import 'item_routes.dart';
import 'item_tile.dart';
import 'reference_view.dart';

/// Everything about one item, its history, and Edit and Delete.
class ItemDetailsScreen extends ConsumerWidget {
  const ItemDetailsScreen({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return switch (ref.watch(itemProvider(itemId))) {
      AsyncData(value: final item?) => _Details(item: item),
      AsyncData() => Scaffold(
        appBar: AppBar(),
        body: MessageView(icon: Icons.delete_outline, title: l10n.itemGone),
      ),
      AsyncError() => Scaffold(
        appBar: AppBar(),
        body: MessageView(
          icon: Icons.error_outline,
          title: l10n.itemsLoadFailed,
        ),
      ),
      _ => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
    };
  }
}

class _Details extends ConsumerWidget {
  const _Details({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = l10n.localeName;
    final supported = item.recurrence.isSupported;
    final pending = ref.watch(
      itemsControllerProvider.select((writes) => writes.contains(item.id)),
    );
    final due = item.dueOn;
    final scheduled = item.scheduledOn;
    final snoozed = item.snoozedUntil;
    final minute = item.dueMinute;
    final notes = item.notes;
    final reference = item.reference;
    final amount = item.amount;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.kindLabel(item.kind)),
        actions: [
          IconButton(
            tooltip: l10n.edit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: supported && !pending
                ? () => openItemEditor(context, item: item)
                : null,
          ),
          IconButton(
            tooltip: l10n.delete,
            icon: const Icon(Icons.delete_outline),
            onPressed: pending ? null : () => _delete(context, ref),
          ),
          const DemoBadge(),
        ],
      ),
      body: ContentListView(
        maxWidth: 640,
        children: [
          Row(
            children: [
              KindAvatar(kind: item.kind),
              const SizedBox(width: 16),
              Expanded(
                child: UserText(
                  item.title,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusBadge(label: l10n.categoryLabel(item.category)),
              if (!item.isOpen)
                StatusBadge(label: l10n.statusLabel(item.status)),
            ],
          ),
          if (!supported)
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 16),
              child: Text(
                l10n.repeatUnsupportedNotice,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          const SizedBox(height: 8),
          _Fact(
            icon: Icons.event_outlined,
            label: _dateLabel(l10n, item.kind),
            value: Text(
              [
                if (due == null)
                  l10n.noDueDate
                else
                  DateFormat.yMMMMEEEEd(locale).format(due.toDateTime()),
                if (minute != null) isolate(formatMinute(minute, locale)),
              ].join(' · '),
            ),
          ),
          if (scheduled != null &&
              due != null &&
              scheduled != due &&
              item.recurrence.repeats)
            _Fact(
              icon: Icons.move_down_outlined,
              label: l10n.factMoved,
              value: Text(l10n.movedFrom(scheduled.toDateTime())),
            ),
          if (snoozed != null)
            _Fact(
              icon: Icons.snooze_outlined,
              label: l10n.factSnoozed,
              value: Text(
                DateFormat.yMMMMEEEEd(locale).format(snoozed.toDateTime()),
              ),
            ),
          if (item.recurrence.repeats)
            _Fact(
              icon: Icons.repeat,
              label: l10n.factRepeat,
              value: Text(l10n.describeRepeat(item.recurrence)),
            ),
          if (item.kind == ItemKind.bill)
            _Fact(
              icon: Icons.payments_outlined,
              label: l10n.fieldAmount,
              value: Text(
                [
                  if (amount == null)
                    l10n.amountNotKnown
                  else
                    isolate(formatMoney(amount, locale)),
                  if (!item.amountIsFixed) l10n.amountVaries,
                ].join(' · '),
              ),
            ),
          if (notes != null)
            _Fact(
              icon: Icons.notes_outlined,
              label: l10n.fieldNotes,
              value: UserText(notes),
            ),
          if (reference != null)
            _Fact(
              icon: Icons.tag,
              label: l10n.fieldReference,
              value: ReferenceView(reference: reference),
            ),
          if (_completeAction(l10n) case (final label, final paid)?)
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 16),
              child: FilledButton.icon(
                onPressed: () => runQuickAction(
                  context,
                  action: (actions) => paid
                      ? actions.markPaid(item.id, item.scheduledOn)
                      : actions.markDone(item.id, item.scheduledOn),
                  message: paid ? l10n.markedPaid : l10n.markedDone,
                ),
                icon: const Icon(Icons.check),
                label: Text(label),
              ),
            ),
          _History(item: item),
          const SizedBox(height: 16),
          Text(
            l10n.addedAndChanged(
              item.createdAt.toLocal(),
              item.updatedAt.toLocal(),
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// The button that completes the current occurrence, if the item has one.
  (String, bool)? _completeAction(AppLocalizations l10n) {
    if (!item.isOpen ||
        item.doseTimes != null ||
        !item.recurrence.isSupported) {
      return null;
    }
    return item.kind == ItemKind.bill
        ? (l10n.markPaidButton, true)
        : (l10n.markDoneButton, false);
  }

  static String _dateLabel(AppLocalizations l10n, ItemKind kind) =>
      switch (kind) {
        ItemKind.bill => l10n.fieldDueDate,
        ItemKind.expiry => l10n.fieldExpiresOn,
        ItemKind.medicine => l10n.fieldFirstDay,
        ItemKind.appointment || ItemKind.task => l10n.fieldDate,
      };

  /// Deletes at once and offers Undo, rather than asking first: the undo
  /// puts back the item and its whole history.
  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final messenger = Messenger.of(context);
    final controller = ref.read(itemsControllerProvider.notifier);
    Navigator.of(context).pop();
    switch (await controller.delete(item)) {
      case ItemWritten(:final undo):
        messenger.showUndo(messenger.l10n.deleted, () async {
          if (await controller.undo(undo) is! ItemWritten) {
            messenger.show(messenger.l10n.undoRefused);
          }
        });
      case ItemStale():
        messenger.show(messenger.l10n.changedSince);
      case ItemNotWritten():
        messenger.show(messenger.l10n.notSaved);
    }
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 2),
            child: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                DefaultTextStyle.merge(
                  style: theme.textTheme.bodyLarge,
                  child: value,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Payments, completions and dose marks, newest first.
class _History extends ConsumerWidget {
  const _History({required this.item});

  static const _shown = 20;

  final Item item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(completionsProvider(item.id)).value;
    if (history == null || history.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              l10n.historyTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          for (final completion in history.take(_shown))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(_describe(completion, l10n)),
            ),
        ],
      ),
    );
  }

  static String _describe(Completion completion, AppLocalizations l10n) {
    final locale = l10n.localeName;
    final minute = completion.occurrenceMinute;
    final amount = completion.amount;
    return [
      l10n.outcomeLabel(completion.outcome),
      DateFormat.yMMMd(locale).format(completion.occurrenceOn.toDateTime()),
      if (minute != null) isolate(formatMinute(minute, locale)),
      if (amount != null) isolate(formatMoney(amount, locale)),
    ].join(' · ');
  }
}
