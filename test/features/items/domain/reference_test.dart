import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/features/items/domain/reference.dart';

void main() {
  group('maskReference', () {
    final cases = {
      '12345-6789012-3': '•••• •••• 0123',
      '00 00000 0001234': '•••• •••• 1234',
      '0000001234': '•••• •••• 1234',
      'AB12CD34': '•••• •••• CD34',
      '1234567': '•••• ••••',
      '12-34-56': '•••• ••••',
      '': '•••• ••••',
    };
    cases.forEach((reference, masked) {
      test(
        '"$reference" shows as "$masked"',
        () => expect(maskReference(reference), masked),
      );
    });

    test('never contains more than four of its characters', () {
      const reference = '35202-1234567-1';
      expect(maskReference(reference), isNot(contains('35202')));
    });
  });

  group('findMisplacedNumber', () {
    test('a CNIC in the title', () {
      final found = findMisplacedNumber(
        title: 'Abbu CNIC 35202-1234567-1',
        notes: '',
      )!;
      expect(found.field, NumberField.title);
      expect(found.value, '35202-1234567-1');
      expect(found.removeFrom('Abbu CNIC 35202-1234567-1'), 'Abbu CNIC');
    });

    test('a CNIC without dashes, typed in Urdu digits', () {
      const title = 'شناختی کارڈ ۳۵۲۰۲۱۲۳۴۵۶۷۱';
      final found = findMisplacedNumber(title: title, notes: '')!;
      expect(found.value, '۳۵۲۰۲۱۲۳۴۵۶۷۱');
      expect(found.removeFrom(title), 'شناختی کارڈ');
    });

    test('a long consumer number in the notes', () {
      final found = findMisplacedNumber(
        title: 'LESCO bill',
        notes: 'Ref 04111234567890 U, pay at the bank',
      )!;
      expect(found.field, NumberField.notes);
      expect(found.value, '04111234567890');
      expect(
        found.removeFrom('Ref 04111234567890 U, pay at the bank'),
        'Ref U, pay at the bank',
      );
    });

    test('the title is checked before the notes', () {
      expect(
        findMisplacedNumber(title: '1234567890', notes: '0987654321')!.field,
        NumberField.title,
      );
    });

    final harmless = [
      'Rs 4,250 due on 10/11',
      '2026-11-02',
      'Flat 12, Street 45',
      '123456789',
      'Call 0300 123 4567',
    ];
    for (final text in harmless) {
      test('"$text" is left alone', () {
        expect(findMisplacedNumber(title: text, notes: text), isNull);
      });
    }

    test('toString leaves out the number', () {
      final found = findMisplacedNumber(title: '35202-1234567-1', notes: '')!;
      expect(found.toString(), isNot(contains('35202')));
    });
  });
}
