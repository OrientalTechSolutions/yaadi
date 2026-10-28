import 'package:intl/intl.dart';

import '../text/bidi.dart';
import '../text/digits.dart';
import 'money.dart';

/// Formats [money] for [locale]: `Rs 4,250`, `£12.50`, `$80`. A zero minor
/// part is left out, the way bills print whole amounts. The space after a
/// symbol is a no-break space, so "Rs" never ends a line with the digits on
/// the next.
String formatMoney(Money money, String locale) {
  final info = money.info;
  final numbers = NumberFormat.decimalPattern(locale);
  final whole = money.minorUnits ~/ info.minorPerMajor;
  final fraction = money.minorUnits % info.minorPerMajor;

  final buffer = StringBuffer(info.symbol);
  if (info.spaceAfterSymbol) buffer.write(noBreakSpace);
  buffer.write(stripBidiControls(numbers.format(whole)));
  if (fraction != 0) {
    buffer
      ..write(numbers.symbols.DECIMAL_SEP)
      ..write(fraction.toString().padLeft(info.fractionDigits, '0'));
  }
  return buffer.toString();
}

/// [money] as the editor shows it for changing: plain digits with no symbol
/// or grouping, `4250` or `12.50`, which [parseMoney] reads back in any
/// locale.
String formatMoneyInput(Money money) {
  final info = money.info;
  final whole = money.minorUnits ~/ info.minorPerMajor;
  final fraction = money.minorUnits % info.minorPerMajor;
  if (fraction == 0) return '$whole';
  return '$whole.${fraction.toString().padLeft(info.fractionDigits, '0')}';
}

/// Parses an amount the user typed in [currency], or returns null when it is
/// not one. Accepts Urdu and ASCII digits and the locale's separators. PKR
/// takes whole rupees only; GBP and USD take up to two decimals.
Money? parseMoney(String input, String currency, String locale) {
  final info = CurrencyInfo.of(currency);
  final symbols = NumberFormat.decimalPattern(locale).symbols;

  var text = stripBidiControls(normalizeDigits(input)).trim();
  for (final group in {symbols.GROUP_SEP, ',', '\u066C', ' ', '\u00A0'}) {
    text = text.replaceAll(group, '');
  }
  for (final decimal in {symbols.DECIMAL_SEP, '\u066B'}) {
    text = text.replaceAll(decimal, '.');
  }

  final match = _amountPattern.firstMatch(text);
  if (match == null) return null;
  final whole = match.group(1)!;
  final fraction = match.group(2) ?? '';
  if (fraction.length > info.inputFractionDigits) return null;
  // Keeps every amount far below 2^53, where web integers lose precision.
  if (whole.length > _maxWholeDigits) return null;

  final minor =
      int.parse(whole) * info.minorPerMajor +
      int.parse(fraction.padRight(info.fractionDigits, '0'));
  return Money(minor, info.code);
}

final _amountPattern = RegExp(r'^(\d+)(?:\.(\d+))?$');

const _maxWholeDigits = 12;
