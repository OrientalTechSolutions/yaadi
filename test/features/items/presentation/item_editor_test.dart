import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/money/money.dart';
import 'package:yaadi/core/theme/app_theme.dart';
import 'package:yaadi/core/time/local_date.dart';
import 'package:yaadi/features/items/domain/item_category.dart';
import 'package:yaadi/features/items/domain/item_kind.dart';
import 'package:yaadi/features/items/domain/recurrence.dart';
import 'package:yaadi/features/items/presentation/item_editor_screen.dart';
import 'package:yaadi/features/today/presentation/today_screen.dart';

import '../../../support/fake_storage.dart';
import '../../../support/households.dart';
import '../../../support/items.dart';
import '../../../support/pump_app.dart';

Finder inEditor(Finder finder) => onScreen(ItemEditorScreen, finder);

Finder field(String label) => inEditor(find.widgetWithText(TextField, label));

/// The tappable part of a date or time field: its label alone is not.
Finder pickerField(String label) => find
    .ancestor(of: inEditor(find.text(label)), matching: find.byType(InkWell))
    .first;

Finder kindChip(String label) =>
    inEditor(find.widgetWithText(ChoiceChip, label));

Future<void> openEditor(WidgetTester tester) async {
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
}

/// Opens the date picker from the field labelled [label] and accepts the
/// date it starts on.
Future<void> acceptDate(WidgetTester tester, String label) async {
  await tester.tap(pickerField(label));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

Future<void> save(WidgetTester tester) async {
  await tester.tap(inEditor(find.text('Save')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Save asks for a title and a date first', (tester) async {
    final vault = FakeStorageBackend();
    await pumpApp(tester, vault);
    await openEditor(tester);

    expect(inEditor(find.text('Add item')), findsOneWidget);
    await save(tester);
    expect(inEditor(find.text('Enter a title')), findsOneWidget);
    expect(inEditor(find.text('Choose a date')), findsOneWidget);
    expect(await vault.items.find('new-1'), isNull);
  });

  testWidgets('screen readers hear what to fix and land on the first field', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpApp(tester, FakeStorageBackend());
    await openEditor(tester);
    tester.takeAnnouncements();

    await save(tester);
    expect(tester.takeAnnouncements().map((a) => a.message), [
      'Check 2 fields',
    ]);
    final title = tester.widget<EditableText>(
      find.descendant(of: field('Title'), matching: find.byType(EditableText)),
    );
    expect(title.focusNode.hasFocus, isTrue);

    // A date field with an error says both, and stays in the focus order.
    final date = tester.getSemantics(
      find.bySemanticsLabel('Due date, Choose a date'),
    );
    expect(
      date.getSemanticsData().flagsCollection.isFocused,
      isNot(Tristate.none),
    );
    semantics.dispose();
  });

  testWidgets('a new bill is saved with its amount and shows on Today', (
    tester,
  ) async {
    final vault = FakeStorageBackend();
    await pumpApp(tester, vault);
    await openEditor(tester);

    await tester.enterText(field('Title'), 'LESCO bill');
    await tester.enterText(field('Amount'), '4,250');
    await acceptDate(tester, 'Due date');
    await save(tester);

    expect(find.byType(ItemEditorScreen), findsNothing);
    expect(find.text('Added'), findsOneWidget);
    final saved = (await vault.items.find('new-1'))!;
    expect(saved.title, 'LESCO bill');
    expect(saved.kind, ItemKind.bill);
    expect(saved.category, ItemCategory.electricity);
    expect(saved.amount, Money(425000, 'PKR'));
    expect(saved.dueOn, fixtureToday);
    expect(onScreen(TodayScreen, findPlain('Due today')), findsOneWidget);
  });

  testWidgets('an amount that cannot be read is pointed out', (tester) async {
    await pumpApp(tester, FakeStorageBackend());
    await openEditor(tester);
    await tester.enterText(field('Title'), 'LESCO bill');
    await tester.enterText(field('Amount'), '12.50');
    await acceptDate(tester, 'Due date');
    await save(tester);
    expect(inEditor(find.text('Enter an amount like 4250')), findsOneWidget);
  });

  testWidgets('an ID number in the title is offered a move to Reference', (
    tester,
  ) async {
    final vault = FakeStorageBackend();
    await pumpApp(tester, vault);
    await openEditor(tester);

    await tester.tap(kindChip('Expiry date'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Title'), 'Abbu CNIC 35202-1234567-1');
    await acceptDate(tester, 'Expires on');
    await save(tester);

    expect(find.text('Move this number to Reference?'), findsOneWidget);
    await tester.tap(find.text('Move to Reference'));
    await tester.pumpAndSettle();

    final saved = (await vault.items.find('new-1'))!;
    expect(saved.kind, ItemKind.expiry);
    expect(saved.category, ItemCategory.idDocument);
    expect(saved.title, 'Abbu CNIC');
    expect(saved.reference, '35202-1234567-1');
  });

  testWidgets('the Reference field stays hidden while typing', (tester) async {
    await pumpApp(tester, FakeStorageBackend());
    await openEditor(tester);

    final reference = field('Reference number');
    await tester.ensureVisible(reference);
    await tester.enterText(reference, '12345-6789012-3');
    await tester.pumpAndSettle();
    EditableText editable() => tester.widget<EditableText>(
      find.descendant(of: reference, matching: find.byType(EditableText)),
    );
    expect(editable().obscureText, isTrue);
    expect(editable().enableIMEPersonalizedLearning, isFalse);
    expect(editable().autocorrect, isFalse);
    expect(editable().enableSuggestions, isFalse);
    // Only null keeps it from the platform's autofill service; an empty
    // list would let a password manager offer to save the number.
    expect(editable().autofillHints, isNull);
    expect(tester.testTextInput.setClientArgs!['autofill'], isNull);

    await tester.tap(inEditor(find.byTooltip('Show')));
    await tester.pumpAndSettle();
    expect(editable().obscureText, isFalse);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(editable().obscureText, isTrue);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  });

  testWidgets('medicine needs at least one time, and keeps the ones typed', (
    tester,
  ) async {
    final vault = FakeStorageBackend();
    await pumpApp(tester, vault);
    await openEditor(tester);

    await tester.tap(kindChip('Medicine'));
    await tester.pumpAndSettle();
    expect(inEditor(find.text('Repeat')), findsNothing);
    await tester.enterText(field('Title'), 'امی کی دوائی');
    await acceptDate(tester, 'First day');
    await save(tester);
    expect(inEditor(find.text('Add at least one time')), findsOneWidget);

    await tester.tap(inEditor(find.text('Add a time')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(inEditor(findPlain(clock(540))), findsOneWidget);
    await save(tester);

    final saved = (await vault.items.find('new-1'))!;
    expect(saved.kind, ItemKind.medicine);
    expect(saved.category, ItemCategory.health);
    expect(saved.recurrence, DoseTimes([540]));
  });

  testWidgets("a new date on a repeating bill moves this month's only", (
    tester,
  ) async {
    final vault = FakeStorageBackend(
      items: [
        bill(
          id: 'lesco',
          dueOn: LocalDate(2026, 11, 10),
          recurrence: MonthlyRepeat(10),
        ),
      ],
    );
    await pumpApp(tester, vault);

    await tester.tap(onScreen(TodayScreen, findPlain('LESCO bill')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();
    expect(inEditor(find.text('Edit item')), findsOneWidget);

    await tester.tap(pickerField('Due date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('13'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(inEditor(find.text('Repeat from the new date')), findsOneWidget);
    await save(tester);

    expect(find.text('Saved'), findsOneWidget);
    final saved = (await vault.items.find('lesco'))!;
    expect(saved.dueOn, LocalDate(2026, 11, 13));
    expect(saved.scheduledOn, LocalDate(2026, 11, 10));
    expect(saved.recurrence, MonthlyRepeat(10));
  });

  testWidgets('a date set back to the original leaves the series alone', (
    tester,
  ) async {
    final vault = FakeStorageBackend(
      items: [
        bill(
          id: 'lesco',
          dueOn: LocalDate(2026, 11, 10),
          recurrence: MonthlyRepeat(10),
        ),
      ],
    );
    await pumpApp(tester, vault);
    await tester.tap(onScreen(TodayScreen, findPlain('LESCO bill')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();

    Future<void> pickDay(String day) async {
      await tester.tap(pickerField('Due date'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(day));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    }

    await pickDay('13');
    await tester.tap(
      inEditor(find.widgetWithText(SwitchListTile, 'Repeat from the new date')),
    );
    await tester.pumpAndSettle();
    await pickDay('10');
    expect(inEditor(find.text('Repeat from the new date')), findsNothing);

    // Nothing visible changed, so leaving does not ask.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Discard your changes?'), findsNothing);
    expect(find.byType(ItemEditorScreen), findsNothing);
  });

  testWidgets('leaving with unsaved changes asks first', (tester) async {
    final vault = FakeStorageBackend();
    await pumpApp(tester, vault);
    await openEditor(tester);
    await tester.enterText(field('Title'), 'Half typed');
    await tester.pump();

    // The phone's back gesture, which the editor intercepts.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Discard your changes?'), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(find.byType(ItemEditorScreen), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.byType(ItemEditorScreen), findsNothing);
    expect(await vault.items.find('new-1'), isNull);
  });

  testWidgets('Undo after adding takes the item away again', (tester) async {
    final vault = FakeStorageBackend();
    await pumpApp(tester, vault);
    await openEditor(tester);
    await tester.tap(kindChip('Task'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Title'), 'Renew library card');
    await save(tester);
    expect(await vault.items.find('new-1'), isNotNull);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(await vault.items.find('new-1'), isNull);
  });

  testWidgets('the Urdu editor with large text has room for everything', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpApp(
      tester,
      FakeStorageBackend(
        settings: const {'language': 'ur', 'large_text': 'true'},
      ),
    );
    await openEditor(tester);

    expect(inEditor(find.text('چیز شامل کریں')), findsOneWidget);
    await tester.tap(inEditor(find.text('محفوظ کریں')));
    await tester.pumpAndSettle();
    expect(inEditor(find.text('عنوان لکھیں')), findsOneWidget);
    await tester.drag(inEditor(find.byType(ListView)), const Offset(0, -2000));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('the Urdu editor types amounts and reference numbers in Roboto', (
    tester,
  ) async {
    await pumpApp(
      tester,
      FakeStorageBackend(settings: const {'language': 'ur'}),
    );
    await openEditor(tester);

    final amount = field('رقم');
    expect(tester.widget<TextField>(amount).style?.fontFamily, AppFonts.ui);
    // Still lined up with the currency beside it.
    Rect box(Finder of) => tester.getRect(
      find.descendant(of: of, matching: find.byType(InputDecorator)).first,
    );
    final currency = inEditor(find.byType(DropdownButtonFormField<String>));
    expect(box(amount).bottom, closeTo(box(currency).bottom, 0.5));

    await tester.drag(inEditor(find.byType(ListView)), const Offset(0, -2000));
    await tester.pumpAndSettle();
    final reference = tester.widget<TextField>(field('حوالہ نمبر'));
    expect(reference.style?.fontFamily, AppFonts.ui);
  });
}
