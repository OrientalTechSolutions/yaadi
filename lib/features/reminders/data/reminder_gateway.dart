import 'package:meta/meta.dart';

import '../../../core/time/local_date.dart';
import '../domain/reminder_payload.dart';

/// Which notification channel a reminder uses. Android lets the user mute
/// each one on its own.
enum ReminderChannel { reminders, summary }

/// One notification ready for the phone: wall-clock time, text and buttons.
@immutable
final class ScheduledReminder {
  const ScheduledReminder({
    required this.id,
    required this.on,
    required this.minute,
    required this.title,
    required this.body,
    required this.payload,
    this.channel = ReminderChannel.reminders,
    this.actions = const [],
  });

  final int id;
  final LocalDate on;
  final int minute;
  final String title;
  final String body;
  final String payload;
  final ReminderChannel channel;

  /// Each button with its label in the app's language.
  final List<(ReminderAction, String)> actions;

  @override
  bool operator ==(Object other) =>
      other is ScheduledReminder &&
      other.id == id &&
      other.on == on &&
      other.minute == minute &&
      other.title == title &&
      other.body == body &&
      other.payload == payload &&
      other.channel == channel &&
      _sameActions(other.actions, actions);

  @override
  int get hashCode => Object.hash(
    id,
    on,
    minute,
    title,
    body,
    payload,
    channel,
    Object.hashAll(actions),
  );

  /// Leaves out the text, which may hold titles.
  @override
  String toString() => 'ScheduledReminder($id, $on, $minute, ${channel.name})';
}

bool _sameActions(
  List<(ReminderAction, String)> a,
  List<(ReminderAction, String)> b,
) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Text for the notification channels, which Android shows in the app's
/// notification settings.
typedef ChannelNames = ({
  String reminders,
  String remindersDescription,
  String summary,
  String summaryDescription,
});

/// Whether reminders will actually arrive, as far as the phone says.
@immutable
final class ReminderHealth {
  const ReminderHealth({
    this.notificationsAllowed,
    this.exactAllowed,
    this.batteryUnrestricted,
    this.manufacturer,
  });

  /// Everything fine, as on a platform that does not report these.
  static const unknown = ReminderHealth();

  /// Null when the phone did not say.
  final bool? notificationsAllowed;

  /// Android 12 and later can withhold exact alarms; without them a
  /// reminder may come some minutes late.
  final bool? exactAllowed;

  /// Whether Android's battery optimisation leaves Yaadi alone.
  final bool? batteryUnrestricted;

  /// The phone's maker, lower case, for makers known to stop reminders.
  final String? manufacturer;

  bool get notificationsOff => notificationsAllowed == false;

  @override
  bool operator ==(Object other) =>
      other is ReminderHealth &&
      other.notificationsAllowed == notificationsAllowed &&
      other.exactAllowed == exactAllowed &&
      other.batteryUnrestricted == batteryUnrestricted &&
      other.manufacturer == manufacturer;

  @override
  int get hashCode => Object.hash(
    notificationsAllowed,
    exactAllowed,
    batteryUnrestricted,
    manufacturer,
  );

  @override
  String toString() =>
      'ReminderHealth(notifications: $notificationsAllowed, '
      'exact: $exactAllowed, battery: $batteryUnrestricted, '
      'maker: $manufacturer)';
}

/// The phone's notification system, as the app needs it.
abstract interface class ReminderGateway {
  /// Sets up channels and the time zone. [onTap] hears about taps while the
  /// app runs; [launchTap] about the one that started it.
  Future<void> initialize(
    ChannelNames channels,
    void Function(ReminderTap tap) onTap,
  );

  /// The tap that launched the app, once; null afterwards.
  Future<ReminderTap?> launchTap();

  /// Replaces every scheduled reminder with [reminders]. Notifications
  /// already on screen stay.
  Future<void> replaceAll(List<ScheduledReminder> reminders);

  Future<ReminderHealth> health();

  /// Asks for notification permission. True when granted.
  Future<bool> requestPermission();

  /// Opens the system screen that allows exact alarms.
  Future<void> requestExactTimes();

  /// Opens the system's battery optimisation settings.
  Future<void> openBatterySettings();

  /// Shows [reminder] after [delay], whatever is scheduled.
  Future<void> showTest(ScheduledReminder reminder, Duration delay);
}

/// For the web demo, tests and anywhere else without notifications.
final class NoReminders implements ReminderGateway {
  const NoReminders();

  @override
  Future<void> initialize(
    ChannelNames channels,
    void Function(ReminderTap tap) onTap,
  ) async {}

  @override
  Future<ReminderTap?> launchTap() async => null;

  @override
  Future<void> replaceAll(List<ScheduledReminder> reminders) async {}

  @override
  Future<ReminderHealth> health() async => ReminderHealth.unknown;

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> requestExactTimes() async {}

  @override
  Future<void> openBatterySettings() async {}

  @override
  Future<void> showTest(ScheduledReminder reminder, Duration delay) async {}
}
