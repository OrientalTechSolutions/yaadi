import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/app_info.dart';
import 'package:yaadi/core/platform/session_store_memory.dart';
import 'package:yaadi/features/demo/presentation/demo_picker.dart';
import 'package:yaadi/features/items/data/session_item_repository.dart';
import 'package:yaadi/features/settings/presentation/settings_screen.dart';
import 'package:yaadi/features/today/presentation/today_screen.dart';
import 'package:yaadi/vault/session_demo_backend.dart';

import '../../support/fake_storage.dart';
import '../../support/items.dart';
import '../../support/pump_app.dart';

Finder inToday(Finder finder) => onScreen(TodayScreen, finder);
Finder inSettings(Finder finder) => onScreen(SettingsScreen, finder);

Future<void> openSettings(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.settings_outlined));
  await tester.pumpAndSettle();
}

void main() {
  group('on a phone', () {
    testWidgets('a demo household is one tap away and one tap back', (
      tester,
    ) async {
      final vault = FakeStorageBackend();
      await pumpApp(tester, vault);

      await tester.tap(inToday(find.text('Try a demo household')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Khan family, Lahore'));
      await tester.pumpAndSettle();

      expect(inToday(find.text('Demo')), findsOneWidget);
      expect(
        findPlainContaining('You are looking at the Khan family, Lahore demo'),
        findsOneWidget,
      );
      expect(inToday(findPlain('Overdue: گیس کا بل')), findsOneWidget);

      final paid = inToday(findLabelled("Mark Ayesha's school fee as paid"));
      await scrollTo(tester, paid);
      await tester.tap(paid);
      await tester.pumpAndSettle();
      expect(await vault.items.find('khan-school'), isNull);

      await tester.tap(find.text('Leave demo'));
      await tester.pumpAndSettle();
      expect(inToday(find.text('Nothing here yet')), findsOneWidget);
      expect(find.text('Demo'), findsNothing);
      expect(await vault.settings.readAll(), isEmpty);
    });

    testWidgets('Settings switches households and clears the demo', (
      tester,
    ) async {
      final vault = FakeStorageBackend(items: [task()]);
      await pumpApp(tester, vault);
      await openSettings(tester);

      final taylor = inSettings(find.text('Taylor family, Manchester'));
      await scrollTo(tester, taylor);
      await tester.tap(taylor);
      await tester.pumpAndSettle();
      expect(inSettings(find.text('Demo')), findsOneWidget);
      expect(inSettings(find.text('Delete all my items')), findsNothing);

      final clear = inSettings(find.text('Clear demo data'));
      await scrollTo(tester, clear);
      await tester.tap(clear);
      await tester.pumpAndSettle();
      expect(inSettings(find.text('Demo')), findsNothing);
      expect(inSettings(find.text('Clear demo data')), findsNothing);

      await tester.tap(find.byIcon(Icons.today_outlined));
      await tester.pumpAndSettle();
      expect(inToday(findPlain('Renew library card')), findsOneWidget);
    });
  });

  group('on the web', () {
    testWidgets(
      'a household is chosen first, and clearing returns to the choice',
      (tester) async {
        final store = MemorySessionStore();
        await pumpApp(tester, SessionDemoBackend(store));

        expect(find.byType(DemoPickerScreen), findsOneWidget);
        expect(find.text('Try Yaadi with a made-up family'), findsOneWidget);
        expect(
          find.textContaining('is not encrypted and is not sent to us'),
          findsOneWidget,
        );

        await tester.tap(find.text('Taylor family, Manchester'));
        await tester.pumpAndSettle();
        expect(inToday(find.text('Demo')), findsOneWidget);
        expect(inToday(findPlain('Overdue: Council tax')), findsOneWidget);
        expect(store.read(sessionItemsKey), contains('Council tax'));

        await openSettings(tester);
        final clear = inSettings(find.text('Clear demo data'));
        await scrollTo(tester, clear);
        await tester.tap(clear);
        await tester.pumpAndSettle();

        expect(find.byType(DemoPickerScreen), findsOneWidget);
        expect(store.read(sessionItemsKey), isNot(contains('Council tax')));
      },
    );

    testWidgets('the picker offers the other language in its own script', (
      tester,
    ) async {
      await pumpApp(tester, SessionDemoBackend(MemorySessionStore()));
      await tester.tap(findPlain('اردو'));
      await tester.pumpAndSettle();
      expect(find.text('ایک فرضی خاندان کے ساتھ یادی آزمائیں'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.byType(DemoPickerScreen))),
        TextDirection.rtl,
      );
      expect(findPlain('English'), findsOneWidget);
    });
  });

  group('Settings', () {
    testWidgets('Delete all erases the vault only after confirmation', (
      tester,
    ) async {
      final vault = FakeStorageBackend(items: [task()]);
      await pumpApp(tester, vault);
      await openSettings(tester);

      final deleteAll = inSettings(find.text('Delete all my items'));
      await scrollTo(tester, deleteAll);
      await tester.tap(deleteAll);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(vault.erases, 0);

      await tester.tap(deleteAll);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete everything'));
      await tester.pumpAndSettle();
      expect(vault.erases, 1);
    });

    testWidgets('About links to the maker and their Upwork profile', (
      tester,
    ) async {
      final opened = <Uri>[];
      await pumpApp(tester, FakeStorageBackend(), openedLinks: opened);
      await openSettings(tester);

      final maker = inSettings(find.text('Built by Oriental Tech Solutions'));
      await scrollTo(tester, maker);
      expect(inSettings(find.text('Yaadi ${AppInfo.version}')), findsOneWidget);
      await tester.tap(maker);
      await tester.pumpAndSettle();
      final hire = inSettings(find.text('Hire us on Upwork'));
      await scrollTo(tester, hire);
      await tester.tap(hire);
      await tester.pumpAndSettle();
      expect(opened, [AppInfo.github, AppInfo.upwork]);
    });
  });
}
