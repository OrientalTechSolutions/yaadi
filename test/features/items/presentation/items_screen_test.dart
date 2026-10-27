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

    await tapChip(tester, 'Paid and done');
    expect(inItems(find.text('No items match these filters')), findsOneWidget);

    await tapChip(tester, 'All kinds');
    await tapChip(tester, 'All');
    expect(inItems(find.text('11 items')), findsOneWidget);
  });
}
