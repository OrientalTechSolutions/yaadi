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
