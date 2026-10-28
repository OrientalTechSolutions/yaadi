import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/features/demo/domain/demo_household.dart';
import 'package:yaadi/features/items/presentation/item_details_screen.dart';
import 'package:yaadi/features/today/presentation/today_screen.dart';

import '../../../support/fake_storage.dart';
import '../../../support/pump_app.dart';

Finder inDetails(Finder finder) => onScreen(ItemDetailsScreen, finder);

Future<FakeStorageBackend> openDetails(
  WidgetTester tester,
  String title,
) async {
  final vault = vaultWith(DemoHousehold.khan);
  await pumpApp(tester, vault);
  final card = onScreen(TodayScreen, findPlain(title));
  await scrollTo(tester, card);
  await tester.tap(card);
  await tester.pumpAndSettle();
  return vault;
}

void main() {
  testWidgets('the reference is hidden until Show and never read out', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await openDetails(tester, "Abbu's CNIC");

    expect(inDetails(find.text('•••• •••• 0123')), findsOneWidget);
    expect(find.text('12345-6789012-3'), findsNothing);
    expect(find.bySemanticsLabel('Reference, hidden'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('6789')), findsNothing);

    await tester.tap(inDetails(find.text('Show')));
    await tester.pumpAndSettle();
    expect(inDetails(find.text('12345-6789012-3')), findsOneWidget);
    // Shown, it is read digit by digit rather than as one large number.
    final shown = tester.getSemantics(
      find.bySemanticsLabel('Reference 12345-6789012-3'),
    );
    final label = shown.getSemanticsData().attributedLabel;
    expect(
      label.attributes.whereType<SpellOutStringAttribute>().single.range,
      const TextRange(start: 10, end: 25),
    );
    semantics.dispose();
  });

  testWidgets('a shown reference hides itself when the app is left', (
    tester,
  ) async {
    await openDetails(tester, "Abbu's CNIC");
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

    await tester.tap(inDetails(find.text('Show')));
    await tester.pump();
    expect(inDetails(find.text('12345-6789012-3')), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(find.text('12345-6789012-3'), findsNothing);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
  });

  testWidgets('a shown reference hides itself after half a minute', (
    tester,
  ) async {
    await openDetails(tester, "Abbu's CNIC");
    await tester.tap(inDetails(find.text('Show')));
    await tester.pump();
    expect(inDetails(find.text('12345-6789012-3')), findsOneWidget);

    await tester.pump(const Duration(seconds: 29));
    expect(inDetails(find.text('12345-6789012-3')), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('12345-6789012-3'), findsNothing);
  });

  testWidgets('shows how it repeats, the amount and the history', (
    tester,
  ) async {
    await openDetails(tester, 'LESCO bill');

    expect(inDetails(find.text('Every month on day 5')), findsOneWidget);
    expect(
      inDetails(findPlain('Rs 4,250 · Changes each time')),
      findsOneWidget,
    );
    await scrollTo(tester, inDetails(find.text('History')));
    // What the line is for, and when it was paid, which is a different day.
    expect(
      inDetails(findPlain('For Oct 5, 2026: paid Oct 3, 2026 · Rs 3,980')),
      findsOneWidget,
    );
  });

  testWidgets('Delete closes the page, and Undo brings back the history', (
    tester,
  ) async {
    final vault = await openDetails(tester, 'LESCO bill');

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    expect(find.byType(ItemDetailsScreen), findsNothing);
    expect(findPlain('Deleted LESCO bill'), findsOneWidget);
    expect(await vault.items.find('khan-lesco'), isNull);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(await vault.items.find('khan-lesco'), isNotNull);
    expect(await vault.items.completionsOf('khan-lesco'), hasLength(1));
  });

  testWidgets('Mark as paid works from the page too', (tester) async {
    final vault = await openDetails(tester, 'LESCO bill');
    final button = inDetails(find.text('Mark as paid'));
    await scrollTo(tester, button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(
      findPlain('Marked LESCO bill as paid. Next due Sat, Dec 5.'),
      findsOneWidget,
    );
    expect(await vault.items.completionsOf('khan-lesco'), hasLength(2));
  });
}
