import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_date.dart';

/// Returns the current local time. Tests and screenshot builds replace it.
typedef Clock = DateTime Function();

final clockProvider = Provider<Clock>((ref) => DateTime.now);

/// Screenshot builds pin the date with `--dart-define=YAADI_TODAY=2026-11-02`
/// so the demo households always look the same.
const _pinnedToday = String.fromEnvironment('YAADI_TODAY');

/// Today's local date, the one input every Today and summary calculation
/// takes. It moves on by itself at midnight or after a time-zone change,
/// and at once when the app returns to the foreground.
final todayProvider = NotifierProvider<TodayController, LocalDate>(
  TodayController.new,
);

class TodayController extends Notifier<LocalDate> {
  /// Midnight and zone changes show up within this long. A timer aimed at
  /// midnight would miss a zone change, and a minute costs nothing.
  static const checkEvery = Duration(minutes: 1);

  @override
  LocalDate build() {
    final pinned = LocalDate.tryParse(_pinnedToday);
    if (pinned != null) return pinned;
    final clock = ref.watch(clockProvider);
    final timer = Timer.periodic(checkEvery, (_) => refresh());
    ref.onDispose(timer.cancel);
    return LocalDate.fromDateTime(clock());
  }

  /// Reads the clock again. Listeners hear about it only when the date has
  /// changed. The app calls this when it resumes.
  void refresh() {
    if (_pinnedToday.isNotEmpty) return;
    final now = LocalDate.fromDateTime(ref.read(clockProvider)());
    if (now != state) state = now;
  }
}
