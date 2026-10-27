import 'package:meta/meta.dart';

/// An amount owed or paid, in minor units (paisa, pence, cents) of an
/// ISO 4217 currency. Never a double, and never negative.
@immutable
final class Money {
  Money(this.minorUnits, this.currency) {
    if (minorUnits < 0) {
      throw RangeError.value(minorUnits, 'minorUnits', 'Must not be negative');
    }
    if (!isCurrencyCode(currency)) {
      throw ArgumentError.value(currency, 'currency', 'Not an ISO 4217 code');
    }
  }

  final int minorUnits;
  final String currency;

  static bool isCurrencyCode(String code) => _codePattern.hasMatch(code);

  static final _codePattern = RegExp(r'^[A-Z]{3}$');

  CurrencyInfo get info => CurrencyInfo.of(currency);

  @override
  bool operator ==(Object other) =>
      other is Money &&
      other.minorUnits == minorUnits &&
      other.currency == currency;

  @override
  int get hashCode => Object.hash(minorUnits, currency);

  @override
  String toString() => 'Money($minorUnits $currency)';
}

/// How a currency is written and typed.
@immutable
final class CurrencyInfo {
  const CurrencyInfo._(
    this.code,
    this.symbol, {
    this.inputFractionDigits = 2,
    this.spaceAfterSymbol = false,
  });

  static const pkr = CurrencyInfo._(
    'PKR',
    'Rs',
    inputFractionDigits: 0,
    spaceAfterSymbol: true,
  );
  static const gbp = CurrencyInfo._('GBP', '£');
  static const usd = CurrencyInfo._('USD', r'$');

  static const supported = [pkr, gbp, usd];

  /// Falls back to the bare code for currencies Yaadi has no symbol for.
  static CurrencyInfo of(String code) {
    for (final info in supported) {
      if (info.code == code) return info;
    }
    return CurrencyInfo._(code, code, spaceAfterSymbol: true);
  }

  final String code;
  final String symbol;

  /// Paisa are not used on Pakistani bills, so PKR amounts are typed in
  /// whole rupees even though they are stored in minor units.
  final int inputFractionDigits;

  final bool spaceAfterSymbol;

  /// Minor units per major unit. Every supported currency uses 100.
  int get minorPerMajor => 100;

  /// Digits after the decimal separator when the minor part is not zero.
  int get fractionDigits => 2;
}
