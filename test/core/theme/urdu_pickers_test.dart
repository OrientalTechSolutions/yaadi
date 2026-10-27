import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/theme/app_theme.dart';
import 'package:yaadi/features/today/presentation/today_screen.dart';

import '../../support/fake_storage.dart';
import '../../support/pump_app.dart';

void main() {
  // Every appointment time and medicine time is set in this picker. With
  // Nastaliq's line height its readout sat in an 80 dp box half cut off.
  testWidgets('the Urdu time picker shows the whole hour and minute', (
    tester,
  ) async {
    await pumpApp(
      tester,
      FakeStorageBackend(settings: const {'language': 'ur'}),
    );
    unawaited(
      showTimePicker(
        context: tester.element(find.byType(TodayScreen)),
        initialTime: const TimeOfDay(hour: 17, minute: 0),
      ),
    );
    await tester.pumpAndSettle();

    for (final text in ['5', '00']) {
      final readout = tester
          .renderObjectList<RenderParagraph>(
            find.descendant(of: find.byType(Dialog), matching: find.text(text)),
          )
          .reduce(
            (a, b) =>
                (a.text.style?.fontSize ?? 0) >= (b.text.style?.fontSize ?? 0)
                ? a
                : b,
          );
      expect(readout.text.style?.fontFamily, isNot(AppFonts.urdu));
      expect(readout.size.height, lessThanOrEqualTo(80), reason: text);
    }
    expect(find.text('شام'), findsOneWidget);
  });
}
