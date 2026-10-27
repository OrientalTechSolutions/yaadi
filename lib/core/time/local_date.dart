import 'package:meta/meta.dart';

/// A calendar date with no time of day and no time zone, such as the
/// "10th" printed on a bill.
///
/// All arithmetic goes through UTC, where every day has 24 hours, so a
/// daylight-saving change can never move a date.
@immutable
final class LocalDate implements Comparable<LocalDate> {
  /// Throws a [RangeError] for dates that do not exist, such as 30 February.
  factory LocalDate(int year, int month, int day) {
    RangeError.checkValueInInterval(year, 1, 9999, 'year');
    RangeError.checkValueInInterval(month, 1, 12, 'month');
    RangeError.checkValueInInterval(day, 1, daysInMonth(year, month), 'day');
    return LocalDate._(year, month, day);
  }

  const LocalDate._(this.year, this.month, this.day);

  /// The wall-clock date of [dateTime], in whatever zone it carries.
  factory LocalDate.fromDateTime(DateTime dateTime) =>
      LocalDate._(dateTime.year, dateTime.month, dateTime.day);

  /// Parses `YYYY-MM-DD`, the storage format.
  static LocalDate parse(String text) {
    final date = tryParse(text);
    if (date == null) throw FormatException('Not a YYYY-MM-DD date', text);
    return date;
  }

  static LocalDate? tryParse(String text) {
    final match = _isoPattern.firstMatch(text);
    if (match == null) return null;
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    if (year < 1 || month < 1 || month > 12) return null;
    if (day < 1 || day > daysInMonth(year, month)) return null;
    return LocalDate._(year, month, day);
  }

  static final _isoPattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  static int daysInMonth(int year, int month) =>
      DateTime.utc(year, month + 1, 0).day;

  final int year;
  final int month;
  final int day;

  /// ISO weekday: 1 is Monday, 7 is Sunday.
  int get weekday => _utc.weekday;

  DateTime get _utc => DateTime.utc(year, month, day);

  LocalDate addDays(int days) =>
      LocalDate.fromDateTime(DateTime.utc(year, month, day + days));

  /// The date [months] later on [day], or on the last day of that month when
  /// it is shorter: 31 January plus one month is 28 or 29 February.
  LocalDate addMonths(int months, {int? onDay}) {
    final first = DateTime.utc(year, month + months);
    final wanted = onDay ?? day;
    final last = daysInMonth(first.year, first.month);
    return LocalDate(first.year, first.month, wanted < last ? wanted : last);
  }

  /// Whole days from this date to [other]; negative when [other] is earlier.
  int daysUntil(LocalDate other) => other._utc.difference(_utc).inDays;

  bool isBefore(LocalDate other) => compareTo(other) < 0;

  bool isAfter(LocalDate other) => compareTo(other) > 0;

  /// Midnight at the start of this date, as a local [DateTime], for
  /// formatting with `intl`.
  DateTime toDateTime() => DateTime(year, month, day);

  String toIso() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  @override
  int compareTo(LocalDate other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      other is LocalDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIso();
}
