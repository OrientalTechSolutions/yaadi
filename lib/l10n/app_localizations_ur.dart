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

  @override
  String get webDemoNoticeShort =>
      'فرضی خاندانوں کا ڈیمو۔ انکرپٹ نہیں ہوتا: اصلی شناختی نمبر نہ لکھیں۔';

  @override
  String get demoNoticeDetails => 'تفصیل';

  @override
  String get webDemoNotSaving =>
      'یہ براؤزر ڈیمو محفوظ نہیں کر رہا؛ دوبارہ لوڈ کرنے پر یہ نئے سرے سے شروع ہو گا۔';

  @override
  String get morningSummaryTitle => 'صبح کا خلاصہ';

  @override
  String get summaryQuietToday => 'آج کچھ واجب نہیں';

  @override
  String summaryOverdue(int others, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: 'زائد المیعاد: $title اور $others مزید',
      one: 'زائد المیعاد: $title اور 1 مزید',
      zero: 'زائد المیعاد: $title',
    );
    return '$_temp0';
  }

  @override
  String summaryToConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تصدیق باقی: $count گزری چیزیں',
      one: 'تصدیق باقی: 1 گزری چیز',
    );
    return '$_temp0';
  }

  @override
  String summaryToday(String details) {
    return 'آج: $details';
  }

  @override
  String summaryMoreToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'آج: $count مزید',
      one: 'آج: 1 مزید',
    );
    return '$_temp0';
  }

  @override
  String summaryDoses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'دوا: آج $count اوقات',
      one: 'دوا: آج 1 وقت',
    );
    return '$_temp0';
  }

  @override
  String summaryComingUp(String date, String title) {
    return 'آگے: $title · $date';
  }

  @override
  String summaryToPay(String amounts, String date) {
    return '$date تک ادائیگی: $amounts';
  }

  @override
  String summaryUnknownAmounts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count رقمیں ابھی معلوم نہیں',
      one: '1 رقم ابھی معلوم نہیں',
    );
    return '$_temp0';
  }

  @override
  String get navItems => 'چیزیں';

  @override
  String get navSearch => 'تلاش';

  @override
  String get addItem => 'چیز شامل کریں';

  @override
  String get editItem => 'چیز میں ترمیم';

  @override
  String get todayAllDoneTitle => 'سب کچھ مکمل';

  @override
  String get todayAllDoneBody =>
      'ابھی کچھ باقی نہیں۔ ادا شدہ اور مکمل چیزیں «چیزیں» میں ہیں۔';

  @override
  String get tryDemo => 'ڈیمو گھرانہ دیکھیں';

  @override
  String get sectionToConfirm => 'کیا یہ ہو گیا؟';

  @override
  String get sectionOverdue => 'زائد المیعاد';

  @override
  String get sectionToday => 'آج';

  @override
  String get sectionNextWeek => 'اگلے 7 دن';

  @override
  String get sectionExpiringSoon => 'میعاد جلد ختم';

  @override
  String get sectionLater => 'بعد میں';

  @override
  String sectionLabel(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count چیزیں',
      one: '1 چیز',
    );
    return '$title، $_temp0';
  }

  @override
  String get amountNotKnown => 'رقم ابھی معلوم نہیں';

  @override
  String get dosesToday => 'آج دوا کے اوقات';

  @override
  String startsOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMEd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString سے شروع';
  }

  @override
  String snoozedTo(DateTime date, DateTime due) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMEd(localeName);
    final String dateString = dateDateFormat.format(date);
    final intl.DateFormat dueDateFormat = intl.DateFormat.MMMd(localeName);
    final String dueString = dueDateFormat.format(due);

    return '$dateString تک مؤخر · اصل تاریخ $dueString';
  }

  @override
  String expiredDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days دن پہلے میعاد ختم ہوئی',
      one: 'کل میعاد ختم ہوئی',
    );
    return '$_temp0';
  }

  @override
  String get expiresToday => 'آج میعاد ختم';

  @override
  String expiresInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days دن میں میعاد ختم',
      one: 'کل میعاد ختم',
    );
    return '$_temp0';
  }

  @override
  String get wasYesterday => 'کل تھا';

  @override
  String wasOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMEd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString کو تھا';
  }

  @override
  String overdueByDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'تاریخ کو $days دن گزر گئے',
      one: 'تاریخ کو 1 دن گزر گیا',
    );
    return '$_temp0';
  }

  @override
  String get dueToday => 'آج واجب الادا';

  @override
  String get whenToday => 'آج';

  @override
  String get dueTomorrow => 'کل واجب الادا';

  @override
  String get whenTomorrow => 'کل';

  @override
  String inDays(int days, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMEd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$days دن بعد · $dateString';
  }

  @override
  String onDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMEd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String onDateWithYear(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMEd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get actionPaid => 'ادا ہو گیا';

  @override
  String get actionDone => 'ہو گیا';

  @override
  String get actionSnooze => 'مؤخر کریں';

  @override
  String get actionReschedule => 'نئی تاریخ';

  @override
  String markPaidLabel(String title) {
    return '$title کو ادا شدہ نشان زد کریں';
  }

  @override
  String markDoneLabel(String title) {
    return '$title کو مکمل نشان زد کریں';
  }

  @override
  String snoozeLabel(String title) {
    return '$title کو مؤخر کریں';
  }

  @override
  String rescheduleLabel(String title) {
    return '$title کی نئی تاریخ رکھیں';
  }

  @override
  String get rescheduleTo => 'کس دن پر منتقل کریں؟';

  @override
  String movedTo(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMEd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString پر منتقل';
  }

  @override
  String snoozedUntil(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMEd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString تک مؤخر';
  }

  @override
  String snoozeDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days دن',
      one: '1 دن',
    );
    return '$_temp0';
  }

  @override
  String get snoozeWeek => '1 ہفتہ';

  @override
  String get markedPaid => 'ادا شدہ نشان زد';

  @override
  String get markedDone => 'مکمل نشان زد';

  @override
  String doseMarked(String time) {
    return '$time نشان زد';
  }

  @override
  String doseMarkedLabel(String title, String time) {
    return '$title، $time، نشان زد';
  }

  @override
  String doseNotMarkedLabel(String title, String time) {
    return '$title، $time، ابھی نشان زد نہیں';
  }

  @override
  String get undo => 'واپس کریں';

  @override
  String get undoRefused => 'اس دوران تبدیلی ہو چکی، اس لیے واپس نہیں ہوا';

  @override
  String get notSaved => 'محفوظ نہیں ہو سکا۔ دوبارہ کوشش کریں۔';

  @override
  String get actionStale =>
      'اس دوران یہ چیز بدل چکی تھی، اس لیے کچھ محفوظ نہیں ہوا۔';

  @override
  String get reopenPaid => 'ادائیگی کا نشان ہٹائیں';

  @override
  String get reopenDone => 'مکمل کا نشان ہٹائیں';

  @override
  String get reopenSkipped => 'چھوڑنے کا نشان ہٹائیں';

  @override
  String get reopened => 'دوبارہ باقی';

  @override
  String get catchUpChange => 'تبدیل کریں';

  @override
  String catchUpMarkedPaid(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'پچھلے $count بل ادا شدہ درج ہوئے۔',
      one: 'پچھلا 1 بل ادا شدہ درج ہوا۔',
    );
    return '$_temp0';
  }

  @override
  String catchUpSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'پچھلی $count قسطیں چھوڑ دی گئیں۔',
      one: 'پچھلی 1 قسط چھوڑ دی گئی۔',
    );
    return '$_temp0';
  }

  @override
  String catchUpStillOwed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مزید ادائیگیاں باقی ہیں۔',
      one: '1 مزید ادائیگی باقی ہے۔',
    );
    return '$_temp0';
  }

  @override
  String catchUpKeepUnpaid(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'پچھلی $count ادائیگیاں باقی رہنے دیں',
      one: 'پچھلی 1 ادائیگی باقی رہنے دیں',
    );
    return '$_temp0';
  }

  @override
  String catchUpMarkEarlierPaid(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'پچھلی $count قسطیں ادا شدہ نشان زد کریں',
      one: 'پچھلی 1 قسط ادا شدہ نشان زد کریں',
    );
    return '$_temp0';
  }

  @override
  String get catchUpSkipToCurrent => 'موجودہ پر چلے جائیں';

  @override
  String catchUpQuestion(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'درمیان میں رہ جانے والی $count ادائیگیوں کا کیا کریں؟',
      one: 'درمیان میں رہ جانے والی 1 ادائیگی کا کیا کریں؟',
    );
    return '$_temp0';
  }

  @override
  String get catchUpUpdated => 'تبدیل ہو گیا';

  @override
  String get itemsEmpty => 'ابھی کوئی چیز نہیں';

  @override
  String get itemsNoMatch => 'ان فلٹرز کے مطابق کوئی چیز نہیں';

  @override
  String get filterOpen => 'باقی';

  @override
  String get filterClosed => 'ادا شدہ اور مکمل';

  @override
  String get filterAll => 'سب';

  @override
  String get filterAllKinds => 'ہر قسم';

  @override
  String get statusOpen => 'باقی';

  @override
  String get statusPaid => 'ادا شدہ';

  @override
  String get statusDone => 'مکمل';

  @override
  String get outcomeSkipped => 'چھوڑ دیا';

  @override
  String get repeatNone => 'دہرایا نہیں جاتا';

  @override
  String get repeatDaily => 'روزانہ';

  @override
  String get repeatWeekly => 'ہر ہفتے';

  @override
  String get repeatMonthly => 'ہر مہینے';

  @override
  String get repeatYearly => 'ہر سال';

  @override
  String get repeatDoses => 'روزانہ دوا کے اوقات';

  @override
  String repeatWeeklyOn(String weekday) {
    return 'ہر ہفتے $weekday کو';
  }

  @override
  String repeatMonthlyOn(int day) {
    return 'ہر مہینے کی $day تاریخ';
  }

  @override
  String repeatMonthlyOnLate(int day) {
    return 'ہر مہینے کی $day تاریخ، چھوٹے مہینوں میں آخری دن';
  }

  @override
  String repeatYearlyOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'ہر سال $dateString';
  }

  @override
  String repeatDosesAt(String times) {
    return 'روزانہ $times';
  }

  @override
  String get repeatUnsupported =>
      'اس طرح دہرایا جاتا ہے جو یہ ورژن نہیں دکھا سکتا';

  @override
  String repeatUntil(String rule, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$rule، $dateString تک';
  }

  @override
  String get itemGone => 'یہ چیز حذف ہو چکی ہے';

  @override
  String get edit => 'ترمیم';

  @override
  String get delete => 'حذف کریں';

  @override
  String get repeatUnsupportedNotice =>
      'یہ یادی کے نئے ورژن میں بنی ہے۔ اسے بدلنے کے لیے ایپ اپ ڈیٹ کریں۔';

  @override
  String get factMoved => 'منتقل';

  @override
  String movedFrom(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'صرف اس بار، $dateString سے';
  }

  @override
  String get factSnoozed => 'اس تاریخ تک مؤخر';

  @override
  String get factRepeat => 'دہرانا';

  @override
  String get fieldAmount => 'رقم';

  @override
  String get amountVaries => 'ہر بار بدلتی ہے';

  @override
  String get fieldNotes => 'نوٹس';

  @override
  String get fieldReference => 'حوالہ نمبر';

  @override
  String get markPaidButton => 'ادا شدہ نشان زد کریں';

  @override
  String get markDoneButton => 'مکمل نشان زد کریں';

  @override
  String get historyTitle => 'پچھلا ریکارڈ';

  @override
  String addedAndChanged(DateTime created, DateTime changed) {
    final intl.DateFormat createdDateFormat = intl.DateFormat.yMMMd(localeName);
    final String createdString = createdDateFormat.format(created);
    final intl.DateFormat changedDateFormat = intl.DateFormat.yMMMd(localeName);
    final String changedString = changedDateFormat.format(changed);

    return 'شامل: $createdString · تبدیلی: $changedString';
  }

  @override
  String get fieldDueDate => 'آخری تاریخ';

  @override
  String get fieldExpiresOn => 'میعاد ختم ہونے کی تاریخ';

  @override
  String get fieldFirstDay => 'پہلا دن';

  @override
  String get fieldDate => 'تاریخ';

  @override
  String get fieldDateOptional => 'تاریخ (اختیاری)';

  @override
  String get deleted => 'حذف ہو گیا';

  @override
  String get changedSince =>
      'آپ کے کھولنے کے بعد یہ چیز بدل چکی ہے۔ کچھ حذف نہیں ہوا۔';

  @override
  String referenceShownLabel(String reference) {
    return 'حوالہ نمبر $reference';
  }

  @override
  String get referenceHiddenLabel => 'حوالہ نمبر، چھپا ہوا';

  @override
  String get referenceShow => 'دکھائیں';

  @override
  String get referenceHide => 'چھپائیں';

  @override
  String get referenceHint =>
      'کنزیومر نمبر، شناختی کارڈ نمبر یا ایسا ہی کوئی نمبر۔ «دکھائیں» دبانے تک چھپا رہتا ہے۔';

  @override
  String get referenceDemoHint => 'ڈیمو: کوئی فرضی نمبر لکھیں۔';

  @override
  String get fieldKind => 'یہ کیا ہے؟';

  @override
  String get fieldTitle => 'عنوان';

  @override
  String get titleHintBill => 'مثلاً LESCO بل';

  @override
  String get titleHintAppointment => 'مثلاً دانتوں کا ڈاکٹر';

  @override
  String get titleHintExpiry => 'مثلاً ابو کا شناختی کارڈ';

  @override
  String get titleHintMedicine => 'مثلاً امی کی گولیاں';

  @override
  String get titleHintTask => 'مثلاً لائبریری کارڈ کی تجدید';

  @override
  String get fieldCategory => 'زمرہ';

  @override
  String get fieldCurrency => 'کرنسی';

  @override
  String get amountHint => 'معلوم نہ ہو تو خالی چھوڑ دیں';

  @override
  String get amountVariesSwitch => 'رقم ہر بار بدلتی ہے';

  @override
  String get amountVariesHint =>
      'جیسے بجلی یا گیس۔ ہر نئے بل کی اپنی رقم ہوتی ہے۔';

  @override
  String get chooseDate => 'ابھی نہیں چنی';

  @override
  String get moveSeriesTitle => 'نئی تاریخ سے دہرائیں';

  @override
  String moveSeriesHint(String rule) {
    return 'بند ہو تو صرف اس بار کی تاریخ بدلے گی۔ آگے بدستور: $rule۔';
  }

  @override
  String get fieldTime => 'وقت';

  @override
  String get noTime => 'کوئی وقت نہیں';

  @override
  String get fieldRepeat => 'دہرائیں';

  @override
  String get fieldLastDay => 'آخری دن (اختیاری)';

  @override
  String get fieldEndsOn => 'ختم ہونے کی تاریخ (اختیاری)';

  @override
  String get noEndDate => 'کوئی آخری تاریخ نہیں';

  @override
  String get fieldDoseTimes => 'روزانہ کے اوقات';

  @override
  String removeTime(String time) {
    return '$time ہٹائیں';
  }

  @override
  String get addTime => 'وقت شامل کریں';

  @override
  String get doseTimesNote =>
      'یادی صرف وہی اوقات یاد دلاتا ہے جو آپ لکھیں۔ یہ کبھی کوئی دوا، خوراک یا وقت تجویز نہیں کرتا۔';

  @override
  String get save => 'محفوظ کریں';

  @override
  String get added => 'شامل ہو گیا';

  @override
  String get saved => 'محفوظ ہو گیا';

  @override
  String get saveConflict =>
      'آپ کی ترمیم کے دوران یہ چیز بدل گئی۔ آپ کی تبدیلیاں محفوظ نہیں ہوئیں۔';

  @override
  String get misplacedTitle => 'یہ نمبر حوالہ نمبر میں منتقل کریں؟';

  @override
  String get misplacedInTitle =>
      'لگتا ہے عنوان میں کوئی شناختی یا اکاؤنٹ نمبر ہے۔ حوالہ نمبر میں یہ «دکھائیں» دبانے تک چھپا رہتا ہے۔';

  @override
  String get misplacedInNotes =>
      'لگتا ہے نوٹس میں کوئی شناختی یا اکاؤنٹ نمبر ہے۔ حوالہ نمبر میں یہ «دکھائیں» دبانے تک چھپا رہتا ہے۔';

  @override
  String get misplacedKeep => 'وہیں رہنے دیں';

  @override
  String get misplacedMove => 'حوالہ نمبر میں منتقل کریں';

  @override
  String get discardTitle => 'اپنی تبدیلیاں چھوڑ دیں؟';

  @override
  String get keepEditing => 'ترمیم جاری رکھیں';

  @override
  String get discard => 'چھوڑ دیں';

  @override
  String get problemTitleRequired => 'عنوان لکھیں';

  @override
  String get problemDoseTimesRequired => 'کم از کم ایک وقت شامل کریں';

  @override
  String get problemDateRequired => 'تاریخ چنیں';

  @override
  String get problemTooLong => 'یہ بہت لمبا ہے';

  @override
  String problemAmount(String example) {
    return 'رقم اس طرح لکھیں: $example';
  }

  @override
  String get problemEndBeforeStart => 'آخری تاریخ پہلی تاریخ سے پہلے ہے';

  @override
  String editorProblems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count خانے درست کریں',
      one: '1 خانہ درست کریں',
    );
    return '$_temp0';
  }

  @override
  String fieldWithProblem(String label, String problem) {
    return '$label، $problem';
  }

  @override
  String expiresOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'میعاد $dateString تک';
  }

  @override
  String clearField(String label) {
    return '$label صاف کریں';
  }

  @override
  String get searchHint => 'تلاش: bijli، گیس، school fee';

  @override
  String get clearSearch => 'تلاش صاف کریں';

  @override
  String get searchNoResults => 'کچھ نہیں ملا';

  @override
  String get searchNoResultsHint =>
      'کوئی اور ہجے آزمائیں، یا یہی لفظ اردو یا انگریزی میں۔';

  @override
  String searchResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نتائج',
      one: '1 نتیجہ',
    );
    return '$_temp0';
  }

  @override
  String get searchExplain =>
      'تلاش آف لائن کام کرتی ہے اور انگریزی، اردو اور رومن اردو سمجھتی ہے: bijli، بجلی اور electricity تینوں سے بجلی کا بل مل جاتا ہے۔';

  @override
  String get searchTry => 'آزمائیں';

  @override
  String phoneDemoNotice(String household) {
    return 'آپ $household کا ڈیمو دیکھ رہے ہیں۔ تبدیلیاں محفوظ نہیں ہوتیں اور آپ کی اپنی چیزیں جوں کی توں ہیں۔';
  }

  @override
  String get leaveDemo => 'ڈیمو بند کریں';

  @override
  String get householdKhan => 'خان فیملی، لاہور';

  @override
  String get householdTaylor => 'ٹیلر فیملی، مانچسٹر';

  @override
  String get householdKhanDescription =>
      'بل، اسکول فیس، شناختی کارڈ اور امی کی دوا کے اوقات، اردو اور انگریزی میں۔ روپے۔';

  @override
  String get householdTaylorDescription =>
      'کونسل ٹیکس، بجلی، دانتوں کا ڈاکٹر، پاسپورٹ اور دوا کے اوقات۔ پاؤنڈ۔';

  @override
  String get pickerTitle => 'ایک فرضی خاندان کے ساتھ یادی آزمائیں';

  @override
  String get pickerBody =>
      'ایک گھرانہ چنیں اور دیکھیں کہ یادی بل، اپوائنٹمنٹ، میعاد کی تاریخیں اور دوا کے اوقات کیسے سنبھالتا ہے۔ اس کے سب لوگ فرضی ہیں۔';

  @override
  String get demoExplain =>
      'ڈیمو گھرانے فرضی ہیں۔ جب تک کوئی ڈیمو کھلا ہو، آپ کی اپنی چیزیں جوں کی توں رہتی ہیں اور ڈیمو میں کی گئی کوئی تبدیلی محفوظ نہیں ہوتی۔';

  @override
  String get webDemoExplain =>
      'یہ ویب ڈیمو ایک فرضی خاندان دکھاتا ہے۔ گھرانہ بدلنے سے ڈیمو نئے سرے سے شروع ہوتا ہے۔';

  @override
  String get settingsDemo => 'ڈیمو گھرانے';

  @override
  String get demoOwnItems => 'میری اپنی چیزیں';

  @override
  String get clearDemo => 'ڈیمو ڈیٹا صاف کریں';

  @override
  String get settingsYourData => 'آپ کا ڈیٹا';

  @override
  String get deleteAll => 'میری تمام چیزیں حذف کریں';

  @override
  String get deleteAllHint =>
      'اس فون پر یادی میں محفوظ سب کچھ ہمیشہ کے لیے حذف کرتا ہے';

  @override
  String get settingsAbout => 'تعارف';

  @override
  String aboutVersion(String version) {
    return 'یادی $version';
  }

  @override
  String get aboutBody =>
      'کاغذ سے یاد دہانی تک۔ بل، اپوائنٹمنٹ، میعاد کی تاریخیں اور دوا کے اوقات، آف لائن، اردو اور انگریزی میں۔';

  @override
  String aboutMaker(String maker) {
    return '$maker کی تیار کردہ';
  }

  @override
  String get aboutHire => 'Upwork پر ہماری خدمات حاصل کریں';

  @override
  String get linkFailed => 'لنک نہیں کھل سکا۔';
}
