import 'package:yaadi/core/money/money.dart';
import 'package:yaadi/core/time/local_date.dart';
import 'package:yaadi/features/items/domain/completion.dart';
import 'package:yaadi/features/items/domain/item.dart';
import 'package:yaadi/features/items/domain/item_category.dart';
import 'package:yaadi/features/items/domain/item_kind.dart';
import 'package:yaadi/features/items/domain/recurrence.dart';
import 'package:yaadi/vault/vault_key_store.dart';

/// The committed SQLCipher fixture (ARCHITECTURE.md section 5.4): a schema v1
/// vault written through the production open path by the SQLCipher 4.19.0
/// build of `sqlite3` 3.8.0, made once with make_vault_fixture.dart.
///
/// It is never regenerated. A `sqlite3`, SQLCipher or key-derivation change
/// that can no longer read it fails CI instead of phones; a new schema
/// version adds its own fixture next to this one.
const vaultFixtureV1 = 'test/fixtures/vault_v1.sqlite';

/// The schema version the fixture was written at.
const vaultFixtureSchemaVersion = 1;

/// The fixture's key record: a test value that protects nothing else. The
/// database key is derived from it with HKDF, as on phones.
final vaultFixtureKey = VaultKeyRecord(List.generate(32, (i) => i));

final _createdAt = DateTime.utc(2026, 10, 1, 9, 30);

/// Written with `create`, then paid once, which makes it revision 2.
final vaultFixtureBill = Item(
  id: '0199a0f2-6c00-7000-8000-000000000001',
  kind: ItemKind.bill,
  title: 'LESCO bill',
  category: ItemCategory.electricity,
  amount: Money(425000, 'PKR'),
  dueOn: LocalDate(2026, 11, 10),
  recurrence: MonthlyRepeat(10),
  notes: 'Fixture notes',
  reference: 'FIXTURE-REF-0042',
  createdAt: _createdAt,
  updatedAt: _createdAt,
);

final vaultFixtureMedicine = Item(
  id: '0199a0f2-6c00-7000-8000-000000000002',
  kind: ItemKind.medicine,
  title: 'امی کی دوائی',
  category: ItemCategory.health,
  dueOn: LocalDate(2026, 10, 27),
  recurrence: DoseTimes(const [480, 1200], until: LocalDate(2026, 11, 3)),
  createdAt: _createdAt,
  updatedAt: _createdAt,
);

final vaultFixtureTask = Item(
  id: '0199a0f2-6c00-7000-8000-000000000003',
  kind: ItemKind.task,
  title: 'Renew library card',
  category: ItemCategory.other,
  createdAt: _createdAt,
  updatedAt: _createdAt,
);

final vaultFixtureBillPayment = Completion(
  id: '0199a0f2-6c00-7000-8000-000000000004',
  itemId: vaultFixtureBill.id,
  occurrenceOn: LocalDate(2026, 10, 10),
  outcome: CompletionOutcome.paid,
  amount: Money(398000, 'PKR'),
  recordedAt: DateTime.utc(2026, 10, 9, 8),
);

const vaultFixtureSettings = {'language': 'ur'};

/// Every item as the fixture stores it.
List<Item> get vaultFixtureItems => [
  vaultFixtureBill.copyWith(revision: 2),
  vaultFixtureMedicine,
  vaultFixtureTask,
];

/// Text that must never appear in the fixture's bytes.
List<String> get vaultFixturePlaintext => [
  'SQLite format 3',
  vaultFixtureBill.title,
  vaultFixtureBill.reference!,
  vaultFixtureBill.notes!,
  vaultFixtureTask.title,
  'CREATE TABLE',
];
