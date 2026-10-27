import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/money/money.dart';
import 'package:yaadi/core/time/local_date.dart';
import 'package:yaadi/features/demo/domain/demo_household.dart';
import 'package:yaadi/features/items/domain/item_category.dart';
import 'package:yaadi/features/items/domain/item_kind.dart';
import 'package:yaadi/features/items/domain/recurrence.dart';
import 'package:yaadi/features/today/presentation/today_screen.dart';

import '../../../support/fake_storage.dart';
import '../../../support/households.dart';
import '../../../support/items.dart';
import '../../../support/pump_app.dart';

Finder inToday(Finder finder) => onScreen(TodayScreen, finder);

void main() {
  testWidgets('groups the household and sums up the morning', (tester) async {
    await pumpApp(tester, vaultWith(DemoHousehold.khan));

    expect(inToday(find.text('Morning summary')), findsOneWidget);
    expect(inToday(findPlain('Overdue: گیس کا بل')), findsOneWidget);
    expect(
      inToday(findPlain("Today: Ayesha's school fee · Rs 12,000")),
      findsOneWidget,
    );
    expect(inToday(findPlain('Medicine: 3 times today')), findsOneWidget);

    await scrollTo(tester, inToday(find.text('Did these happen? · 1')));
    expect(
      inToday(findPlain('Was yesterday · ${clock(1020)}')),
      findsOneWidget,
    );
    await scrollTo(tester, inToday(find.text('Overdue · 1')));
    expect(inToday(findPlain('Overdue by 2 days')), findsOneWidget);
    await scrollTo(tester, inToday(find.text('Today · 2')));
    await scrollTo(tester, inToday(findPlain('Due today')));

    await scrollTo(tester, inToday(find.text('Next 7 days · 4')));
    await scrollTo(tester, inToday(findPlain('In 3 days · Thu, Nov 5')));
    expect(inToday(findPlain('Expires in 23 days')), findsOneWidget);
    await scrollTo(tester, inToday(find.text('Later · 3')));
    await scrollTo(tester, inToday(findPlain('Wed, Nov 11')));
    await scrollTo(tester, inToday(findPlain('Expires in 70 days')));
  });

  testWidgets('Paid rolls the fee to next month, and Undo brings it back', (
    tester,
  ) async {
    final vault = vaultWith(DemoHousehold.khan);
    await pumpApp(tester, vault);

    final paid = inToday(findLabelled("Mark Ayesha's school fee as paid"));
    await scrollTo(tester, paid);
    await tester.tap(paid);
    await tester.pumpAndSettle();
    expect(find.text('Marked as paid'), findsOneWidget);
    expect(
      (await vault.items.find('khan-school'))?.dueOn,
      LocalDate(2026, 12, 2),
    );
    expect(await vault.items.completionsOf('khan-school'), hasLength(1));

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect((await vault.items.find('khan-school'))?.dueOn, fixtureToday);
    expect(await vault.items.completionsOf('khan-school'), isEmpty);
    await scrollTo(tester, inToday(findPlain('Due today')));
  });

  testWidgets('Snooze shows the item again later and keeps its due date', (
    tester,
  ) async {
    final vault = vaultWith(DemoHousehold.khan);
    await pumpApp(tester, vault);

    final snooze = inToday(findLabelled('Snooze گیس کا بل'));
    await scrollTo(tester, snooze);
    await tester.tap(snooze);
    await tester.pumpAndSettle();
    await tester.tap(find.text('3 days'));
    await tester.pumpAndSettle();

    expect(find.text('Snoozed until Thu, Nov 5'), findsOneWidget);
    expect(
      (await vault.items.find('khan-gas'))?.snoozedUntil,
      LocalDate(2026, 11, 5),
    );
    expect(inToday(find.text('Overdue · 1')), findsNothing);
    await scrollTo(
      tester,
      inToday(findPlain('Snoozed to Thu, Nov 5 · due Oct 31')),
    );
  });

  testWidgets('medicine times are marked one by one', (tester) async {
    final vault = vaultWith(DemoHousehold.khan);
    await pumpApp(tester, vault);

    final afternoon = inToday(
      findLabelled('امی کی دوائی, ${clock(840)}, not marked yet'),
    );
    await scrollTo(tester, afternoon);
    await tester.tap(afternoon);
    await tester.pumpAndSettle();

    expect(findPlain('${clock(840)} marked'), findsOneWidget);
    expect(
      inToday(findLabelled('امی کی دوائی, ${clock(840)}, marked')),
      findsOneWidget,
    );
    final marks = await vault.items.completionsOf('khan-ammi');
    expect(marks.single.occurrenceMinute, 840);
    expect(marks.single.occurrenceOn, fixtureToday);
  });

  testWidgets('a past appointment can be moved to another day', (tester) async {
    final vault = vaultWith(DemoHousehold.khan);
    await pumpApp(tester, vault);

    final reschedule = inToday(findLabelled("Reschedule Ammi's check-up"));
    await scrollTo(tester, reschedule);
    await tester.tap(reschedule);
    await tester.pumpAndSettle();
    await tester.tap(find.text('6'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Moved to Fri, Nov 6'), findsOneWidget);
    expect(
      (await vault.items.find('khan-checkup'))?.dueOn,
      LocalDate(2026, 11, 6),
    );
    expect(inToday(find.text('Did these happen? · 1')), findsNothing);
  });

  testWidgets(
    'paying a bill months late offers to keep the missed ones unpaid',
    (tester) async {
      final vault = FakeStorageBackend(
        items: [
          item(
            'old',
            kind: ItemKind.bill,
            title: 'LESCO bill',
            category: ItemCategory.electricity,
            due: LocalDate(2026, 8, 10),
            recurrence: MonthlyRepeat(10),
            amount: Money(425000, 'PKR'),
          ),
        ],
      );
      await pumpApp(tester, vault);

      await tester.tap(inToday(findLabelled('Mark LESCO bill as paid')));
      await tester.pumpAndSettle();
      expect(
        find.text('Marked as paid 2 earlier bills recorded as paid.'),
        findsOneWidget,
      );
      expect((await vault.items.find('old'))?.dueOn, LocalDate(2026, 11, 10));

      await tester.tap(find.text('Change'));
      await tester.pumpAndSettle();
      expect(find.text('What about the 2 missed in between?'), findsOneWidget);
      await tester.tap(find.text('Keep 2 earlier ones unpaid'));
      await tester.pumpAndSettle();

      expect(find.text('Updated'), findsOneWidget);
      expect((await vault.items.find('old'))?.dueOn, LocalDate(2026, 9, 10));
      expect(await vault.items.completionsOf('old'), hasLength(1));
    },
  );

  testWidgets('an empty vault offers to add an item or try a demo', (
    tester,
  ) async {
    await pumpApp(tester, FakeStorageBackend());
    expect(inToday(find.text('Nothing here yet')), findsOneWidget);
    expect(inToday(find.text('Add item')), findsOneWidget);
    expect(inToday(find.text('Try a demo household')), findsOneWidget);
  });

  testWidgets('everything finished says so instead of looking empty', (
    tester,
  ) async {
    final vault = FakeStorageBackend(items: [task()]);
    await pumpApp(tester, vault);
    await tester.tap(inToday(findLabelled('Mark Renew library card as done')));
    await tester.pumpAndSettle();
    expect(inToday(find.text('All caught up')), findsOneWidget);
  });

  group('in Urdu', () {
    testWidgets('the screen is right-to-left and English titles are not', (
      tester,
    ) async {
      await pumpApp(
        tester,
        vaultWith(DemoHousehold.khan, settings: const {'language': 'ur'}),
      );

      final screen = tester.element(find.byType(TodayScreen));
      expect(Directionality.of(screen), TextDirection.rtl);
      expect(inToday(find.text('صبح کا خلاصہ')), findsOneWidget);
      expect(inToday(find.text('کیا یہ ہو گیا؟ · 1')), findsOneWidget);
      expect(inToday(find.text('زائد المیعاد · 1')), findsOneWidget);

      final gasTitle = inToday(findPlain('گیس کا بل'));
      await scrollTo(tester, gasTitle);
      expect(
        tester.widget<RichText>(gasTitle).textDirection,
        TextDirection.rtl,
      );
      final schoolTitle = inToday(findPlain("Ayesha's school fee"));
      await scrollTo(tester, schoolTitle);
      expect(
        tester.widget<RichText>(schoolTitle).textDirection,
        TextDirection.ltr,
      );
    });

    testWidgets('large text lays out every card without clipping', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpApp(
        tester,
        vaultWith(
          DemoHousehold.khan,
          settings: const {'language': 'ur', 'large_text': 'true'},
        ),
      );

      final context = tester.element(find.byType(TodayScreen));
      expect(MediaQuery.textScalerOf(context).scale(10), closeTo(20, 0.01));
      // An overflow anywhere fails the test; scroll so every card is built.
      await scrollTo(tester, inToday(findPlain('Fridge warranty')));
      expect(tester.takeException(), isNull);
    });
  });
}
