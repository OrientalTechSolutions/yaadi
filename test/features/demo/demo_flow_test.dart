import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/app_info.dart';
import 'package:yaadi/core/platform/session_store.dart';
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
      expect(find.text('Undo'), findsOneWidget);

      await tester.tap(find.text('Leave demo'));
      await tester.pumpAndSettle();
      expect(inToday(find.text('Nothing here yet')), findsOneWidget);
      expect(find.text('Demo'), findsNothing);
      expect(await vault.settings.readAll(), isEmpty);
      // The demo's Undo leaves with it: it would act on the wrong items.
      expect(find.text('Undo'), findsNothing);
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

    testWidgets(
      'the screens keep one line of notice, with the rest a tap away',
      (tester) async {
        await pumpApp(tester, SessionDemoBackend(MemorySessionStore()));
        await tester.tap(find.text('Khan family, Lahore'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Demo with made-up families. Not encrypted: do not enter real ID '
            'numbers.',
          ),
          findsOneWidget,
        );
        expect(find.textContaining('GitHub Pages'), findsNothing);

        await tester.tap(find.text('Details'));
        await tester.pumpAndSettle();
        expect(
          find.textContaining('which keeps standard access logs'),
          findsOne,
        );
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);
      },
    );

    testWidgets('a browser that does not save the demo is named', (
      tester,
    ) async {
      await pumpApp(tester, SessionDemoBackend(_RefusingSessionStore()));
      await tester.tap(find.text('Taylor family, Manchester'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'This browser is not saving the demo; it will reset when you '
          'reload.',
        ),
        findsOneWidget,
      );
      // The demo itself carries on in memory.
      expect(inToday(findPlain('Overdue: Council tax')), findsOneWidget);
    });

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

/// A browser that refuses every write, as in some private windows or over
/// quota.
final class _RefusingSessionStore implements SessionStore {
  var _failed = false;

  @override
  String? read(String key) => null;

  @override
  bool write(String key, String value) {
    _failed = true;
    return false;
  }

  @override
  void remove(String key) {}

  @override
  bool get hasFailedWrites => _failed;
}
