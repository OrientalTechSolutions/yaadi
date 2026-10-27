import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/time/clock.dart';
import 'package:yaadi/core/time/local_date.dart';
import 'package:yaadi/features/items/application/items_providers.dart';
import 'package:yaadi/features/items/data/memory_item_repository.dart';
import 'package:yaadi/features/today/application/quick_actions.dart';
import 'package:yaadi/features/today/application/today_providers.dart';
import 'package:yaadi/features/today/domain/morning_summary.dart';
import 'package:yaadi/features/today/domain/today_view.dart';

import '../../../support/households.dart';

void main() {
  late DateTime now;
  late ProviderContainer container;

  setUp(() {
    now = DateTime(2026, 11, 2, 7, 30);
    container = ProviderContainer.test(
      overrides: [
        itemRepositoryProvider.overrideWithValue(
          MemoryItemRepository(items: khanHousehold),
        ),
        clockProvider.overrideWithValue(() => now),
      ],
    );
  });

  Future<TodayView> view() async {
    container.listen(todayViewProvider, (_, _) {});
    await pumpEventQueue();
    return container.read(todayViewProvider).requireValue;
  }

  test('groups the household once items and marks have loaded', () async {
    expect(container.read(todayViewProvider), isA<AsyncLoading<TodayView>>());
    final today = await view();
    expect(today.today, fixtureToday);
    expect(today[TodaySection.overdue].map((e) => e.item.id), ['rent']);
    expect(today[TodaySection.today].map((e) => e.item.id), [
      'ammi',
      'jazz',
      'water',
    ]);
  });

  test('a marked dose shows as marked', () async {
    await view();
    await container
        .read(quickActionsProvider.notifier)
        .markDose('ammi', fixtureToday, 840);
    await pumpEventQueue();

    final ammi = (await view())[TodaySection.today].first;
    expect(ammi.doses.map((dose) => dose.marked), [false, true, false]);
  });

  test('regroups when the date moves on', () async {
    await view();
    now = DateTime(2026, 11, 3, 0, 0, 5);
    container.read(todayProvider.notifier).refresh();
    await pumpEventQueue();

    final tomorrow = await view();
    expect(tomorrow.today, LocalDate(2026, 11, 3));
    expect(tomorrow[TodaySection.overdue].map((e) => e.item.id), [
      'rent',
      'jazz',
      'water',
    ]);
    final doses = tomorrow[TodaySection.today].single.doses;
    expect(doses.map((dose) => dose.marked), everyElement(isFalse));
  });

  test('the morning summary follows the view', () async {
    container.listen(morningSummaryProvider, (_, _) {});
    await pumpEventQueue();
    final summary = container.read(morningSummaryProvider).requireValue;
    expect(summary, MorningSummary.of(await view()));
    expect(summary.overdue, 1);
  });
}
