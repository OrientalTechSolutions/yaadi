import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:yaadi/core/money/money.dart';
import 'package:yaadi/core/time/local_date.dart';
import 'package:yaadi/core/time/time_format.dart';
import 'package:yaadi/features/items/domain/item_kind.dart';
import 'package:yaadi/features/reminders/application/reminder_text.dart';
import 'package:yaadi/features/reminders/data/reminder_gateway.dart';
import 'package:yaadi/features/reminders/domain/reminder_payload.dart';
import 'package:yaadi/features/reminders/domain/reminder_plan.dart';
import 'package:yaadi/l10n/app_localizations.dart';

import '../../../support/items.dart';
import '../../../support/pump_app.dart';

void main() {
  setUpAll(initializeDateFormatting);

  // Times as UK English writes them.
  String gb(int minute) => plain(formatMinute(minute, 'en_GB'));

  final en = lookupAppLocalizations(const Locale('en', 'GB'));
  final ur = lookupAppLocalizations(const Locale('ur'));
  final today = LocalDate(2026, 11, 2);

  final secretBill = bill(
    title: 'LESCO bill',
    dueOn: LocalDate(2026, 11, 3),
    amount: Money(425000, 'PKR'),
    reference: '35202-1234567-1',
    notes: 'meter 7',
  );
  final items = [
    secretBill,
    medicine(),
    item(
      'dentist',
      title: 'Dentist',
      kind: ItemKind.appointment,
      due: LocalDate(2026, 11, 4),
      minute: 17 * 60,
    ),
    item('cnic', title: 'CNIC', kind: ItemKind.expiry, due: today.addDays(7)),
  ];
  final plan = planReminders(
    items,
    today: today,
    nowMinute: 0,
    prefs: const ReminderPrefs(),
  );

  String everything(List<ScheduledReminder> reminders) =>
      [for (final r in reminders) '${r.title}\n${r.body}\n${r.payload}']
          .join('\n');

  test('by default no title, reference or note reaches the phone', () {
    for (final l10n in [en, ur]) {
      final text = everything(
        scheduledReminders(plan, l10n, showTitles: false),
      );
      for (final secret in [
        'LESCO',
        'Dentist',
        'CNIC',
        'امی',
        '35202',
        'meter',
        '4,250',
      ]) {
        expect(
          text,
          isNot(contains(secret)),
          reason: '${l10n.localeName}: $secret',
        );
      }
    }
  });

  test('with titles on, references and notes still never appear', () {
    final text = everything(scheduledReminders(plan, en, showTitles: true));
    expect(text, contains('LESCO bill'));
    expect(text, isNot(contains('35202')));
    expect(text, isNot(contains('meter')));
  });

  test('generic English wording', () {
    final reminders = scheduledReminders(plan, en, showTitles: false);
    final titles = [for (final r in reminders) plain(r.title)];
    expect(titles, contains('A bill is due tomorrow'));
    expect(titles, contains('A bill is due today'));
    expect(titles, contains('Something expires in 7 days'));
    expect(titles, contains('An appointment at ${gb(17 * 60)}'));
    expect(titles, contains('Medicine time, ${gb(1200)}'));
  });

  test('named wording includes the amount for a bill', () {
    final reminders = scheduledReminders(plan, en, showTitles: true);
    final dueToday = reminders.firstWhere(
      (r) => r.title == 'LESCO bill' && plain(r.body).startsWith('Due today'),
    );
    expect(plain(dueToday.body), 'Due today · Rs 4,250');
    expect(dueToday.actions.map((a) => a.$1), [
      ReminderAction.paid,
      ReminderAction.snoozeTomorrow,
    ]);
    expect(dueToday.actions.map((a) => a.$2), ['Paid', 'Tomorrow']);
  });

  test('the morning summary uses its own channel and counts only', () {
    final summary = scheduledReminders(
      plan,
      en,
      showTitles: false,
    ).firstWhere((r) => r.channel == ReminderChannel.summary);
    expect(summary.title, 'Morning summary');
    expect(summary.body, isNot(contains('LESCO')));
    expect(summary.body, contains('medicine time'));
  });

  test('every reminder has its own id', () {
    final reminders = scheduledReminders(plan, ur, showTitles: false);
    expect(reminders.map((r) => r.id).toSet(), hasLength(reminders.length));
  });

  test('Urdu text is Urdu', () {
    final reminders = scheduledReminders(plan, ur, showTitles: false);
    expect(
      reminders.map((r) => r.title),
      contains('کل ایک بل کی آخری تاریخ ہے'),
    );
  });
}
