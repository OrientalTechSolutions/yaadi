import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

/// Flutter's Urdu material strings with the two things its pickers get wrong
/// for Urdu readers: the date picker's weekday columns use Latin letters
/// from CLDR ("S F T W T M S", with T and S twice), and the time picker
/// writes AM and PM in Latin. Part of the Urdu text awaiting native review
/// (ARCHITECTURE.md section 13).
///
/// Listed before [GlobalMaterialLocalizations.delegate], so it wins for Urdu
/// and every other locale falls through to Flutter's own.
abstract final class UrduMaterialLocalizations {
  static const LocalizationsDelegate<MaterialLocalizations> delegate =
      _Delegate();
}

final class _UrduMaterial extends MaterialLocalizationUr {
  const _UrduMaterial({
    required super.fullYearFormat,
    required super.compactDateFormat,
    required super.shortDateFormat,
    required super.mediumDateFormat,
    required super.longDateFormat,
    required super.yearMonthFormat,
    required super.shortMonthDayFormat,
    required super.decimalFormat,
    required super.twoDigitZeroPaddedFormat,
  });

  /// Sunday first, as the date picker expects. The names are short enough
  /// to stand whole, and their first letters would repeat.
  @override
  List<String> get narrowWeekdays => const [
    'اتوار',
    'پیر',
    'منگل',
    'بدھ',
    'جمعرات',
    'جمعہ',
    'ہفتہ',
  ];

  @override
  String get anteMeridiemAbbreviation => 'صبح';

  @override
  String get postMeridiemAbbreviation => 'شام';
}

final class _Delegate extends LocalizationsDelegate<MaterialLocalizations> {
  const _Delegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ur';

  /// Flutter's own delegate loads intl's Urdu date data first. Both futures
  /// are synchronous, so the first frame is not delayed.
  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(locale).then((_) {
        const name = 'ur';
        return _UrduMaterial(
          fullYearFormat: intl.DateFormat.y(name),
          compactDateFormat: intl.DateFormat.yMd(name),
          shortDateFormat: intl.DateFormat.yMMMd(name),
          mediumDateFormat: intl.DateFormat.MMMEd(name),
          longDateFormat: intl.DateFormat.yMMMMEEEEd(name),
          yearMonthFormat: intl.DateFormat.yMMMM(name),
          shortMonthDayFormat: intl.DateFormat.MMMd(name),
          decimalFormat: intl.NumberFormat.decimalPattern(name),
          twoDigitZeroPaddedFormat: intl.NumberFormat('00', name),
        );
      });

  @override
  bool shouldReload(_Delegate old) => false;
}
