import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/theme/app_theme.dart';
import 'package:yaadi/core/widgets/auto_direction_field.dart';
import 'package:yaadi/core/widgets/user_text.dart';

void main() {
  group('direction follows the first strong character', () {
    const cases = [
      ('LESCO bill', TextDirection.ltr),
      ('امی کی دوائی', TextDirection.rtl),
      ('LESCO کا بل', TextDirection.ltr),
      ('بجلی LESCO', TextDirection.rtl),
      ('12 بجلی', TextDirection.rtl),
    ];
    for (final (text, expected) in cases) {
      test(text, () {
        expect(textDirectionOf(text, TextDirection.ltr), expected);
        expect(textDirectionOf(text, TextDirection.rtl), expected);
      });
    }

    test('numbers alone take the UI direction', () {
      expect(textDirectionOf('4250', TextDirection.rtl), TextDirection.rtl);
      expect(textDirectionOf('4250', TextDirection.ltr), TextDirection.ltr);
    });
  });

  group('script runs', () {
    test('split between Latin and Arabic script, with neutrals joining in', () {
      expect(scriptRuns('LESCO کا بل 4250'), [
        (text: 'LESCO ', isArabic: false),
        (text: 'کا بل 4250', isArabic: true),
      ]);
    });

    test('keep Urdu digits and harakat inside the Nastaliq run', () {
      expect(scriptRuns('دَوا ۲ بار'), [(text: 'دَوا ۲ بار', isArabic: true)]);
    });

    test('cover the whole string exactly', () {
      for (final text in ['', '  ', 'Ammi امی ki dawai دوائی!', '۱۰ تاریخ']) {
        expect(scriptRuns(text).map((run) => run.text).join(), text);
      }
    });
  });

  testWidgets('Urdu runs use Nastaliq with room for descenders', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: UserText('LESCO کا بل'))),
    );
    final rich = tester.widget<RichText>(find.byType(RichText).last);
    // Text.rich wraps the given span in one carrying the default style.
    final root = (rich.text as TextSpan).children!.single as TextSpan;
    final spans = root.children!.cast<TextSpan>();
    expect(spans.first.style?.fontFamily, AppFonts.ui);
    expect(spans.last.style?.fontFamily, AppFonts.urdu);
    expect(spans.last.style?.height, urduLineHeight);
    expect(rich.textDirection, TextDirection.ltr);
  });

  testWidgets('each run carries its language and a size that matches', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: UserText('LESCO کا بل', style: TextStyle(fontSize: 20)),
        ),
      ),
    );
    final rich = tester.widget<RichText>(find.byType(RichText).last);
    final root = (rich.text as TextSpan).children!.single as TextSpan;
    final [latin, urdu] = root.children!.cast<TextSpan>().toList();
    // Screen readers switch voice by span locale.
    expect(latin.locale, const Locale('en'));
    expect(urdu.locale, const Locale('ur'));
    // Nastaliq looks smaller at the same size, so it is set a size up.
    expect(latin.style?.fontSize, 20);
    expect(urdu.style?.fontSize, closeTo(23, 1e-9));
  });

  testWidgets('a field keeps its height when the first Urdu letter is typed', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'bijli');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AutoDirectionField(controller: controller)),
      ),
    );
    final latin = tester.getSize(find.byType(TextField)).height;

    controller.text = 'بجلی';
    await tester.pump();
    expect(tester.getSize(find.byType(TextField)).height, latin);
  });

  test('in the Urdu UI the Latin run is the one scaled back', () {
    const base = TextStyle(fontFamily: AppFonts.urdu, fontSize: 23);
    final (:urdu, :latin) = scriptStyles(base);
    expect(urdu.fontSize, 23);
    expect(latin.fontSize, closeTo(20, 1e-9));
    expect(latin.fontFamily, AppFonts.ui);
  });
}
