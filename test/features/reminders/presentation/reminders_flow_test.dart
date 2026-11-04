import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/features/demo/domain/demo_household.dart';
import 'package:yaadi/features/items/presentation/item_details_screen.dart';
import 'package:yaadi/features/reminders/data/reminder_gateway.dart';
import 'package:yaadi/features/reminders/domain/reminder_payload.dart';
import 'package:yaadi/features/settings/presentation/settings_screen.dart';

import '../../../support/fake_reminders.dart';
import '../../../support/pump_app.dart';

/// Lets the debounced scheduling pass run.
Future<void> settle(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

void main() {
  group('scheduling', () {
    testWidgets('the user\'s items are scheduled after launch, titles hidden', (
      tester,
    ) async {
      final reminders = FakeReminders();
      await pumpApp(
        tester,
        vaultWith(DemoHousehold.khan),
        reminders: reminders,
      );
      await settle(tester);

      final scheduled = reminders.scheduled!;
      expect(scheduled, isNotEmpty);
      expect(
        scheduled.any((r) => r.channel == ReminderChannel.summary),
        isTrue,
      );
      final text = scheduled.map((r) => '${r.title} ${r.body}').join(' ');
      expect(text, isNot(contains('LESCO')));
      expect(text, isNot(contains('school fee')));
    });

    testWidgets('a demo household pauses reminders', (tester) async {
      final reminders = FakeReminders();
      await pumpApp(
        tester,
        vaultWith(DemoHousehold.khan, settings: {'demo_household': 'khan'}),
        reminders: reminders,
      );
      await settle(tester);
      expect(reminders.scheduled, isEmpty);
    });

    testWidgets('reminders off in Settings clears the schedule', (
      tester,
    ) async {
      final reminders = FakeReminders();
      await pumpApp(
        tester,
        vaultWith(DemoHousehold.khan, settings: {'reminders_enabled': 'false'}),
        reminders: reminders,
      );
      await settle(tester);
      expect(reminders.scheduled, isEmpty);
    });

    testWidgets('marking a bill paid reschedules', (tester) async {
      final reminders = FakeReminders();
      await pumpApp(
        tester,
        vaultWith(DemoHousehold.khan),
        reminders: reminders,
      );
      await settle(tester);
      final before = reminders.replaceCount;

      final paid = reminders.scheduled!.firstWhere(
        (r) => r.actions.any((a) => a.$1 == ReminderAction.paid),
      );
      reminders.tap(readReminderTap(paid.payload, actionId: 'paid'));
      await settle(tester);

      expect(findPlainContaining('as paid'), findsOneWidget);
      expect(reminders.replaceCount, greaterThan(before));
    });
  });

  group('taps', () {
    testWidgets('a tapped reminder opens its item', (tester) async {
      final reminders = FakeReminders();
      await pumpApp(
        tester,
        vaultWith(DemoHousehold.khan),
        reminders: reminders,
      );
      await settle(tester);
      final any = reminders.scheduled!.firstWhere(
        (r) => r.channel == ReminderChannel.reminders,
      );
      reminders.tap(readReminderTap(any.payload));
      await settle(tester);
      expect(find.byType(ItemDetailsScreen), findsOneWidget);
    });

    testWidgets('the reminder that launched the app is handled', (
      tester,
    ) async {
      // A first run only to learn an id the launch can point at.
      final probe = FakeReminders();
      await pumpApp(tester, vaultWith(DemoHousehold.khan), reminders: probe);
      await settle(tester);
      final payload = probe.scheduled!
          .firstWhere((r) => r.channel == ReminderChannel.reminders)
          .payload;

      final reminders = FakeReminders(launch: readReminderTap(payload));
      await pumpApp(
        tester,
        vaultWith(DemoHousehold.khan),
        reminders: reminders,
      );
      await settle(tester);
      expect(find.byType(ItemDetailsScreen), findsOneWidget);
    });

    testWidgets('a reminder for a deleted item says so', (tester) async {
      final reminders = FakeReminders();
      await pumpApp(
        tester,
        vaultWith(DemoHousehold.khan),
        reminders: reminders,
      );
      await settle(tester);
      reminders.tap(const ReminderTap(itemId: 'gone'));
      await settle(tester);
      expect(
        find.text("That reminder's item has been deleted."),
        findsOneWidget,
      );
    });
  });

  group('Settings', () {
    Future<void> openSettings(WidgetTester tester) async {
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
    }

    testWidgets('the web demo and tests without a phone show no section', (
      tester,
    ) async {
      await pumpApp(tester, vaultWith(DemoHousehold.khan));
      await openSettings(tester);
      expect(find.text('Remind me'), findsNothing);
    });

    testWidgets('checks say what stops reminders and offer a fix', (
      tester,
    ) async {
      final reminders = FakeReminders(
        health_: const ReminderHealth(
          notificationsAllowed: true,
          exactAllowed: false,
          batteryUnrestricted: false,
          manufacturer: 'xiaomi',
        ),
      );
      await pumpApp(
        tester,
        vaultWith(DemoHousehold.khan),
        reminders: reminders,
      );
      await openSettings(tester);

      final list = find
          .descendant(
            of: find.byType(SettingsScreen),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        find.text('Send a test reminder'),
        200,
        scrollable: list,
      );
      await tester.pumpAndSettle();

      expect(find.text('Notifications are allowed'), findsOneWidget);
      expect(
        find.text('Reminders may come a few minutes late'),
        findsOneWidget,
      );
      expect(findPlainContaining('On Xiaomi phones'), findsOneWidget);
      expect(find.text('Fix'), findsNWidgets(2));

      await tester.ensureVisible(find.text('Fix').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Fix').first);
      await tester.pumpAndSettle();
      expect(reminders.exactRequests, 1);

      await tester.ensureVisible(find.text('Send a test reminder'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send a test reminder'));
      await tester.pumpAndSettle();
      expect(reminders.tests, hasLength(1));
      expect(find.text('Test reminder on its way'), findsOneWidget);
    });

    testWidgets('turning reminders off is remembered', (tester) async {
      final reminders = FakeReminders();
      final backend = vaultWith(DemoHousehold.khan);
      await pumpApp(tester, backend, reminders: reminders);
      await openSettings(tester);
      await tester.tap(find.text('Remind me'));
      await settle(tester);
      expect(find.text('Reminder time'), findsNothing);
      expect(reminders.scheduled, isEmpty);
    });
  });

  group('the Today card', () {
    FakeReminders blocked() => FakeReminders(
      health_: const ReminderHealth(notificationsAllowed: false),
    );

    testWidgets('asks once while notifications are blocked', (tester) async {
      final reminders = blocked();
      await pumpApp(
        tester,
        vaultWith(DemoHousehold.khan),
        reminders: reminders,
      );
      await settle(tester);
      expect(find.text('Turn on reminders?'), findsOneWidget);

      await tester.tap(find.text('Turn on'));
      await settle(tester);
      expect(reminders.permissionRequests, 1);
      expect(find.text('Turn on reminders?'), findsNothing);
    });

    testWidgets('Not now hides it for good', (tester) async {
      final reminders = blocked();
      final backend = vaultWith(DemoHousehold.khan);
      await pumpApp(tester, backend, reminders: reminders);
      await settle(tester);
      await tester.tap(find.text('Not now'));
      await settle(tester);
      expect(find.text('Turn on reminders?'), findsNothing);
      expect(
        (await backend.settings.readAll())['reminder_prompt_hidden'],
        'true',
      );
    });

    testWidgets('never shown for a demo household', (tester) async {
      await pumpApp(
        tester,
        vaultWith(DemoHousehold.khan, settings: {'demo_household': 'khan'}),
        reminders: blocked(),
      );
      await settle(tester);
      expect(find.text('Turn on reminders?'), findsNothing);
    });
  });
}
