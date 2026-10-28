# Yaadi: paper to reminder

Yaadi is for the person who handles a family's bills, notices and medicines. It turns each paper into a reminder they can read in their own language, so they can act on time, every day. Pakistan first (Urdu, Roman Urdu and English), and English-speaking homes in the UK and US. It works offline.

This is Milestone 1 (version 0.1.0): the app, an encrypted SQLCipher vault (encryption at rest is tested on the desktop test runner, and on-device checks come in M2; see Privacy), the Today screen, offline search in three ways of writing, and a web demo with two made-up households. In this milestone you type items in; reading a paper from the camera, a PDF or the share button comes in M3. Nothing is in an app store yet.

**[Try the web demo](https://orientaltechsolutions.github.io/yaadi/)**: pick a made-up household and use the app in your browser. The demo is not encrypted and keeps what you type in that browser tab only, so do not enter real details.

## Screenshots

| Today | Today in Urdu, dark theme | Search in Roman Urdu |
| --- | --- | --- |
| <img src="docs/screenshots/today_en.png" alt="Today for the Khan household: the morning summary, a past check-up to confirm and an overdue gas bill titled in Urdu" width="260"> | <img src="docs/screenshots/today_ur_dark.png" alt="The same Today screen in the Urdu interface and the dark theme, right to left in Nastaliq" width="260"> | <img src="docs/screenshots/search_roman_urdu.png" alt="Searching for bijli ka bill finds the LESCO bill, with LESCO, bill, Electricity and Bill highlighted" width="260"> |

| Adding an item in Urdu | Demo households | The Taylor family |
| --- | --- | --- |
| <img src="docs/screenshots/add_item_ur.png" alt="The Urdu editor adding an electricity bill titled in Urdu script, with 4250 rupees typed in" width="260"> | <img src="docs/screenshots/settings.png" alt="Settings in the web demo: the two made-up households with the Khan family chosen, and Clear demo data" width="260"> | <img src="docs/screenshots/today_taylor.png" alt="Today for the Taylor household in Manchester: council tax overdue, prescription times and amounts in pounds, dates written day first" width="260"> |

## The problem

- A bill's due date hides in small English print. Miss it and a late fee follows, and in many homes one person reads every paper for everyone.
- A school fee notice arrives as a WhatsApp forward and gets buried. Nobody remembers whether Ammi's tablet is for the morning or the night. An expired ID card is noticed at the counter.
- ChatGPT can read a bill once. Nothing reminds you next month, and nothing works without the internet.

## What Milestone 1 does

- **Today, at a glance.** A morning summary worked out on the phone ("Overdue: gas bill", "To pay by Mon, Nov 9: Rs 20,530"), then past appointments to confirm, overdue items, today, the next 7 days, expiry dates coming up and later. Expiry dates show 30 days early, because renewing an ID card takes weeks.
- **Paid, Done, Snooze and Undo.** Paying a monthly bill moves it to next month and keeps its day: a bill on the 31st falls on 28 or 29 February and is back on 31 March. A bill paid months late asks what to do with the missed ones, and utility bills never invent arrears. Every action can be undone, a double tap counts once, and a Paid tapped by mistake can be taken back from the item's page later.
- **Medicine times you type.** Each day's times are marked one by one, in any order. Yaadi never suggests a medicine, a dose or a time, and never calls a dose "missed".
- **Items added by hand.** Bills, appointments, expiry dates, medicine and tasks, with amounts in rupees, pounds or dollars, repeats (daily, weekly, monthly, yearly, or medicine times), end dates and notes. A reference number such as a CNIC or consumer number is hidden until you tap Show, and an ID number typed into the title is offered a move into it.
- **Search in English, Urdu and Roman Urdu.** "bijli ka bill", "بجلی کا بل" and "electricity" find the same LESCO bill; "ammi ki dawai" finds "امی کی دوائی"; "lesco" never finds an IESCO bill. Typos are forgiven and the matched words are highlighted. It runs on the phone, offline.
- **English and Urdu.** Full right-to-left layout, Noto Nastaliq Urdu sized and spaced for its tall letters at every text size, dates written day first outside the US, and text you type keeps its own direction in either interface. Light and dark themes, a Large text setting, screen reader labels and headings, and 48 dp touch targets.
- **Demo households.** The Khan family in Lahore and the Taylor family in Manchester, both made up. On a phone they are shown from memory and your own items are never touched; one tap goes back. The web demo is always a demo and keeps what you type in this browser's session storage for that tab (browsers may save it to disk to restore tabs).

## Roadmap

- **M2:** reminders that still fire after a restart or a time-zone change, and repair themselves; a home-screen widget; the morning summary on a schedule; the encrypted vault checked on devices (Android Keystore, the iOS Keychain and backup rules); a first export, since there is no backup yet.
- **M3:** capture by camera, PDF or the share button. A small server, reusing the proxy from our flutter-ai-chat-starter project, reads the paper into a card you check and confirm, with each number linked to where it came from.
- **M4:** voice, Explain in Urdu, Roman Urdu or English, Ask my papers, sharing to WhatsApp, app lock and a simple mode.

## How it is built

- **Flutter 3.47.8 and Riverpod 3**, organised by feature (items, today, search, settings, demo), with the domain logic in plain Dart: recurrence and roll-forward, Today grouping, the morning summary and search have no Flutter or database code and run the same on phones, the web and the test VM.
- **One repository contract, three implementations.** The vault, memory (the demo households) and the browser session (the web demo) pass the same tests for revision checks, one payment per occurrence and undo. An undo only ever applies to the storage it came from, so a demo item can never land in your own items.
- **Dates are calendar dates.** "Due on the 10th" is stored as a date, not an instant, so daylight saving and time-zone changes never move it.
- **An encrypted vault.** Drift over SQLCipher, with a random key made on the phone, protected by Android Keystore or the iOS Keychain and turned into the database key with HKDF. Encryption at rest is tested on every run with the same SQLCipher release the phone builds bundle. The file and its write-ahead log hold no plaintext, a missing or wrong key lands on the Recovery screen, and a committed encrypted vault must keep opening after every library upgrade. The open path refuses to run without SQLCipher, a failure never silently resets the vault, deletes are cleared from the write-ahead log, and a versioned schema has a migration test harness.

[ARCHITECTURE.md](ARCHITECTURE.md) has the whole design: the threat model, every decision with its trade-off, and what is verified so far.

## Privacy

Encryption at rest is tested on the desktop test runner with SQLCipher 4.19.0, from the same sqlite3 release the Android and iPhone builds bundle. The phone builds themselves, with Android Keystore, the iOS Keychain and the backup rules, are checked on devices in M2.

When phone builds ship (M2), this is the statement they will carry:

> On Android and iPhone, Yaadi keeps your items in an encrypted database on the phone (SQLCipher, AES-256). The key is created on the phone, protected by Android Keystore or stored in the iOS Keychain, and never leaves it. This version makes no network requests and has no analytics or crash reporting. Encryption protects a copy of the database file on its own. It does not protect against someone who can unlock your phone and open Yaadi, a rooted or jailbroken phone, or malware. On a shared phone, the main protection is that the Reference field is hidden until you tap Show. There is no backup yet: if you lose or reset your phone, your Yaadi data cannot be recovered.

The web demo shows this notice. It is built for GitHub Pages, and CI publishes it from the main branch once the repository is public:

> Demo with made-up families. What you type stays in this browser, is not encrypted and is not sent to us. Do not enter real ID numbers. The demo is hosted on GitHub Pages, which keeps standard access logs.

The two links in Settings open GitHub and Upwork in your browser; the app itself requests nothing.

## Run it

You need Flutter 3.47.8 (Dart 3.13.7). The first test run downloads the SQLCipher library for your machine from the [sqlite3 package's GitHub release](https://github.com/simolus3/sqlite3.dart/releases) and checks its sha256 hash against the one shipped in the package. After that it is cached under `.dart_tool`.

```sh
flutter pub get
flutter run -d chrome
```

The web build opens on the household picker. To make the demo show the same dates every time, as the screenshots do, pin today's date:

```sh
flutter run -d chrome --dart-define=YAADI_TODAY=2026-11-02
```

The release web build used for the screenshots:

```sh
flutter build web --release --no-web-resources-cdn --dart-define=YAADI_TODAY=2026-11-02
```

Android and iOS builds are configured but are not part of Milestone 1. They bundle the same release's SQLCipher library, fetched when a device build first runs, and are checked on devices in M2 (ARCHITECTURE.md section 5.1).

## Tests

```sh
flutter analyze
flutter test
```

About 860 tests run without a device or a real clock, and without a network once the SQLCipher library is downloaded:

- table-driven domain tests for recurrence (month ends, leap years, `until`), catch-up, taking a payment back, Today grouping, medicine times, the morning summary, money and Urdu digits, the editor's rules and the reference mask;
- 90 search queries in English, Urdu script and Roman Urdu, normalizer rules, highlight boundaries and a 5,000-item time budget;
- one repository contract run against the vault, memory and the browser session, plus the vault's key handling, startup states, migrations, constraints and the open path refusing to run without SQLCipher;
- encryption at rest on SQLCipher: no plaintext in the file, its header or its write-ahead log; "not a database" without the key; a wrong key, a missing key or a plaintext file landing on Recovery with the file untouched; the production open path in its background isolate; and a committed encrypted vault opened through the startup path on every run;
- widget tests of the main flows in English and Urdu with the real fonts loaded: quick actions and undo, the editor, hidden reference numbers, search highlights, the demo households, right-to-left layout and large text at 2x;
- Flutter's tap-target and label guidelines on six screens in both languages and themes, its contrast guideline on the English screens (it cannot measure thin Nastaliq strokes), and every colour pair of the theme checked at 4.5:1 for both.

The encryption tests (tag `sqlcipher`) never skip. GitHub Actions runs the same checks on every push to main and every pull request: generated code must be up to date, then format, analyze, the tests, the encryption tests again on their own (the job fails if SQLCipher is not loaded), a provenance check of a freshly downloaded SQLCipher library, the date tests again under London, New York, Karachi and Santiago time zones, and a release web build. The workflow first runs when the repository is pushed.

Generated code is committed. After changing ARB files, tables or the schema, regenerate it with the same commands CI checks:

```sh
flutter gen-l10n
dart run build_runner build
dart run drift_dev make-migrations
dart run drift_dev schema generate --data-classes --companions drift_schemas/vault/ test/drift/vault/generated/
```

## Licences

Yaadi is released under the [MIT License](LICENSE). It bundles Noto Nastaliq Urdu (SIL Open Font License 1.1) and Roboto (Apache License 2.0); both licences ship in `assets/fonts` and appear on the in-app licence page. Phone builds also bundle SQLCipher (BSD-style licence, Zetetic LLC), which links OpenSSL (Apache License 2.0) on Android. Both licences ship in `assets/licenses` and appear on the licence page of those builds. The Urdu text is waiting for a review by a native speaker.

## Built by Oriental Tech Solutions

Yaadi is built by [Oriental Tech Solutions](https://github.com/OrientalTechSolutions), a Flutter studio in Lahore, Pakistan, founded by Attaullah Hazarvi. We have been building mobile apps for 13+ years and now focus on iOS and Android apps with AI features built in.

If you need an offline-first app, Urdu and right-to-left support or a complete Flutter app built on the same foundations, we would be glad to help.

**Hire us on Upwork:** https://www.upwork.com/freelancers/attaullahhazarvi
