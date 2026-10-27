import 'package:intl/intl.dart';

/// A time of day given as minutes after midnight, formatted for [locale]:
/// `8:00 AM` in English.
String formatMinute(int minute, String locale) {
  RangeError.checkValueInInterval(minute, 0, 1439, 'minute');
  // Any date works; 1 January has no daylight-saving change anywhere.
  final time = DateTime(2000, 1, 1, minute ~/ 60, minute % 60);
  return DateFormat.jm(locale).format(time);
}
