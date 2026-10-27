import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../core/text/bidi.dart';
import '../../../core/time/local_date.dart';
import '../../../core/time/time_format.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/completion.dart';
import '../domain/item.dart';
import '../domain/item_category.dart';
import '../domain/item_kind.dart';
import '../domain/item_status.dart';
import '../domain/recurrence.dart';

extension ItemLabels on AppLocalizations {
  String kindLabel(ItemKind kind) => switch (kind) {
    ItemKind.bill => kindBill,
    ItemKind.appointment => kindAppointment,
    ItemKind.expiry => kindExpiry,
    ItemKind.medicine => kindMedicine,
    ItemKind.task => kindTask,
  };

  String categoryLabel(ItemCategory category) => switch (category) {
    ItemCategory.electricity => categoryElectricity,
    ItemCategory.gas => categoryGas,
    ItemCategory.water => categoryWater,
    ItemCategory.internet => categoryInternet,
    ItemCategory.phone => categoryPhone,
    ItemCategory.school => categorySchool,
    ItemCategory.rent => categoryRent,
    ItemCategory.health => categoryHealth,
    ItemCategory.idDocument => categoryIdDocument,
    ItemCategory.warranty => categoryWarranty,
    ItemCategory.other => categoryOther,
  };

  String statusLabel(ItemStatus status) => switch (status) {
    ItemStatus.open => statusOpen,
    ItemStatus.paid => statusPaid,
    ItemStatus.done => statusDone,
  };

  String outcomeLabel(CompletionOutcome outcome) => switch (outcome) {
    CompletionOutcome.paid => statusPaid,
    CompletionOutcome.done => statusDone,
    CompletionOutcome.skipped => outcomeSkipped,
  };

  /// A choice in the editor's Repeat field.
  String repeatRuleLabel(RepeatRule rule) => switch (rule) {
    RepeatRule.none => repeatNone,
    RepeatRule.daily => repeatDaily,
    RepeatRule.weekly => repeatWeekly,
    RepeatRule.monthly => repeatMonthly,
    RepeatRule.yearly => repeatYearly,
    RepeatRule.doses => repeatDoses,
  };

  /// How [recurrence] repeats, in words: "Every month on day 10, until
  /// Jan 31, 2027".
  String describeRepeat(Recurrence recurrence) {
    final rule = switch (recurrence) {
      NoRepeat() => repeatNone,
      DailyRepeat() => repeatDaily,
      WeeklyRepeat(:final weekday) => repeatWeeklyOn(weekdayName(weekday)),
      MonthlyRepeat(:final day) when day > 28 => repeatMonthlyOnLate(day),
      MonthlyRepeat(:final day) => repeatMonthlyOn(day),
      YearlyRepeat(:final month, :final day) => repeatYearlyOn(
        DateTime(2000, month, day),
      ),
      DoseTimes(:final minutes) => repeatDosesAt(
        minutes.map((minute) => formatMinute(minute, localeName)).join(', '),
      ),
      UnsupportedRepeat() => repeatUnsupported,
    };
    final until = recurrence.until;
    return until == null ? rule : repeatUntil(rule, until.toDateTime());
  }

  /// When [item] is, in the words its kind needs, for lists: a bill's due
  /// date, when an ID card expires, an appointment's day and time, or a
  /// medicine's times. Never a "deadline" for a dentist or a tablet.
  String dateSummary(Item item) {
    final due = item.dueOn;
    if (due == null) return noDueDate;
    final minute = item.dueMinute;
    return switch (item.kind) {
      ItemKind.medicine when item.doseTimes != null => describeRepeat(
        item.recurrence,
      ),
      ItemKind.expiry => expiresOn(due.toDateTime()),
      ItemKind.appointment || ItemKind.medicine => [
        onDateWithYear(due.toDateTime()),
        if (minute != null) isolate(formatMinute(minute, localeName)),
      ].join(' · '),
      ItemKind.bill || ItemKind.task => dueOn(due.toDateTime()),
    };
  }

  /// The ISO [weekday] (1 is Monday) by name in this language.
  String weekdayName(int weekday) =>
      DateFormat.EEEE(localeName)
          .format(LocalDate(2024, 1, weekday).toDateTime());
}

IconData kindIcon(ItemKind kind) => switch (kind) {
  ItemKind.bill => Icons.receipt_long_outlined,
  ItemKind.appointment => Icons.event_outlined,
  ItemKind.expiry => Icons.badge_outlined,
  ItemKind.medicine => Icons.medication_outlined,
  ItemKind.task => Icons.task_alt_outlined,
};

/// The kind's icon in a tinted circle; [alert] marks something overdue.
class KindAvatar extends StatelessWidget {
  const KindAvatar({super.key, required this.kind, this.alert = false});

  final ItemKind kind;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: alert ? colors.errorContainer : colors.secondaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        kindIcon(kind),
        size: 22,
        color: alert ? colors.onErrorContainer : colors.onSecondaryContainer,
        semanticLabel: AppLocalizations.of(context).kindLabel(kind),
      ),
    );
  }
}
