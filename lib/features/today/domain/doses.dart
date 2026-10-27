import 'package:meta/meta.dart';

import '../../../core/time/local_date.dart';
import '../../items/domain/completion.dart';
import '../../items/domain/item.dart';

/// One of a day's medicine times and whether it has been marked.
///
/// There is deliberately no "missed" or "late" state: Yaadi records what the
/// user marks and never nudges a dose (ARCHITECTURE.md section 11).
@immutable
final class Dose {
  const Dose(this.minute, {required this.marked});

  /// Minutes after midnight, as the user typed it.
  final int minute;
  final bool marked;

  @override
  bool operator ==(Object other) =>
      other is Dose && other.minute == minute && other.marked == marked;

  @override
  int get hashCode => Object.hash(minute, marked);

  @override
  String toString() => 'Dose($minute${marked ? ', marked' : ''})';
}

extension DoseSchedule on Item {
  /// Whether this is a medicine course that runs on [day]: from its first
  /// day through `until`, inclusive.
  bool takesDosesOn(LocalDate day) {
    final course = doseTimes;
    final start = dueOn;
    if (course == null || start == null || day.isBefore(start)) return false;
    final until = course.until;
    return until == null || !day.isAfter(until);
  }

  /// Whether the course finished before [day]. Such items leave Today.
  bool courseEndedBefore(LocalDate day) {
    final until = doseTimes?.until;
    return until != null && until.isBefore(day);
  }

  /// The doses on [day] in time order, each marked when [marks] holds a
  /// completion for it. Marks for other items or days are ignored.
  List<Dose> dosesOn(LocalDate day, Iterable<Completion> marks) {
    final course = doseTimes;
    if (course == null || !takesDosesOn(day)) return const [];
    final marked = {
      for (final mark in marks)
        if (mark.itemId == id && mark.occurrenceOn == day)
          ?mark.occurrenceMinute,
    };
    return [
      for (final minute in course.minutes)
        Dose(minute, marked: marked.contains(minute)),
    ];
  }

  /// Whether the dose at [minute] on [day] exists and may be marked.
  bool canMarkDose(LocalDate day, int minute) =>
      isOpen &&
      recurrence.isSupported &&
      takesDosesOn(day) &&
      doseTimes!.minutes.contains(minute);

  /// The completion that marks the dose at [minute] on [day].
  Completion doseMark(
    LocalDate day,
    int minute, {
    required String id,
    required DateTime now,
  }) {
    if (!canMarkDose(day, minute)) {
      throw ArgumentError.value(minute, 'minute', 'No such dose on $day');
    }
    return Completion(
      id: id,
      itemId: this.id,
      occurrenceOn: day,
      occurrenceMinute: minute,
      outcome: CompletionOutcome.done,
      recordedAt: now,
    );
  }
}
