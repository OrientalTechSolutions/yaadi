import 'package:yaadi/features/reminders/data/reminder_gateway.dart';
import 'package:yaadi/features/reminders/domain/reminder_payload.dart';

/// Records what the app asks of the phone's notifications.
final class FakeReminders implements ReminderGateway {
  FakeReminders({this.health_ = const ReminderHealth(), this.launch});

  /// What [health] reports; tests change it to simulate the user fixing a
  /// setting.
  ReminderHealth health_;

  /// The tap that "launched" the app.
  ReminderTap? launch;

  /// The last full schedule handed over, or null before the first.
  List<ScheduledReminder>? scheduled;
  int replaceCount = 0;
  final tests = <ScheduledReminder>[];
  int permissionRequests = 0;
  bool grantOnRequest = true;
  int exactRequests = 0;
  int batteryOpens = 0;

  void Function(ReminderTap tap)? _onTap;

  /// Simulates a tap on a notification while the app runs.
  void tap(ReminderTap tap) => _onTap!(tap);

  @override
  Future<void> initialize(
    ChannelNames channels,
    void Function(ReminderTap tap) onTap,
  ) async => _onTap = onTap;

  @override
  Future<ReminderTap?> launchTap() async {
    final tap = launch;
    launch = null;
    return tap;
  }

  @override
  Future<void> replaceAll(List<ScheduledReminder> reminders) async {
    scheduled = reminders;
    replaceCount++;
  }

  @override
  Future<ReminderHealth> health() async => health_;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    if (grantOnRequest) {
      health_ = ReminderHealth(
        notificationsAllowed: true,
        exactAllowed: health_.exactAllowed,
        batteryUnrestricted: health_.batteryUnrestricted,
        manufacturer: health_.manufacturer,
      );
    }
    return grantOnRequest;
  }

  @override
  Future<void> requestExactTimes() async => exactRequests++;

  @override
  Future<void> openBatterySettings() async => batteryOpens++;

  @override
  Future<void> showTest(ScheduledReminder reminder, Duration delay) async =>
      tests.add(reminder);
}
