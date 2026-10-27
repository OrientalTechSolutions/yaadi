import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/features/demo/domain/demo_household.dart';
import 'package:yaadi/features/settings/presentation/settings_screen.dart';
import 'package:yaadi/features/today/presentation/today_screen.dart';

import 'support/pump_app.dart';

/// Tap targets of at least 48 dp and labelled buttons in both languages and
/// themes, and text contrast where the guideline can measure it
/// (ARCHITECTURE.md section 13).
///
/// The contrast guideline samples pixels and takes the most common darker
/// shade as the text colour. Thin Nastaliq strokes in tall Urdu lines are
/// mostly anti-aliased, so it reads near-background greys as text there; the
/// Urdu screens use the same colour roles, which
/// test/core/theme/theme_contrast_test.dart checks numerically.
Future<void> expectGuidelines(
  WidgetTester tester, {
  required bool measureContrast,
}) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  if (measureContrast) {
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  }
}

typedef _Screen = Future<void> Function(WidgetTester tester);

Future<void> _today(WidgetTester tester) async {}

Future<void> _items(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.inventory_2_outlined));
  await tester.pumpAndSettle();
}

Future<void> _search(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.search_outlined));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), 'bill');
  await tester.pumpAndSettle();
}

Future<void> _settings(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.settings_outlined));
  await tester.pumpAndSettle();
}

Future<void> _editor(WidgetTester tester) async {
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
}

Future<void> _details(WidgetTester tester) async {
  await tester.tap(findPlain('گیس کا بل').first);
  await tester.pumpAndSettle();
}

void main() {
  const variants = {
    'English, light': <String, String>{},
    'English, dark': {'theme': 'dark'},
    'Urdu, light': {'language': 'ur'},
    'Urdu, dark': {'language': 'ur', 'theme': 'dark'},
  };
  const screens = <String, _Screen>{
    'Today': _today,
    'Items': _items,
    'Search with results': _search,
    'Settings': _settings,
    'Editor': _editor,
    'Item details': _details,
  };

  group('screen readers', () {
    // A header flag without a container of its own merges into the parent,
    // turning a whole card or section into one long "heading".
    testWidgets('headings are their own nodes', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpApp(tester, vaultWith(DemoHousehold.khan));
      expect(
        tester.getSemantics(find.text('Morning summary')),
        matchesSemantics(isHeader: true, label: 'Morning summary'),
      );

      await _settings(tester);
      final settingsList = find
          .descendant(
            of: find.byType(SettingsScreen),
            matching: find.byType(Scrollable),
          )
          .first;
      for (final heading in ['Demo households', 'About']) {
        await tester.scrollUntilVisible(
          find.text(heading),
          200,
          scrollable: settingsList,
        );
        await tester.pumpAndSettle();
        expect(
          tester.getSemantics(find.text(heading)),
          matchesSemantics(isHeader: true, label: heading),
        );
      }
      semantics.dispose();
    });

    testWidgets('the item page has a History heading', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpApp(tester, vaultWith(DemoHousehold.khan));
      final card = onScreen(TodayScreen, findPlain('LESCO bill'));
      await scrollTo(tester, card);
      await tester.tap(card);
      await tester.pumpAndSettle();
      await scrollTo(tester, find.text('History'));
      expect(
        tester.getSemantics(find.text('History')),
        matchesSemantics(isHeader: true, label: 'History'),
      );
      semantics.dispose();
    });

    testWidgets('the two "Same as phone" choices say which group', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpApp(tester, vaultWith(DemoHousehold.khan));
      await _settings(tester);
      for (final group in ['Language', 'Theme']) {
        expect(
          find.bySemanticsLabel(group),
          findsAtLeastNWidgets(1),
          reason: group,
        );
      }
      final themeGroup = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Theme' &&
            widget.container,
      );
      expect(
        find.descendant(of: themeGroup, matching: find.text('Same as phone')),
        findsOneWidget,
      );
      semantics.dispose();
    });
  });

  variants.forEach((variant, settings) {
    group(variant, () {
      screens.forEach((name, open) {
        testWidgets(name, (tester) async {
          final semantics = tester.ensureSemantics();
          await pumpApp(
            tester,
            vaultWith(DemoHousehold.khan, settings: settings),
          );
          await open(tester);
          await expectGuidelines(
            tester,
            measureContrast: settings['language'] != 'ur',
          );
          semantics.dispose();
        });
      });
    });
  });
}
