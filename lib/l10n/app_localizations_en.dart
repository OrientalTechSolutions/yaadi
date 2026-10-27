// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Yaadi';

  @override
  String get navToday => 'Today';

  @override
  String get navSettings => 'Settings';

  @override
  String get todayEmptyTitle => 'Nothing here yet';

  @override
  String get todayEmptyBody =>
      'Bills, appointments, expiry dates, medicine times and tasks you add will show up here.';

  @override
  String get itemsLoadFailed => 'Your items could not be loaded.';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String dueOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Due $dateString';
  }

  @override
  String get noDueDate => 'No date';

  @override
  String get kindBill => 'Bill';

  @override
  String get kindAppointment => 'Appointment';

  @override
  String get kindExpiry => 'Expiry date';

  @override
  String get kindMedicine => 'Medicine';

  @override
  String get kindTask => 'Task';

  @override
  String get categoryElectricity => 'Electricity';

  @override
  String get categoryGas => 'Gas';

  @override
  String get categoryWater => 'Water';

  @override
  String get categoryInternet => 'Internet';

  @override
  String get categoryPhone => 'Phone';

  @override
  String get categorySchool => 'School';

  @override
  String get categoryRent => 'Rent';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryIdDocument => 'ID document';

  @override
  String get categoryWarranty => 'Warranty';

  @override
  String get categoryOther => 'Other';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageDevice => 'Same as phone';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageUrdu => 'اردو';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'Same as phone';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsLargeText => 'Large text';

  @override
  String get settingsLargeTextHint =>
      'Makes text 30% larger than the phone setting';

  @override
  String get settingsLicenses => 'Open-source licences';

  @override
  String get vaultOpening => 'Opening your items';

  @override
  String get vaultTryAgainTitle => 'Yaadi could not open your items';

  @override
  String get vaultKeyUnavailableBody =>
      'Your phone\'s secure key storage did not respond. This is usually temporary. Your items have not been changed.';

  @override
  String get vaultUnexpectedBody =>
      'Something went wrong while opening your items. Your items have not been changed.';

  @override
  String get vaultTryAgain => 'Try again';

  @override
  String get vaultRecoveryTitle => 'Your items cannot be opened';

  @override
  String get vaultKeyMissingBody =>
      'The key that unlocks your saved items is no longer on this phone. This happens when Yaadi\'s data is restored onto a new phone or the phone\'s key storage was cleared. These items cannot be recovered.';

  @override
  String get vaultWrongKeyBody =>
      'Your saved items could not be read with this phone\'s key. The file may be damaged. These items cannot be recovered.';

  @override
  String get vaultReset => 'Delete and start again';

  @override
  String get vaultResetConfirmTitle => 'Delete everything?';

  @override
  String get vaultResetConfirmBody =>
      'This permanently deletes every item saved in Yaadi on this phone. It cannot be undone.';

  @override
  String get vaultResetConfirm => 'Delete everything';

  @override
  String get cancel => 'Cancel';

  @override
  String get vaultUpdateTitle => 'Update Yaadi';

  @override
  String get vaultUpdateBody =>
      'Your items were saved by a newer version of Yaadi. Install the latest version to open them. Nothing has been deleted.';

  @override
  String get vaultBuildErrorTitle => 'This build cannot protect your items';

  @override
  String get vaultBuildErrorBody =>
      'This build of Yaadi has no encryption, so it will not open or create your vault. Install an official build.';

  @override
  String get demoBadge => 'Demo';

  @override
  String get webDemoNotice =>
      'Demo with made-up families. What you type stays in this browser, is not encrypted and is not sent to us. Do not enter real ID numbers. The demo is hosted on GitHub Pages, which keeps standard access logs.';

  @override
  String get morningSummaryTitle => 'Morning summary';

  @override
  String get summaryQuietToday => 'Nothing due today';

  @override
  String summaryOverdue(int others, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: 'Overdue: $title and $others more',
      one: 'Overdue: $title and 1 more',
      zero: 'Overdue: $title',
    );
    return '$_temp0';
  }

  @override
  String summaryToConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'To confirm: $count past items',
      one: 'To confirm: 1 past item',
    );
    return '$_temp0';
  }

  @override
  String summaryToday(String details) {
    return 'Today: $details';
  }

  @override
  String summaryMoreToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Today: $count more',
      one: 'Today: 1 more',
    );
    return '$_temp0';
  }

  @override
  String summaryDoses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Medicine: $count times today',
      one: 'Medicine: 1 time today',
    );
    return '$_temp0';
  }

  @override
  String summaryComingUp(DateTime date, String title) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMEd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Coming up: $title, $dateString';
  }

  @override
  String summaryToPay(String amounts, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMEd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'To pay by $dateString: $amounts';
  }

  @override
  String summaryUnknownAmounts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count amounts not known yet',
      one: '1 amount not known yet',
    );
    return '$_temp0';
  }
}
