import 'package:yaadi/core/money/money.dart';
import 'package:yaadi/core/time/local_date.dart';
import 'package:yaadi/features/items/domain/item.dart';
import 'package:yaadi/features/items/domain/item_category.dart';
import 'package:yaadi/features/items/domain/item_kind.dart';
import 'package:yaadi/features/items/domain/recurrence.dart';

import 'items.dart';

/// The day the fixtures are written for, a Monday.
final fixtureToday = LocalDate(2026, 11, 2);

LocalDate _in(int days) => fixtureToday.addDays(days);

Money _rupees(int rupees) => Money(rupees * 100, 'PKR');

/// A fictional Lahore household, in English, Urdu and both.
final khanHousehold = <Item>[
  item(
    'lesco',
    kind: ItemKind.bill,
    title: 'LESCO bill',
    category: ItemCategory.electricity,
    due: _in(8),
    recurrence: MonthlyRepeat(10),
    amount: _rupees(4250),
    notes: 'Pay before the 10th to avoid the late fee',
  ),
  item(
    'iesco',
    kind: ItemKind.bill,
    title: 'IESCO bill (shop)',
    category: ItemCategory.electricity,
    due: _in(10),
    recurrence: MonthlyRepeat(12),
  ),
  item(
    'gas',
    kind: ItemKind.bill,
    title: 'SNGPL gas bill',
    category: ItemCategory.gas,
    due: _in(4),
    recurrence: MonthlyRepeat(6),
  ),
  item(
    'water',
    kind: ItemKind.bill,
    title: 'پانی کا بل',
    category: ItemCategory.water,
    due: _in(0),
    amount: _rupees(900),
  ),
  item(
    'school',
    kind: ItemKind.bill,
    title: 'Bilal school fee',
    category: ItemCategory.school,
    due: _in(3),
    recurrence: MonthlyRepeat(5),
    amount: _rupees(12000),
  ),
  item(
    'rent',
    kind: ItemKind.bill,
    title: 'مکان کا کرایہ',
    category: ItemCategory.rent,
    due: _in(-1),
    recurrence: MonthlyRepeat(1),
    amount: _rupees(45000),
  ),
  item(
    'ptcl',
    kind: ItemKind.bill,
    title: 'PTCL internet',
    category: ItemCategory.internet,
    due: _in(13),
    recurrence: MonthlyRepeat(15),
    amount: _rupees(3000),
  ),
  item(
    'jazz',
    kind: ItemKind.bill,
    title: 'Jazz mobile package',
    category: ItemCategory.phone,
    due: _in(0),
    minute: 1080,
  ),
  item(
    'cnic',
    kind: ItemKind.expiry,
    title: "Abbu's CNIC",
    category: ItemCategory.idDocument,
    due: _in(23),
    notes: 'Renew at the NADRA office',
  ),
  item(
    'ammi',
    kind: ItemKind.medicine,
    title: 'امی کی دوائی',
    category: ItemCategory.health,
    due: _in(-6),
    recurrence: DoseTimes([480, 840, 1200], until: _in(28)),
  ),
];

/// A fictional Manchester household.
final taylorHousehold = <Item>[
  item(
    'council',
    kind: ItemKind.bill,
    title: 'Council tax',
    category: ItemCategory.other,
    due: _in(-1),
    recurrence: MonthlyRepeat(1, until: LocalDate(2027, 1, 1)),
    amount: Money(15600, 'GBP'),
  ),
  item(
    'energy',
    kind: ItemKind.bill,
    title: 'Energy bill',
    category: ItemCategory.electricity,
    due: _in(12),
    recurrence: MonthlyRepeat(14),
  ),
  item(
    'dentist',
    kind: ItemKind.appointment,
    title: 'Dentist check-up',
    category: ItemCategory.health,
    due: _in(2),
    minute: 630,
  ),
  item(
    'passport',
    kind: ItemKind.expiry,
    title: 'Passport renewal (Emma)',
    category: ItemCategory.idDocument,
    due: _in(43),
  ),
  item(
    'mot',
    kind: ItemKind.appointment,
    title: 'MOT for the car',
    due: _in(18),
  ),
  item(
    'prescription',
    kind: ItemKind.medicine,
    title: "Dad's prescription",
    category: ItemCategory.health,
    due: _in(-20),
    recurrence: DoseTimes([540, 1260]),
  ),
  item('tesco', title: 'Tesco delivery slot', due: _in(1)),
];
