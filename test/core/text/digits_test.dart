import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/text/bidi.dart';
import 'package:yaadi/core/text/digits.dart';

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

  test('isolate wraps text in a first-strong isolate', () {
    expect(isolate('Rs 4,250'), '\u2068Rs 4,250\u2069');
    expect(stripBidiControls(isolate('x')), 'x');
  });
}
