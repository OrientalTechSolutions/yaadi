import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/time/clock.dart';
import '../../items/application/items_providers.dart';
import '../../items/domain/completion.dart';
import '../domain/morning_summary.dart';
import '../domain/today_view.dart';

/// Completions recorded for today's occurrences: which doses are marked.
final todayMarksProvider = StreamProvider<List<Completion>>((ref) {
  final today = ref.watch(todayProvider);
  return ref.watch(itemRepositoryProvider).watchCompletionsOn(today);
});

/// The Today screen's groups, rebuilt when an item changes, a dose is
/// marked or the date moves on.
final todayViewProvider = Provider<AsyncValue<TodayView>>((ref) {
  final today = ref.watch(todayProvider);
  final items = ref.watch(itemsProvider);
  final marks = ref.watch(todayMarksProvider);

  for (final source in [items, marks]) {
    if (source case AsyncError(:final error, :final stackTrace)) {
      return AsyncError(error, stackTrace);
    }
  }
  final (itemList, markList) = (items.value, marks.value);
  if (itemList == null || markList == null) return const AsyncLoading();
  // Marks from before a date change are filtered out by the view itself.
  return AsyncData(TodayView.build(itemList, today: today, marks: markList));
});

/// The facts for the morning summary card.
final morningSummaryProvider = Provider<AsyncValue<MorningSummary>>(
  (ref) => ref.watch(todayViewProvider).whenData(MorningSummary.of),
);
