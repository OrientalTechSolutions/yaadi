import 'package:intl/intl.dart' show DateFormat;

import '../../../core/money/money_format.dart';
import '../../../core/text/bidi.dart';
import '../../../core/time/local_date.dart';
import '../../../core/time/time_format.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/morning_summary.dart';

/// The morning summary as short lines in the app's language.
///
/// The lines are labels ("Today: LESCO bill · Rs 4,250") rather than full
/// sentences, so Urdu never has to agree with the gender of a title the
/// user typed. Titles and amounts are isolated from the surrounding
/// direction. The same facts always produce the same lines; read-aloud in
/// M4 speaks them as they are.
List<String> morningSummaryLines(
  MorningSummary summary,
  AppLocalizations l10n,
) {
  final locale = l10n.localeName;

  // No-break spaces keep a date on one line at large text sizes, where
  // "29," at the end of a line and "October" on the next is hard to read.
  String date(LocalDate day) =>
      isolate(unbreakable(DateFormat.MMMEd(locale).format(day.toDateTime())));

  // Each dot travels with what follows it when the line wraps.
  String describe(SummaryItem item) => [
    isolate(item.title),
    if (item.minute case final minute?) isolate(formatMinute(minute, locale)),
    if (item.amount case final amount?) isolate(formatMoney(amount, locale)),
  ].join(' ·$noBreakSpace');

  final firstOverdue = summary.firstOverdue;
  final comingUp = summary.comingUp;
  return [
    if (summary.isQuietToday) l10n.summaryQuietToday,
    if (firstOverdue != null)
      l10n.summaryOverdue(summary.overdue - 1, isolate(firstOverdue)),
    if (summary.toConfirm > 0) l10n.summaryToConfirm(summary.toConfirm),
    for (final item in summary.today) l10n.summaryToday(describe(item)),
    if (summary.moreToday > 0) l10n.summaryMoreToday(summary.moreToday),
    if (summary.dosesToday > 0)
      summary.dosesMarked < summary.dosesToday
          ? l10n.summaryDosesLeft(
              summary.dosesToday - summary.dosesMarked,
              summary.dosesToday,
            )
          : l10n.summaryDosesMarked(summary.dosesToday),
    if (comingUp != null)
      l10n.summaryComingUp(date(comingUp.on), isolate(comingUp.title)),
    if (summary.totals.isNotEmpty)
      l10n.summaryToPay(
        [
          for (final total in summary.totals)
            isolate(formatMoney(total, locale)),
        ].join(' · '),
        date(summary.payBy),
      ),
    if (summary.unknownAmounts > 0)
      l10n.summaryUnknownAmounts(summary.unknownAmounts),
  ];
}
