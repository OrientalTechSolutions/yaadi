import '../../../core/money/money_format.dart';
import '../../../core/text/bidi.dart';
import '../../../core/time/local_date.dart';
import '../../../core/time/time_format.dart';
import '../../../l10n/app_localizations.dart';
import '../../items/domain/item_kind.dart';
import '../../today/application/morning_summary_text.dart';
import '../data/reminder_gateway.dart';
import '../domain/reminder_payload.dart';
import '../domain/reminder_plan.dart';

/// [plan] as notifications in the app's language, with ids from
/// [notificationIds].
///
/// Unless the user turned titles on, nothing here names an item: the phone
/// stores scheduled notifications outside the vault (ARCHITECTURE.md
/// section 18). References and notes never appear either way.
List<ScheduledReminder> scheduledReminders(
  List<PlannedReminder> plan,
  AppLocalizations l10n, {
  required bool showTitles,
}) {
  final ids = notificationIds(plan);
  return [
    for (final reminder in plan)
      _scheduled(reminder, ids[reminder.key]!, l10n, showTitles: showTitles),
  ];
}

ScheduledReminder _scheduled(
  PlannedReminder reminder,
  int id,
  AppLocalizations l10n, {
  required bool showTitles,
}) {
  final locale = l10n.localeName;
  final (title, body) = showTitles
      ? _named(reminder, l10n, locale)
      : _anonymous(reminder, l10n, locale);
  return ScheduledReminder(
    id: id,
    on: reminder.on,
    minute: reminder.minute,
    title: title,
    body: body,
    payload: reminderPayload(reminder),
    channel: reminder.reason == ReminderReason.morningSummary
        ? ReminderChannel.summary
        : ReminderChannel.reminders,
    actions: [
      for (final action in reminderActions(reminder))
        (action, actionLabel(action, l10n)),
    ],
  );
}

String actionLabel(ReminderAction action, AppLocalizations l10n) =>
    switch (action) {
      ReminderAction.paid => l10n.actionPaid,
      ReminderAction.done => l10n.actionDone,
      ReminderAction.snoozeTomorrow => l10n.notifySnoozeTomorrow,
      ReminderAction.taken => l10n.notifyTaken,
    };

/// Title and text that say what kind of thing is due, never which one.
(String, String) _anonymous(
  PlannedReminder reminder,
  AppLocalizations l10n,
  String locale,
) {
  final time = isolate(formatMinute(reminder.minute, locale));
  if (reminder.summary case final summary?) {
    final parts = [
      if (summary.overdue > 0) l10n.notifySummaryOverdue(summary.overdue),
      if (summary.toConfirm > 0) l10n.notifySummaryToConfirm(summary.toConfirm),
      if (summary.today.length + summary.moreToday > 0)
        l10n.notifySummaryToday(summary.today.length + summary.moreToday),
      if (summary.dosesToday > summary.dosesMarked)
        l10n.notifySummaryDoses(summary.dosesToday - summary.dosesMarked),
    ];
    return (l10n.channelSummary, parts.join(' · '));
  }
  final item = reminder.item!;
  final title = switch (reminder.reason) {
    ReminderReason.dueToday => switch (item.kind) {
      ItemKind.bill => l10n.notifyBillToday,
      ItemKind.appointment => l10n.notifyAppointmentToday,
      _ => l10n.notifyTaskToday,
    },
    ReminderReason.dueTomorrow =>
      item.kind == ItemKind.bill
          ? l10n.notifyBillTomorrow
          : l10n.notifyAppointmentTomorrow,
    ReminderReason.startsSoon => l10n.notifyAppointmentAt(
      isolate(formatMinute(item.dueMinute ?? reminder.minute, locale)),
    ),
    ReminderReason.expiresIn => l10n.notifyExpiry(reminder.daysAhead),
    ReminderReason.dose => l10n.notifyMedicine(time),
    ReminderReason.morningSummary => l10n.channelSummary,
  };
  return (title, l10n.notifyOpen);
}

/// The item's own title, with what is due and, for a bill, its amount.
(String, String) _named(
  PlannedReminder reminder,
  AppLocalizations l10n,
  String locale,
) {
  if (reminder.summary case final summary?) {
    return (l10n.channelSummary, morningSummaryLines(summary, l10n).join('\n'));
  }
  final item = reminder.item!;
  final what = switch (reminder.reason) {
    ReminderReason.dueToday => l10n.notifyDueToday,
    ReminderReason.dueTomorrow => l10n.notifyDueTomorrow,
    ReminderReason.startsSoon => l10n.notifyAt(
      isolate(formatMinute(item.dueMinute ?? reminder.minute, locale)),
    ),
    ReminderReason.expiresIn => l10n.notifyExpiresIn(reminder.daysAhead),
    ReminderReason.dose => l10n.notifyMedicine(
      isolate(formatMinute(reminder.minute, locale)),
    ),
    ReminderReason.morningSummary => '',
  };
  final amount = item.kind == ItemKind.bill ? item.amount : null;
  final body = amount == null
      ? what
      : '$what ·$noBreakSpace${isolate(formatMoney(amount, locale))}';
  return (item.title, body);
}

/// The one-off test notification. It is shown after a delay, so its date
/// is only a placeholder.
ScheduledReminder testReminder(AppLocalizations l10n) => ScheduledReminder(
  id: testReminderId,
  on: LocalDate(2000, 1, 1),
  minute: 0,
  title: l10n.testReminderTitle,
  body: l10n.testReminderBody,
  payload: '{}',
);
