import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/app.dart';
import 'package:yaadi/core/app_info.dart';
import 'package:yaadi/core/ids.dart';
import 'package:yaadi/core/time/clock.dart';
import 'package:yaadi/core/time/time_format.dart';
import 'package:yaadi/features/demo/data/demo_seed.dart';
import 'package:yaadi/features/demo/domain/demo_household.dart';
import 'package:yaadi/vault/app_storage.dart';

import 'fake_storage.dart';
import 'households.dart';

/// Nine in the morning on the fixture Monday, 2 November 2026.
final testNow = DateTime(2026, 11, 2, 9);

const phoneSize = Size(412, 915);
const wideSize = Size(1280, 800);

/// Pumps the whole app on [backend] at [size], with a fixed clock, counting
/// ids and a link opener that records instead of opening a browser.
Future<void> pumpApp(
  WidgetTester tester,
  StorageBackend backend, {
  Size size = phoneSize,
  DateTime? now,
  List<Uri>? openedLinks,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  var nextId = 0;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        storageBackendProvider.overrideWithValue(backend),
        clockProvider.overrideWithValue(() => now ?? testNow),
        idGeneratorProvider.overrideWithValue(() => 'new-${++nextId}'),
        linkOpenerProvider.overrideWithValue((uri) async {
          openedLinks?.add(uri);
          return true;
        }),
      ],
      child: const YaadiApp(),
    ),
  );
  await tester.pumpAndSettle();
}

/// A vault holding a demo household as if it were the user's own items.
FakeStorageBackend vaultWith(
  DemoHousehold household, {
  Map<String, String> settings = const {},
}) {
  final seed = demoSeed(household, today: fixtureToday, now: testNow.toUtc());
  return FakeStorageBackend(
    items: seed.items,
    completions: seed.completions,
    settings: settings,
  );
}

/// [text] without isolates and with ordinary spaces, so expectations can be
/// written plainly. Times use a narrow no-break space before AM and PM.
String plain(String text) => text
    .replaceAll(RegExp('[\u2066-\u2069]'), '')
    .replaceAll(RegExp(r'\s'), ' ');

/// The rendered text that reads [text] once isolates are ignored.
Finder findPlain(String text) => find.byWidgetPredicate(
  (widget) => widget is RichText && plain(widget.text.toPlainText()) == text,
  description: 'text "$text"',
);

Finder findPlainContaining(String text) => find.byWidgetPredicate(
  (widget) =>
      widget is RichText && plain(widget.text.toPlainText()).contains(text),
  description: 'text containing "$text"',
);

/// A button label whose screen reader text is [label], such as "Mark LESCO
/// bill as paid".
Finder findLabelled(String label) => find.byWidgetPredicate((widget) {
  final semanticsLabel = widget is Text ? widget.semanticsLabel : null;
  return semanticsLabel != null && plain(semanticsLabel) == label;
}, description: 'label "$label"');

/// [finder] inside the [screen] widget. The home tabs stay built while
/// hidden, so a title can be on Today and Items at once.
Finder onScreen(Type screen, Finder finder) =>
    find.descendant(of: find.byType(screen), matching: finder);

/// A time of day as the English UI shows it, in [plain] form.
String clock(int minute) => plain(formatMinute(minute, 'en'));

/// Scrolls the first scrollable until [finder] is built and visible.
Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}
