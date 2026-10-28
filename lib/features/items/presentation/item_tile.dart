import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money/money_format.dart';
import '../../../core/text/bidi.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/local_date.dart';
import '../../../core/widgets/user_text.dart';
import '../../../l10n/app_localizations.dart';
import '../../today/domain/doses.dart';
import '../domain/item.dart';
import 'item_labels.dart';
import 'item_routes.dart';

/// The label for a finished item in a list: Paid, Done, or Course ended for
/// a medicine course past its last day. Null while the item is active.
String? finishedLabel(Item item, LocalDate today, AppLocalizations l10n) {
  if (!item.isOpen) return l10n.statusLabel(item.status);
  return item.courseEndedBefore(today) ? l10n.courseEnded : null;
}

/// One item in a list: what it is, when it is due and how much. Opens the
/// item's page when tapped.
class ItemTile extends ConsumerWidget {
  const ItemTile({super.key, required this.item});

  final Item item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final amount = item.amount;
    final finished = finishedLabel(item, ref.watch(todayProvider), l10n);

    return ListTile(
      contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 4),
      leading: KindAvatar(kind: item.kind),
      title: UserText(item.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text:
                  '${l10n.categoryLabel(item.category)} · '
                  '${l10n.dateSummary(item)}',
            ),
            if (amount != null) ...[
              // The dot travels with the amount when it wraps.
              const TextSpan(text: ' ·$noBreakSpace'),
              TextSpan(
                text: isolate(formatMoney(amount, l10n.localeName)),
                // ListTile sets its subtitle in bodyMedium.
                style: latinRun(Theme.of(context).textTheme.bodyMedium),
              ),
            ],
          ],
        ),
      ),
      trailing: finished == null ? null : StatusBadge(label: finished),
      onTap: () => openItemDetails(context, item.id),
    );
  }
}

/// A small label such as "Paid" next to a closed item.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
