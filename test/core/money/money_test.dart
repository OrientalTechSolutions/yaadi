import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/money/money.dart';
import 'package:yaadi/core/money/money_format.dart';
import 'package:yaadi/core/text/bidi.dart';

void main() {
  group('Money', () {
    test('is never negative and always has an ISO code', () {
      expect(() => Money(-1, 'PKR'), throwsRangeError);
      expect(() => Money(100, 'pkr'), throwsArgumentError);
      expect(() => Money(100, 'RUPEES'), throwsArgumentError);
      expect(Money(0, 'GBP').minorUnits, 0);
    });

    test('compares by value', () {
      expect(Money(425000, 'PKR'), Money(425000, 'PKR'));
      expect(Money(425000, 'PKR'), isNot(Money(425000, 'USD')));
    });

    test('knows the supported currencies and falls back to the code', () {
      expect(CurrencyInfo.of('PKR').symbol, 'Rs');
      expect(CurrencyInfo.of('PKR').inputFractionDigits, 0);
      expect(CurrencyInfo.of('GBP').symbol, '£');
      expect(CurrencyInfo.of('EUR').symbol, 'EUR');
    });
  });

  group('formatMoney', () {
    const cases = [
      (425000, 'PKR', 'en', 'Rs${noBreakSpace}4,250'),
      (425050, 'PKR', 'en', 'Rs${noBreakSpace}4,250.50'),
      (12000, 'GBP', 'en', '£120'),
      (1250, 'GBP', 'en', '£12.50'),
      (8005, 'USD', 'en', r'$80.05'),
      (123456700, 'PKR', 'en', 'Rs${noBreakSpace}1,234,567'),
      // Pakistani bills print Latin digits with Western grouping.
      (425000, 'PKR', 'ur', 'Rs${noBreakSpace}4,250'),
      (99, 'EUR', 'en', 'EUR${noBreakSpace}0.99'),
    ];
    for (final (minor, currency, locale, expected) in cases) {
      test('$minor $currency in $locale is $expected', () {
        expect(formatMoney(Money(minor, currency), locale), expected);
      });
    }

    test('the symbol never ends a line with the digits on the next', () {
      // A no-break space joins them, so "Rs" is never left alone at the end
      // of a line in a narrow Urdu list.
      for (final (minor, currency, locale, _) in cases) {
        expect(
          formatMoney(Money(minor, currency), locale),
          isNot(contains(' ')),
        );
      }
    });
  });

  group('parseMoney', () {
    const cases = [
      ('4250', 'PKR', 425000),
      ('4,250', 'PKR', 425000),
      (' 4250 ', 'PKR', 425000),
      ('۴۲۵۰', 'PKR', 425000),
      ('٤٢٥٠', 'PKR', 425000),
      ('\u200E4250', 'PKR', 425000),
      ('12.5', 'GBP', 1250),
      ('12.50', 'GBP', 1250),
      ('1,200.05', 'USD', 120005),
      ('0', 'GBP', 0),
    ];
    for (final (input, currency, minor) in cases) {
      test('"$input" in $currency is $minor', () {
        expect(parseMoney(input, currency, 'en'), Money(minor, currency));
        expect(parseMoney(input, currency, 'ur'), Money(minor, currency));
      });
    }

    const rejected = [
      ('', 'PKR'),
      ('abc', 'PKR'),
      ('12.50', 'PKR'),
      ('12.555', 'GBP'),
      ('-5', 'GBP'),
      ('12.', 'GBP'),
      ('1234567890123', 'PKR'),
    ];
    for (final (input, currency) in rejected) {
      test('"$input" in $currency is not an amount', () {
        expect(parseMoney(input, currency, 'en'), isNull);
      });
    }
  });
}
