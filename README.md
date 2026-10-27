# Yaadi: paper to reminder

Yaadi is for the person who handles a family's bills, notices and medicines.
It keeps each paper as a reminder they can read in their own language, and
helps them act on time. Pakistan first (Urdu, Roman Urdu, English), and
English-speaking homes in the UK and US. It works offline.

## Status

Milestone 1 is in progress. Built so far:

- the app shell in English and Urdu, with right-to-left layout, Noto Nastaliq
  Urdu, light and dark themes and a Large text setting;
- the encrypted vault for phones and the browser-session store for the web
  demo;
- the item model (bills, appointments, expiry dates, medicine times, tasks),
  repositories with revision checks and undo, and the schema v1 migration
  harness.

Adding items, the Today groups, search and the demo households come next.
[ARCHITECTURE.md](ARCHITECTURE.md) describes the whole design and its
trade-offs.

## Privacy

The Android and iPhone builds are set up to use SQLCipher. Encryption has not
been tested yet: the tests are written and skipped until the SQLCipher test
library is enabled, and on-device checks come in M2.

> On Android and iPhone, Yaadi keeps your items in an encrypted database on
> the phone (SQLCipher, AES-256). The key is created on the phone, held by
> Android Keystore or the iOS Keychain, and never leaves it. This version
> makes no network requests and has no analytics or crash reporting.
> Encryption protects a copy of the database file on its own. It does not
> protect against someone who can unlock your phone and open Yaadi, a rooted
> or jailbroken phone, or malware. On a shared phone, the main protection is
> that the Reference field is hidden until you tap Show. There is no backup
> yet: if you lose or reset your phone, your Yaadi data cannot be recovered.

The web build is a demo:

> Demo with made-up families. What you type stays in this browser, is not
> encrypted and is not sent to us. Do not enter real ID numbers. The demo is
> hosted on GitHub Pages, which keeps standard access logs.

## Build and test

Flutter 3.47.8 (Dart 3.13.7).

```sh
flutter pub get
flutter analyze
flutter test
flutter build web --release --no-web-resources-cdn
```

Generated code is committed. After changing ARB files, tables or the schema,
regenerate it:

```sh
flutter gen-l10n
dart run build_runner build
dart run drift_dev make-migrations
```

## Licences

Yaadi is MIT licensed. It bundles Noto Nastaliq Urdu (SIL Open Font License
1.1) and Roboto (Apache License 2.0); both licences ship in `assets/fonts` and
appear on the in-app licence page.

Built by [Oriental Tech Solutions](https://github.com/OrientalTechSolutions)
([Upwork](https://www.upwork.com/freelancers/attaullahhazarvi)).
