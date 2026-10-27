# Changelog

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
