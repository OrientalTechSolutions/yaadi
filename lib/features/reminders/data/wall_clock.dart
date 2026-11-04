import 'package:timezone/timezone.dart' as tz;

import '../../../core/time/local_date.dart';

/// The instant a wall-clock reminder goes off in [location].
///
/// Where clocks jump forward the requested minute may not exist (02:30 on
/// the morning the UK moves to summer time): the reminder moves to the next
/// minute that does, 03:00. Where clocks go back a minute happens twice:
/// the reminder takes the first one (ARCHITECTURE.md section 18).
tz.TZDateTime wallClock(tz.Location location, LocalDate on, int minute) {
  RangeError.checkValueInInterval(minute, 0, 1439, 'minute');
  bool shows(tz.TZDateTime time, LocalDate day, int wanted) =>
      LocalDate.fromDateTime(time) == day &&
      time.hour * 60 + time.minute == wanted;

  var candidate = tz.TZDateTime(
    location,
    on.year,
    on.month,
    on.day,
    minute ~/ 60,
    minute % 60,
  );

  if (!shows(candidate, on, minute)) {
    // In a gap: walk forward to the first minute that exists. Gaps are at
    // most a few hours long anywhere.
    for (var step = 1; step <= 24 * 60; step++) {
      final day = on.addDays((minute + step) ~/ 1440);
      final wanted = (minute + step) % 1440;
      final next = tz.TZDateTime(
        location,
        day.year,
        day.month,
        day.day,
        wanted ~/ 60,
        wanted % 60,
      );
      if (shows(next, day, wanted)) return next;
    }
    return candidate;
  }

  // In an overlap the same wall-clock minute also exists earlier; the
  // largest step back that still shows it is the first one.
  final found = candidate;
  for (final back in const [30, 60, 120]) {
    final earlier = tz.TZDateTime.fromMillisecondsSinceEpoch(
      location,
      found.millisecondsSinceEpoch - back * 60 * 1000,
    );
    if (shows(earlier, on, minute)) candidate = earlier;
  }
  return candidate;
}
