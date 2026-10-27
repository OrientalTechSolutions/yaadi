import '../../items/domain/item_category.dart';
import '../../items/domain/item_kind.dart';
import 'concept.dart';
import 'region.dart';

/// The household words search understands, in English, Urdu script and
/// Roman Urdu.
///
/// Terms are written the way people spell them; the normalizer folds
/// variants (bijlee and bijly match bijli, بجلي matches بجلی), so only
/// spellings it cannot fold need their own entry. A term may be a phrase of
/// up to three words, and longer phrases win over shorter ones.
const householdConcepts = <Concept>[
  Concept.category(ItemCategory.electricity, [
    'electricity',
    'electric',
    'power',
    'bijli',
    'bjli',
    'بجلی',
  ]),
  // "Light ka bill" is how many Pakistani homes say electricity bill.
  Concept.category(ItemCategory.electricity, region: Region.pk, [
    'wapda',
    'واپڈا',
    'light',
    'لائٹ',
  ]),
  Concept.category(ItemCategory.gas, ['gas', 'sui gas', 'گیس', 'سوئی گیس']),
  Concept.category(ItemCategory.water, ['water', 'pani', 'پانی']),
  Concept.category(ItemCategory.internet, [
    'internet',
    'wifi',
    'wi fi',
    'broadband',
    'انٹرنیٹ',
    'وائی فائی',
  ]),
  Concept.category(ItemCategory.phone, [
    'phone',
    'mobile',
    'cell',
    'fone',
    'landline',
    'فون',
    'موبائل',
  ]),
  Concept.category(ItemCategory.school, [
    'school',
    'skool',
    'college',
    'university',
    'tuition',
    'اسکول',
    'سکول',
    'کالج',
    'ٹیوشن',
  ]),
  Concept.category(ItemCategory.rent, ['rent', 'kiraya', 'kraya', 'کرایہ']),
  Concept.category(ItemCategory.health, [
    'health',
    'doctor',
    'dr',
    'hospital',
    'clinic',
    'dentist',
    'checkup',
    'صحت',
    'ڈاکٹر',
    'ہسپتال',
    'اسپتال',
    'کلینک',
  ]),
  Concept.category(ItemCategory.health, region: Region.uk, ['gp', 'nhs']),
  Concept.category(ItemCategory.idDocument, [
    'cnic',
    'id card',
    'identity card',
    'shanakhti card',
    'shanakhti',
    'shnakhti',
    'shanakhati',
    'passport',
    'licence',
    'license',
    'شناختی کارڈ',
    'شناختی',
    'پاسپورٹ',
    'لائسنس',
  ]),
  Concept.category(ItemCategory.idDocument, region: Region.pk, [
    'nicop',
    'b form',
  ]),
  Concept.category(ItemCategory.warranty, [
    'warranty',
    'guarantee',
    'وارنٹی',
    'گارنٹی',
  ]),

  // Billers. Their names belong to one country, and each finds only itself.
  Concept.biller(
    'lesco',
    ItemCategory.electricity,
    region: Region.pk,
    alsoWritten: ['لیسکو'],
  ),
  Concept.biller(
    'k-electric',
    ItemCategory.electricity,
    region: Region.pk,
    alsoWritten: ['kelectric', 'کے الیکٹرک'],
  ),
  Concept.biller('iesco', ItemCategory.electricity, region: Region.pk),
  Concept.biller('mepco', ItemCategory.electricity, region: Region.pk),
  Concept.biller('pesco', ItemCategory.electricity, region: Region.pk),
  Concept.biller('fesco', ItemCategory.electricity, region: Region.pk),
  Concept.biller('gepco', ItemCategory.electricity, region: Region.pk),
  Concept.biller('hesco', ItemCategory.electricity, region: Region.pk),
  Concept.biller('qesco', ItemCategory.electricity, region: Region.pk),
  Concept.biller('sepco', ItemCategory.electricity, region: Region.pk),
  Concept.biller('tesco', ItemCategory.electricity, region: Region.pk),
  Concept.biller(
    'sngpl',
    ItemCategory.gas,
    region: Region.pk,
    alsoWritten: ['sui northern'],
  ),
  Concept.biller(
    'ssgc',
    ItemCategory.gas,
    region: Region.pk,
    alsoWritten: ['ssgcl', 'sui southern'],
  ),
  Concept.biller(
    'wasa',
    ItemCategory.water,
    region: Region.pk,
    alsoWritten: ['واسا'],
  ),
  Concept.biller('ptcl', ItemCategory.internet, region: Region.pk),
  Concept.biller('nayatel', ItemCategory.internet, region: Region.pk),
  Concept.biller('jazz', ItemCategory.phone, region: Region.pk),
  Concept.biller('zong', ItemCategory.phone, region: Region.pk),
  Concept.biller('telenor', ItemCategory.phone, region: Region.pk),
  Concept.biller('ufone', ItemCategory.phone, region: Region.pk),
  Concept.biller(
    'nadra',
    ItemCategory.idDocument,
    region: Region.pk,
    alsoWritten: ['نادرا'],
  ),
  Concept.biller('dvla', ItemCategory.idDocument, region: Region.uk),
  Concept.biller('dmv', ItemCategory.idDocument, region: Region.us),

  Concept.kind(ItemKind.bill, ['bill', 'invoice', 'بل']),
  Concept.kind(ItemKind.appointment, [
    'appointment',
    'appt',
    'visit',
    'meeting',
    'ملاقات',
    'اپوائنٹمنٹ',
  ]),
  Concept.kind(ItemKind.expiry, [
    'expiry',
    'expire',
    'expires',
    'expired',
    'expiring',
    'renewal',
    'renew',
    'khatam',
    'khtm',
    'miyad',
    'tajdeed',
    'ختم',
    'میعاد',
    'تجدید',
  ]),
  Concept.kind(ItemKind.medicine, [
    'medicine',
    'medicines',
    'medication',
    'meds',
    'dose',
    'dawa',
    'dawai',
    'dwai',
    'dawaiyan',
    'tablet',
    'tablets',
    'goli',
    'golian',
    'syrup',
    'prescription',
    'دوا',
    'دوائی',
    'دوائیں',
    'گولی',
    'گولیاں',
    'شربت',
    'نسخہ',
  ]),
  Concept.kind(ItemKind.task, ['task', 'todo', 'to do', 'kaam', 'کام']),

  // Words with no category of their own that people search by, linking
  // their spellings across scripts: "ammi" finds "امی کی دوائی".
  Concept.alias('fee', ['fee', 'fees', 'fis', 'فیس']),
  Concept.alias('ammi', [
    'ammi',
    'amma',
    'mother',
    'mom',
    'mum',
    'امی',
    'اماں',
    'والدہ',
  ]),
  Concept.alias('abbu', [
    'abbu',
    'abba',
    'father',
    'dad',
    'ابو',
    'ابا',
    'والد',
  ]),
  Concept.alias('dadi', ['dadi', 'دادی']),
  Concept.alias('dada', ['dada', 'دادا']),
  Concept.alias('nani', ['nani', 'نانی']),
  Concept.alias('nana', ['nana', 'نانا']),
  Concept.alias('bachay', [
    'bachay',
    'bache',
    'bachon',
    'children',
    'kids',
    'بچے',
    'بچوں',
  ]),
  Concept.alias('council tax', ['council tax'], region: Region.uk),
  Concept.alias('mot', ['mot'], region: Region.uk),
  Concept.alias('tv licence', ['tv licence', 'tv license'], region: Region.uk),
];

/// Words that carry no meaning in a search: "bijli ka bill" looks for bijli
/// and bill.
const householdStopwords = <String>[
  // English
  'a', 'an', 'the', 'of', 'my', 'for', 'to', 'is', 'on', 'in', 'and', //
  'when', 'due',
  // Roman Urdu
  'ka', 'ki', 'ke', 'ko', 'se', 'mein', 'main', 'me', 'mai', 'hai', //
  'hain', 'kab', 'kya', 'kia', 'wala', 'wali', 'wale', 'aur', 'ya', 'tak',
  // Urdu
  'کا', 'کی', 'کے', 'کو', 'سے', 'میں', 'ہے', 'ہیں', 'کب', 'کیا', //
  'والا', 'والی', 'والے', 'اور', 'تک',
];
