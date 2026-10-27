import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:yaadi/core/time/clock.dart';
import 'package:yaadi/core/time/local_date.dart';
import 'package:yaadi/core/time/time_format.dart';

/// Linux CI runs this file under TZ=Europe/London, America/New_York and
/// Asia/Karachi (ARCHITECTURE.md section 17); Dart on Windows ignores TZ.
void main() {
  // The app's localization delegates do this; plain tests do it themselves.
  setUpAll(initializeDateFormatting);

  ProviderContainer containerAt(DateTime Function() clock) =>
      ProviderContainer.test(
        overrides: [clockProvider.overrideWithValue(clock)],
      );

  group('today', () {
    test('23:59 is still today and 00:00 is tomorrow', () {
      expect(
        containerAt(() => DateTime(2026, 11, 2, 23, 59, 59))
            .read(todayProvider),
        LocalDate(2026, 11, 2),
      );
      expect(
        containerAt(() => DateTime(2026, 11, 3)).read(todayProvider),
        LocalDate(2026, 11, 3),
      );
    });

    // The 2026 daylight-saving changes in London and the US. Local times
    // around them still belong to their own date.
    for (final (month, day) in [(3, 29), (10, 25), (3, 8), (11, 1)]) {
      test('every hour of 2026-$month-$day belongs to that date', () {
        for (var hour = 0; hour < 24; hour++) {
          final container = containerAt(
            () => DateTime(2026, month, day, hour, 30),
          );
          expect(
            container.read(todayProvider),
            LocalDate(2026, month, day),
            reason: '$hour:30',
          );
        }
      });
    }

    test('moves on by itself at midnight, within a minute', () {
      fakeAsync((async) {
        var now = DateTime(2026, 11, 2, 23, 59, 30);
        final container = containerAt(() => now);
        final seen = <LocalDate>[];
        container.listen(todayProvider, (_, next) => seen.add(next));
        expect(container.read(todayProvider), LocalDate(2026, 11, 2));

        async.elapse(TodayController.checkEvery);
        expect(seen, isEmpty);

        now = DateTime(2026, 11, 3, 0, 0, 30);
        async.elapse(TodayController.checkEvery);
        expect(seen, [LocalDate(2026, 11, 3)]);

        async.elapse(TodayController.checkEvery * 10);
        expect(seen, hasLength(1));
      });
    });

    test('a time-zone change that crosses midnight is picked up', () {
      fakeAsync((async) {
        // Flying from Lahore to London in the evening: the wall clock jumps
        // back across midnight.
        var now = DateTime(2026, 11, 3, 0, 30);
        final container = containerAt(() => now);
        final seen = <LocalDate>[];
        container.listen(todayProvider, (_, next) => seen.add(next));

        now = DateTime(2026, 11, 2, 19, 31);
        async.elapse(TodayController.checkEvery);
        expect(seen, [LocalDate(2026, 11, 2)]);
      });
    });

    test('refresh on resume reads the clock at once', () {
      var now = DateTime(2026, 11, 2, 22);
      final container = containerAt(() => now);
      expect(container.read(todayProvider), LocalDate(2026, 11, 2));

      now = DateTime(2026, 11, 3, 7);
      container.read(todayProvider.notifier).refresh();
      expect(container.read(todayProvider), LocalDate(2026, 11, 3));
    });

    test('stops checking once nothing listens', () {
      fakeAsync((async) {
        final container = ProviderContainer(
          overrides: [
            clockProvider.overrideWithValue(() => DateTime(2026, 11, 2)),
          ],
        );
        container.read(todayProvider);
        expect(async.periodicTimerCount, 1);
        container.dispose();
        expect(async.periodicTimerCount, 0);
      });
    });
  });

  group('times of day', () {
    String plain(String text) => text.replaceAll(RegExp(r'\s'), ' ');

    test('format for the locale', () {
      expect(plain(formatMinute(480, 'en')), '8:00 AM');
      expect(plain(formatMinute(1230, 'en')), '8:30 PM');
      expect(plain(formatMinute(0, 'en')), '12:00 AM');
      expect(plain(formatMinute(1439, 'en')), '11:59 PM');
    });

    test('reject minutes outside a day', () {
      expect(() => formatMinute(-1, 'en'), throwsRangeError);
      expect(() => formatMinute(1440, 'en'), throwsRangeError);
    });
  });
}
