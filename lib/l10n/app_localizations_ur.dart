// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'یادی';

  @override
  String get navToday => 'آج';

  @override
  String get navSettings => 'ترتیبات';

  @override
  String get todayEmptyTitle => 'ابھی یہاں کچھ نہیں';

  @override
  String get todayEmptyBody =>
      'آپ جو بل، اپوائنٹمنٹ، میعاد کی تاریخیں، دوا کے اوقات اور کام شامل کریں گے، وہ یہاں نظر آئیں گے۔';

  @override
  String get itemsLoadFailed => 'آپ کی چیزیں لوڈ نہیں ہو سکیں۔';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count چیزیں',
      one: '1 چیز',
      zero: 'کوئی چیز نہیں',
    );
    return '$_temp0';
  }

  @override
  String dueOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'آخری تاریخ: $dateString';
  }

  @override
  String get noDueDate => 'کوئی تاریخ نہیں';

  @override
  String get kindBill => 'بل';

  @override
  String get kindAppointment => 'اپوائنٹمنٹ';

  @override
  String get kindExpiry => 'میعاد';

  @override
  String get kindMedicine => 'دوا';

  @override
  String get kindTask => 'کام';

  @override
  String get categoryElectricity => 'بجلی';

  @override
  String get categoryGas => 'گیس';

  @override
  String get categoryWater => 'پانی';

  @override
  String get categoryInternet => 'انٹرنیٹ';

  @override
  String get categoryPhone => 'فون';

  @override
  String get categorySchool => 'اسکول';

  @override
  String get categoryRent => 'کرایہ';

  @override
  String get categoryHealth => 'صحت';

  @override
  String get categoryIdDocument => 'شناختی دستاویز';

  @override
  String get categoryWarranty => 'وارنٹی';

  @override
  String get categoryOther => 'دیگر';

  @override
  String get settingsLanguage => 'زبان';

  @override
  String get languageDevice => 'فون کے مطابق';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageUrdu => 'اردو';

  @override
  String get settingsTheme => 'تھیم';

  @override
  String get themeSystem => 'فون کے مطابق';

  @override
  String get themeLight => 'روشن';

  @override
  String get themeDark => 'گہرا';

  @override
  String get settingsLargeText => 'بڑا متن';

  @override
  String get settingsLargeTextHint =>
      'متن کو فون کی ترتیب سے 30 فیصد بڑا کرتا ہے';

  @override
  String get settingsLicenses => 'اوپن سورس لائسنس';

  @override
  String get vaultOpening => 'آپ کی چیزیں کھولی جا رہی ہیں';

  @override
  String get vaultTryAgainTitle => 'یادی آپ کی چیزیں نہیں کھول سکا';

  @override
  String get vaultKeyUnavailableBody =>
      'فون کی محفوظ کلید اسٹوریج نے جواب نہیں دیا۔ یہ عموماً عارضی ہوتا ہے۔ آپ کی چیزوں میں کوئی تبدیلی نہیں ہوئی۔';

  @override
  String get vaultUnexpectedBody =>
      'آپ کی چیزیں کھولتے وقت کچھ غلط ہو گیا۔ آپ کی چیزوں میں کوئی تبدیلی نہیں ہوئی۔';

  @override
  String get vaultTryAgain => 'دوبارہ کوشش کریں';

  @override
  String get vaultRecoveryTitle => 'آپ کی چیزیں نہیں کھل سکتیں';

  @override
  String get vaultKeyMissingBody =>
      'آپ کی محفوظ چیزیں کھولنے والی کلید اب اس فون پر موجود نہیں۔ ایسا تب ہوتا ہے جب یادی کا ڈیٹا نئے فون پر بحال کیا جائے یا فون کی کلید اسٹوریج صاف ہو جائے۔ یہ چیزیں واپس نہیں لائی جا سکتیں۔';

  @override
  String get vaultWrongKeyBody =>
      'اس فون کی کلید سے آپ کی محفوظ چیزیں پڑھی نہیں جا سکیں۔ ممکن ہے فائل خراب ہو گئی ہو۔ یہ چیزیں واپس نہیں لائی جا سکتیں۔';

  @override
  String get vaultReset => 'سب حذف کر کے نئے سرے سے شروع کریں';

  @override
  String get vaultResetConfirmTitle => 'سب کچھ حذف کریں؟';

  @override
  String get vaultResetConfirmBody =>
      'اس سے اس فون پر یادی میں محفوظ تمام چیزیں ہمیشہ کے لیے حذف ہو جائیں گی۔ یہ واپس نہیں ہو سکتا۔';

  @override
  String get vaultResetConfirm => 'سب کچھ حذف کریں';

  @override
  String get cancel => 'منسوخ کریں';

  @override
  String get vaultUpdateTitle => 'یادی اپ ڈیٹ کریں';

  @override
  String get vaultUpdateBody =>
      'آپ کی چیزیں یادی کے نئے ورژن نے محفوظ کی ہیں۔ انہیں کھولنے کے لیے تازہ ترین ورژن انسٹال کریں۔ کچھ بھی حذف نہیں ہوا۔';

  @override
  String get vaultBuildErrorTitle => 'یہ بلڈ آپ کی چیزوں کی حفاظت نہیں کر سکتا';

  @override
  String get vaultBuildErrorBody =>
      'یادی کے اس بلڈ میں انکرپشن نہیں ہے، اس لیے یہ آپ کا والٹ نہ کھولے گا نہ بنائے گا۔ سرکاری بلڈ انسٹال کریں۔';

  @override
  String get demoBadge => 'ڈیمو';

  @override
  String get webDemoNotice =>
      'فرضی خاندانوں کے ساتھ ڈیمو۔ آپ جو لکھیں وہ اسی براؤزر میں رہتا ہے، انکرپٹ نہیں ہوتا اور ہمیں نہیں بھیجا جاتا۔ اصلی شناختی نمبر نہ لکھیں۔ یہ ڈیمو GitHub Pages پر ہے، جو معیاری رسائی لاگ رکھتا ہے۔';
}
