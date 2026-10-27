import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/app.dart';
import 'package:yaadi/core/money/money.dart';
import 'package:yaadi/core/time/local_date.dart';
import 'package:yaadi/features/settings/domain/app_settings.dart';
import 'package:yaadi/features/today/presentation/today_screen.dart';
import 'package:yaadi/vault/app_storage.dart';

import 'support/fake_storage.dart';
import 'support/items.dart';

Future<FakeStorageBackend> pumpApp(
  WidgetTester tester, {
  FakeStorageBackend? backend,
}) async {
  final storage = backend ?? FakeStorageBackend();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [storageBackendProvider.overrideWithValue(storage)],
      child: const YaadiApp(),
    ),
  );
  await tester.pumpAndSettle();
  return storage;
}

TextDirection directionOf(WidgetTester tester) =>
    Directionality.of(tester.element(find.byType(TodayScreen)));

void main() {
  testWidgets('a first launch shows the empty Today screen', (tester) async {
    await pumpApp(tester);
    expect(find.text('Nothing here yet'), findsOneWidget);
    expect(find.text('Demo'), findsNothing);
    expect(directionOf(tester), TextDirection.ltr);
  });

  testWidgets('open items are listed with their date and amount', (
    tester,
  ) async {
    await pumpApp(
      tester,
      backend: FakeStorageBackend(
        items: [
          bill(dueOn: LocalDate(2026, 11, 10), amount: Money(425000, 'PKR')),
          task(),
        ],
      ),
    );
    expect(find.text('LESCO bill', findRichText: true), findsOneWidget);
    expect(find.text('Renew library card', findRichText: true), findsOneWidget);
    expect(
      find.textContaining('Due Nov 10, 2026 · \u2068Rs 4,250\u2069'),
      findsOneWidget,
    );
  });

  testWidgets('choosing Urdu turns the whole app right-to-left and is saved', (
    tester,
  ) async {
    final backend = await pumpApp(tester);

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
      backend: FakeStorageBackend(
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
    final backend = await pumpApp(tester);
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

  testWidgets('the web demo says what happens to typed data', (tester) async {
    await pumpApp(
      tester,
      backend: FakeStorageBackend(kind: StorageKind.webDemo),
    );
    expect(find.text('Demo'), findsOneWidget);
    expect(
      find.textContaining('is not encrypted and is not sent to us'),
      findsOneWidget,
    );
  });

  testWidgets('Urdu text in the English UI keeps its own direction', (
    tester,
  ) async {
    await pumpApp(tester, backend: FakeStorageBackend(items: [medicine()]));
    final title = tester.widget<RichText>(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText && widget.text.toPlainText() == 'امی کی دوائی',
      ),
    );
    expect(title.textDirection, TextDirection.rtl);
    expect(directionOf(tester), TextDirection.ltr);
  });
}
