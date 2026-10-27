import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/features/demo/domain/demo_household.dart';
import 'package:yaadi/features/search/presentation/search_screen.dart';

import '../../../support/pump_app.dart';

Finder inSearch(Finder finder) => onScreen(SearchScreen, finder);

Future<void> openSearch(
  WidgetTester tester, {
  Map<String, String> settings = const {},
}) async {
  await pumpApp(tester, vaultWith(DemoHousehold.khan, settings: settings));
  await tester.tap(find.byIcon(Icons.search_outlined));
  await tester.pumpAndSettle();
}

Future<void> search(WidgetTester tester, String query) async {
  await tester.enterText(inSearch(find.byType(TextField)), query);
  await tester.pumpAndSettle();
}

/// The highlighted stretches of the title that reads [title].
List<String> highlightsIn(WidgetTester tester, String title) {
  final text = tester.widget<RichText>(inSearch(findPlain(title))).text;
  final highlighted = <String>[];
  text.visitChildren((span) {
    if (span is TextSpan &&
        span.text != null &&
        span.style?.backgroundColor != null) {
      highlighted.add(span.text!);
    }
    return true;
  });
  return highlighted;
}

void main() {
  testWidgets('suggests searches in the household languages', (tester) async {
    await openSearch(tester);
    expect(
      inSearch(findPlainContaining('Search works offline')),
      findsOneWidget,
    );
    await tester.tap(inSearch(findPlain('ammi ki dawai')));
    await tester.pumpAndSettle();
    expect(inSearch(find.text('1 result')), findsOneWidget);
    expect(inSearch(findPlain('امی کی دوائی')), findsOneWidget);
  });

  testWidgets('highlights the words that matched', (tester) async {
    await openSearch(tester);
    await search(tester, 'lesco bil');
    expect(inSearch(find.text('1 result')), findsOneWidget);
    expect(highlightsIn(tester, 'LESCO bill'), ['LESCO', 'bill']);
  });

  testWidgets('Roman Urdu finds the electricity bill by its category', (
    tester,
  ) async {
    await openSearch(tester);
    await search(tester, 'bijlee ka bil');
    expect(inSearch(findPlain('LESCO bill')), findsOneWidget);
    expect(highlightsIn(tester, 'LESCO bill'), contains('bill'));
  });

  testWidgets('Urdu script finds the gas bill, highlighted whole', (
    tester,
  ) async {
    await openSearch(tester);
    await search(tester, 'گیس');
    expect(highlightsIn(tester, 'گیس کا بل'), ['گیس']);
  });

  testWidgets('says so when nothing matches, and clears', (tester) async {
    await openSearch(tester);
    await search(tester, 'xylophone');
    expect(inSearch(find.text('Nothing found')), findsOneWidget);

    await tester.tap(inSearch(find.byTooltip('Clear search')));
    await tester.pumpAndSettle();
    expect(inSearch(find.text('Try')), findsOneWidget);
  });

  testWidgets('the Urdu UI searches the same way', (tester) async {
    await openSearch(tester, settings: const {'language': 'ur'});
    await search(tester, 'shanakhti card');
    expect(inSearch(find.text('1 نتیجہ')), findsOneWidget);
    expect(inSearch(findPlain("Abbu's CNIC")), findsOneWidget);
  });
}
