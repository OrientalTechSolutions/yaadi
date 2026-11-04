import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_10y.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../domain/reminder_payload.dart';
import 'reminder_gateway.dart';
import 'wall_clock.dart';

/// Reminders through `flutter_local_notifications`, which keeps scheduled
/// notifications in the phone's alarm system and puts them back after a
/// restart or an app update.
final class LocalNotificationsGateway implements ReminderGateway {
  LocalNotificationsGateway({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  /// Battery settings and the phone's maker, from `MainActivity.kt`.
  static const _health = MethodChannel('yaadi/reminder_health');

  /// The drawable Android shows in the status bar: white on transparent.
  static const _icon = 'ic_stat_yaadi';

  ChannelNames? _channels;
  tz.Location? _location;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<void> initialize(
    ChannelNames channels,
    void Function(ReminderTap tap) onTap,
  ) async {
    _channels = channels;
    tzdata.initializeTimeZones();
    _location = await _localZone();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(_icon),
        // Permission is asked for when the user turns reminders on, never
        // at launch.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestSoundPermission: false,
          requestBadgePermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) =>
          onTap(readReminderTap(response.payload, actionId: response.actionId)),
    );
  }

  /// The phone's zone, read again before every scheduling pass so a trip
  /// abroad moves reminders to the new local times. UTC if the phone
  /// names a zone the database does not know.
  Future<tz.Location> _localZone() async {
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      return tz.getLocation(info.identifier);
    } on Object {
      return tz.UTC;
    }
  }

  @override
  Future<ReminderTap?> launchTap() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    final response = details?.notificationResponse;
    if (details == null || !details.didNotificationLaunchApp) return null;
    if (response == null) return null;
    return readReminderTap(response.payload, actionId: response.actionId);
  }

  @override
  Future<void> replaceAll(List<ScheduledReminder> reminders) async {
    final location = _location = await _localZone();
    final mode = await _scheduleMode();
    await _plugin.cancelAllPendingNotifications();
    final now = tz.TZDateTime.now(location);
    for (final reminder in reminders) {
      final at = wallClock(location, reminder.on, reminder.minute);
      // Planning skips the past, but the clock may have moved on since.
      if (!at.isAfter(now)) continue;
      await _plugin.zonedSchedule(
        id: reminder.id,
        scheduledDate: at,
        notificationDetails: _details(reminder),
        androidScheduleMode: mode,
        title: reminder.title,
        body: reminder.body,
        payload: reminder.payload,
      );
    }
  }

  /// Exact while the phone allows it, otherwise as close as Android
  /// manages while idle.
  Future<AndroidScheduleMode> _scheduleMode() async {
    final exact = await _android?.canScheduleExactNotifications() ?? false;
    return exact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  NotificationDetails _details(ScheduledReminder reminder) {
    final channels =
        _channels ??
        (
          reminders: 'Reminders',
          remindersDescription: '',
          summary: 'Morning summary',
          summaryDescription: '',
        );
    final summary = reminder.channel == ReminderChannel.summary;
    return NotificationDetails(
      android: AndroidNotificationDetails(
        summary ? 'summary' : 'reminders',
        summary ? channels.summary : channels.reminders,
        channelDescription: summary
            ? channels.summaryDescription
            : channels.remindersDescription,
        importance: summary ? Importance.defaultImportance : Importance.high,
        priority: summary ? Priority.defaultPriority : Priority.high,
        category: AndroidNotificationCategory.reminder,
        // The lock screen shows that Yaadi has a reminder, not its text.
        visibility: NotificationVisibility.private,
        styleInformation: BigTextStyleInformation(reminder.body),
        actions: [
          for (final (action, label) in reminder.actions)
            AndroidNotificationAction(
              action.name,
              label,
              // The vault is written only by the app in the foreground.
              showsUserInterface: true,
            ),
        ],
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }

  @override
  Future<ReminderHealth> health() async {
    final android = _android;
    if (android == null) {
      return const ReminderHealth();
    }
    final allowed = await android.areNotificationsEnabled();
    final exact = await android.canScheduleExactNotifications();
    bool? battery;
    String? maker;
    try {
      battery = await _health.invokeMethod<bool>('batteryUnrestricted');
      maker = (await _health.invokeMethod<String>('manufacturer'))
          ?.toLowerCase();
    } on PlatformException {
      // Reported as unknown.
    } on MissingPluginException {
      // Reported as unknown.
    }
    return ReminderHealth(
      notificationsAllowed: allowed,
      exactAllowed: exact,
      batteryUnrestricted: battery,
      manufacturer: maker,
    );
  }

  @override
  Future<bool> requestPermission() async {
    if (_android case final android?) {
      return await android.requestNotificationsPermission() ?? false;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await ios?.requestPermissions(alert: true, sound: true) ?? false;
    }
    return false;
  }

  @override
  Future<void> requestExactTimes() async {
    await _android?.requestExactAlarmsPermission();
  }

  @override
  Future<void> openBatterySettings() async {
    try {
      await _health.invokeMethod<void>('openBatterySettings');
    } on PlatformException {
      await _plugin.openAppNotificationSettings();
    } on MissingPluginException {
      // Nothing to open on this platform.
    }
  }

  @override
  Future<void> showTest(ScheduledReminder reminder, Duration delay) async {
    final location = _location ??= await _localZone();
    final at = tz.TZDateTime.now(location).add(delay);
    await _plugin.zonedSchedule(
      id: reminder.id,
      scheduledDate: at,
      notificationDetails: _details(reminder),
      androidScheduleMode: await _scheduleMode(),
      title: reminder.title,
      body: reminder.body,
      payload: reminder.payload,
    );
  }
}
