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
  String get webDemoNoticeShort =>
      'Demo with made-up families. Not encrypted: do not enter real ID numbers.';

  @override
  String get demoNoticeDetails => 'Details';

  @override
  String get webDemoNotSaving =>
      'This browser is not saving the demo; it will reset when you reload.';

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
  String summaryComingUp(String date, String title) {
    return 'Coming up: $title, $date';
  }

  @override
  String summaryToPay(String amounts, String date) {
    return 'To pay by $date: $amounts';
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

  @override
  String get navItems => 'Items';

  @override
  String get navSearch => 'Search';

  @override
  String get addItem => 'Add item';

  @override
  String get editItem => 'Edit item';

  @override
  String get todayAllDoneTitle => 'All caught up';

  @override
  String get todayAllDoneBody =>
      'Nothing is open right now. Paid and done items are under Items.';

  @override
  String get tryDemo => 'Try a demo household';

  @override
  String get sectionToConfirm => 'Did these happen?';

  @override
  String get sectionOverdue => 'Overdue';

  @override
  String get sectionToday => 'Today';

  @override
  String get sectionNextWeek => 'Next 7 days';

  @override
  String get sectionExpiringSoon => 'Expiring soon';

  @override
  String get sectionLater => 'Later';

  @override
  String sectionLabel(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$title, $_temp0';
  }

  @override
  String get amountNotKnown => 'Amount not known yet';

  @override
  String get dosesToday => 'Medicine times today';

  @override
  String startsOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMEd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Starts $dateString';
  }

  @override
  String snoozedTo(DateTime date, DateTime due) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMEd(localeName);
    final String dateString = dateDateFormat.format(date);
    final intl.DateFormat dueDateFormat = intl.DateFormat.MMMd(localeName);
    final String dueString = dueDateFormat.format(due);

    return 'Snoozed to $dateString · due $dueString';
  }

  @override
  String expiredDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Expired $days days ago',
      one: 'Expired yesterday',
    );
    return '$_temp0';
  }

  @override
  String get expiresToday => 'Expires today';

  @override
  String expiresInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Expires in $days days',
      one: 'Expires tomorrow',
    );
    return '$_temp0';
  }

  @override
  String get wasYesterday => 'Was yesterday';

  @override
  String wasOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMEd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Was on $dateString';
  }

  @override
  String overdueByDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Overdue by $days days',
      one: 'Overdue by 1 day',
    );
    return '$_temp0';
  }

  @override
  String get dueToday => 'Due today';

  @override
  String get whenToday => 'Today';

  @override
  String get dueTomorrow => 'Due tomorrow';

  @override
  String get whenTomorrow => 'Tomorrow';

  @override
  String inDays(int days, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMEd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'In $days days · $dateString';
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
  String get actionPaid => 'Paid';

  @override
  String get actionDone => 'Done';

  @override
  String get actionSnooze => 'Snooze';

  @override
  String get actionReschedule => 'Reschedule';

  @override
  String markPaidLabel(String title) {
    return 'Mark $title as paid';
  }

  @override
  String markDoneLabel(String title) {
    return 'Mark $title as done';
  }

  @override
  String snoozeLabel(String title) {
    return 'Snooze $title';
  }

  @override
  String rescheduleLabel(String title) {
    return 'Reschedule $title';
  }

  @override
  String get rescheduleTo => 'Move to which day?';

  @override
  String movedTo(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMEd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Moved to $dateString';
  }

  @override
  String snoozedUntil(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMEd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Snoozed until $dateString';
  }

  @override
  String snoozeDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get snoozeWeek => '1 week';

  @override
  String get markedPaid => 'Marked as paid';

  @override
  String get markedDone => 'Marked as done';

  @override
  String doseMarked(String time) {
    return '$time marked';
  }

  @override
  String doseMarkedLabel(String title, String time) {
    return '$title, $time, marked';
  }

  @override
  String doseNotMarkedLabel(String title, String time) {
    return '$title, $time, not marked yet';
  }

  @override
  String get undo => 'Undo';

  @override
  String get undoRefused => 'Changed since, so it was not undone';

  @override
  String get notSaved => 'Could not save. Try again.';

  @override
  String get actionStale =>
      'This item changed in the meantime, so nothing was saved.';

  @override
  String get reopenPaid => 'Mark as not paid';

  @override
  String get reopenDone => 'Mark as not done';

  @override
  String get reopenSkipped => 'Mark as not skipped';

  @override
  String get reopened => 'Due again';

  @override
  String get catchUpChange => 'Change';

  @override
  String catchUpMarkedPaid(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count earlier bills recorded as paid.',
      one: '1 earlier bill recorded as paid.',
    );
    return '$_temp0';
  }

  @override
  String catchUpSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count earlier ones skipped.',
      one: '1 earlier one skipped.',
    );
    return '$_temp0';
  }

  @override
  String catchUpStillOwed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more are still to pay.',
      one: '1 more is still to pay.',
    );
    return '$_temp0';
  }

  @override
  String catchUpKeepUnpaid(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Keep $count earlier ones unpaid',
      one: 'Keep the earlier one unpaid',
    );
    return '$_temp0';
  }

  @override
  String catchUpMarkEarlierPaid(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mark $count earlier ones as paid',
      one: 'Mark the earlier one as paid',
    );
    return '$_temp0';
  }

  @override
  String get catchUpSkipToCurrent => 'Skip to the current one';

  @override
  String catchUpQuestion(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'What about the $count missed in between?',
      one: 'What about the 1 missed in between?',
    );
    return '$_temp0';
  }

  @override
  String get catchUpUpdated => 'Updated';

  @override
  String get itemsEmpty => 'No items yet';

  @override
  String get itemsNoMatch => 'No items match these filters';

  @override
  String get filterOpen => 'Open';

  @override
  String get filterClosed => 'Paid and done';

  @override
  String get filterAll => 'All';

  @override
  String get filterAllKinds => 'All kinds';

  @override
  String get statusOpen => 'Open';

  @override
  String get statusPaid => 'Paid';

  @override
  String get statusDone => 'Done';

  @override
  String get outcomeSkipped => 'Skipped';

  @override
  String get repeatNone => 'Does not repeat';

  @override
  String get repeatDaily => 'Every day';

  @override
  String get repeatWeekly => 'Every week';

  @override
  String get repeatMonthly => 'Every month';

  @override
  String get repeatYearly => 'Every year';

  @override
  String get repeatDoses => 'Medicine times every day';

  @override
  String repeatWeeklyOn(String weekday) {
    return 'Every week on $weekday';
  }

  @override
  String repeatMonthlyOn(int day) {
    return 'Every month on day $day';
  }

  @override
  String repeatMonthlyOnLate(int day) {
    return 'Every month on day $day, or the last day of shorter months';
  }

  @override
  String repeatYearlyOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Every year on $dateString';
  }

  @override
  String repeatDosesAt(String times) {
    return 'Every day at $times';
  }

  @override
  String get repeatUnsupported => 'Repeats in a way this version cannot show';

  @override
  String repeatUntil(String rule, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$rule, until $dateString';
  }

  @override
  String get itemGone => 'This item has been deleted';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get repeatUnsupportedNotice =>
      'Made by a newer version of Yaadi. Update the app to change it.';

  @override
  String get factMoved => 'Moved';

  @override
  String movedFrom(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'This time only, from $dateString';
  }

  @override
  String get factSnoozed => 'Snoozed until';

  @override
  String get factRepeat => 'Repeats';

  @override
  String get fieldAmount => 'Amount';

  @override
  String get amountVaries => 'Changes each time';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get fieldReference => 'Reference number';

  @override
  String get markPaidButton => 'Mark as paid';

  @override
  String get markDoneButton => 'Mark as done';

  @override
  String get historyTitle => 'History';

  @override
  String addedAndChanged(DateTime created, DateTime changed) {
    final intl.DateFormat createdDateFormat = intl.DateFormat.yMMMd(localeName);
    final String createdString = createdDateFormat.format(created);
    final intl.DateFormat changedDateFormat = intl.DateFormat.yMMMd(localeName);
    final String changedString = changedDateFormat.format(changed);

    return 'Added $createdString · Changed $changedString';
  }

  @override
  String get fieldDueDate => 'Due date';

  @override
  String get fieldExpiresOn => 'Expires on';

  @override
  String get fieldFirstDay => 'First day';

  @override
  String get fieldDate => 'Date';

  @override
  String get fieldDateOptional => 'Date (optional)';

  @override
  String get deleted => 'Deleted';

  @override
  String get changedSince =>
      'This item changed since you opened it. Nothing was deleted.';

  @override
  String referenceShownLabel(String reference) {
    return 'Reference $reference';
  }

  @override
  String get referenceHiddenLabel => 'Reference, hidden';

  @override
  String get referenceShow => 'Show';

  @override
  String get referenceHide => 'Hide';

  @override
  String get referenceHint =>
      'Consumer number, CNIC or similar. Hidden until you tap Show.';

  @override
  String get referenceDemoHint => 'Demo: use a made-up number.';

  @override
  String get fieldKind => 'What is it?';

  @override
  String get fieldTitle => 'Title';

  @override
  String get titleHintBill => 'For example, LESCO bill';

  @override
  String get titleHintAppointment => 'For example, dentist';

  @override
  String get titleHintExpiry => 'For example, Abbu\'s CNIC';

  @override
  String get titleHintMedicine => 'For example, Ammi\'s tablets';

  @override
  String get titleHintTask => 'For example, renew the library card';

  @override
  String get fieldCategory => 'Category';

  @override
  String get fieldCurrency => 'Currency';

  @override
  String get amountHint => 'Leave empty if not known yet';

  @override
  String get amountVariesSwitch => 'Amount changes each time';

  @override
  String get amountVariesHint =>
      'Like electricity or gas. Each new bill needs its own amount.';

  @override
  String get chooseDate => 'Not chosen yet';

  @override
  String get moveSeriesTitle => 'Repeat from the new date';

  @override
  String moveSeriesHint(String rule) {
    return 'When off, only this time moves. It still repeats: $rule.';
  }

  @override
  String get fieldTime => 'Time';

  @override
  String get noTime => 'No time';

  @override
  String get fieldRepeat => 'Repeat';

  @override
  String get fieldLastDay => 'Last day (optional)';

  @override
  String get fieldEndsOn => 'Ends on (optional)';

  @override
  String get noEndDate => 'No end date';

  @override
  String get fieldDoseTimes => 'Times each day';

  @override
  String removeTime(String time) {
    return 'Remove $time';
  }

  @override
  String get addTime => 'Add a time';

  @override
  String get doseTimesNote =>
      'Yaadi reminds you of the times you type. It never suggests a medicine, a dose or a time.';

  @override
  String get save => 'Save';

  @override
  String get added => 'Added';

  @override
  String get saved => 'Saved';

  @override
  String get saveConflict =>
      'This item changed while you were editing. Your changes were not saved.';

  @override
  String get misplacedTitle => 'Move this number to Reference?';

  @override
  String get misplacedInTitle =>
      'The title seems to contain an ID or account number. In Reference it stays hidden until you tap Show.';

  @override
  String get misplacedInNotes =>
      'The notes seem to contain an ID or account number. In Reference it stays hidden until you tap Show.';

  @override
  String get misplacedKeep => 'Leave it there';

  @override
  String get misplacedMove => 'Move to Reference';

  @override
  String get discardTitle => 'Discard your changes?';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get discard => 'Discard';

  @override
  String get problemTitleRequired => 'Enter a title';

  @override
  String get problemDoseTimesRequired => 'Add at least one time';

  @override
  String get problemDateRequired => 'Choose a date';

  @override
  String get problemTooLong => 'This is too long';

  @override
  String problemAmount(String example) {
    return 'Enter an amount like $example';
  }

  @override
  String get problemEndBeforeStart => 'The end date is before the first date';

  @override
  String editorProblems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Check $count fields',
      one: 'Check 1 field',
    );
    return '$_temp0';
  }

  @override
  String fieldWithProblem(String label, String problem) {
    return '$label, $problem';
  }

  @override
  String expiresOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Expires $dateString';
  }

  @override
  String clearField(String label) {
    return 'Clear $label';
  }

  @override
  String get searchHint => 'Search: bijli, گیس, school fee';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get searchNoResults => 'Nothing found';

  @override
  String get searchNoResultsHint =>
      'Try another spelling, or the same word in Urdu or English.';

  @override
  String searchResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
    );
    return '$_temp0';
  }

  @override
  String get searchExplain =>
      'Search works offline and understands English, Urdu and Roman Urdu: bijli, بجلی and electricity all find the electricity bill.';

  @override
  String get searchTry => 'Try';

  @override
  String phoneDemoNotice(String household) {
    return 'You are looking at the $household demo. Changes are not kept, and your own items are untouched.';
  }

  @override
  String get leaveDemo => 'Leave demo';

  @override
  String get householdKhan => 'Khan family, Lahore';

  @override
  String get householdTaylor => 'Taylor family, Manchester';

  @override
  String get householdKhanDescription =>
      'Bills, a school fee, an ID card and Ammi\'s medicine times, in Urdu and English. Rupees.';

  @override
  String get householdTaylorDescription =>
      'Council tax, energy, the dentist, a passport and prescription times. Pounds.';

  @override
  String get pickerTitle => 'Try Yaadi with a made-up family';

  @override
  String get pickerBody =>
      'Pick a household to see how Yaadi keeps bills, appointments, expiry dates and medicine times. Everyone in it is invented.';

  @override
  String get demoExplain =>
      'Demo households are made up. While one is shown, your own items stay as they are, and nothing you change in the demo is kept.';

  @override
  String get webDemoExplain =>
      'This web demo shows a made-up family. Switching household starts it again from the beginning.';

  @override
  String get settingsDemo => 'Demo households';

  @override
  String get demoOwnItems => 'My own items';

  @override
  String get clearDemo => 'Clear demo data';

  @override
  String get settingsYourData => 'Your data';

  @override
  String get deleteAll => 'Delete all my items';

  @override
  String get deleteAllHint =>
      'Permanently deletes everything Yaadi keeps on this phone';

  @override
  String get settingsAbout => 'About';

  @override
  String aboutVersion(String version) {
    return 'Yaadi $version';
  }

  @override
  String get aboutBody =>
      'Paper to reminder. Bills, appointments, expiry dates and medicine times, offline, in English and Urdu.';

  @override
  String aboutMaker(String maker) {
    return 'Built by $maker';
  }

  @override
  String get aboutHire => 'Hire us on Upwork';

  @override
  String get linkFailed => 'The link could not be opened.';
}

/// The translations for English, as used in the United Kingdom (`en_GB`).
class AppLocalizationsEnGb extends AppLocalizationsEn {
  AppLocalizationsEnGb() : super('en_GB');
}
