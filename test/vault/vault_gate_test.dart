import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/app.dart';
import 'package:yaadi/vault/app_storage.dart';
import 'package:yaadi/vault/vault_failure.dart';

import '../support/fake_storage.dart';

Future<FakeStorageBackend> pumpWithFailures(
  WidgetTester tester,
  List<VaultFailureKind> failures,
) async {
  final backend = FakeStorageBackend(failures: failures);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [storageBackendProvider.overrideWithValue(backend)],
      child: const YaadiApp(),
    ),
  );
  await tester.pumpAndSettle();
  return backend;
}

void main() {
  testWidgets('a slow keystore offers Try again, and no reset at first', (
    tester,
  ) async {
    final backend = await pumpWithFailures(tester, [
      VaultFailureKind.keyUnavailable,
    ]);

    expect(find.text('Yaadi could not open your items'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('Delete and start again'), findsNothing);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(backend.opens, 2);
    expect(find.text('Nothing here yet'), findsOneWidget);
    expect(backend.erases, 0);
  });

  testWidgets('a reset appears only after three failed attempts', (
    tester,
  ) async {
    await pumpWithFailures(
      tester,
      List.filled(5, VaultFailureKind.keyUnavailable),
    );

    for (var attempt = 1; attempt < 3; attempt++) {
      expect(
        find.text('Delete and start again'),
        findsNothing,
        reason: '$attempt',
      );
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Delete and start again'), findsOneWidget);
  });

  testWidgets('an unexpected failure never offers a reset', (tester) async {
    await pumpWithFailures(tester, List.filled(5, VaultFailureKind.unexpected));

    for (var attempt = 1; attempt <= 4; attempt++) {
      expect(find.text('Try again'), findsOneWidget, reason: '$attempt');
      expect(
        find.text('Delete and start again'),
        findsNothing,
        reason: '$attempt',
      );
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('Recovery deletes only after confirmation, then starts empty', (
    tester,
  ) async {
    final backend = await pumpWithFailures(tester, [
      VaultFailureKind.keyMissing,
    ]);

    expect(find.text('Your items cannot be opened'), findsOneWidget);
    expect(find.text('Try again'), findsNothing);

    await tester.tap(find.text('Delete and start again'));
    await tester.pumpAndSettle();
    expect(find.text('Delete everything?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(backend.erases, 0);

    await tester.tap(find.text('Delete and start again'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete everything'));
    await tester.pumpAndSettle();

    expect(backend.erases, 1);
    expect(find.text('Nothing here yet'), findsOneWidget);
  });

  testWidgets('a wrong key goes to Recovery without claiming to know why', (
    tester,
  ) async {
    await pumpWithFailures(tester, [VaultFailureKind.wrongKeyOrCorrupt]);
    expect(find.text('Your items cannot be opened'), findsOneWidget);
    expect(find.textContaining('may be damaged'), findsOneWidget);
  });

  testWidgets('a vault from a newer version is never offered a reset', (
    tester,
  ) async {
    await pumpWithFailures(tester, [VaultFailureKind.schemaTooNew]);
    expect(find.text('Update Yaadi'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(OutlinedButton), findsNothing);
  });

  testWidgets('a build without encryption refuses to store anything', (
    tester,
  ) async {
    await pumpWithFailures(tester, [VaultFailureKind.cipherMissing]);
    expect(find.text('This build cannot protect your items'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets(
    'failure screens follow the phone language before the vault opens',
    (tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('ur', 'PK')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await pumpWithFailures(tester, [VaultFailureKind.keyUnavailable]);
      expect(find.text('دوبارہ کوشش کریں'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text('دوبارہ کوشش کریں'))),
        TextDirection.rtl,
      );
    },
  );
}
