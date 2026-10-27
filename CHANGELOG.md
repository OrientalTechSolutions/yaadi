# Changelog

## Unreleased

Encryption at rest is switched on for tests and tested on the desktop test runner.

### Vault

- Tests load the SQLCipher build of the `sqlite3` hook, and CI and phone builds are configured to load the same one: SQLCipher 4.19.0 community on SQLite 3.53.4, from the `sqlite3` 3.8.0 release, checked against the sha256 hashes shipped in the pub.dev package. The Windows build reports OpenSSL 4.0.3, linked in statically. Tests no longer use the operating system's SQLite.
- The encryption tests run on every test run and never skip. They cover: no plaintext in the vault file, its header or its WAL; "not a database" without the key; a wrong key, a missing key or a plaintext file landing on Recovery with the file untouched; and the production open path applying every vault setting.
- An encrypted schema v1 vault, `test/fixtures/vault_v1.sqlite`, is opened through the startup path on every run, so a library upgrade that cannot read existing vaults fails CI.
- The fail-closed open is still tested on every run, now against a simulated build without SQLCipher.
- CI runs the encryption tests again on their own and fails if SQLCipher is not loaded. It caches the downloaded library and checks a fresh download with `gh attestation verify`.
- The SQLCipher and OpenSSL licences ship in `assets/licenses` and appear on the in-app licence page of phone builds (OpenSSL on Android only).

### Known limits

- No phone build is part of this milestone yet. The Android and iOS SQLCipher libraries, Android Keystore, the iOS Keychain and the backup rules are checked on devices in M2.
- The CI workflow first runs when the repository is pushed, so the Linux library, its cache and the provenance check have not run yet.

## 0.1.0 - 2026-10-28

First version: items added by hand, the Today screen, offline search, English and Urdu, a vault set up for SQLCipher encryption on phones (not yet tested; see Known limits) and a web demo with two made-up households.

### Screens

- Today: a morning summary, then past appointments to confirm, Overdue, Today, Next 7 days, Expiring soon and Later.
- Quick actions: Paid, Done, Snooze, Reschedule and dose marks, each with Undo; a late payment explains the missed months and offers alternatives.
- Items: everything saved, filtered by status and kind.
- Editor: bills, appointments, expiry dates, medicine and tasks, with amounts, repeats, end dates, notes and a hidden reference number.
- Item page: every field, its history, Mark as paid or done, Mark as not paid for a mistaken tap, Edit, and Delete with Undo.
- Search: English, Urdu script and Roman Urdu, with highlighted matches.
- Settings: language, theme, Large text, demo households, Delete all and About.

### Demo households

- The Khan family in Lahore (rupees, English and Urdu titles) and the Taylor family in Manchester (pounds); all names are invented.
- On a phone a household is shown from memory and the vault is never written; one tap goes back.
- The web demo opens on a household picker and keeps the visitor's changes in the browser tab.

### Known limits

- Encryption is not tested yet: the tests run on the system SQLite until the SQLCipher build is switched on for tests in M2, and no phone build is part of this milestone.
- The Urdu text is waiting for a review by a native speaker.
- No reminders, widget, backup or export yet (M2), and no golden screenshot tests yet.
