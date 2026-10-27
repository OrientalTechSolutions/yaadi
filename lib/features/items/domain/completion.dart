import 'package:meta/meta.dart';

import '../../../core/money/money.dart';
import '../../../core/time/instant.dart';
import '../../../core/time/local_date.dart';

enum CompletionOutcome { paid, done, skipped }

/// One occurrence that was paid, done or skipped. Kept as history (bill
/// amounts, dose marks) and as half of every undo snapshot.
@immutable
final class Completion {
  Completion({
    required this.id,
    required this.itemId,
    required this.occurrenceOn,
    this.occurrenceMinute,
    required this.outcome,
    this.amount,
    required DateTime recordedAt,
  }) : recordedAt = utcMillis(recordedAt) {
    if (occurrenceMinute case final minute?) {
      RangeError.checkValueInInterval(minute, 0, 1439, 'occurrenceMinute');
    }
  }

  final String id;
  final String itemId;

  /// The scheduled date that was completed, not the day it was marked.
  final LocalDate occurrenceOn;

  /// The dose time for medicine; null for everything else.
  final int? occurrenceMinute;

  final CompletionOutcome outcome;

  /// The amount at that time. Utility bills change every month.
  final Money? amount;

  final DateTime recordedAt;

  /// Two completions with the same key are the same occurrence; the vault's
  /// unique index allows only one.
  (String, LocalDate, int) get occurrenceKey =>
      (itemId, occurrenceOn, occurrenceMinute ?? -1);

  @override
  bool operator ==(Object other) =>
      other is Completion &&
      other.id == id &&
      other.itemId == itemId &&
      other.occurrenceOn == occurrenceOn &&
      other.occurrenceMinute == occurrenceMinute &&
      other.outcome == outcome &&
      other.amount == amount &&
      other.recordedAt == recordedAt;

  @override
  int get hashCode => Object.hash(
    id,
    itemId,
    occurrenceOn,
    occurrenceMinute,
    outcome,
    amount,
    recordedAt,
  );

  @override
  String toString() =>
      'Completion($id, item: $itemId, $occurrenceOn'
      '${occurrenceMinute == null ? '' : ' @$occurrenceMinute'}, '
      '${outcome.name})';
}

/// History order: by occurrence, then dose time, then when it was recorded.
int compareCompletions(Completion a, Completion b) {
  final byDate = a.occurrenceOn.compareTo(b.occurrenceOn);
  if (byDate != 0) return byDate;
  final byMinute = (a.occurrenceMinute ?? -1).compareTo(
    b.occurrenceMinute ?? -1,
  );
  if (byMinute != 0) return byMinute;
  final byTime = a.recordedAt.compareTo(b.recordedAt);
  return byTime != 0 ? byTime : a.id.compareTo(b.id);
}
