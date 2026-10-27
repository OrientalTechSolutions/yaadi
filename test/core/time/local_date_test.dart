import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/time/local_date.dart';

void main() {
  group('construction', () {
    test('rejects dates that do not exist instead of rolling them over', () {
      expect(() => LocalDate(2026, 2, 29), throwsRangeError);
      expect(() => LocalDate(2026, 4, 31), throwsRangeError);
      expect(() => LocalDate(2026, 13, 1), throwsRangeError);
      expect(() => LocalDate(2026, 0, 1), throwsRangeError);
      expect(LocalDate(2028, 2, 29).day, 29);
    });

    test('parses only well-formed YYYY-MM-DD', () {
      expect(LocalDate.parse('2026-11-02'), LocalDate(2026, 11, 2));
      for (final bad in [
        '2026-2-1',
        '2026-02-30',
        '26-02-01',
        '2026-02-01T00:00',
        '',
      ]) {
        expect(LocalDate.tryParse(bad), isNull, reason: bad);
      }
      expect(() => LocalDate.parse('2026-02-30'), throwsFormatException);
    });

    test('takes the wall-clock fields of a DateTime as they are', () {
      expect(
        LocalDate.fromDateTime(DateTime(2026, 10, 27, 23, 59)),
        LocalDate(2026, 10, 27),
      );
      expect(
        LocalDate.fromDateTime(DateTime.utc(2026, 10, 28, 0, 0)),
        LocalDate(2026, 10, 28),
      );
    });

    test('formats with padding and round-trips', () {
      expect(LocalDate(2026, 3, 9).toIso(), '2026-03-09');
      expect(LocalDate(987, 1, 1).toIso(), '0987-01-01');
      expect(
        LocalDate.parse(LocalDate(2026, 12, 31).toIso()),
        LocalDate(2026, 12, 31),
      );
    });
  });

  group('arithmetic', () {
    // Europe/London and US daylight-saving changes in 2026. A local-time
    // DateTime.add(Duration(days: 1)) would land on 23:00 or 01:00 here.
    const transitions = [
      (2026, 3, 29),
      (2026, 10, 25),
      (2026, 3, 8),
      (2026, 11, 1),
    ];

    for (final (year, month, day) in transitions) {
      test('stepping over $year-$month-$day keeps whole days', () {
        final before = LocalDate(year, month, day).addDays(-1);
        expect(before.addDays(1), LocalDate(year, month, day));
        expect(before.addDays(2), LocalDate(year, month, day + 1));
        expect(before.daysUntil(before.addDays(2)), 2);
      });
    }

    test('adds days across months and years', () {
      expect(LocalDate(2026, 12, 31).addDays(1), LocalDate(2027, 1, 1));
      expect(LocalDate(2028, 2, 28).addDays(1), LocalDate(2028, 2, 29));
      expect(LocalDate(2026, 3, 1).addDays(-1), LocalDate(2026, 2, 28));
      expect(LocalDate(2026, 1, 1).daysUntil(LocalDate(2027, 1, 1)), 365);
      expect(LocalDate(2026, 1, 10).daysUntil(LocalDate(2026, 1, 3)), -7);
    });

    test('counts days exactly as UTC DateTime does, across centuries', () {
      final origin = LocalDate(2026, 11, 2);
      for (final date in [
        LocalDate(1, 1, 1),
        LocalDate(1600, 2, 29),
        LocalDate(1900, 3, 1),
        LocalDate(1970, 1, 1),
        LocalDate(2000, 2, 29),
        LocalDate(2026, 3, 29),
        LocalDate(2100, 2, 28),
        LocalDate(9999, 12, 31),
      ]) {
        final expected = DateTime.utc(
          date.year,
          date.month,
          date.day,
        ).difference(DateTime.utc(2026, 11, 2)).inDays;
        expect(origin.daysUntil(date), expected, reason: '$date');
      }
      var day = LocalDate(2027, 12, 31);
      for (var i = 0; i < 800; i++) {
        expect(origin.daysUntil(day), 424 - i, reason: '$day');
        day = day.addDays(-1);
      }
    });

    test('adds months on a day, clamped to short months', () {
      final jan31 = LocalDate(2026, 1, 31);
      expect(jan31.addMonths(1), LocalDate(2026, 2, 28));
      expect(LocalDate(2028, 1, 31).addMonths(1), LocalDate(2028, 2, 29));
      expect(jan31.addMonths(3), LocalDate(2026, 4, 30));
      expect(LocalDate(2026, 12, 15).addMonths(1), LocalDate(2027, 1, 15));
      expect(
        LocalDate(2026, 2, 28).addMonths(1, onDay: 31),
        LocalDate(2026, 3, 31),
      );
    });

    test('knows ISO weekdays and order', () {
      expect(LocalDate(2026, 11, 2).weekday, DateTime.monday);
      expect(LocalDate(2026, 11, 8).weekday, DateTime.sunday);
      expect(LocalDate(2026, 1, 1).isBefore(LocalDate(2026, 1, 2)), isTrue);
      expect(LocalDate(2026, 1, 2).isAfter(LocalDate(2026, 1, 1)), isTrue);
      final sorted = [
        LocalDate(2027, 1, 1),
        LocalDate(2026, 12, 31),
        LocalDate(2026, 2, 1),
      ]..sort();
      expect(sorted.first, LocalDate(2026, 2, 1));
    });
  });

  // Labels and date pickers see dates as local DateTimes. CI also runs this
  // in America/Santiago, where clocks change at midnight.
  test('every day survives the trip through a local DateTime', () {
    for (
      var day = LocalDate(2026, 1, 1);
      day.year == 2026;
      day = day.addDays(1)
    ) {
      expect(LocalDate.fromDateTime(day.toDateTime()), day);
    }
  });
}
