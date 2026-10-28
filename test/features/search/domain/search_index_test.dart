import 'package:characters/characters.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/time/local_date.dart';
import 'package:yaadi/features/items/domain/item.dart';
import 'package:yaadi/features/items/domain/item_kind.dart';
import 'package:yaadi/features/items/domain/item_status.dart';
import 'package:yaadi/features/items/domain/recurrence.dart';
import 'package:yaadi/features/search/domain/highlight.dart';
import 'package:yaadi/features/search/domain/household_lexicon.dart';
import 'package:yaadi/features/search/domain/region.dart';
import 'package:yaadi/features/search/domain/search_index.dart';
import 'package:yaadi/features/search/domain/search_query.dart';

import '../../../support/households.dart';
import '../../../support/items.dart';

SearchIndex indexOf(List<Item> items, Region region) =>
    SearchDocuments(HouseholdLexicon.forRegion(region)).index(items);

/// Every query people type, with the item that must come first, the items
/// that must be found, and the items that must not be.
typedef QueryCase = ({
  String query,
  String? first,
  List<String> found,
  List<String> notFound,
});

QueryCase q(
  String query, {
  String? first,
  List<String> found = const [],
  List<String> notFound = const [],
}) => (query: query, first: first, found: found, notFound: notFound);

final khanQueries = <QueryCase>[
  // Electricity, however it is spelled.
  q('bijli', first: 'lesco', found: ['iesco'], notFound: ['gas']),
  q('bijlee', first: 'lesco'),
  q('bijly', first: 'lesco'),
  q('bjli', first: 'lesco'),
  q('BIJLI', first: 'lesco'),
  q('بجلی', first: 'lesco', found: ['iesco']),
  q('بجلي', first: 'lesco'),
  q('electricity', first: 'lesco'),
  q('electric', first: 'lesco'),
  q('light ka bill', first: 'lesco', notFound: ['gas', 'water']),
  q('wapda', first: 'lesco'),
  q('bjli bil', first: 'lesco', notFound: ['gas', 'school']),
  q('bijli ka bill', first: 'lesco', notFound: ['gas', 'school', 'water']),
  q('bijli ki bill', first: 'lesco'),
  q('بجلی کا بل', first: 'lesco', notFound: ['gas', 'water']),
  // Billers find only themselves.
  q('lesco', first: 'lesco', notFound: ['iesco']),
  q('LESCO bill', first: 'lesco', notFound: ['iesco', 'gas']),
  q('iesco', first: 'iesco', notFound: ['lesco']),
  q('lesc', first: 'lesco', notFound: ['iesco']),
  q('lesko', first: 'lesco', notFound: ['iesco']),
  // Gas.
  q('gas', first: 'gas', notFound: ['lesco', 'iesco']),
  q('gas bil', first: 'gas', notFound: ['lesco']),
  q('gas ka bill', first: 'gas'),
  q('sui gas', first: 'gas', notFound: ['lesco']),
  q('گیس', first: 'gas'),
  q('sngpl', first: 'gas'),
  // Water.
  q('pani', first: 'water'),
  q('paani', first: 'water'),
  q('پانی', first: 'water'),
  q('water', first: 'water'),
  q('pani ka bill', first: 'water', notFound: ['lesco']),
  // School and fees.
  q('school', first: 'school'),
  q('scho', first: 'school'),
  q('schoo', first: 'school'),
  q('اسکول', first: 'school'),
  q('fis', first: 'school'),
  q('fees', first: 'school'),
  q('fee', first: 'school'),
  q('فیس', first: 'school'),
  q('Bilal', first: 'school'),
  q('school fee', first: 'school', notFound: ['lesco']),
  // Medicine, in both scripts.
  q('dawai', first: 'ammi'),
  q('dawaai', first: 'ammi'),
  q('dava', first: 'ammi'),
  q('dawa', first: 'ammi'),
  q('دوا', first: 'ammi'),
  q('دَوا', first: 'ammi'),
  q('دوائی', first: 'ammi'),
  q('tablet', first: 'ammi'),
  q('medicine', first: 'ammi'),
  q('ammi', first: 'ammi'),
  q('امی', first: 'ammi'),
  q('ammi ki dawai', first: 'ammi'),
  q('ammi دوائی', first: 'ammi'),
  // ID documents and expiry.
  q('cnic', first: 'cnic'),
  q('shanakhti card', first: 'cnic'),
  q('شناختی کارڈ', first: 'cnic'),
  q('shanakhti card kab khatam', first: 'cnic'),
  q('shanakhti ca', first: 'cnic'),
  q('khatam', first: 'cnic'),
  q('expire', first: 'cnic'),
  q('nadra', first: 'cnic'),
  q('abbu', first: 'cnic'),
  // Rent, internet, phone.
  q('kiraya', first: 'rent'),
  q('کرایہ', first: 'rent'),
  q('rent', first: 'rent'),
  q('wifi', first: 'ptcl'),
  q('internet', first: 'ptcl'),
  q('ptc', first: 'ptcl'),
  q('internet bill', first: 'ptcl'),
  q('net', first: 'ptcl', notFound: ['lesco']),
  q('net ka bill', first: 'ptcl', notFound: ['lesco', 'gas']),
  q('نیٹ', first: 'ptcl'),
  q('gais', first: 'gas', notFound: ['lesco']),
  q('gais ka bill', first: 'gas'),
  q('mobile', first: 'jazz'),
  q('jazz', first: 'jazz'),
  q('phone', first: 'jazz'),
  // Notes count too.
  q('late fee', first: 'lesco', notFound: ['school']),
  // Typos.
  q('electrisity', first: 'lesco', found: ['iesco']),
  q('medicin', first: 'ammi'),
];

