import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/money/money.dart';
import 'package:yaadi/features/items/domain/item.dart';
import 'package:yaadi/features/items/domain/item_category.dart';
import 'package:yaadi/features/items/domain/item_kind.dart';
import 'package:yaadi/features/search/domain/household_lexicon.dart';
import 'package:yaadi/features/search/domain/region.dart';
import 'package:yaadi/features/search/domain/search_index.dart';

import '../../../support/households.dart';
import '../../../support/items.dart';

const _words = [
  'LESCO', 'bill', 'gas', 'school', 'fee', 'rent', 'Bilal', 'Ayesha', //
  'November', 'December', 'internet', 'PTCL', 'Jazz', 'package', 'CNIC', //
  'passport', 'warranty', 'fridge', 'AC', 'service', 'tuition', 'van', //
  'بجلی', 'بل', 'گیس', 'پانی', 'فیس', 'کرایہ', 'امی', 'ابو', 'دوائی', //
  'اسکول', 'مکان', 'دکان', 'گاڑی', 'قسط', 'شناختی', 'کارڈ', //
];

/// A household far larger than any real one: 5,000 items.
List<Item> generatedHousehold() {
  final random = Random(7);
  String words(int count) => List.generate(
    count,
    (_) => _words[random.nextInt(_words.length)],
  ).join(' ');
  return List.generate(5000, (i) {
    final kind = ItemKind.values[random.nextInt(ItemKind.values.length)];
    return item(
      'item-$i',
      kind: kind == ItemKind.medicine ? ItemKind.task : kind,
      title: words(2 + random.nextInt(3)),
      category: ItemCategory.values[random.nextInt(ItemCategory.values.length)],
      due: fixtureToday.addDays(random.nextInt(400) - 100),
      amount: kind == ItemKind.bill
          ? Money(random.nextInt(9999900), 'PKR')
          : null,
      notes: random.nextBool() ? words(4 + random.nextInt(6)) : null,
    );
  });
}

void main() {
  test('5,000 items are searched well within budget', () {
    final items = generatedHousehold();
    final index = SearchDocuments(HouseholdLexicon.forRegion(Region.pk))
        .index(items);
    const queries = [
      'bijli ka bill',
      'bi',
      'school fee',
      'امی کی دوائی',
      'electrisity',
      'shanakhti card kab khatam',
      'warrnty',
      'kiraya',
    ];
    for (final query in queries) {
      index.search(query, today: fixtureToday);
    }

    final stopwatch = Stopwatch()..start();
    const rounds = 5;
    var found = 0;
    for (var round = 0; round < rounds; round++) {
      for (final query in queries) {
        found += index.search(query, today: fixtureToday).length;
      }
    }
    stopwatch.stop();

    expect(found, greaterThan(0));
    final perQuery = stopwatch.elapsedMicroseconds / (rounds * queries.length);
    // Generous on purpose: this catches accidental quadratic work, not a
    // slow CI machine. Expect a few milliseconds on a laptop.
    expect(perQuery, lessThan(100000), reason: '$perQuery µs per query');
  });
}
