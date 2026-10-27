# Changelog

## Unreleased

Milestone 1, in progress.

- App shell: Material 3 light and dark themes, a Large text setting that
  multiplies the phone's text size, and Today and Settings tabs.
- English and Urdu with gen-l10n, right-to-left layout for Urdu, and Noto
  Nastaliq Urdu bundled with line heights tuned for its descenders. The Urdu
  text is a draft until a native speaker reviews it.
- Encrypted vault for phones: Drift on SQLCipher with a key kept in Android
  Keystore or the iOS Keychain, a fail-closed open path, startup recovery
  states and a crash-safe erase. Encryption is not tested yet; see
  ARCHITECTURE.md section 5.1.
- Web demo storage in the browser session, labelled on screen as a demo.
- Item model (bills, appointments, expiry dates, medicine times, tasks) with
  money in minor units, wall-clock dates and typed recurrence rules.
- Repositories for the vault, memory and the browser session, sharing one
  contract test suite: revision checks, one completion per occurrence and
  undo.
- Schema v1 snapshot and migration test harness.
- Today logic: Overdue, Today, Next 7 days and Later groups with a "Did these
  happen?" group for past appointments, a 30-day window for expiry dates,
  and medicine courses expanded into each day's times, marked in any order
  and never shown as overdue.
- Paid, Done and Snooze: repeating items roll forward from the rule's date
  (31 January to 28 or 29 February and back to 31 March), `until` ends a
  series, variable bills clear their amount, and missed occurrences are
  caught up by bill type, with the alternatives offered. Double taps apply
  once and every action can be undone.
- A deterministic morning summary in English and Urdu (the Urdu text is a
  draft until reviewed).
- Offline search over English, Urdu script and Roman Urdu: letter-variant and
  harakat folding, Roman Urdu spellings, a bilingual household lexicon with
  billers per country, prefix and one-typo matching, field-weighted ranking
  and grapheme-safe highlights.
- Today's date now moves on by itself at midnight, after a time-zone change
  and when the app resumes.
