import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('en', 'GB'),
    Locale('ur'),
  ];

  /// App name shown in the app bar and the task switcher.
  ///
  /// In en, this message translates to:
  /// **'Yaadi'**
  String get appTitle;

  /// Bottom navigation label for the Today screen.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// Bottom navigation label for the Settings screen.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Heading on the Today screen when there are no items.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get todayEmptyTitle;

  /// Explanation on the Today screen when there are no items.
  ///
  /// In en, this message translates to:
  /// **'Bills, appointments, expiry dates, medicine times and tasks you add will show up here.'**
  String get todayEmptyBody;

  /// Shown instead of the list when reading items failed.
  ///
  /// In en, this message translates to:
  /// **'Your items could not be loaded.'**
  String get itemsLoadFailed;

  /// Number of items in a list.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items} =1{1 item} other{{count} items}}'**
  String itemCount(int count);

  /// When an item is due, as a short label.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String dueOn(DateTime date);

  /// Label for a task that has no due date.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get noDueDate;

  /// Item kind: a bill to pay.
  ///
  /// In en, this message translates to:
  /// **'Bill'**
  String get kindBill;

  /// Item kind: an appointment, such as a doctor or dentist visit.
  ///
  /// In en, this message translates to:
  /// **'Appointment'**
  String get kindAppointment;

  /// Item kind: something that expires, such as an ID card, passport or warranty.
  ///
  /// In en, this message translates to:
  /// **'Expiry date'**
  String get kindExpiry;

  /// Item kind: medicine times the user typed in.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get kindMedicine;

  /// Item kind: a general task.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get kindTask;

  /// Item category.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get categoryElectricity;

  /// Item category.
  ///
  /// In en, this message translates to:
  /// **'Gas'**
  String get categoryGas;

  /// Item category.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get categoryWater;

  /// Item category.
  ///
  /// In en, this message translates to:
  /// **'Internet'**
  String get categoryInternet;

  /// Item category: mobile or landline phone bills.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get categoryPhone;

  /// Item category.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get categorySchool;

  /// Item category.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get categoryRent;

  /// Item category.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// Item category: identity documents such as a CNIC or passport.
  ///
  /// In en, this message translates to:
  /// **'ID document'**
  String get categoryIdDocument;

  /// Item category.
  ///
  /// In en, this message translates to:
  /// **'Warranty'**
  String get categoryWarranty;

  /// Item category for anything else.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// Settings section for the app language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Language option that follows the phone's language.
  ///
  /// In en, this message translates to:
  /// **'Same as phone'**
  String get languageDevice;

  /// The English language, written in English in every locale.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// The Urdu language, written in Urdu in every locale.
  ///
  /// In en, this message translates to:
  /// **'اردو'**
  String get languageUrdu;

  /// Settings section for light or dark colours.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// Theme option that follows the phone's light or dark setting.
  ///
  /// In en, this message translates to:
  /// **'Same as phone'**
  String get themeSystem;

  /// Light theme option.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Dark theme option.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Switch that makes all text larger.
  ///
  /// In en, this message translates to:
  /// **'Large text'**
  String get settingsLargeText;

  /// Explains the Large text switch.
  ///
  /// In en, this message translates to:
  /// **'Makes text 30% larger than the phone setting'**
  String get settingsLargeTextHint;

  /// Opens the list of open-source licences for fonts and packages.
  ///
  /// In en, this message translates to:
  /// **'Open-source licences'**
  String get settingsLicenses;

  /// Spoken label for the progress indicator while the encrypted vault opens.
  ///
  /// In en, this message translates to:
  /// **'Opening your items'**
  String get vaultOpening;

  /// Heading when the vault could not be opened but nothing is lost.
  ///
  /// In en, this message translates to:
  /// **'Yaadi could not open your items'**
  String get vaultTryAgainTitle;

  /// Explains that the keystore did not answer.
  ///
  /// In en, this message translates to:
  /// **'Your phone\'s secure key storage did not respond. This is usually temporary. Your items have not been changed.'**
  String get vaultKeyUnavailableBody;

  /// Explains an unexpected failure while opening the vault.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while opening your items. Your items have not been changed.'**
  String get vaultUnexpectedBody;

  /// Button that tries to open the vault again.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get vaultTryAgain;

  /// Heading when the saved items can never be read again.
  ///
  /// In en, this message translates to:
  /// **'Your items cannot be opened'**
  String get vaultRecoveryTitle;

  /// Explains that the key is gone while the database is still there.
  ///
  /// In en, this message translates to:
  /// **'The key that unlocks your saved items is no longer on this phone. This happens when Yaadi\'s data is restored onto a new phone or the phone\'s key storage was cleared. These items cannot be recovered.'**
  String get vaultKeyMissingBody;

  /// Explains that the key does not open the database, or the file is damaged.
  ///
  /// In en, this message translates to:
  /// **'Your saved items could not be read with this phone\'s key. The file may be damaged. These items cannot be recovered.'**
  String get vaultWrongKeyBody;

  /// Button that erases the unreadable vault and starts with an empty one.
  ///
  /// In en, this message translates to:
  /// **'Delete and start again'**
  String get vaultReset;

  /// Heading of the confirmation before erasing the vault.
  ///
  /// In en, this message translates to:
  /// **'Delete everything?'**
  String get vaultResetConfirmTitle;

  /// Body of the confirmation before erasing the vault.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes every item saved in Yaadi on this phone. It cannot be undone.'**
  String get vaultResetConfirmBody;

  /// Confirms erasing the vault.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get vaultResetConfirm;

  /// Closes a dialog without doing anything.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Heading when the vault was saved by a newer version of the app.
  ///
  /// In en, this message translates to:
  /// **'Update Yaadi'**
  String get vaultUpdateTitle;

  /// Explains that an older app cannot open a newer vault.
  ///
  /// In en, this message translates to:
  /// **'Your items were saved by a newer version of Yaadi. Install the latest version to open them. Nothing has been deleted.'**
  String get vaultUpdateBody;

  /// Heading when the app was built without encryption.
  ///
  /// In en, this message translates to:
  /// **'This build cannot protect your items'**
  String get vaultBuildErrorTitle;

  /// Explains that the app refuses to store items without encryption.
  ///
  /// In en, this message translates to:
  /// **'This build of Yaadi has no encryption, so it will not open or create your vault. Install an official build.'**
  String get vaultBuildErrorBody;

  /// Badge shown in the app bar while demo data is shown.
  ///
  /// In en, this message translates to:
  /// **'Demo'**
  String get demoBadge;

  /// Full privacy notice of the web demo, on its first screen, in Settings and behind Details. Must match the privacy text in ARCHITECTURE.md section 8.
  ///
  /// In en, this message translates to:
  /// **'Demo with made-up families. What you type stays in this browser, is not encrypted and is not sent to us. Do not enter real ID numbers. The demo is hosted on GitHub Pages, which keeps standard access logs.'**
  String get webDemoNotice;

  /// One-line strip above every screen of the web demo. Details opens the full notice.
  ///
  /// In en, this message translates to:
  /// **'Demo with made-up families. Not encrypted: do not enter real ID numbers.'**
  String get webDemoNoticeShort;

  /// Button on the web demo's strip that opens the full privacy notice.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get demoNoticeDetails;

  /// Added to the web demo notice when the browser refused to store the demo, for example in private browsing or over quota.
  ///
  /// In en, this message translates to:
  /// **'This browser is not saving the demo; it will reset when you reload.'**
  String get webDemoNotSaving;

  /// Heading of the card on the Today screen that sums up the day.
  ///
  /// In en, this message translates to:
  /// **'Morning summary'**
  String get morningSummaryTitle;

  /// Morning summary line when nothing is overdue, due today or waiting to be confirmed.
  ///
  /// In en, this message translates to:
  /// **'Nothing due today'**
  String get summaryQuietToday;

  /// Morning summary line naming the oldest overdue item and counting the rest. Written as a label so the sentence never has to agree with the title.
  ///
  /// In en, this message translates to:
  /// **'{others, plural, =0{Overdue: {title}} =1{Overdue: {title} and 1 more} other{Overdue: {title} and {others} more}}'**
  String summaryOverdue(int others, String title);

  /// Morning summary line counting past appointments the user has not yet marked as done or rescheduled.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{To confirm: 1 past item} other{To confirm: {count} past items}}'**
  String summaryToConfirm(int count);

  /// Morning summary line for one item due today.
  ///
  /// In en, this message translates to:
  /// **'Today: {details}'**
  String summaryToday(String details);

  /// Morning summary line counting items due today beyond the three named one by one.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Today: 1 more} other{Today: {count} more}}'**
  String summaryMoreToday(int count);

  /// Morning summary line counting today's medicine times the user entered. Neutral wording: never advice.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Medicine: 1 time today} other{Medicine: {count} times today}}'**
  String summaryDoses(int count);

  /// Morning summary line naming the next item in the coming seven days.
  ///
  /// In en, this message translates to:
  /// **'Coming up: {title}, {date}'**
  String summaryComingUp(String date, String title);

  /// Morning summary line with what overdue bills and bills due in the next seven days add up to.
  ///
  /// In en, this message translates to:
  /// **'To pay by {date}: {amounts}'**
  String summaryToPay(String amounts, String date);

  /// Morning summary line counting bills in the totals whose amount is not known yet, such as an electricity bill before the paper arrives.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 amount not known yet} other{{count} amounts not known yet}}'**
  String summaryUnknownAmounts(int count);

  /// Navigation label for the list of all items, open and finished.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get navItems;

  /// Navigation label for the search screen.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// Button and screen title for adding a new bill, appointment, expiry date, medicine or task.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItem;

  /// Screen title when changing an existing item.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get editItem;

  /// Heading on the Today screen when there are items but none is open.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get todayAllDoneTitle;

  /// Explanation on the Today screen when everything is paid or done.
  ///
  /// In en, this message translates to:
  /// **'Nothing is open right now. Paid and done items are under Items.'**
  String get todayAllDoneBody;

  /// Button that shows a made-up family's items instead of the user's own.
  ///
  /// In en, this message translates to:
  /// **'Try a demo household'**
  String get tryDemo;

  /// Today screen group for appointments whose date has passed. Asked as a question, never called overdue.
  ///
  /// In en, this message translates to:
  /// **'Did these happen?'**
  String get sectionToConfirm;

  /// Today screen group for bills, tasks and expiry dates whose date has passed.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get sectionOverdue;

  /// Today screen group for items due today and today's medicine times.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get sectionToday;

  /// Today screen group for items due in the coming week.
  ///
  /// In en, this message translates to:
  /// **'Next 7 days'**
  String get sectionNextWeek;

  /// Today screen group for ID cards, passports and warranties that expire in 8 to 30 days, shown early because renewing takes weeks.
  ///
  /// In en, this message translates to:
  /// **'Expiring soon'**
  String get sectionExpiringSoon;

  /// Today screen group for items due after next week, and tasks without a date.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get sectionLater;

  /// What screen readers announce for a Today group heading.
  ///
  /// In en, this message translates to:
  /// **'{title}, {count, plural, =1{1 item} other{{count} items}}'**
  String sectionLabel(String title, int count);

  /// Shown for a bill whose amount the user has not entered yet, such as an electricity bill before the paper arrives.
  ///
  /// In en, this message translates to:
  /// **'Amount not known yet'**
  String get amountNotKnown;

  /// Label on a medicine card above today's times. Neutral wording: never advice.
  ///
  /// In en, this message translates to:
  /// **'Medicine times today'**
  String get dosesToday;

  /// When a medicine course begins, for a course that has not started yet.
  ///
  /// In en, this message translates to:
  /// **'Starts {date}'**
  String startsOn(DateTime date);

  /// A snoozed item's card. The real due date is always shown next to the snooze date.
  ///
  /// In en, this message translates to:
  /// **'Snoozed to {date} · due {due}'**
  String snoozedTo(DateTime date, DateTime due);

  /// An ID card, passport or warranty that has already expired.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{Expired yesterday} other{Expired {days} days ago}}'**
  String expiredDaysAgo(int days);

  /// Something that expires today.
  ///
  /// In en, this message translates to:
  /// **'Expires today'**
  String get expiresToday;

  /// Something that expires soon.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{Expires tomorrow} other{Expires in {days} days}}'**
  String expiresInDays(int days);

  /// A past appointment from yesterday, waiting for the user to confirm it happened.
  ///
  /// In en, this message translates to:
  /// **'Was yesterday'**
  String get wasYesterday;

  /// A past appointment waiting for the user to confirm it happened.
  ///
  /// In en, this message translates to:
  /// **'Was on {date}'**
  String wasOn(DateTime date);

  /// A bill or task whose date has passed.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{Overdue by 1 day} other{Overdue by {days} days}}'**
  String overdueByDays(int days);

  /// A bill due today.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get dueToday;

  /// An appointment or task on today's date.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get whenToday;

  /// A bill due tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Due tomorrow'**
  String get dueTomorrow;

  /// An appointment or task on tomorrow's date.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get whenTomorrow;

  /// An item due within the coming week, two or more days away.
  ///
  /// In en, this message translates to:
  /// **'In {days} days · {date}'**
  String inDays(int days, DateTime date);

  /// An item due later this year.
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String onDate(DateTime date);

  /// An item due in another year.
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String onDateWithYear(DateTime date);

  /// Quick action on a bill: records it as paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get actionPaid;

  /// Quick action on an appointment, expiry date or task: records it as done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// Quick action that shows an item again in a few days. Opens a menu of durations.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get actionSnooze;

  /// Quick action on a past appointment: moves it to another day.
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get actionReschedule;

  /// What screen readers announce for the Paid button.
  ///
  /// In en, this message translates to:
  /// **'Mark {title} as paid'**
  String markPaidLabel(String title);

  /// What screen readers announce for the Done button.
  ///
  /// In en, this message translates to:
  /// **'Mark {title} as done'**
  String markDoneLabel(String title);

  /// What screen readers announce for the Snooze button.
  ///
  /// In en, this message translates to:
  /// **'Snooze {title}'**
  String snoozeLabel(String title);

  /// What screen readers announce for the Reschedule button.
  ///
  /// In en, this message translates to:
  /// **'Reschedule {title}'**
  String rescheduleLabel(String title);

  /// Heading of the date picker when rescheduling a past appointment.
  ///
  /// In en, this message translates to:
  /// **'Move to which day?'**
  String get rescheduleTo;

  /// Confirmation after rescheduling.
  ///
  /// In en, this message translates to:
  /// **'Moved to {date}'**
  String movedTo(DateTime date);

  /// Confirmation after snoozing.
  ///
  /// In en, this message translates to:
  /// **'Snoozed until {date}'**
  String snoozedUntil(DateTime date);

  /// A choice in the Snooze menu.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day} other{{days} days}}'**
  String snoozeDays(int days);

  /// A choice in the Snooze menu: seven days.
  ///
  /// In en, this message translates to:
  /// **'1 week'**
  String get snoozeWeek;

  /// Confirmation after Paid, shown with an Undo button.
  ///
  /// In en, this message translates to:
  /// **'Marked as paid'**
  String get markedPaid;

  /// Confirmation after Done, shown with an Undo button.
  ///
  /// In en, this message translates to:
  /// **'Marked as done'**
  String get markedDone;

  /// Confirmation after the user marks one of today's medicine times. Neutral wording: never advice.
  ///
  /// In en, this message translates to:
  /// **'{time} marked'**
  String doseMarked(String time);

  /// What screen readers announce for a medicine time that is marked.
  ///
  /// In en, this message translates to:
  /// **'{title}, {time}, marked'**
  String doseMarkedLabel(String title, String time);

  /// What screen readers announce for a medicine time that is not marked. Neutral wording: never missed or late.
  ///
  /// In en, this message translates to:
  /// **'{title}, {time}, not marked yet'**
  String doseNotMarkedLabel(String title, String time);

  /// Button that reverses the last change.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Shown when Undo is refused because the item was changed again in the meantime.
  ///
  /// In en, this message translates to:
  /// **'Changed since, so it was not undone'**
  String get undoRefused;

  /// Shown when storage refused a change. Nothing was changed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Try again.'**
  String get notSaved;

  /// Shown when Paid, Done, Snooze or another quick action is refused because the item was changed, completed or deleted since the screen showed it.
  ///
  /// In en, this message translates to:
  /// **'This item changed in the meantime, so nothing was saved.'**
  String get actionStale;

  /// Button on an item's page that takes back its latest payment, for a Paid tapped by mistake.
  ///
  /// In en, this message translates to:
  /// **'Mark as not paid'**
  String get reopenPaid;

  /// Button on an item's page that takes back its latest Done, for a Done tapped by mistake.
  ///
  /// In en, this message translates to:
  /// **'Mark as not done'**
  String get reopenDone;

  /// Button on an item's page that takes back its latest skipped instalment.
  ///
  /// In en, this message translates to:
  /// **'Mark as not skipped'**
  String get reopenSkipped;

  /// Confirmation after taking back a payment or a Done, shown with an Undo button.
  ///
  /// In en, this message translates to:
  /// **'Due again'**
  String get reopened;

  /// Button after paying an old bill that opens the other ways to handle the missed months.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get catchUpChange;

  /// After paying an old utility bill: the missed months in between were recorded as paid, without amounts.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 earlier bill recorded as paid.} other{{count} earlier bills recorded as paid.}}'**
  String catchUpMarkedPaid(int count);

  /// After paying an old instalment: the missed ones in between were skipped.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 earlier one skipped.} other{{count} earlier ones skipped.}}'**
  String catchUpSkipped(int count);

  /// After paying an old instalment such as rent: the missed ones are still owed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 more is still to pay.} other{{count} more are still to pay.}}'**
  String catchUpStillOwed(int count);

  /// Choice: leave the missed months as still owed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Keep the earlier one unpaid} other{Keep {count} earlier ones unpaid}}'**
  String catchUpKeepUnpaid(int count);

  /// Choice: record the missed instalments as paid.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Mark the earlier one as paid} other{Mark {count} earlier ones as paid}}'**
  String catchUpMarkEarlierPaid(int count);

  /// Choice: record the missed instalments as skipped and move to the current one.
  ///
  /// In en, this message translates to:
  /// **'Skip to the current one'**
  String get catchUpSkipToCurrent;

  /// Heading of the sheet with the ways to handle missed months.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{What about the 1 missed in between?} other{What about the {count} missed in between?}}'**
  String catchUpQuestion(int count);

  /// Confirmation after choosing another way to handle missed months.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get catchUpUpdated;

  /// Items screen when there are no items at all.
  ///
  /// In en, this message translates to:
  /// **'No items yet'**
  String get itemsEmpty;

  /// Items screen when the chosen filters hide everything.
  ///
  /// In en, this message translates to:
  /// **'No items match these filters'**
  String get itemsNoMatch;

  /// Items filter: items still to pay or do.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get filterOpen;

  /// Items filter: finished items.
  ///
  /// In en, this message translates to:
  /// **'Paid and done'**
  String get filterClosed;

  /// Items filter: open and finished items.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Items filter: bills, appointments, expiry dates, medicine and tasks together.
  ///
  /// In en, this message translates to:
  /// **'All kinds'**
  String get filterAllKinds;

  /// Item status: still to pay or do.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get statusOpen;

  /// Item or history status: paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// Item or history status: done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get statusDone;

  /// History entry for an instalment the user chose to skip.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get outcomeSkipped;

  /// Repeat choice: a one-off item.
  ///
  /// In en, this message translates to:
  /// **'Does not repeat'**
  String get repeatNone;

  /// Repeat choice.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get repeatDaily;

  /// Repeat choice.
  ///
  /// In en, this message translates to:
  /// **'Every week'**
  String get repeatWeekly;

  /// Repeat choice.
  ///
  /// In en, this message translates to:
  /// **'Every month'**
  String get repeatMonthly;

  /// Repeat choice.
  ///
  /// In en, this message translates to:
  /// **'Every year'**
  String get repeatYearly;

  /// How a medicine item repeats: on the times the user typed, every day.
  ///
  /// In en, this message translates to:
  /// **'Medicine times every day'**
  String get repeatDoses;

  /// A weekly item, with its day.
  ///
  /// In en, this message translates to:
  /// **'Every week on {weekday}'**
  String repeatWeeklyOn(String weekday);

  /// A monthly item, with its day of the month.
  ///
  /// In en, this message translates to:
  /// **'Every month on day {day}'**
  String repeatMonthlyOn(int day);

  /// A monthly item on the 29th, 30th or 31st, which falls on the last day of shorter months.
  ///
  /// In en, this message translates to:
  /// **'Every month on day {day}, or the last day of shorter months'**
  String repeatMonthlyOnLate(int day);

  /// A yearly item, with its date.
  ///
  /// In en, this message translates to:
  /// **'Every year on {date}'**
  String repeatYearlyOn(DateTime date);

  /// A medicine item's times.
  ///
  /// In en, this message translates to:
  /// **'Every day at {times}'**
  String repeatDosesAt(String times);

  /// An item saved by a newer version of Yaadi with a rule this version does not know.
  ///
  /// In en, this message translates to:
  /// **'Repeats in a way this version cannot show'**
  String get repeatUnsupported;

  /// A repeating item that ends on a date.
  ///
  /// In en, this message translates to:
  /// **'{rule}, until {date}'**
  String repeatUntil(String rule, DateTime date);

  /// Shown on an item's page after the item was deleted.
  ///
  /// In en, this message translates to:
  /// **'This item has been deleted'**
  String get itemGone;

  /// Button that opens the editor for an item.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Button that deletes an item. An Undo follows.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// On the page of an item this version can show but not change.
  ///
  /// In en, this message translates to:
  /// **'Made by a newer version of Yaadi. Update the app to change it.'**
  String get repeatUnsupportedNotice;

  /// Label on an item's page when this occurrence's date was moved.
  ///
  /// In en, this message translates to:
  /// **'Moved'**
  String get factMoved;

  /// Explains that a repeating item's date was moved for this occurrence only.
  ///
  /// In en, this message translates to:
  /// **'This time only, from {date}'**
  String movedFrom(DateTime date);

  /// Label on an item's page for the snooze date.
  ///
  /// In en, this message translates to:
  /// **'Snoozed until'**
  String get factSnoozed;

  /// Label on an item's page for how it repeats.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get factRepeat;

  /// A bill's amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get fieldAmount;

  /// A bill whose amount changes every time, such as electricity.
  ///
  /// In en, this message translates to:
  /// **'Changes each time'**
  String get amountVaries;

  /// Free text the user adds to an item.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get fieldNotes;

  /// A consumer number, CNIC number or similar ID, hidden until the user taps Show.
  ///
  /// In en, this message translates to:
  /// **'Reference number'**
  String get fieldReference;

  /// Button on a bill's page.
  ///
  /// In en, this message translates to:
  /// **'Mark as paid'**
  String get markPaidButton;

  /// Button on an item's page.
  ///
  /// In en, this message translates to:
  /// **'Mark as done'**
  String get markDoneButton;

  /// Heading above an item's past payments and completions.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// When an item was created and last changed.
  ///
  /// In en, this message translates to:
  /// **'Added {created} · Changed {changed}'**
  String addedAndChanged(DateTime created, DateTime changed);

  /// A bill's due date.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get fieldDueDate;

  /// The date an ID card, passport or warranty expires.
  ///
  /// In en, this message translates to:
  /// **'Expires on'**
  String get fieldExpiresOn;

  /// The first day of a medicine course.
  ///
  /// In en, this message translates to:
  /// **'First day'**
  String get fieldFirstDay;

  /// An appointment's or task's date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get fieldDate;

  /// A task's date, which may be left empty.
  ///
  /// In en, this message translates to:
  /// **'Date (optional)'**
  String get fieldDateOptional;

  /// Confirmation after deleting an item, shown with an Undo button.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// Shown when a delete is refused because the item changed in the meantime.
  ///
  /// In en, this message translates to:
  /// **'This item changed since you opened it. Nothing was deleted.'**
  String get changedSince;

  /// What screen readers announce for a shown reference number. The platform adds how to activate it.
  ///
  /// In en, this message translates to:
  /// **'Reference {reference}'**
  String referenceShownLabel(String reference);

  /// What screen readers announce for a hidden reference number. Never includes the number.
  ///
  /// In en, this message translates to:
  /// **'Reference, hidden'**
  String get referenceHiddenLabel;

  /// Button that shows a hidden reference number for a short time.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get referenceShow;

  /// Button that hides a reference number again.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get referenceHide;

  /// Help under the Reference number field.
  ///
  /// In en, this message translates to:
  /// **'Consumer number, CNIC or similar. Hidden until you tap Show.'**
  String get referenceHint;

  /// Help under the Reference number field in the web demo.
  ///
  /// In en, this message translates to:
  /// **'Demo: use a made-up number.'**
  String get referenceDemoHint;

  /// Label above the choice of bill, appointment, expiry date, medicine or task.
  ///
  /// In en, this message translates to:
  /// **'What is it?'**
  String get fieldKind;

  /// An item's title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get fieldTitle;

  /// Example title for a bill.
  ///
  /// In en, this message translates to:
  /// **'For example, LESCO bill'**
  String get titleHintBill;

  /// Example title for an appointment.
  ///
  /// In en, this message translates to:
  /// **'For example, dentist'**
  String get titleHintAppointment;

  /// Example title for an expiry date.
  ///
  /// In en, this message translates to:
  /// **'For example, Abbu\'s CNIC'**
  String get titleHintExpiry;

  /// Example title for medicine times.
  ///
  /// In en, this message translates to:
  /// **'For example, Ammi\'s tablets'**
  String get titleHintMedicine;

  /// Example title for a task.
  ///
  /// In en, this message translates to:
  /// **'For example, renew the library card'**
  String get titleHintTask;

  /// An item's category, such as Electricity or School.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get fieldCategory;

  /// The currency of a bill's amount.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get fieldCurrency;

  /// Help under the amount field.
  ///
  /// In en, this message translates to:
  /// **'Leave empty if not known yet'**
  String get amountHint;

  /// Switch for bills whose amount changes every time.
  ///
  /// In en, this message translates to:
  /// **'Amount changes each time'**
  String get amountVariesSwitch;

  /// Explains the switch for bills whose amount changes.
  ///
  /// In en, this message translates to:
  /// **'Like electricity or gas. Each new bill needs its own amount.'**
  String get amountVariesHint;

  /// Placeholder in a date field with no date yet.
  ///
  /// In en, this message translates to:
  /// **'Not chosen yet'**
  String get chooseDate;

  /// Switch shown after changing a repeating item's date: also move future dates.
  ///
  /// In en, this message translates to:
  /// **'Repeat from the new date'**
  String get moveSeriesTitle;

  /// Explains the switch for moving a repeating item's future dates.
  ///
  /// In en, this message translates to:
  /// **'When off, only this time moves. It still repeats: {rule}.'**
  String moveSeriesHint(String rule);

  /// An item's time of day.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get fieldTime;

  /// Placeholder in a time field with no time.
  ///
  /// In en, this message translates to:
  /// **'No time'**
  String get noTime;

  /// How often an item comes back.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get fieldRepeat;

  /// The last day of a medicine course.
  ///
  /// In en, this message translates to:
  /// **'Last day (optional)'**
  String get fieldLastDay;

  /// The last date a repeating item comes back.
  ///
  /// In en, this message translates to:
  /// **'Ends on (optional)'**
  String get fieldEndsOn;

  /// Placeholder when a repeating item has no end date.
  ///
  /// In en, this message translates to:
  /// **'No end date'**
  String get noEndDate;

  /// Label above the medicine times the user types.
  ///
  /// In en, this message translates to:
  /// **'Times each day'**
  String get fieldDoseTimes;

  /// Tooltip on the button that removes a medicine time.
  ///
  /// In en, this message translates to:
  /// **'Remove {time}'**
  String removeTime(String time);

  /// Button that adds a medicine time.
  ///
  /// In en, this message translates to:
  /// **'Add a time'**
  String get addTime;

  /// Note under the medicine times: the app is an organiser and gives no medical advice.
  ///
  /// In en, this message translates to:
  /// **'Yaadi reminds you of the times you type. It never suggests a medicine, a dose or a time.'**
  String get doseTimesNote;

  /// Button that saves the item being edited.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Confirmation after adding an item, shown with an Undo button.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get added;

  /// Confirmation after changing an item, shown with an Undo button.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// Shown when a save is refused because the item changed in the meantime.
  ///
  /// In en, this message translates to:
  /// **'This item changed while you were editing. Your changes were not saved.'**
  String get saveConflict;

  /// Heading of the offer to move an ID or account number into the hidden Reference field.
  ///
  /// In en, this message translates to:
  /// **'Move this number to Reference?'**
  String get misplacedTitle;

  /// Explains why moving a number out of the title helps.
  ///
  /// In en, this message translates to:
  /// **'The title seems to contain an ID or account number. In Reference it stays hidden until you tap Show.'**
  String get misplacedInTitle;

  /// Explains why moving a number out of the notes helps.
  ///
  /// In en, this message translates to:
  /// **'The notes seem to contain an ID or account number. In Reference it stays hidden until you tap Show.'**
  String get misplacedInNotes;

  /// Saves without moving the number.
  ///
  /// In en, this message translates to:
  /// **'Leave it there'**
  String get misplacedKeep;

  /// Moves the number into the hidden Reference field and saves.
  ///
  /// In en, this message translates to:
  /// **'Move to Reference'**
  String get misplacedMove;

  /// Asked when leaving the editor with unsaved changes.
  ///
  /// In en, this message translates to:
  /// **'Discard your changes?'**
  String get discardTitle;

  /// Stays in the editor.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditing;

  /// Leaves the editor without saving.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// Error when the title is empty.
  ///
  /// In en, this message translates to:
  /// **'Enter a title'**
  String get problemTitleRequired;

  /// Error when a medicine item has no times.
  ///
  /// In en, this message translates to:
  /// **'Add at least one time'**
  String get problemDoseTimesRequired;

  /// Error when a date is needed.
  ///
  /// In en, this message translates to:
  /// **'Choose a date'**
  String get problemDateRequired;

  /// Error when text is longer than allowed.
  ///
  /// In en, this message translates to:
  /// **'This is too long'**
  String get problemTooLong;

  /// Error when the amount cannot be read.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount like {example}'**
  String problemAmount(String example);

  /// Error when a repeating item would end before it starts.
  ///
  /// In en, this message translates to:
  /// **'The end date is before the first date'**
  String get problemEndBeforeStart;

  /// Announced to screen readers when Save finds fields to fix.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Check 1 field} other{Check {count} fields}}'**
  String editorProblems(int count);

  /// What screen readers announce for a date or time field with an error.
  ///
  /// In en, this message translates to:
  /// **'{label}, {problem}'**
  String fieldWithProblem(String label, String problem);

  /// When an ID card, passport or warranty expires, as a short label in lists.
  ///
  /// In en, this message translates to:
  /// **'Expires {date}'**
  String expiresOn(DateTime date);

  /// Tooltip on the button that empties a date or time field.
  ///
  /// In en, this message translates to:
  /// **'Clear {label}'**
  String clearField(String label);

  /// Placeholder in the search field, with examples in Roman Urdu, Urdu and English. Keep the examples.
  ///
  /// In en, this message translates to:
  /// **'Search: bijli, گیس, school fee'**
  String get searchHint;

  /// Tooltip on the button that empties the search field.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// Heading when a search finds nothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get searchNoResults;

  /// Suggestion when a search finds nothing.
  ///
  /// In en, this message translates to:
  /// **'Try another spelling, or the same word in Urdu or English.'**
  String get searchNoResultsHint;

  /// Number of search results, also announced to screen readers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 result} other{{count} results}}'**
  String searchResultCount(int count);

  /// Shown on the search screen before anything is typed. Keep the three example words.
  ///
  /// In en, this message translates to:
  /// **'Search works offline and understands English, Urdu and Roman Urdu: bijli, بجلی and electricity all find the electricity bill.'**
  String get searchExplain;

  /// Heading above example searches.
  ///
  /// In en, this message translates to:
  /// **'Try'**
  String get searchTry;

  /// Strip at the top of every screen while a demo household is shown on a phone.
  ///
  /// In en, this message translates to:
  /// **'You are looking at the {household} demo. Changes are not kept, and your own items are untouched.'**
  String phoneDemoNotice(String household);

  /// Button that goes back from a demo household to the user's own items.
  ///
  /// In en, this message translates to:
  /// **'Leave demo'**
  String get leaveDemo;

  /// Name of a made-up demo household in Pakistan.
  ///
  /// In en, this message translates to:
  /// **'Khan family, Lahore'**
  String get householdKhan;

  /// Name of a made-up demo household in England.
  ///
  /// In en, this message translates to:
  /// **'Taylor family, Manchester'**
  String get householdTaylor;

  /// What the Khan demo household contains.
  ///
  /// In en, this message translates to:
  /// **'Bills, a school fee, an ID card and Ammi\'s medicine times, in Urdu and English. Rupees.'**
  String get householdKhanDescription;

  /// What the Taylor demo household contains.
  ///
  /// In en, this message translates to:
  /// **'Council tax, energy, the dentist, a passport and prescription times. Pounds.'**
  String get householdTaylorDescription;

  /// Heading of the web demo's first screen.
  ///
  /// In en, this message translates to:
  /// **'Try Yaadi with a made-up family'**
  String get pickerTitle;

  /// Explanation on the web demo's first screen.
  ///
  /// In en, this message translates to:
  /// **'Pick a household to see how Yaadi keeps bills, appointments, expiry dates and medicine times. Everyone in it is invented.'**
  String get pickerBody;

  /// Explains demo households on a phone.
  ///
  /// In en, this message translates to:
  /// **'Demo households are made up. While one is shown, your own items stay as they are, and nothing you change in the demo is kept.'**
  String get demoExplain;

  /// Explains demo households in the web demo.
  ///
  /// In en, this message translates to:
  /// **'This web demo shows a made-up family. Switching household starts it again from the beginning.'**
  String get webDemoExplain;

  /// Settings section for the made-up families.
  ///
  /// In en, this message translates to:
  /// **'Demo households'**
  String get settingsDemo;

  /// Choice that shows the user's own items instead of a demo household.
  ///
  /// In en, this message translates to:
  /// **'My own items'**
  String get demoOwnItems;

  /// Button that removes the demo household in one tap.
  ///
  /// In en, this message translates to:
  /// **'Clear demo data'**
  String get clearDemo;

  /// Settings section for deleting the user's items.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get settingsYourData;

  /// Button that erases everything Yaadi keeps on the phone, after confirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete all my items'**
  String get deleteAll;

  /// Explains the Delete all button.
  ///
  /// In en, this message translates to:
  /// **'Permanently deletes everything Yaadi keeps on this phone'**
  String get deleteAllHint;

  /// Settings section about the app and who built it.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// The app's name and version.
  ///
  /// In en, this message translates to:
  /// **'Yaadi {version}'**
  String aboutVersion(String version);

  /// One line about what the app does.
  ///
  /// In en, this message translates to:
  /// **'Paper to reminder. Bills, appointments, expiry dates and medicine times, offline, in English and Urdu.'**
  String get aboutBody;

  /// Who built the app; opens their GitHub page.
  ///
  /// In en, this message translates to:
  /// **'Built by {maker}'**
  String aboutMaker(String maker);

  /// Opens the maker's Upwork profile.
  ///
  /// In en, this message translates to:
  /// **'Hire us on Upwork'**
  String get aboutHire;

  /// Shown when no browser could open a link.
  ///
  /// In en, this message translates to:
  /// **'The link could not be opened.'**
  String get linkFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
      {
        switch (locale.countryCode) {
          case 'GB':
            return AppLocalizationsEnGb();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
