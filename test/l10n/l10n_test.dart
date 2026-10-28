import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/app.dart';
import 'package:yaadi/features/items/domain/recurrence.dart';
import 'package:yaadi/features/items/presentation/item_labels.dart';
import 'package:yaadi/l10n/app_localizations.dart';
import 'package:yaadi/l10n/urdu_material_localizations.dart';

Map<String, Object?> readArb(String name) =>
    jsonDecode(File('lib/l10n/$name').readAsStringSync())
        as Map<String, Object?>;

Set<String> placeholdersIn(String message) =>
    RegExp(r'\{(\w+)[,}]').allMatches(message).map((m) => m.group(1)!).toSet();

/// The Urdu text is a draft until a native speaker reviews it
/// (ARCHITECTURE.md section 13), so these tests check structure, not wording.
void main() {
  final english = readArb('app_en.arb');
  final urdu = readArb('app_ur.arb');
  final keys = english.keys.where((key) => !key.startsWith('@')).toList();

  test('every English message has an Urdu translation and no extras', () {
    final urduKeys = urdu.keys.where((key) => !key.startsWith('@')).toSet();
    expect(urduKeys, keys.toSet());
  });

  test('every message is described for translators', () {
    for (final key in keys) {
      final meta = english['@$key'];
      expect(meta, isA<Map<String, Object?>>(), reason: key);
      expect(
        (meta! as Map<String, Object?>)['description'],
        isA<String>(),
        reason: key,
      );
    }
  });

  test('translations use the same placeholders', () {
    for (final key in keys) {
      expect(
        placeholdersIn(urdu[key]! as String),
        placeholdersIn(english[key]! as String),
        reason: key,
      );
    }
  });

  testWidgets('Urdu renders right-to-left with plurals and month names', (
    tester,
  ) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ur'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(
      Directionality.of(tester.element(find.byType(SizedBox))),
      TextDirection.rtl,
    );
    expect(l10n.itemCount(0), isNot(l10n.itemCount(1)));
    expect(l10n.itemCount(3), contains('3'));
    expect(l10n.dueOn(DateTime(2026, 2, 28)), contains('فروری'));
  });

  testWidgets('English plurals', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(l10n.itemCount(0), 'No items');
    expect(l10n.itemCount(1), '1 item');
    expect(l10n.itemCount(4), '4 items');
    expect(l10n.dueOn(DateTime(2026, 2, 28)), 'Due Feb 28, 2026');
  });

  group('English dates follow the country', () {
    test('day first everywhere but the US', () {
      for (final (requested, expected) in [
        (const Locale('en', 'US'), const Locale('en')),
        (const Locale('en', 'GB'), const Locale('en', 'GB')),
        (const Locale('en', 'PK'), const Locale('en', 'GB')),
        (const Locale('en'), const Locale('en', 'GB')),
        (const Locale('fr', 'FR'), const Locale('en', 'GB')),
        (const Locale('ur', 'PK'), const Locale('ur')),
        (null, const Locale('en', 'GB')),
      ]) {
        expect(resolveAppLocale(requested), expected, reason: '$requested');
      }
    });

    testWidgets('British English shares every message, written day first', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(
        const Locale('en', 'GB'),
      );
      expect(l10n.localeName, 'en_GB');
      expect(l10n.dueOn(DateTime(2026, 2, 28)), 'Due 28 Feb 2026');
      expect(l10n.markedPaid('LESCO bill'), 'Marked LESCO bill as paid');
    });

    testWidgets('the licences link is spelled like the page it opens', (
      tester,
    ) async {
      for (final locale in [const Locale('en'), const Locale('en', 'GB')]) {
        final l10n = await AppLocalizations.delegate.load(locale);
        final material = await GlobalMaterialLocalizations.delegate.load(
          locale,
        );
        // "licenses" in the US, "licences" in the UK, both times.
        final page = material.licensesPageTitle.toLowerCase();
        expect(l10n.settingsLicenses.toLowerCase(), endsWith(page));
      }
    });
  });

  testWidgets('Urdu lists use the Urdu comma', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ur'));
    expect(l10n.listSeparator, '\u060C ');
    expect(
      l10n.describeRepeat(DoseTimes(const [480, 840, 1260])),
      isNot(contains(',')),
    );
    final english = await AppLocalizations.delegate.load(const Locale('en'));
    expect(
      english.describeRepeat(DoseTimes(const [480, 1260])),
      contains(', '),
    );
  });

  testWidgets('Urdu pickers name the weekdays and the time of day in Urdu', (
    tester,
  ) async {
    late MaterialLocalizations material;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ur'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          UrduMaterialLocalizations.delegate,
          ...AppLocalizations.localizationsDelegates,
        ],
        home: Builder(
          builder: (context) {
            material = MaterialLocalizations.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(material.narrowWeekdays, hasLength(7));
    expect(material.narrowWeekdays.toSet(), hasLength(7));
    expect(material.narrowWeekdays.first, 'اتوار');
    expect(material.anteMeridiemAbbreviation, 'صبح');
    expect(material.postMeridiemAbbreviation, 'شام');
    // Everything else is still Flutter's own Urdu.
    expect(material.cancelButtonLabel, 'منسوخ کریں');
  });
}
