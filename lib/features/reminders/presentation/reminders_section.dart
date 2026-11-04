import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/time/time_format.dart';
import '../../../core/widgets/heading.dart';
import '../../../core/widgets/messenger.dart';
import '../../../l10n/app_localizations.dart';
import '../../demo/application/demo_providers.dart';
import '../../settings/application/settings_controller.dart';
import '../application/reminder_providers.dart';
import '../application/reminder_text.dart';
import '../domain/reminder_plan.dart';

/// Makers whose battery managers are known to stop scheduled alarms unless
/// the user allows Autostart (dontkillmyapp.com).
const _strictMakers = {
  'xiaomi': 'Xiaomi',
  'redmi': 'Xiaomi',
  'poco': 'Xiaomi',
  'oppo': 'Oppo',
  'realme': 'Realme',
  'oneplus': 'OnePlus',
  'vivo': 'Vivo',
  'iqoo': 'Vivo',
  'huawei': 'Huawei',
  'honor': 'Honor',
  'infinix': 'Infinix',
  'tecno': 'Tecno',
  'itel': 'itel',
  'samsung': 'Samsung',
};

/// The Reminders part of Settings: the switches, the two times, and what
/// the phone says about whether reminders will arrive.
class RemindersSection extends ConsumerWidget {
  const RemindersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final prefs = ref.watch(reminderPrefsProvider);
    final demo = ref.watch(demoHouseholdProvider) != null;
    final controller = ref.read(settingsProvider.notifier);
    final locale = l10n.localeName;

    void save(ReminderPrefs next) => controller.setReminders(next);

    Future<void> pickTime(
      int current,
      ReminderPrefs Function(int) apply,
    ) async {
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
      );
      if (picked != null) save(apply(picked.hour * 60 + picked.minute));
    }

    final hint = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 4),
          child: Heading(
            l10n.settingsReminders,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        if (demo)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
            child: Text(l10n.remindersDemoPaused, style: hint),
          ),
        SwitchListTile(
          value: prefs.enabled,
          onChanged: (on) async {
            save(prefs.copyWith(enabled: on));
            // Turning reminders on is the moment to ask the phone.
            if (on) await askReminderPermission(context, ref);
          },
          title: Text(l10n.remindersSwitch),
          subtitle: Text(l10n.remindersSwitchHint),
        ),
        if (prefs.enabled) ...[
          ListTile(
            leading: const Icon(Icons.schedule),
            title: Text(l10n.reminderTime),
            subtitle: Text(l10n.reminderTimeHint),
            trailing: Text(formatMinute(prefs.remindMinute, locale)),
            onTap: () => pickTime(
              prefs.remindMinute,
              (minute) => prefs.copyWith(remindMinute: minute),
            ),
          ),
          SwitchListTile(
            value: prefs.morningSummary,
            onChanged: (on) => save(prefs.copyWith(morningSummary: on)),
            title: Text(l10n.summaryReminderSwitch),
            subtitle: Text(l10n.summaryReminderHint),
          ),
          if (prefs.morningSummary)
            ListTile(
              leading: const Icon(Icons.wb_sunny_outlined),
              title: Text(l10n.summaryTime),
              trailing: Text(formatMinute(prefs.summaryMinute, locale)),
              onTap: () => pickTime(
                prefs.summaryMinute,
                (minute) => prefs.copyWith(summaryMinute: minute),
              ),
            ),
          SwitchListTile(
            value: prefs.showTitles,
            onChanged: (on) => save(prefs.copyWith(showTitles: on)),
            title: Text(l10n.reminderTitlesSwitch),
            subtitle: Text(l10n.reminderTitlesHint),
          ),
          const _HealthChecks(),
        ],
      ],
    );
  }
}

/// Asks the phone for notification permission, and says so when it has
/// been refused for good. Also used by the Today card.
Future<void> askReminderPermission(BuildContext context, WidgetRef ref) async {
  final messenger = Messenger.of(context);
  final l10n = AppLocalizations.of(context);
  final granted = await ref.read(reminderGatewayProvider).requestPermission();
  ref.invalidate(reminderHealthProvider);
  final health = await ref.read(reminderHealthProvider.future);
  if (!granted && health.notificationsOff) {
    messenger.show(l10n.remindersBlocked);
  }
}

class _HealthChecks extends ConsumerWidget {
  const _HealthChecks();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final gateway = ref.read(reminderGatewayProvider);
    final health = ref.watch(reminderHealthProvider).value;
    if (health == null) return const SizedBox.shrink();
    final maker = _strictMakers[health.manufacturer];

    Widget check({
      required bool? ok,
      required String good,
      required String bad,
      required String fixLabel,
      required Future<void> Function() fix,
    }) {
      if (ok == null) return const SizedBox.shrink();
      return ListTile(
        leading: Icon(
          ok ? Icons.check_circle_outline : Icons.error_outline,
          color: ok ? theme.colorScheme.primary : theme.colorScheme.error,
        ),
        title: Text(ok ? good : bad),
        trailing: ok
            ? null
            : TextButton(
                onPressed: () async {
                  await fix();
                  ref.invalidate(reminderHealthProvider);
                },
                child: Text(fixLabel),
              ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
          child: Heading(
            l10n.reminderHealthTitle,
            style: theme.textTheme.titleSmall,
          ),
        ),
        check(
          ok: health.notificationsAllowed,
          good: l10n.healthNotificationsOk,
          bad: l10n.healthNotificationsOff,
          fixLabel: l10n.healthAllow,
          fix: () => askReminderPermission(context, ref),
        ),
        check(
          ok: health.exactAllowed,
          good: l10n.healthExactOk,
          bad: l10n.healthExactOff,
          fixLabel: l10n.healthFix,
          fix: gateway.requestExactTimes,
        ),
        check(
          ok: health.batteryUnrestricted,
          good: l10n.healthBatteryOk,
          bad: l10n.healthBatteryOff,
          fixLabel: l10n.healthFix,
          fix: gateway.openBatterySettings,
        ),
        if (maker != null)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 8),
            child: Text(
              l10n.healthMakerTip(maker),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ListTile(
          leading: const Icon(Icons.notifications_active_outlined),
          title: Text(l10n.testReminder),
          subtitle: Text(l10n.testReminderHint),
          onTap: () async {
            final messenger = Messenger.of(context);
            await gateway.showTest(
              testReminder(l10n),
              const Duration(seconds: 10),
            );
            messenger.show(l10n.testReminderSent);
          },
        ),
      ],
    );
  }
}
