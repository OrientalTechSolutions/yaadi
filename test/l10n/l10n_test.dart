import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/l10n/app_localizations.dart';

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
}
