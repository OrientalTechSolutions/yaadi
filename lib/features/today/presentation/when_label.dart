import 'package:intl/intl.dart' show DateFormat;

import '../../../core/text/bidi.dart';
import '../../../core/time/local_date.dart';
import '../../../core/time/time_format.dart';
import '../../../l10n/app_localizations.dart';
import '../../items/domain/item_kind.dart';
import '../domain/today_view.dart';

/// When a Today card is due, relative to [today]: "Overdue by 2 days",
/// "Due today · 6:00 PM", "Expires in 23 days". A snoozed card always names
/// its real due date too.
String whenLabel(TodayEntry entry, LocalDate today, AppLocalizations l10n) {
  final on = entry.on;
  if (on == null) return l10n.noDueDate;
  if (entry.doses.isNotEmpty) return l10n.dosesToday;

  final item = entry.item;
  final date = on.toDateTime();
  final days = today.daysUntil(on);
  final isBill = item.kind == ItemKind.bill;
  final String when;
  if (item.doseTimes != null) {
    when = l10n.startsOn(date);
  } else if (entry.snoozedFrom case final due?) {
    final locale = l10n.localeName;
    when = l10n.snoozedTo(
      isolate(unbreakable(DateFormat.MMMEd(locale).format(date))),
      isolate(unbreakable(DateFormat.MMMd(locale).format(due.toDateTime()))),
    );
  } else if (item.kind == ItemKind.expiry) {
    when = days < 0
        ? l10n.expiredDaysAgo(-days)
        : days == 0
        ? l10n.expiresToday
        : l10n.expiresInDays(days);
  } else if (entry.section == TodaySection.toConfirm) {
    when = days == -1 ? l10n.wasYesterday : l10n.wasOn(date);
  } else if (days < 0) {
    when = l10n.overdueByDays(-days);
  } else if (days == 0) {
    when = isBill ? l10n.dueToday : l10n.whenToday;
  } else if (days == 1) {
    when = isBill ? l10n.dueTomorrow : l10n.whenTomorrow;
  } else if (days <= TodayRules.nextDays) {
    when = l10n.inDays(days, date);
  } else {
    when = on.year == today.year
        ? l10n.onDate(date)
        : l10n.onDateWithYear(date);
  }

  final minute = item.dueMinute;
  if (minute == null || item.doseTimes != null) return when;
  return '$when · ${isolate(formatMinute(minute, l10n.localeName))}';
}