final taylorQueries = <QueryCase>[
  q('council tax', first: 'council'),
  q('council', first: 'council'),
  q('MOT', first: 'mot'),
  q('tesco', first: 'tesco', notFound: ['energy']),
  q('dentist', first: 'dentist'),
  q('passport', first: 'passport'),
  q('renewal', first: 'passport'),
  q('prescription', first: 'prescription'),
  q('dad', first: 'prescription'),
  q('energy', first: 'energy'),
  q('bijli', first: 'energy'),
  q('appointment', first: 'dentist', found: ['mot']),
  // LESCO means nothing in Manchester, so it reads as a typo of Tesco and
  // never as electricity.
  q('lesco', first: 'tesco', notFound: ['energy']),
  q('pesco xyz'),
];

void main() {
  final khan = indexOf(khanHousehold, Region.pk);
  final taylor = indexOf(taylorHousehold, Region.uk);

  void runTable(String household, SearchIndex index, List<QueryCase> cases) {
    group(household, () {
      for (final (:query, :first, :found, :notFound) in cases) {
        test(query, () {
          final ids = [
            for (final result in index.search(query, today: fixtureToday))
              result.item.id,
          ];
          if (first == null) {
            expect(ids, isEmpty);
          } else {
            expect(ids, isNotEmpty);
            expect(ids.first, first);
          }
          expect(ids, containsAll(found));
          for (final id in notFound) {
            expect(ids, isNot(contains(id)));
          }
        });
      }
    });
  }

  runTable('Khan family, Lahore', khan, khanQueries);
  runTable('Taylor family, Manchester', taylor, taylorQueries);

  test('the query table is large enough to mean something', () {
    expect(khanQueries.length + taylorQueries.length, greaterThan(60));
  });

  group('ranking', () {
    List<String> idsFor(SearchIndex index, String query) => [
      for (final result in index.search(query, today: fixtureToday))
        result.item.id,
    ];

    test('"bill" never puts Bilal\'s school fee first', () {
      final ids = idsFor(khan, 'bill');
      expect(ids.first, isNot('school'));
      expect(ids.indexOf('school'), greaterThan(ids.indexOf('lesco')));
    });

    test('a concept match beats a title prefix, whatever the weights', () {
      final results = khan.search('bill', today: fixtureToday);
      final school = results.firstWhere((r) => r.item.id == 'school');
      expect(school.tier, MatchTier.exact);
      final bilalOnly = indexOf([
        item('bilal', title: 'Bilal birthday'),
      ], Region.pk).search('bil', today: fixtureToday);
      expect(bilalOnly.single.tier, MatchTier.prefix);
    });

    test('every term must match', () {
      expect(idsFor(khan, 'bijli gas'), isEmpty);
      expect(idsFor(khan, 'ammi bill'), isEmpty);
    });

    test('ties go to open items, then the nearest date, then the title', () {
      final index = indexOf([
        item('far', title: 'Rent', due: fixtureToday.addDays(20)),
        item('near', title: 'Rent', due: fixtureToday.addDays(-2)),
        item('closed', title: 'Rent', due: fixtureToday).copyWith(
          status: ItemStatus.done,
          completedAt: DateTime.utc(2026, 11, 2),
        ),
        item('undated', title: 'Rent'),
        item('also-near', title: 'Rent', due: fixtureToday.addDays(2)),
      ], Region.pk);
      expect(idsFor(index, 'rent'), [
        'also-near',
        'near',
        'far',
        'undated',
        'closed',
      ]);
    });

    test('a plural is the same word, above a name that starts like it', () {
      final index = indexOf([
        item('dentist', title: 'Dentist', notes: 'Bring the bill'),
        item('file', title: 'File the bills'),
        item('billo', title: 'Call Billo'),
      ], Region.uk);
      final ids = idsFor(index, 'bill');
      expect(ids.indexOf('file'), lessThan(ids.indexOf('dentist')));
      expect(ids.indexOf('file'), lessThan(ids.indexOf('billo')));
    });

    test('a medicine course that has ended ranks with the finished', () {
      final index = indexOf([
        item(
          'ended',
          title: 'Rent',
          kind: ItemKind.medicine,
          due: fixtureToday.addDays(-20),
          recurrence: DoseTimes(const [480], until: fixtureToday.addDays(-1)),
        ),
        item('open', title: 'Rent', due: fixtureToday.addDays(20)),
      ], Region.pk);
      expect(idsFor(index, 'rent'), ['open', 'ended']);
    });

    test('finished stopwords and lone letters alone find nothing', () {
      for (final query in ['', '   ', 'ka ', 'کا ', 'the ', 'b', 'ka ki ke ']) {
        expect(idsFor(khan, query), isEmpty, reason: query);
      }
    });

    test('a word that starts out as a stopword keeps its results', () {
      final index = indexOf([
        item('meeting', title: 'Meeting with Ali'),
        item('haider', title: 'Haider school fee'),
        item('kiran', title: 'Kiran birthday'),
      ], Region.pk);
      // "me" folds like "my", and "mee" folds to "mi".
      for (final (query, id) in [
        ('me', 'meeting'),
        ('mee', 'meeting'),
        ('hai', 'haider'),
        ('ki', 'kiran'),
      ]) {
        expect(idsFor(index, query), contains(id), reason: query);
      }
      expect(idsFor(khan, 'ammi ki'), ['ammi']);
    });

    test('a doubled vowel is not shortened into another word', () {
      final index = indexOf([
        item('fees', title: 'School fees'),
        item('notice', title: 'Final notice from bank'),
        item('light', title: 'Fix the kitchen light'),
      ], Region.pk);
      // "fee" folds to "fi", which begins "final" and "fix".
      expect(idsFor(index, 'fee'), ['fees']);
      // "too" folds to "tu", which begins "tuition", a school word.
      expect(idsFor(index, 'too'), isEmpty);
      expect(idsFor(khan, 'too'), isNot(contains('school')));
      expect(idsFor(khan, 'tooth'), isNot(contains('school')));
    });

    test('the reference is never searched', () {
      final index = indexOf([
        item('cnic', title: 'CNIC').copyWith(reference: '35202-1234567-1'),
      ], Region.pk);
      expect(idsFor(index, '35202'), isEmpty);
      expect(idsFor(index, '1234567'), isEmpty);
    });
  });

  group('highlights', () {
    SearchResult top(SearchIndex index, String query) =>
        index.search(query, today: fixtureToday).first;

    test('a prefix highlights only what was typed', () {
      expect(top(khan, 'scho').titleRanges, const [MatchRange(6, 10)]);
    });

    test('exact words and concepts highlight the whole word', () {
      expect(top(khan, 'bill').item.id, 'gas');
      expect(top(khan, 'lesco bill').titleRanges, const [
        MatchRange(0, 5),
        MatchRange(6, 10),
      ]);
      expect(top(khan, 'ammi').titleRanges, const [MatchRange(0, 3)]);
      expect(top(khan, 'dawai').titleRanges, const [MatchRange(7, 12)]);
      expect(top(khan, 'shanakhti card').titleRanges, const [
        MatchRange(7, 11),
      ]);
    });

    test('notes are highlighted where they matched', () {
      final cnic = top(khan, 'nadra');
      expect(cnic.notesRanges, const [MatchRange(13, 18)]);
      expect(cnic.titleRanges, isEmpty);
    });

    test('a category-only match emphasizes the category', () {
      final energy = top(taylor, 'bijli');
      expect(energy.titleRanges, isEmpty);
      expect(energy.categoryMatched, isTrue);
      expect(top(khan, 'tablet').kindMatched, isTrue);
    });

    test('folded spellings map back to the letters typed in the title', () {
      final index = indexOf([
        item('bijlee', title: 'Bijlee wala bill'),
      ], Region.pk);
      expect(top(index, 'bijl').titleRanges, const [MatchRange(0, 4)]);
      expect(top(index, 'bijli').titleRanges, const [MatchRange(0, 6)]);
    });

    test('Urdu words are highlighted whole, harakat included', () {
      final index = indexOf([
        item('dawa', title: 'امی کی دَوائیاں'),
      ], Region.pk);
      expect(top(index, 'دوا').titleRanges, const [MatchRange(7, 15)]);
    });

    test('every range is inside its text and on grapheme boundaries', () {
      void check(String text, List<MatchRange> ranges, String query) {
        final boundaries = <int>{0};
        var offset = 0;
        for (final cluster in text.characters) {
          offset += cluster.length;
          boundaries.add(offset);
        }
        for (final range in ranges) {
          expect(range.start, lessThan(range.end), reason: query);
          expect(range.end, lessThanOrEqualTo(text.length), reason: query);
          expect(boundaries, contains(range.start), reason: query);
          expect(boundaries, contains(range.end), reason: query);
        }
      }

      for (final (index, cases) in [
        (khan, khanQueries),
        (taylor, taylorQueries),
      ]) {
        for (final (:query, first: _, found: _, notFound: _) in cases) {
          for (final result in index.search(query, today: fixtureToday)) {
            check(result.item.title, result.titleRanges, query);
            check(result.item.notes ?? '', result.notesRanges, query);
          }
        }
      }
    });
  });

  group('documents', () {
    test('are reused until their item changes', () {
      final documents = SearchDocuments(HouseholdLexicon.forRegion(Region.pk));
      final first = documents.index(khanHousehold) as LinearSearchIndex;
      final again = documents.index(khanHousehold) as LinearSearchIndex;
      for (var i = 0; i < khanHousehold.length; i++) {
        expect(identical(first.documents[i], again.documents[i]), isTrue);
      }

      final edited = [
        khanHousehold.first.copyWith(title: 'LESCO November', revision: 2),
        ...khanHousehold.skip(1),
      ];
      final changed = documents.index(edited) as LinearSearchIndex;
      expect(
        identical(changed.documents.first, first.documents.first),
        isFalse,
      );
      expect(identical(changed.documents[1], first.documents[1]), isTrue);
      expect(
        changed.search('november', today: fixtureToday).single.item.id,
        'lesco',
      );
    });

    test('follow deletions', () {
      final documents = SearchDocuments(HouseholdLexicon.forRegion(Region.pk));
      documents.index(khanHousehold);
      final remaining = documents.index(
        khanHousehold.where((item) => item.id != 'lesco').toList(),
      );
      expect(
        remaining
            .search('lesco', today: fixtureToday)
            .map((result) => result.item.id),
        isEmpty,
      );
    });
  });

  group('query parsing', () {
    final lexicon = HouseholdLexicon.forRegion(Region.pk);

    test('keeps phrases together and drops stopwords', () {
      final terms = SearchQuery.parse(
        'shanakhti card kab khatam',
        lexicon,
      ).terms;
      expect(terms, hasLength(2));
      expect(terms.first.tokens, hasLength(2));
      expect(terms.first.concepts, {'category:idDocument': MatchTier.exact});
      expect(terms.last.concepts, {'kind:expiry': MatchTier.exact});
    });

    test('only the last word, still being typed, is a prefix', () {
      final typing = SearchQuery.parse('bijli bi', lexicon).terms;
      expect(typing.map((t) => t.prefix), [false, true]);
      final finished = SearchQuery.parse('bijli bi ', lexicon).terms;
      expect(finished.map((t) => t.prefix), [false, false]);
    });

    test('a lexicon term is never fuzzy', () {
      final terms = SearchQuery.parse('lesco lesko', lexicon).terms;
      expect(terms.map((t) => t.fuzzy), [false, true]);
      expect(terms.last.concepts, {'biller:lesco': MatchTier.oneEdit});
    });

    test('the kind of an item is a concept too', () {
      final terms = SearchQuery.parse('appointment', lexicon).terms;
      expect(
        terms.single.concepts.keys,
        contains('kind:${ItemKind.appointment.name}'),
      );
    });
  });

  test('a date far from today does not stop an item being found', () {
    final index = indexOf([
      item('old', title: 'Old warranty', due: LocalDate(2001, 1, 1)),
    ], Region.pk);
    expect(index.search('warranty', today: fixtureToday), hasLength(1));
  });
}
