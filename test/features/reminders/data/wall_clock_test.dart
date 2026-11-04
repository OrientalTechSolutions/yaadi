import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_10y.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:yaadi/core/time/local_date.dart';
import 'package:yaadi/features/reminders/data/wall_clock.dart';

void main() {
  setUpAll(tzdata.initializeTimeZones);

  String utc(tz.TZDateTime time) =>
      time.toUtc().toIso8601String().substring(0, 16);

  test('an ordinary minute is that minute in the zone', () {
    final karachi = tz.getLocation('Asia/Karachi');
    final at = wallClock(karachi, LocalDate(2026, 11, 10), 9 * 60);
    expect(utc(at), '2026-11-10T04:00');
    expect((at.hour, at.minute), (9, 0));
  });

  test('a minute skipped by summer time moves to the next one that exists', () {
    // London goes from 01:00 to 02:00 on 29 March 2026.
    final london = tz.getLocation('Europe/London');
    final at = wallClock(london, LocalDate(2026, 3, 29), 60 + 30);
    expect((at.hour, at.minute), (2, 0));
    expect(utc(at), '2026-03-29T01:00');
  });

  test('a minute that happens twice takes the first', () {
    // London goes from 02:00 back to 01:00 on 25 October 2026.
    final london = tz.getLocation('Europe/London');
    final at = wallClock(london, LocalDate(2026, 10, 25), 60 + 30);
    expect((at.hour, at.minute), (1, 30));
    expect(utc(at), '2026-10-25T00:30');
  });

  test('a zone whose clocks change at midnight', () {
    // Santiago skips midnight on 6 September 2026.
    final santiago = tz.getLocation('America/Santiago');
    final at = wallClock(santiago, LocalDate(2026, 9, 6), 0);
    expect(LocalDate.fromDateTime(at), LocalDate(2026, 9, 6));
    expect((at.hour, at.minute), (1, 0));
  });

  test('a date never moves with the zone', () {
    for (final name in ['Pacific/Kiritimati', 'Pacific/Pago_Pago']) {
      final at = wallClock(tz.getLocation(name), LocalDate(2026, 12, 31), 600);
      expect(LocalDate.fromDateTime(at), LocalDate(2026, 12, 31), reason: name);
    }
  });
}
