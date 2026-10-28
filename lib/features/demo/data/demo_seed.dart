import '../../../core/money/money.dart';
import '../../../core/time/local_date.dart';
import '../../items/domain/completion.dart';
import '../../items/domain/item.dart';
import '../../items/domain/item_category.dart';
import '../../items/domain/item_kind.dart';
import '../../items/domain/item_status.dart';
import '../../items/domain/recurrence.dart';
import '../domain/demo_household.dart';

/// A demo household's items and their history.
typedef DemoSeed = ({List<Item> items, List<Completion> completions});

/// The made-up items of [household], dated around [today] so the demo always
/// has something overdue, something today and something next week.
///
/// Every name is invented and every reference is an obvious placeholder.
/// Utility and agency names appear only as billers, the way they print on
/// real papers.
DemoSeed demoSeed(
  DemoHousehold household, {
  required LocalDate today,
  required DateTime now,
}) {
  final builder = _SeedBuilder(household.name, today, now);
  switch (household) {
    case DemoHousehold.khan:
      _khan(builder);
    case DemoHousehold.taylor:
      _taylor(builder);
  }
  return (
    items: List.unmodifiable(builder.items),
    completions: List.unmodifiable(builder.completions),
  );
}

void _khan(_SeedBuilder seed) {
  Money rupees(int amount) => Money(amount * 100, 'PKR');

  seed
    ..add(
      'lesco',
      ItemKind.bill,
      'LESCO bill',
      ItemCategory.electricity,
      inDays: 3,
      repeat: RepeatRule.monthly,
      amount: rupees(4250),
      notes:
          'Pay at the bank or in the banking app before the due date to '
          'avoid the late fee.',
      reference: '00 00000 0001234',
      lastPaid: rupees(3980),
    )
    ..add(
      'gas',
      ItemKind.bill,
      'گیس کا بل',
      ItemCategory.gas,
      inDays: -2,
      repeat: RepeatRule.monthly,
      amount: rupees(2180),
      notes: 'سردیوں میں SNGPL کا بل زیادہ آتا ہے۔',
      lastPaid: rupees(1640),
    )
    ..add(
      'school',
      ItemKind.bill,
      "Ayesha's school fee",
      ItemCategory.school,
      inDays: 0,
      repeat: RepeatRule.monthly,
      amount: rupees(12000),
      notes: 'Pay at the school office or by bank transfer.',
    )
    ..add(
      'jazz',
      ItemKind.bill,
      'Jazz mobile package',
      ItemCategory.phone,
      inDays: 1,
      repeat: RepeatRule.monthly,
      amount: rupees(1200),
    )
    ..add(
      'water',
      ItemKind.bill,
      'پانی کا بل',
      ItemCategory.water,
      inDays: 5,
      repeat: RepeatRule.monthly,
      amount: rupees(900),
      notes: 'WASA',
    )
    ..add(
      'rent',
      ItemKind.bill,
      'مکان کا کرایہ',
      ItemCategory.rent,
      inDays: 9,
      repeat: RepeatRule.monthly,
      amount: rupees(45000),
    )
    ..add(
      'ptcl',
      ItemKind.bill,
      'PTCL internet',
      ItemCategory.internet,
      inDays: 12,
      repeat: RepeatRule.monthly,
      amount: rupees(3000),
    )
    ..add(
      'cnic',
      ItemKind.expiry,
      "Abbu's CNIC",
      ItemCategory.idDocument,
      inDays: 23,
      notes: 'Renew at the NADRA office. Take the old card and a copy.',
      reference: '12345-6789012-3',
    )
    ..add(
      'ammi',
      ItemKind.medicine,
      'امی کی دوائی',
      ItemCategory.health,
      inDays: -6,
      doses: const [480, 840, 1260],
      untilInDays: 24,
      notes: 'ڈاکٹر صاحب کے بتائے ہوئے اوقات',
    )
    ..add(
      'checkup',
      ItemKind.appointment,
      "Ammi's check-up",
      ItemCategory.health,
      inDays: -1,
      minute: 17 * 60,
    )
    ..add(
      'fridge',
      ItemKind.expiry,
      'Fridge warranty',
      ItemCategory.warranty,
      inDays: 70,
      notes: 'The card is in the kitchen drawer.',
    )
    // Already paid, so the Finished filter has something to show.
    ..add(
      'plumber',
      ItemKind.bill,
      'پلمبر کا بل',
      ItemCategory.other,
      inDays: -4,
      amount: rupees(2500),
      notes: 'Kitchen tap',
      finishedDaysAgo: 3,
    );
}

