import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_date.dart';

/// Returns the current local time. Tests and screenshot builds replace it.
typedef Clock = DateTime Function();

final clockProvider = Provider<Clock>((ref) => DateTime.now);

/// Screenshot builds pin the date with `--dart-define=YAADI_TODAY=2026-11-02`
/// so the demo households always look the same.
const _pinnedToday = String.fromEnvironment('YAADI_TODAY');

final todayProvider = Provider<LocalDate>((ref) {
  final pinned = LocalDate.tryParse(_pinnedToday);
  return pinned ?? LocalDate.fromDateTime(ref.watch(clockProvider)());
});
