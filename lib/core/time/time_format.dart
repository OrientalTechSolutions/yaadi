import 'package:intl/intl.dart';

/// A time of day given as minutes after midnight, formatted for [locale]:
/// `8:00 AM` in English, `صبح 8:00` in Urdu.
String formatMinute(int minute, String locale) {
  RangeError.checkValueInInterval(minute, 0, 1439, 'minute');
  if (Intl.shortLocale(locale) == 'ur') return _urduTime(minute);
  // Any date works; 1 January has no daylight-saving change anywhere.
  final time = DateTime(2000, 1, 1, minute ~/ 60, minute % 60);
  return DateFormat.jm(locale).format(time);
}

/// `intl`'s Urdu data writes AM and PM as a bare "a" and "p", which nobody
/// reads. Urdu speakers name the part of the day instead, so the clock is
/// twelve-hour with صبح (morning), دوپہر (midday), شام (evening) or رات
/// (night) in front. Part of the Urdu text awaiting native review
/// (ARCHITECTURE.md section 13).
String _urduTime(int minute) {
  final hour = minute ~/ 60;
  final period = switch (hour) {
    >= 4 && < 12 => 'صبح',
    >= 12 && < 16 => 'دوپہر',
    >= 16 && < 19 => 'شام',
    _ => 'رات',
  };
  final twelve = hour % 12 == 0 ? 12 : hour % 12;
  final minutes = (minute % 60).toString().padLeft(2, '0');
  return '$period $twelve:$minutes';
}
