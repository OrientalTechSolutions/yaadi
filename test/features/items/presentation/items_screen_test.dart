import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/features/demo/domain/demo_household.dart';
import 'package:yaadi/features/items/presentation/items_screen.dart';

import '../../../support/pump_app.dart';

Finder inItems(Finder finder) => onScreen(ItemsScreen, finder);

/// Chips sit in rows that scroll sideways on a phone.
Future<void> tapChip(WidgetTester tester, String label) async {
  final chip = inItems(find.widgetWithText(ChoiceChip, label));
  await tester.ensureVisible(chip);
  await tester.pumpAndSettle();
  await tester.tap(chip);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lists everything and filters by kind and status', (
    tester,
  ) async {
    await pumpApp(tester, vaultWith(DemoHousehold.khan));
    await tester.tap(find.byIcon(Icons.inventory_2_outlined));
    await tester.pumpAndSettle();

    expect(inItems(find.text('11 items')), findsOneWidget);

    await tapChip(tester, 'Medicine');
    expect(inItems(find.text('1 item')), findsOneWidget);
    expect(inItems(findPlain('امی کی دوائی')), findsOneWidget);

    // An empty Finished list says why a paid monthly bill is not in it.
    await tapChip(tester, 'Finished');
    expect(inItems(find.text('Nothing finished yet')), findsOneWidget);
    expect(inItems(find.textContaining('stays under Open')), findsOneWidget);

    await tapChip(tester, 'All kinds');
    expect(inItems(find.text('1 item')), findsOneWidget);
    expect(inItems(findPlain('پلمبر کا بل')), findsOneWidget);
    expect(inItems(find.text('Paid')), findsOneWidget);

    await tapChip(tester, 'All');
    expect(inItems(find.text('12 items')), findsOneWidget);
  });

  testWidgets('a medicine course past its last day is listed as ended', (
    tester,
  ) async {
    // The Khan course ends 24 days after the fixture day.
    await pumpApp(
      tester,
      vaultWith(DemoHousehold.khan),
      now: testNow.add(const Duration(days: 30)),
    );
    await tester.tap(find.byIcon(Icons.inventory_2_outlined));
    await tester.pumpAndSettle();
    await tapChip(tester, 'Medicine');
    expect(inItems(find.text('No items match these filters')), findsOneWidget);

    await tapChip(tester, 'Finished');
    expect(inItems(findPlain('امی کی دوائی')), findsOneWidget);
    expect(inItems(find.text('Course ended')), findsOneWidget);
  });

  testWidgets('the kind chips scroll with a mouse too', (tester) async {
    await pumpApp(
      tester,
      vaultWith(DemoHousehold.khan),
      size: const Size(360, 800),
    );
    await tester.tap(find.byIcon(Icons.inventory_2_outlined));
    await tester.pumpAndSettle();
    final task = inItems(find.widgetWithText(ChoiceChip, 'Task'));
    final before = tester.getTopLeft(task).dx;
    await tester.dragFrom(
      tester.getCenter(inItems(find.widgetWithText(ChoiceChip, 'Bill'))),
      const Offset(-200, 0),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(task).dx, lessThan(before));
  });
}
