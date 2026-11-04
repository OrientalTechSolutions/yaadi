import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/text/bidi.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/time_format.dart';
import '../../../core/widgets/messenger.dart';
import '../../../l10n/app_localizations.dart';
import '../../demo/application/demo_providers.dart';
import '../../items/application/items_providers.dart';
import '../../items/presentation/item_routes.dart';
import '../../today/domain/schedule.dart';
import '../../today/presentation/quick_action_runner.dart';
import '../application/reminder_providers.dart';
import '../domain/reminder_payload.dart';

/// Keeps the phone's scheduled reminders in step with the items, and acts
/// on taps: a tapped reminder opens its item, and a button runs the same
/// quick action as the Today screen, with the same Undo.
///
/// Sits below the vault gate, where the items are open. [onShowToday] asks
/// the home screen to show the Today tab.
class ReminderSync extends ConsumerStatefulWidget {
  const ReminderSync({
    super.key,
    required this.onShowToday,
    required this.child,
  });

  final VoidCallback onShowToday;
  final Widget child;

  @override
  ConsumerState<ReminderSync> createState() => _ReminderSyncState();
}

class _ReminderSyncState extends ConsumerState<ReminderSync> {
  /// Edits often come in bursts, such as a quick action and its roll
  /// forward; one pass after they settle is enough.
  static const _settle = Duration(milliseconds: 800);

  late final AppLifecycleListener _lifecycle;
  Timer? _pending;
  bool _initialized = false;
  bool _handling = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _onResume);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      unawaited(_initialize());
    } else {
      // The language changed: the scheduled text must follow.
      _schedule();
    }
  }

  Future<void> _initialize() async {
    final l10n = AppLocalizations.of(context);
    final gateway = ref.read(reminderGatewayProvider);
    final taps = ref.read(reminderTapsProvider.notifier);
    await gateway.initialize((
      reminders: l10n.channelReminders,
      remindersDescription: l10n.channelRemindersDescription,
      summary: l10n.channelSummary,
      summaryDescription: l10n.channelSummaryDescription,
    ), taps.add);
    final launch = await gateway.launchTap();
    if (launch != null) taps.add(launch);
    _schedule();
  }

  /// Back from the phone's settings or another app: the date, the time
  /// zone and the permissions may all have changed.
  void _onResume() {
    ref.invalidate(reminderHealthProvider);
    _schedule();
  }

  void _schedule() {
    // The web demo and tests have nothing to schedule.
    if (!_initialized || !ref.read(remindersAvailableProvider)) return;
    _pending?.cancel();
    _pending = Timer(_settle, _sync);
  }

  Future<void> _sync() async {
    final inputs = ref.read(reminderInputsProvider);
    if (inputs == null || !mounted) return;
    try {
      await syncReminders(
        ref.read(reminderGatewayProvider),
        inputs,
        AppLocalizations.of(context),
        now: ref.read(clockProvider)(),
      );
    } on Exception {
      // A phone that refuses to schedule keeps what it had; the next
      // change or resume tries again, and Settings shows the cause.
    }
  }

  @override
  void dispose() {
    _pending?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _handleTaps() async {
    if (_handling) return;
    _handling = true;
    try {
      while (mounted) {
        final tap = ref.read(reminderTapsProvider.notifier).take();
        if (tap == null) break;
        await _handle(tap);
      }
    } finally {
      _handling = false;
    }
  }

  Future<void> _handle(ReminderTap tap) async {
    final l10n = AppLocalizations.of(context);
    final itemId = tap.itemId;
    widget.onShowToday();
    // A demo household is on screen: the reminder was about the user's own
    // items, which are not here.
    if (itemId == null || ref.read(showingDemoProvider)) return;
    final items = await ref.read(itemsProvider.future);
    if (!mounted) return;
    final item = items.where((item) => item.id == itemId).firstOrNull;
    if (item == null) {
      Messenger.of(context).show(l10n.notifyItemGone);
      return;
    }
    final title = isolate(item.title);
    switch (tap.action) {
      case null:
        await openItemDetails(context, itemId);
      case ReminderAction.paid:
        await runQuickAction(
          context,
          action: (actions) => actions.markPaid(itemId, tap.scheduledOn),
          message: l10n.markedPaid(title),
          sayNextDue: true,
        );
      case ReminderAction.done:
        await runQuickAction(
          context,
          action: (actions) => actions.markDone(itemId, tap.scheduledOn),
          message: l10n.markedDone(title),
          sayNextDue: true,
        );
      case ReminderAction.snoozeTomorrow:
        final today = ref.read(todayProvider);
        await runQuickAction(
          context,
          action: (actions) => actions.snooze(itemId, SnoozeFor.oneDay),
          message: l10n.snoozedUntil(today.addDays(1).toDateTime()),
        );
      case ReminderAction.taken:
        final (on, minute) = (tap.doseOn, tap.doseMinute);
        if (on == null || minute == null) return;
        final time = isolate(formatMinute(minute, l10n.localeName));
        await runQuickAction(
          context,
          action: (actions) => actions.markDose(itemId, on, minute),
          message: l10n.doseMarked(time),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref
      ..listen(reminderInputsProvider, (_, _) => _schedule())
      ..listen(reminderTapsProvider, (_, taps) {
        if (taps.isNotEmpty) unawaited(_handleTaps());
      });
    return widget.child;
  }
}
