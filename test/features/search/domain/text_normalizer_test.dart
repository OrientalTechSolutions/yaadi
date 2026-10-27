import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/features/search/domain/text_normalizer.dart';

void main() {
  group('search keys', () {
    final cases = <(String, String, String)>[
      // (rule, text, key)
      ('lowercase', 'LESCO Bill', 'lesco bil'),
      ('harakat are removed', 'دَوا', 'دوا'),
      ('superscript alef is removed', 'رحمٰن', 'رحمن'),
      ('ZWNJ keeps a word whole', 'دوا\u200Cئی', 'دوایی'),
      ('tatweel is removed', 'بـــل', 'بل'),
      ('bidi controls are removed', '\u2068LESCO\u2069 \u200Fبل', 'lesco بل'),
      ('Arabic yeh', 'بجلي', 'بجلی'),
      ('alef maksura', 'بجلى', 'بجلی'),
      ('yeh barree', 'بچے', 'بچی'),
      ('Arabic kaf', 'كرايه', 'کرایہ'),
      ('heh and teh marbuta', 'كرايه کرایة', 'کرایہ کرایہ'),
      ('do-chashmi heh', 'بھائی', 'بہایی'),
      ('heh with hamza', 'ۂ', 'ہ'),
      ('alef with madda', 'آج', 'اج'),
      ('alef with hamza', 'أمی إمی', 'امی امی'),
      ('waw with hamza', 'مؤقف', 'موقف'),
      ('noon ghunna', 'میں', 'مین'),
      ('standalone hamza', 'دعاء', 'دعا'),
      ('Urdu digits', 'بل ۴۲۵۰', 'بل 4250'),
      ('Arabic digits', '٤٢٥٠', '4250'),
      ('ee to i', 'bijlee', 'bijli'),
      ('final y to i', 'bijly', 'bijli'),
      ('oo to u', 'school', 'schul'),
      ('v to w', 'dava vapda', 'dawa wapda'),
      ('q to k', 'qeemat', 'kimat'),
      ('repeated letters collapse', 'dawaai bill ammi', 'dawai bil ami'),
      ('digits never collapse', 'Rs 1000', 'rs 1000'),
      ('fees and fis meet', 'fees fis', 'fis fis'),
      ('precomposed accents', 'Café Ñandú', 'cafe nandu'),
      ('transliteration macrons', 'Bijlī ṭaim', 'bijli taim'),
      ('sharp s', 'Straße', 'strase'),
      ('punctuation splits words', "Ammi's K-Electric", 'ami s k electric'),
    ];
    for (final (rule, text, key) in cases) {
      test(rule, () => expect(searchKey(text), key));
    }

    test('decomposed accents fold like precomposed ones', () {
      final decomposed = String.fromCharCodes([0x43, 0x61, 0x66, 0x65, 0x301]);
      expect(searchKey(decomposed), 'cafe');
      expect(searchKey(decomposed), searchKey('Café'));
    });

    test('normalizing twice changes nothing', () {
      for (final (_, text, _) in cases) {
        expect(searchKey(searchKey(text)), searchKey(text), reason: text);
      }
      for (final text in ['eee', 'eeee', 'yy', 'vv qq', 'aay', 'oee']) {
        expect(searchKey(searchKey(text)), searchKey(text), reason: text);
      }
    });
  });

  group('tokens', () {
    test('keep their place in the original text', () {
      final tokens = tokenize('LESCO bill, Nov');
      expect(
        [for (final t in tokens) (t.start, t.end)],
        [(0, 5), (6, 10), (12, 15)],
      );
    });

    test('skip invisible characters at their edges', () {
      final token = tokenize('\u2068LESCO\u2069').single;
      expect((token.start, token.end), (1, 6));
    });

    test('keep harakat inside the word they belong to', () {
      final token = tokenize('امی کی دَوائی').last;
      expect(token.base, 'دوایی');
      expect((token.start, token.end), (7, 13));
    });

    test('map folded prefixes back to the original letters', () {
      final token = tokenize('Bijlee').single;
      expect(token.folded, 'bijli');
      expect(token.foldedEndAt(4), 4);
      expect(token.foldedEndAt(5), 6);
      expect(token.baseEndAt(3), 3);
    });

    test('know which words are in Arabic script', () {
      expect(tokenize('LESCO بل').map((t) => t.isArabic), [false, true]);
    });

    test('only all-Latin words are folded', () {
      expect(tokenize('اللہ').single.folded, 'اللہ');
      expect(tokenize('Rs100').single.folded, 'rs100');
    });

    test('words made only of marks or controls disappear', () {
      const rlm = 0x200F;
      const fatha = 0x064E;
      expect(tokenize(String.fromCharCodes([rlm, 0x20, fatha])), isEmpty);
      expect(isIgnorable(0x064E), isTrue);
      expect(isIgnorable(0x0628), isFalse);
    });
  });
}
