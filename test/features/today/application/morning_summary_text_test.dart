import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:yaadi/core/money/money.dart';
import 'package:yaadi/core/text/bidi.dart';
import 'package:yaadi/core/text/digits.dart';
import 'package:yaadi/features/today/application/morning_summary_text.dart';
import 'package:yaadi/features/today/domain/morning_summary.dart';
import 'package:yaadi/features/today/domain/today_view.dart';
import 'package:yaadi/l10n/app_localizations.dart';

import '../../../support/households.dart';

/// Without isolates and with plain spaces, for readable expectations.
String plain(String line) =>
    stripBidiControls(line).replaceAll(RegExp(r'\s'), ' ');

void main() {
  setUpAll(initializeDateFormatting);

  final english = lookupAppLocalizations(const Locale('en'));
  final urdu = lookupAppLocalizations(const Locale('ur'));
  final khan = MorningSummary.of(
    TodayView.build(khanHousehold, today: fixtureToday),
  );

  test('English lines for the Khan household', () {
    expect(morningSummaryLines(khan, english).map(plain), [
      'Overdue: مکان کا کرایہ',
      'Today: Jazz mobile package · 6:00 PM',
      'Today: پانی کا بل · Rs 900',
      'Medicine: 3 of 3 times not marked yet',
      'Coming up: Bilal school fee, Thu, Nov 5',
      'To pay by Mon, Nov 9: Rs 57,900',
      '2 amounts not known yet',
    ]);
  });

  test('titles, times and amounts keep their own direction', () {
    final lines = morningSummaryLines(khan, english);
    expect(lines.first, contains('\u2068مکان کا کرایہ\u2069'));
    expect(lines[2], contains(isolate('Rs${noBreakSpace}900')));
  });

  test('English plurals and the quiet day', () {
    final busy = MorningSummary(
      payBy: fixtureToday.addDays(7),
      overdue: 3,
      firstOverdue: 'LESCO bill',
      toConfirm: 2,
      moreToday: 1,
      dosesToday: 1,
      totals: [Money(15600, 'GBP'), Money(425000, 'PKR')],
      unknownAmounts: 1,
    );
    expect(morningSummaryLines(busy, english).map(plain), [
      'Overdue: LESCO bill and 2 more',
      'To confirm: 2 past items',
      'Today: 1 more',
      "Medicine: today's time not marked yet",
      'To pay by Mon, Nov 9: £156 · Rs 4,250',
      '1 amount not known yet',
    ]);

    final quiet = MorningSummary(payBy: fixtureToday.addDays(7));
    expect(morningSummaryLines(quiet, english), ['Nothing due today']);
  });

  test('the same facts always give the same lines', () {
    expect(
      morningSummaryLines(khan, english),
      morningSummaryLines(khan, english),
    );
    expect(morningSummaryLines(khan, urdu), morningSummaryLines(khan, urdu));
  });

  // The Urdu wording is a draft until the native-speaker review
  // (ARCHITECTURE.md section 13), so only its structure is pinned.
  test('Urdu lines fill every placeholder and isolate user text', () {
    final lines = morningSummaryLines(khan, urdu);
    expect(lines, hasLength(7));
    for (final line in lines) {
      expect(line, isNot(contains('{')));
      expect(line, isNot(contains('}')));
    }
    expect(lines.first, contains('\u2068مکان کا کرایہ\u2069'));
    expect(lines[1], contains('\u2068Jazz mobile package\u2069'));
    expect(lines[2], contains(isolate('Rs${noBreakSpace}900')));
    expect(lines[3], contains('3'));
    expect(lines[4], contains('\u2068Bilal school fee\u2069'));
    expect(lines[4], contains('نومبر'));
    expect(lines[5], contains(isolate('Rs${noBreakSpace}57,900')));
    expect(lines.join(), isNot(contains('Overdue')));
  });

  test('Urdu plurals differ between one and many', () {
    expect(urdu.summaryDosesLeft(1, 1), isNot(urdu.summaryDosesLeft(2, 3)));
    expect(urdu.summaryDosesMarked(1), isNot(urdu.summaryDosesMarked(3)));
    expect(urdu.summaryUnknownAmounts(1), isNot(urdu.summaryUnknownAmounts(3)));
    expect(urdu.summaryOverdue(0, 'x'), isNot(urdu.summaryOverdue(2, 'x')));
  });
}
