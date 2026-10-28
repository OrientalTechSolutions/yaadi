import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money/money_format.dart';
import '../../../core/text/bidi.dart';
import '../../../core/time/local_date.dart';
import '../../../core/time/time_format.dart';
import '../../../core/widgets/user_text.dart';
import '../../../l10n/app_localizations.dart';
import '../../items/domain/item.dart';
import '../../items/domain/item_kind.dart';
import '../../items/presentation/item_labels.dart';
import '../../items/presentation/item_routes.dart';
import '../application/quick_actions.dart';
import '../domain/doses.dart';
import '../domain/schedule.dart';
import '../domain/today_view.dart';
import 'quick_action_runner.dart';
import 'when_label.dart';

/// One card on the Today screen: what, when and how much, today's medicine
/// times, and the quick actions the item allows.
class TodayEntryCard extends ConsumerWidget {
  const TodayEntryCard({super.key, required this.entry, required this.today});

  final TodayEntry entry;
  final LocalDate today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final item = entry.item;
    final alert = entry.section == TodaySection.overdue;
    final pending = ref.watch(
      quickActionsProvider.select((writes) => writes.contains((item.id, null))),
    );
    final amount = item.amount;
    final when = [
      whenLabel(entry, today, l10n),
      if (item.kind == ItemKind.bill && amount == null) l10n.amountNotKnown,
    ].join(' · ');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openItemDetails(context, item.id),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KindAvatar(kind: item.kind, alert: alert),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        UserText(
                          item.title,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          when,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: alert
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (amount != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 8),
                      child: Text(
                        isolate(formatMoney(amount, l10n.localeName)),
                        style: theme.textTheme.titleSmall?.merge(
                          latinRun(theme.textTheme.titleSmall),
                        ),
                      ),
                    ),
                ],
              ),
              if (entry.doses.isNotEmpty)
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final dose in entry.doses)
                        _DoseChip(item: item, dose: dose, today: today),
                    ],
                  ),
                ),
              if (entry.actions.isNotEmpty)
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final action in _ordered(entry.actions))
                        _ActionButton(
                          action: action,
                          item: item,
                          today: today,
                          enabled: !pending,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static List<QuickAction> _ordered(Set<QuickAction> actions) => [
    for (final action in QuickAction.values)
      if (actions.contains(action)) action,
  ];
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.action,
    required this.item,
    required this.today,
    required this.enabled,
  });

  final QuickAction action;
  final Item item;
  final LocalDate today;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = item.title;
    switch (action) {
      case QuickAction.paid:
        return FilledButton.tonalIcon(
          onPressed: enabled
              ? () => runQuickAction(
                  context,
                  action: (actions) =>
                      actions.markPaid(item.id, item.scheduledOn),
                  message: l10n.markedPaid(isolate(title)),
                  sayNextDue: true,
                )
              : null,
          icon: const Icon(Icons.check),
          label: Text(
            l10n.actionPaid,
            semanticsLabel: l10n.markPaidLabel(title),
          ),
        );
      case QuickAction.done:
        return FilledButton.tonalIcon(
          onPressed: enabled
              ? () => runQuickAction(
                  context,
                  action: (actions) =>
                      actions.markDone(item.id, item.scheduledOn),
                  message: l10n.markedDone(isolate(title)),
                  sayNextDue: true,
                )
              : null,
          icon: const Icon(Icons.check),
          label: Text(
            l10n.actionDone,
            semanticsLabel: l10n.markDoneLabel(title),
          ),
        );
      case QuickAction.snooze:
        return _SnoozeButton(item: item, today: today, enabled: enabled);
      case QuickAction.reschedule:
        return OutlinedButton.icon(
          onPressed: enabled ? () => _reschedule(context) : null,
          icon: const Icon(Icons.event_repeat_outlined),
          label: Text(
            l10n.actionReschedule,
            semanticsLabel: l10n.rescheduleLabel(title),
          ),
        );
    }
  }

  Future<void> _reschedule(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: today.toDateTime(),
      firstDate: today.toDateTime(),
      lastDate: today.addDays(5 * 366).toDateTime(),
      helpText: l10n.rescheduleTo,
    );
    if (picked == null || !context.mounted) return;
    final date = LocalDate.fromDateTime(picked);
    await runQuickAction(
      context,
      action: (actions) => actions.reschedule(item.id, date),
      message: l10n.movedTo(picked),
    );
  }
}

class _SnoozeButton extends StatelessWidget {
  const _SnoozeButton({
    required this.item,
    required this.today,
    required this.enabled,
  });

  final Item item;
  final LocalDate today;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MenuAnchor(
      menuChildren: [
        for (final snooze in SnoozeFor.values)
          MenuItemButton(
            onPressed: () => runQuickAction(
              context,
              action: (actions) => actions.snooze(item.id, snooze),
              message: l10n.snoozedUntil(
                today.addDays(snooze.days).toDateTime(),
              ),
            ),
            child: Text(
              snooze == SnoozeFor.oneWeek
                  ? l10n.snoozeWeek
                  : l10n.snoozeDays(snooze.days),
            ),
          ),
      ],
      builder: (context, menu, _) => OutlinedButton.icon(
        onPressed: enabled
            ? () => menu.isOpen ? menu.close() : menu.open()
            : null,
        icon: const Icon(Icons.snooze_outlined),
        label: Text(
          l10n.actionSnooze,
          semanticsLabel: l10n.snoozeLabel(item.title),
        ),
      ),
    );
  }
}

/// One of today's medicine times. A tap marks it, and a tap on a marked time
/// takes the mark off again, so a mistaken tap can be put right after its
/// Undo has gone. The wording stays neutral: never "missed", never "take
/// now".
class _DoseChip extends ConsumerWidget {
  const _DoseChip({
    required this.item,
    required this.dose,
    required this.today,
  });

  final Item item;
  final Dose dose;
  final LocalDate today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final time = formatMinute(dose.minute, l10n.localeName);
    final pending = ref.watch(
      quickActionsProvider.select(
        (writes) => writes.contains((item.id, dose.minute)),
      ),
    );
    return FilterChip(
      selected: dose.marked,
      label: Text(
        time,
        semanticsLabel: dose.marked
            ? l10n.doseMarkedLabel(item.title, time)
            : l10n.doseNotMarkedLabel(item.title, time),
      ),
      onSelected: pending
          ? null
          : (mark) => runQuickAction(
              context,
              action: (actions) => mark
                  ? actions.markDose(item.id, today, dose.minute)
                  : actions.unmarkDose(item.id, today, dose.minute),
              message: mark ? l10n.doseMarked(time) : l10n.doseUnmarked(time),
            ),
    );
  }
}
