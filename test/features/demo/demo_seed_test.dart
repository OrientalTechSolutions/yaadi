import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/text/script.dart';
import 'package:yaadi/core/time/local_date.dart';
import 'package:yaadi/features/demo/data/demo_seed.dart';
import 'package:yaadi/features/demo/domain/demo_household.dart';
import 'package:yaadi/features/items/domain/item_kind.dart';
import 'package:yaadi/features/items/domain/recurrence.dart';
import 'package:yaadi/features/search/domain/household_lexicon.dart';
import 'package:yaadi/features/search/domain/region.dart';
import 'package:yaadi/features/search/domain/search_index.dart';
import 'package:yaadi/features/today/domain/today_view.dart';

final now = DateTime.utc(2026, 11, 2, 4);

/// Days the seed must work on: ordinary, month ends, a leap day, New Year.
final days = [
  LocalDate(2026, 11, 2),
  LocalDate(2027, 1, 31),
  LocalDate(2028, 2, 29),
  LocalDate(2026, 12, 31),
  LocalDate(2027, 1, 1),
];

void main() {
  for (final household in DemoHousehold.values) {
    group(household.name, () {
      for (final today in days) {
        test('is valid and fills every group of Today on $today', () {
          final seed = demoSeed(household, today: today, now: now);
          final ids = {for (final item in seed.items) item.id};

          expect(ids, hasLength(seed.items.length));
          for (final item in seed.items) {
            expect(item.violations, isEmpty, reason: item.id);
            expect(item.id, startsWith('${household.name}-'));
            final amount = item.amount;
            if (amount != null) expect(amount.currency, household.currency);
          }
          for (final completion in seed.completions) {
            expect(ids, contains(completion.itemId));
          }

          final view = TodayView.build(seed.items, today: today);
          for (final section in [
            TodaySection.overdue,
            TodaySection.today,
            TodaySection.nextWeek,
            TodaySection.later,
          ]) {
            expect(view[section], isNotEmpty, reason: '$section');
          }
        });
      }

      test('every kind of item is there', () {
        final seed = demoSeed(household, today: days.first, now: now);
        expect(
          {for (final item in seed.items) item.kind},
          containsAll([
            ItemKind.bill,
            ItemKind.appointment,
            ItemKind.expiry,
            ItemKind.medicine,
          ]),
        );
      });

      test('references are obvious placeholders', () {
        final seed = demoSeed(household, today: days.first, now: now);
        for (final item in seed.items) {
          final reference = item.reference;
          if (reference == null) continue;
          expect(
            reference.contains('0000') || reference.contains('12345'),
            isTrue,
            reason: item.id,
          );
        }
      });

      test('medicine is only ever times the family typed', () {
        final seed = demoSeed(household, today: days.first, now: now);
        final medicine = seed.items.where(
          (item) => item.kind == ItemKind.medicine,
        );
        for (final item in medicine) {
          expect(item.recurrence, isA<DoseTimes>());
        }
      });
    });
  }

  test('the Khan household mixes Urdu and English titles', () {
    final titles = [
      for (final item in demoSeed(
        DemoHousehold.khan,
        today: days.first,
        now: now,
      ).items)
        item.title,
    ];
    expect(titles.where((t) => t.runes.any(isArabicScript)), isNotEmpty);
    expect(titles.where((t) => !t.runes.any(isArabicScript)), isNotEmpty);
  });

  test("the Taylor council tax ends with January's instalment", () {
    for (final today in days) {
      final council = demoSeed(
        DemoHousehold.taylor,
        today: today,
        now: now,
      ).items.singleWhere((item) => item.id == 'taylor-council');
      final until = council.recurrence.until!;
      expect(until.month, 1, reason: '$today');
      expect(until.isBefore(council.dueOn!), isFalse, reason: '$today');
    }
  });

  test('search finds the demo items in their own languages', () {
    List<String> search(DemoHousehold household, String query) {
      final seed = demoSeed(household, today: days.first, now: now);
      final region = Region.forCurrency(household.currency);
      final index = SearchDocuments(HouseholdLexicon.forRegion(region))
          .index(seed.items);
      return [
        for (final result in index.search(query, today: days.first))
          result.item.id,
      ];
    }

    expect(search(DemoHousehold.khan, 'bijli ka bill').first, 'khan-lesco');
    expect(search(DemoHousehold.khan, 'ammi ki dawai').first, 'khan-ammi');
    expect(search(DemoHousehold.khan, 'sui gas').first, 'khan-gas');
    expect(search(DemoHousehold.khan, 'shanakhti card').first, 'khan-cnic');
    expect(search(DemoHousehold.khan, 'کرایہ').first, 'khan-rent');
    expect(search(DemoHousehold.taylor, 'council tax').first, 'taylor-council');
    expect(
      search(DemoHousehold.taylor, 'prescription').first,
      'taylor-prescription',
    );
  });
}
