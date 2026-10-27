import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/features/items/domain/item_category.dart';
import 'package:yaadi/features/items/domain/item_kind.dart';
import 'package:yaadi/features/search/domain/concept.dart';
import 'package:yaadi/features/search/domain/edit_distance.dart';
import 'package:yaadi/features/search/domain/household_lexicon.dart';
import 'package:yaadi/features/search/domain/household_terms.dart';
import 'package:yaadi/features/search/domain/region.dart';
import 'package:yaadi/features/search/domain/text_normalizer.dart';

List<String> keys(String text) => [
  for (final token in tokenize(text)) token.folded,
];

Set<String> namedBy(HouseholdLexicon lexicon, String text) => {
  for (final phrase in lexicon.longestAt(keys(text), 0)) phrase.concept.id,
};

void main() {
  final pakistan = HouseholdLexicon.forRegion(Region.pk);
  final britain = HouseholdLexicon.forRegion(Region.uk);

  group('the household terms', () {
    test('every term is one to three words', () {
      for (final concept in householdConcepts) {
        for (final term in concept.terms) {
          final words = tokenize(term).length;
          expect(words, inInclusiveRange(1, 3), reason: term);
        }
      }
    });

    test('no spelling means two different things in one region', () {
      for (final region in Region.values) {
        final meanings = <String, Set<String>>{};
        for (final phrase in HouseholdLexicon.forRegion(region).phrases) {
          meanings
              .putIfAbsent(phrase.folded.join(' '), () => {})
              .add(phrase.concept.id);
        }
        final ambiguous = {
          for (final MapEntry(:key, :value) in meanings.entries)
            if (value.length > 1) key: value,
        };
        expect(ambiguous, isEmpty, reason: region.name);
      }
    });

    test('no stopword is also a term', () {
      final stopwords = {for (final word in householdStopwords) ...keys(word)};
      final terms = {
        for (final phrase in pakistan.phrases)
          if (phrase.length == 1) phrase.folded.single,
      };
      expect(stopwords.intersection(terms), isEmpty);
    });

    test('every category but other is reachable in English and Urdu', () {
      bool hasArabicTerm(Concept concept) =>
          concept.terms.any((term) => tokenize(term).first.isArabic);
      for (final category in ItemCategory.values) {
        if (category == ItemCategory.other) continue;
        final concepts = householdConcepts.where(
          (c) => c.type == ConceptType.category && c.category == category,
        );
        expect(concepts, isNotEmpty, reason: category.name);
        expect(concepts.any(hasArabicTerm), isTrue, reason: category.name);
      }
      for (final kind in ItemKind.values) {
        expect(
          householdConcepts.any(
            (c) => c.type == ConceptType.kind && c.kind == kind,
          ),
          isTrue,
          reason: kind.name,
        );
      }
    });
  });

  group('matching', () {
    test('folded spellings reach their concept', () {
      for (final spelling in [
        'bijli',
        'bijlee',
        'bijly',
        'bjli',
        'بجلی',
        'بجلي',
      ]) {
        expect(namedBy(pakistan, spelling), {
          'category:electricity',
        }, reason: spelling);
      }
      expect(namedBy(pakistan, 'dawaai'), {'kind:medicine'});
      expect(namedBy(pakistan, 'davai'), {'kind:medicine'});
      expect(namedBy(pakistan, 'fees'), {'alias:fee'});
      expect(namedBy(pakistan, 'فیس'), {'alias:fee'});
    });

    test('the longest phrase wins', () {
      expect(namedBy(pakistan, 'sui gas bill'), {'category:gas'});
      expect(pakistan.longestAt(keys('sui gas bill'), 0).single.length, 2);
      expect(namedBy(pakistan, 'k electric'), {'biller:k-electric'});
      expect(namedBy(pakistan, 'electric'), {'category:electricity'});
      expect(namedBy(pakistan, 'شناختی کارڈ'), {'category:idDocument'});
      expect(namedBy(britain, 'tv licence'), {'alias:tv licence'});
      expect(namedBy(britain, 'licence'), {'category:idDocument'});
    });

    test('a biller tags its item with the category too', () {
      final lesco = pakistan.longestAt(keys('lesco'), 0).single.concept;
      expect(lesco.id, 'biller:lesco');
      expect(lesco.itemTags, {'biller:lesco', 'category:electricity'});
    });

    test('names from another country are not terms', () {
      expect(namedBy(pakistan, 'tesco'), {'biller:tesco'});
      expect(namedBy(britain, 'tesco'), isEmpty);
      expect(namedBy(britain, 'lesco'), isEmpty);
      expect(namedBy(pakistan, 'council tax'), isEmpty);
      expect(namedBy(britain, 'council tax'), {'alias:council tax'});
      expect(namedBy(britain, 'bijli'), {'category:electricity'});
    });

    test('a phrase still being typed is completed', () {
      final typed = tokenize('shanakhti ca');
      final completions = pakistan.completing(
        keys('shanakhti ca'),
        0,
        base: typed.last.base,
        folded: typed.last.folded,
      );
      expect(completions.map((p) => p.concept.id), ['category:idDocument']);
    });

    test('a word is completed on its raw or its folded spelling', () {
      Set<String> completing(String word) {
        final token = tokenize(word).single;
        return {
          for (final phrase in pakistan.completing(
            [token.folded],
            0,
            base: token.base,
            folded: token.folded,
          ))
            phrase.concept.id,
        };
      }

      expect(completing('scho'), contains('category:school'));
      expect(completing('schoo'), contains('category:school'));
      expect(completing('lesc'), contains('biller:lesco'));
    });

    test('typos of four letters or more find their term', () {
      Set<String> near(String word) => {
        for (final phrase in pakistan.withinOneEditOf(searchKey(word)))
          phrase.concept.id,
      };
      expect(near('electrisity'), {'category:electricity'});
      expect(near('medicin'), {'kind:medicine'});
      expect(near('gs'), isEmpty);
    });

    test('stopwords are known in all three spellings', () {
      for (final word in ['ka', 'ki', 'کا', 'کے', 'the', 'kab']) {
        expect(pakistan.isStopword(searchKey(word)), isTrue, reason: word);
      }
      expect(pakistan.isStopword('bijli'), isFalse);
    });
  });

  group('one edit', () {
    final cases = <(String, String, bool)>[
      ('lesco', 'lesco', true),
      ('lesco', 'iesco', true),
      ('lesco', 'lesko', true),
      ('lesco', 'lescoo', true),
      ('lesco', 'esco', true),
      ('lesco', 'elsco', true),
      ('lesco', 'pesko', false),
      ('lesco', 'les', false),
      ('bijli', 'bjil', false),
      ('ab', 'ba', true),
      ('', 'a', true),
    ];
    for (final (a, b, expected) in cases) {
      test('$a and $b', () {
        expect(withinOneEdit(a, b), expected);
        expect(withinOneEdit(b, a), expected);
      });
    }
  });
}
