import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/app_info.dart';
import 'package:yaadi/core/money/money.dart';
import 'package:yaadi/core/time/local_date.dart';
import 'package:yaadi/features/demo/domain/demo_household.dart';
import 'package:yaadi/features/items/presentation/items_screen.dart';
import 'package:yaadi/features/settings/domain/app_settings.dart';
import 'package:yaadi/features/today/presentation/today_screen.dart';

import 'support/fake_storage.dart';
import 'support/items.dart';
import 'support/pump_app.dart';

TextDirection directionOf(WidgetTester tester) =>
    Directionality.of(tester.element(find.byType(TodayScreen)));

void main() {
  testWidgets('a first launch shows the empty Today screen', (tester) async {
    await pumpApp(tester, FakeStorageBackend());
    expect(find.text('Nothing here yet'), findsOneWidget);
    expect(find.text('Demo'), findsNothing);
    expect(directionOf(tester), TextDirection.ltr);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('Items lists what is saved with its date and amount', (
    tester,
  ) async {
    await pumpApp(
      tester,
      FakeStorageBackend(
        items: [
          bill(dueOn: LocalDate(2026, 11, 10), amount: Money(425000, 'PKR')),
          task(),
        ],
      ),
    );
    await tester.tap(find.text('Items'));
    await tester.pumpAndSettle();

    final items = find.byType(ItemsScreen);
    expect(
      find.descendant(
        of: items,
        matching: findPlain('Electricity · Due Nov 10, 2026 · Rs 4,250'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: items, matching: findPlain('Renew library card')),
      findsOneWidget,
    );
  });

  testWidgets('choosing Urdu turns the whole app right-to-left and is saved', (
    tester,
  ) async {
    final backend = FakeStorageBackend();
    await pumpApp(tester, backend);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('اردو', findRichText: true));
    await tester.pumpAndSettle();

    expect(find.text('ترتیبات'), findsWidgets);
    expect(await backend.settings.readAll(), containsPair('language', 'ur'));

    await tester.tap(find.text('آج'));
    await tester.pumpAndSettle();
    expect(directionOf(tester), TextDirection.rtl);
    expect(find.text('ابھی یہاں کچھ نہیں'), findsOneWidget);
  });

  testWidgets('saved settings apply on the next launch', (tester) async {
    await pumpApp(
      tester,
      FakeStorageBackend(
        settings: const {
          'language': 'ur',
          'theme': 'dark',
          'large_text': 'true',
        },
      ),
    );
    final context = tester.element(find.byType(TodayScreen));
    expect(Directionality.of(context), TextDirection.rtl);
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(MediaQuery.textScalerOf(context).scale(10), closeTo(13, 0.001));
  });

  testWidgets('Large text multiplies the phone setting and is saved', (
    tester,
  ) async {
    final backend = FakeStorageBackend();
    await pumpApp(tester, backend);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Large text'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Large text'));
    await tester.pumpAndSettle();

    expect(
      await backend.settings.readAll(),
      containsPair(SettingKeys.largeText, 'true'),
    );
    final context = tester.element(find.text('Large text'));
    expect(MediaQuery.textScalerOf(context).scale(10), closeTo(13, 0.001));
  });

  testWidgets('Urdu text in the English UI keeps its own direction', (
    tester,
  ) async {
    await pumpApp(tester, FakeStorageBackend(items: [medicine()]));
    final title = tester.widget<RichText>(
      onScreen(TodayScreen, findPlain('امی کی دوائی')),
    );
    expect(title.textDirection, TextDirection.rtl);
    expect(directionOf(tester), TextDirection.ltr);
  });

  testWidgets('wide windows get a navigation rail and a centred column', (
    tester,
  ) async {
    await pumpApp(tester, vaultWith(DemoHousehold.khan), size: wideSize);

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    final summary = find.ancestor(
      of: find.text('Morning summary'),
      matching: find.byType(Card),
    );
    expect(tester.getSize(summary).width, lessThanOrEqualTo(720));
    expect(
      tester.getCenter(summary).dx,
      closeTo(tester.getCenter(find.byType(TodayScreen)).dx, 1),
    );
  });

  test('the version in Settings matches pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('\nversion: ${AppInfo.version}+'));
  });
}
