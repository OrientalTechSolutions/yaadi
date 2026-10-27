import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/time/local_date.dart';
import 'package:yaadi/features/items/domain/recurrence.dart';

LocalDate d(int year, int month, int day) => LocalDate(year, month, day);

void main() {
  group('nextAfter', () {
    final cases = <(String, Recurrence, LocalDate, LocalDate?)>[
      ('none never repeats', Recurrence.none, d(2026, 1, 31), null),
      ('daily', const DailyRepeat(), d(2026, 12, 31), d(2027, 1, 1)),
      (
        'weekly keeps the weekday',
        WeeklyRepeat(5),
        d(2026, 11, 6),
        d(2026, 11, 13),
      ),
      (
        'weekly from another weekday',
        WeeklyRepeat(5),
        d(2026, 11, 2),
        d(2026, 11, 6),
      ),
      ('31st to February', MonthlyRepeat(31), d(2026, 1, 31), d(2026, 2, 28)),
      (
        '31st to February in a leap year',
        MonthlyRepeat(31),
        d(2028, 1, 31),
        d(2028, 2, 29),
      ),
      (
        'clamped February back to 31 March',
        MonthlyRepeat(31),
        d(2026, 2, 28),
        d(2026, 3, 31),
      ),
      ('31st to 30 April', MonthlyRepeat(31), d(2026, 3, 31), d(2026, 4, 30)),
      (
        '30th through February',
        MonthlyRepeat(30),
        d(2026, 2, 28),
        d(2026, 3, 30),
      ),
      (
        'December to January',
        MonthlyRepeat(10),
        d(2026, 12, 10),
        d(2027, 1, 10),
      ),
      (
        'a moved date returns to the anchor',
        MonthlyRepeat(10),
        d(2026, 11, 3),
        d(2026, 11, 10),
      ),
      ('yearly', YearlyRepeat(6, 30), d(2026, 6, 30), d(2027, 6, 30)),
      (
        '29 February in a common year',
        YearlyRepeat(2, 29),
        d(2028, 2, 29),
        d(2029, 2, 28),
      ),
      (
        'back to 29 February in a leap year',
        YearlyRepeat(2, 29),
        d(2031, 2, 28),
        d(2032, 2, 29),
      ),
      ('doses never roll', DoseTimes([480]), d(2026, 10, 27), null),
    ];
    for (final (name, rule, from, expected) in cases) {
      test(name, () => expect(rule.nextAfter(from), expected));
    }

    test('stops after until, which is inclusive', () {
      final course = DailyRepeat(until: d(2026, 11, 3));
      expect(course.nextAfter(d(2026, 11, 2)), d(2026, 11, 3));
      expect(course.nextAfter(d(2026, 11, 3)), isNull);
    });

    test('council tax stops after ten monthly instalments', () {
      // April to January, as UK councils bill by default.
      final rule = MonthlyRepeat(1, until: d(2027, 1, 1));
      final dates = <LocalDate>[d(2026, 4, 1)];
      for (
        var next = rule.nextAfter(dates.last);
        next != null;
        next = rule.nextAfter(dates.last)
      ) {
        dates.add(next);
      }
      expect(dates, hasLength(10));
      expect(dates.last, d(2027, 1, 1));
    });

    test('a clamped instance keeps its anchor all year', () {
      final rule = MonthlyRepeat(31);
      var date = d(2026, 1, 31);
      final seen = <int>[];
      for (var i = 0; i < 12; i++) {
        date = rule.nextAfter(date)!;
        seen.add(date.day);
      }
      expect(seen, [28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 31]);
    });
  });

  group('anchored', () {
    test('takes the anchor from the due date', () {
      final due = d(2026, 1, 31);
      expect(Recurrence.anchored(RepeatRule.monthly, due), MonthlyRepeat(31));
      expect(
        Recurrence.anchored(RepeatRule.weekly, due),
        WeeklyRepeat(due.weekday),
      );
      expect(Recurrence.anchored(RepeatRule.yearly, due), YearlyRepeat(1, 31));
      expect(Recurrence.anchored(RepeatRule.none, due), Recurrence.none);
      expect(
        Recurrence.anchored(RepeatRule.doses, due, doseMinutes: [1200, 480]),
        DoseTimes([480, 1200]),
      );
    });
  });

  group('validation', () {
    test('rejects values a rule cannot have', () {
      expect(() => WeeklyRepeat(0), throwsRangeError);
      expect(() => WeeklyRepeat(8), throwsRangeError);
      expect(() => MonthlyRepeat(32), throwsRangeError);
      expect(() => YearlyRepeat(2, 30), throwsRangeError);
      expect(() => YearlyRepeat(13, 1), throwsRangeError);
      expect(() => DoseTimes(const []), throwsRangeError);
      expect(() => DoseTimes([1440]), throwsRangeError);
      expect(
        () => DoseTimes(List.generate(9, (i) => i * 60)),
        throwsRangeError,
      );
    });

    test('dose times are sorted and unique', () {
      expect(DoseTimes([1200, 480, 840, 480]).minutes, [480, 840, 1200]);
    });
  });

  group('JSON', () {
    final rules = <Recurrence>[
      Recurrence.none,
      DailyRepeat(until: d(2026, 11, 7)),
      WeeklyRepeat(5),
      MonthlyRepeat(31),
      MonthlyRepeat(1, until: d(2027, 1, 1)),
      YearlyRepeat(2, 29),
      DoseTimes([480, 840, 1200], until: d(2026, 11, 3)),
    ];
    for (final rule in rules) {
      test('round-trips $rule', () {
        expect(Recurrence.decode(rule.encode()), rule);
      });
    }

    test('writes the documented shape', () {
      expect(Recurrence.none.encode(), '{"type":"none"}');
      expect(
        MonthlyRepeat(1, until: d(2027, 1, 1)).encode(),
        '{"type":"monthly","day":1,"until":"2027-01-01"}',
      );
      expect(
        DoseTimes([480, 840, 1200], until: d(2026, 11, 3)).encode(),
        '{"type":"doses","minutes":[480,840,1200],"until":"2026-11-03"}',
      );
    });

    test('ignores keys it does not know', () {
      expect(
        Recurrence.decode('{"type":"monthly","day":10,"note":"meter reading"}'),
        MonthlyRepeat(10),
      );
      expect(
        Recurrence.decode('{"type":"monthly","day":10,"interval":1}'),
        MonthlyRepeat(10),
      );
    });

    const unsupported = [
      '{"type":"fortnightly"}',
      '{"type":"monthly","day":10,"interval":3}',
      '{"type":"monthly","day":40}',
      '{"type":"monthly","day":"10"}',
      '{"type":"weekly"}',
      '{"type":"daily","until":"soon"}',
      '{"type":"doses","minutes":[]}',
      '{"type":"doses","minutes":["08:00"]}',
      '[1,2,3]',
      'not json',
    ];
    for (final raw in unsupported) {
      test('keeps $raw as unsupported and writes it back unchanged', () {
        final rule = Recurrence.decode(raw);
        expect(rule, isA<UnsupportedRepeat>());
        expect(rule.isSupported, isFalse);
        expect(rule.rule, isNull);
        expect(rule.encode(), raw);
        expect(rule.nextAfter(d(2026, 1, 1)), isNull);
      });
    }
  });

  group('withUntil', () {
    final end = d(2027, 1, 31);
    final cases = <(Recurrence, Recurrence)>[
      (Recurrence.none, Recurrence.none),
      (const DailyRepeat(), DailyRepeat(until: end)),
      (WeeklyRepeat(4), WeeklyRepeat(4, until: end)),
      (MonthlyRepeat(31), MonthlyRepeat(31, until: end)),
      (YearlyRepeat(2, 29), YearlyRepeat(2, 29, until: end)),
      (DoseTimes([1200, 480]), DoseTimes([480, 1200], until: end)),
    ];
    for (final (rule, ended) in cases) {
      test('$rule keeps its anchor', () {
        expect(rule.withUntil(end), ended);
        expect(rule.withUntil(end).withUntil(null), rule);
      });
    }

    test('a rule from a newer version is left alone', () {
      const rule = UnsupportedRepeat('{"type":"lunar"}');
      expect(rule.withUntil(end), same(rule));
    });
  });
}
