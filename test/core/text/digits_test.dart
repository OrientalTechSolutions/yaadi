import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/text/bidi.dart';
import 'package:yaadi/core/text/digits.dart';
import 'package:yaadi/core/text/script.dart';

void main() {
  test('Urdu and Arabic digits become ASCII, everything else stays', () {
    expect(normalizeDigits('۰۱۲۳۴۵۶۷۸۹'), '0123456789');
    expect(normalizeDigits('٠١٢٣٤٥٦٧٨٩'), '0123456789');
    expect(normalizeDigits('بل ۴۲۵۰ روپے'), 'بل 4250 روپے');
    expect(normalizeDigits('LESCO 10'), 'LESCO 10');
  });

  test('bidi controls are stripped, letters are not', () {
    expect(stripBidiControls('\u200E-4,250'), '-4,250');
    expect(stripBidiControls('\u2068Rs 4,250\u2069'), 'Rs 4,250');
    expect(stripBidiControls('\u202Bامی\u202C'), 'امی');
    expect(stripBidiControls('LESCO بل'), 'LESCO بل');
  });

  test('single characters: digits and direction controls', () {
    expect(asciiDigit('۷'.codeUnitAt(0)), '7'.codeUnitAt(0));
    expect(asciiDigit('٣'.codeUnitAt(0)), '3'.codeUnitAt(0));
    expect(asciiDigit('a'.codeUnitAt(0)), 'a'.codeUnitAt(0));
    for (final control in [0x200E, 0x200F, 0x061C, 0x202B, 0x2068]) {
      expect(isBidiControl(control), isTrue, reason: '$control');
    }
    expect(isBidiControl(0x200C), isFalse);
    expect(isBidiControl('ب'.codeUnitAt(0)), isFalse);
  });

  test('Arabic script letters, not its digits', () {
    expect(isArabicScript('ب'.codeUnitAt(0)), isTrue);
    expect(isArabicScript('ے'.codeUnitAt(0)), isTrue);
    expect(isArabicScript('۴'.codeUnitAt(0)), isFalse);
    expect(isArabicDigit('۴'.codeUnitAt(0)), isTrue);
    expect(isArabicScript('L'.codeUnitAt(0)), isFalse);
  });

  test('isolate wraps text in a first-strong isolate', () {
    expect(isolate('Rs 4,250'), '\u2068Rs 4,250\u2069');
    expect(stripBidiControls(isolate('x')), 'x');
  });
}
