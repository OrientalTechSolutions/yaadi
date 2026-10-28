# Changelog

## 0.1.0 - 2026-10-28

First version (Milestone 1): items added by hand, the Today screen, offline search, English and Urdu, an encrypted SQLCipher vault whose encryption at rest is tested on every CI run, and a web demo with two made-up households, live at https://orientaltechsolutions.github.io/yaadi/.

### Screens

- Today: a morning summary, then past appointments to confirm, Overdue, Today, Next 7 days, Expiring soon and Later. The summary counts the medicine times not marked yet, and its totals count every fixed instalment still owed, snoozed or not.
- Quick actions: Paid, Done, Snooze, Reschedule and dose marks, each with Undo. The confirmation names the item and, for a repeating one, when it is due next. A medicine time marked by mistake is unmarked with another tap.
- Paying a bill months late asks at once what happened to the missed ones, with the usual answer for that kind of bill already chosen, and one Undo takes back the payment and the choice together. At most 400 missed occurrences are settled; older ones are passed over.
- Items: everything saved, filtered by kind and by Open or Finished. A medicine course past its last day counts as finished. An empty Finished list explains that a paid repeating bill stays under Open.
- Editor: bills, appointments, expiry dates, medicine and tasks, with amounts, repeats, end dates, notes and a hidden reference number. An ID number in the title or notes is pointed out; moving it to Reference goes back to that field so what is left can be tidied before saving.
- Item page: every field, its history (what each line was for and when it was recorded), Mark as paid or done, Mark as not paid for a mistaken tap, Edit, and Delete with Undo.
- Search: English, Urdu script and Roman Urdu, with highlighted matches. "net ka bill" and "gais" are understood, and a plural ranks with its word.
- Settings: language, theme, Large text, the currency new bills start in, demo households, Delete all and About.
- Messages with Undo stay until dismissed for screen reader users, and are hidden when another tab, screen or language is shown.
- Money and dates in lists never split across lines, and Urdu lists use the Urdu comma.

### Demo households

- The Khan family in Lahore (rupees, English and Urdu titles) and the Taylor family in Manchester (pounds); all names are invented. Each has one finished item.
- On a phone a household is shown from memory and the vault is never written; one tap goes back, after a question.
- The web demo opens on a household picker, which says what this milestone does and links the source code, and keeps the visitor's changes in the browser tab. Switching or clearing a household asks first, and starts with an empty search and no filters.

### Vault

- Tests on Windows and in Linux CI load the SQLCipher build of the `sqlite3` hook, and phone builds are configured to load the same one: SQLCipher 4.19.0 community on SQLite 3.53.4, from the `sqlite3` 3.8.0 release, checked against the sha256 hashes shipped in the pub.dev package. The Windows build reports OpenSSL 4.0.3, linked in statically. Tests do not use the operating system's SQLite.
- The encryption tests run on every test run and never skip. They cover: no plaintext in the vault file, its header or its WAL; "not a database" without the key; a wrong key, a missing key or a plaintext file landing on Recovery with the file untouched; and the production open path applying every vault setting.
- An encrypted schema v1 vault, `test/fixtures/vault_v1.sqlite`, is opened through the startup path on every run, so a library upgrade that cannot read existing vaults fails CI.
- The fail-closed open is tested on every run against a simulated build without SQLCipher.
- The SQLCipher and OpenSSL licences ship in `assets/licenses` and appear on the in-app licence page of phone builds (OpenSSL on Android only). A test fails when the licence names a different SQLCipher version from the library that loaded.

### CI and web demo

- GitHub Actions runs on every push to main and every pull request: generated code up to date, format, analyze, the full test suite with coverage, the encryption tests on their own, `gh attestation verify` on a freshly downloaded SQLCipher library, the date tests in four time zones and a release web build.
- Each passing run on main publishes the web demo to GitHub Pages.
- The web demo shows a loading screen until its first frame, and requests only its own files. Characters its bundled fonts cannot draw, such as emoji, are left out as they are typed, with a note.

### Known limits

- No phone build is part of this milestone yet. The Android and iOS SQLCipher libraries, Android Keystore, the iOS Keychain and the backup rules are checked on devices in M2.
- The Urdu text is waiting for a review by a native speaker.
- No reminders, widget, backup or export yet (M2), and no golden screenshot tests yet.