void _taylor(_SeedBuilder seed) {
  Money pounds(int pence) => Money(pence, 'GBP');
  final today = seed.today;
  // Ten instalments, April to January.
  final lastInstalment = LocalDate(
    today.month == 1 ? today.year : today.year + 1,
    1,
    31,
  );

  seed
    ..add(
      'council',
      ItemKind.bill,
      'Council tax',
      ItemCategory.other,
      inDays: -1,
      repeat: RepeatRule.monthly,
      until: lastInstalment,
      amount: pounds(15600),
      notes: 'Ten instalments, April to January.',
      reference: '0000001234',
    )
    ..add(
      'energy',
      ItemKind.bill,
      'Energy bill',
      ItemCategory.electricity,
      inDays: 12,
      repeat: RepeatRule.monthly,
      lastPaid: pounds(9840),
    )
    ..add(
      'broadband',
      ItemKind.bill,
      'Broadband',
      ItemCategory.internet,
      inDays: 5,
      repeat: RepeatRule.monthly,
      amount: pounds(3200),
    )
    ..add(
      'dentist',
      ItemKind.appointment,
      'Dentist check-up',
      ItemCategory.health,
      inDays: 2,
      minute: 10 * 60 + 30,
    )
    ..add(
      'mot',
      ItemKind.expiry,
      'MOT for the car',
      ItemCategory.other,
      inDays: 26,
      repeat: RepeatRule.yearly,
    )
    ..add(
      'passport',
      ItemKind.expiry,
      "Emma's passport",
      ItemCategory.idDocument,
      inDays: 43,
      notes: 'Renewals can take three weeks.',
      reference: '123456789',
    )
    ..add(
      'prescription',
      ItemKind.medicine,
      "Dad's prescription",
      ItemCategory.health,
      inDays: -20,
      doses: const [540, 1260],
    )
    ..add(
      'bins',
      ItemKind.task,
      'Put the bins out',
      ItemCategory.other,
      inDays: 0,
      repeat: RepeatRule.weekly,
    )
    ..add('boiler', ItemKind.task, 'Book a boiler service', ItemCategory.other)
    // Already paid, so the Finished filter has something to show.
    ..add(
      'window',
      ItemKind.bill,
      'Window cleaner',
      ItemCategory.other,
      inDays: -2,
      amount: pounds(2000),
      finishedDaysAgo: 2,
    );
}

final class _SeedBuilder {
  _SeedBuilder(this.prefix, this.today, this.now);

  final String prefix;
  final LocalDate today;
  final DateTime now;
  final items = <Item>[];
  final completions = <Completion>[];

  /// Noon on [day], as a payment or a Done would have been recorded.
  DateTime _noonOn(LocalDate day) => DateTime(day.year, day.month, day.day, 12);

  /// Adds one item; [inDays] is null for an undated task. [lastPaid] records
  /// last month's payment, two days before it was due, so the item has some
  /// history to show. [finishedDaysAgo] makes a one-off item already paid or
  /// done that many days ago.
  void add(
    String key,
    ItemKind kind,
    String title,
    ItemCategory category, {
    int? inDays,
    int? minute,
    RepeatRule repeat = RepeatRule.none,
    LocalDate? until,
    int? untilInDays,
    List<int> doses = const [],
    Money? amount,
    String? notes,
    String? reference,
    Money? lastPaid,
    int? finishedDaysAgo,
  }) {
    final id = '$prefix-$key';
    final due = inDays == null ? null : today.addDays(inDays);
    final end =
        until ?? (untilInDays == null ? null : today.addDays(untilInDays));
    final finishedAt = finishedDaysAgo == null
        ? null
        : _noonOn(today.addDays(-finishedDaysAgo));
    final outcome = kind == ItemKind.bill
        ? CompletionOutcome.paid
        : CompletionOutcome.done;
    final recurrence = due == null
        ? Recurrence.none
        : Recurrence.anchored(
            doses.isEmpty ? repeat : RepeatRule.doses,
            due,
            until: end,
            doseMinutes: doses,
          );
    items.add(
      Item(
        id: id,
        kind: kind,
        title: title,
        category: category,
        amount: amount,
        dueOn: due,
        dueMinute: minute,
        recurrence: recurrence,
        notes: notes,
        reference: reference,
        status: finishedAt == null
            ? ItemStatus.open
            : outcome == CompletionOutcome.paid
            ? ItemStatus.paid
            : ItemStatus.done,
        completedAt: finishedAt,
        createdAt: finishedAt ?? now,
        updatedAt: finishedAt ?? now,
      ),
    );
    if (finishedAt != null) {
      completions.add(
        Completion(
          id: '$id-${outcome.name}',
          itemId: id,
          occurrenceOn: due ?? today,
          outcome: outcome,
          amount: outcome == CompletionOutcome.paid ? amount : null,
          recordedAt: finishedAt,
        ),
      );
    }
    if (lastPaid != null && due != null) {
      final previous = due.addMonths(-1);
      completions.add(
        Completion(
          id: '$id-paid',
          itemId: id,
          occurrenceOn: previous,
          outcome: CompletionOutcome.paid,
          amount: lastPaid,
          recordedAt: _noonOn(previous.addDays(-2)),
        ),
      );
    }
  }
}
