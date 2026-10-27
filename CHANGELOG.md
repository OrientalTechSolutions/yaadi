# Changelog

## 0.1.0 (Milestone 1)

The first complete version: items added by hand, the Today screen, offline search, English and Urdu, an encrypted vault for phones and a web demo with two made-up households.

### Screens

- Today: a morning summary, then "Did these happen?" for past appointments, Overdue, Today, Next 7 days and Later. Cards show what, when (relative to today, with the real due date kept next to a snooze) and how much, with today's medicine times as chips.
- Quick actions with Undo: Paid on bills, Done on everything else, Snooze for 1 day, 3 days or 1 week on what is due now, Reschedule for past appointments, and dose marks in any order. Paying a bill months late explains what happened to the missed ones and offers the alternatives.
- Items: everything saved, open or paid and done, filtered by status and kind.
- Editor: bills, appointments, expiry dates, medicine and tasks, with kind-specific fields, amounts in rupees, pounds or dollars, Repeat (daily, weekly, monthly, yearly, or medicine times), an end date, notes and a hidden Reference number. It checks the title, date, amount, end date and medicine times before saving, offers to move an ID number from the title or notes into Reference, asks before discarding changes, and keeps a repeating item's day when only this occurrence moves.
- Item page: every field, how it repeats, its payment and dose history, Mark as paid or done, Edit, and Delete with Undo that brings the history back. The reference number is masked until Show, hidden again after 30 seconds or when the app leaves the foreground, never selectable and never read out by screen readers while hidden.
- Search: live results in English, Urdu script and Roman Urdu with the matched words highlighted, notes cut down around the match, and suggestions in the household's own languages.
- Settings: language, theme, Large text, demo households, Clear demo data, Delete all (vault only, after confirmation), and About with the version and links.
- A bottom bar on phones and a navigation rail with a centred column on wide screens.

### Demo households

- The Khan family in Lahore (rupees, titles in English, Urdu and both) and the Taylor family in Manchester (pounds), dated around today so every group of Today has something in it. All names are invented and references are obvious placeholders.
- On a phone a household is shown from memory, with a permanent Demo badge and a strip that says changes are not kept; the vault is never written, and one tap goes back.
- The web demo opens on a household picker with the privacy notice, keeps the visitor's changes in the browser tab, and returns to the picker when the demo data is cleared.

### Under the hood

- App shell: Material 3 light and dark themes and a Large text setting that multiplies the phone's text size.
- English and Urdu with gen-l10n, right-to-left layout for Urdu, and Noto Nastaliq Urdu bundled with line heights tuned for its descenders. Text the user typed keeps its own direction and font in either interface. Urdu times name the part of the day (صبح 8:00).
- Encrypted vault for phones: Drift on SQLCipher with a key kept in Android Keystore or the iOS Keychain, a fail-closed open path, startup recovery states and a crash-safe erase.
- Item model with money in minor units, wall-clock dates and typed recurrence rules; repositories for the vault, memory and the browser session sharing one contract suite, now including a one-off `readAll`.
- Today logic: roll-forward from the rule's date (31 January to 28 or 29 February and back to 31 March), `until`, catch-up by bill type, medicine courses expanded per day, and a deterministic morning summary.
- Offline search: letter-variant and harakat folding, Roman Urdu spellings, a bilingual household lexicon with billers per country, prefix and one-typo matching, field-weighted ranking and grapheme-safe highlights.
- Today's date moves on by itself at midnight, after a time-zone change and when the app resumes.
- Schema v1 snapshot and migration test harness.
- Accessibility: labelled quick actions and dose chips, 48 dp targets, and tests with Flutter's tap-target, label and contrast guidelines plus a numeric check of every theme colour pair.
- New dependency: `url_launcher`, for the About links.

### Known limits

- Encryption is not tested yet: the SQLCipher test library waits on a download decision (ARCHITECTURE.md section 5.1), so the two encryption tests are skipped and no phone build is part of this milestone.
- The Urdu text, including the time-of-day words, is a draft until a native speaker reviews it.
- No reminders, widget, backup or export yet (M2). No golden screenshot tests yet; README screenshots are generated separately.
