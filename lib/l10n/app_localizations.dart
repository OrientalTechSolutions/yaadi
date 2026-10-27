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

  /// Permanent notice on the web demo. Must match the privacy text in ARCHITECTURE.md section 8.
  ///
  /// In en, this message translates to:
  /// **'Demo with made-up families. What you type stays in this browser, is not encrypted and is not sent to us. Do not enter real ID numbers. The demo is hosted on GitHub Pages, which keeps standard access logs.'**
  String get webDemoNotice;

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
  String summaryComingUp(DateTime date, String title);

  /// Morning summary line with what overdue bills and bills due in the next seven days add up to.
  ///
  /// In en, this message translates to:
  /// **'To pay by {date}: {amounts}'**
  String summaryToPay(String amounts, DateTime date);

  /// Morning summary line counting bills in the totals whose amount is not known yet, such as an electricity bill before the paper arrives.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 amount not known yet} other{{count} amounts not known yet}}'**
  String summaryUnknownAmounts(int count);
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
