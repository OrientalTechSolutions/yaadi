import 'package:flutter/material.dart';

import '../../../core/money/money_format.dart';
import '../../../core/text/bidi.dart';
import '../../../core/widgets/user_text.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/item.dart';
import 'item_labels.dart';

/// One item in a list: what it is, when it is due and how much.
class ItemTile extends StatelessWidget {
  const ItemTile({super.key, required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final due = item.dueOn;
    final amount = item.amount;
    final details = [
      l10n.categoryLabel(item.category),
      if (due == null) l10n.noDueDate else l10n.dueOn(due.toDateTime()),
      if (amount != null) isolate(formatMoney(amount, locale)),
    ];

    return ListTile(
      leading: Icon(
        kindIcon(item.kind),
        semanticLabel: l10n.kindLabel(item.kind),
      ),
      title: UserText(item.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(details.join(' · ')),
    );
  }
}
