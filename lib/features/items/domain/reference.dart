import 'package:meta/meta.dart';

import '../../../core/text/digits.dart';

const _hidden = '•••• ••••';

/// What the Reference field shows until the user taps Show: the last four
/// letters or digits of a long value and nothing of a short one, whose last
/// four would be most of it (ARCHITECTURE.md section 7). Spaces and dashes
/// do not count, so a CNIC ends in four digits rather than "12-3".
String maskReference(String reference) {
  final kept = [
    for (final rune in reference.runes)
      if (_letterOrDigit.hasMatch(String.fromCharCode(rune))) rune,
  ];
  if (kept.length < 8) return _hidden;
  return '$_hidden ${String.fromCharCodes(kept.sublist(kept.length - 4))}';
}

final _letterOrDigit = RegExp(r'[\p{L}\p{N}]', unicode: true);
final _trailingSpace = RegExp(r'[ \t]+$');
final _leadingSpace = RegExp(r'^[ \t]+');

enum NumberField { title, notes }

/// A number typed into the title or the notes that looks like it belongs in
/// the hidden Reference field.
@immutable
final class MisplacedNumber {
  const MisplacedNumber(this.field, this.start, this.end, this.value);

  final NumberField field;

  /// Where [value] sits in the field, in code units.
  final int start;
  final int end;

  final String value;

  /// [text] without the number. Only the gap it leaves is tidied, so the
  /// other lines of multi-line notes stay as they were.
  String removeFrom(String text) {
    final before = text.substring(0, start).replaceFirst(_trailingSpace, '');
    var after = text.substring(end).replaceFirst(_leadingSpace, '');
    // A number on a line of its own takes its line with it.
    if (before.endsWith('\n') && after.startsWith('\n')) {
      after = after.substring(1);
    }
    final atLineEdge =
        before.isEmpty ||
        after.isEmpty ||
        before.endsWith('\n') ||
        after.startsWith('\n');
    return '$before${atLineEdge ? '' : ' '}$after'.trim();
  }

  @override
  String toString() => 'MisplacedNumber(${field.name}, [$start, $end))';
}

/// A CNIC number, with or without dashes.
final _cnic = RegExp(r'(?<!\d)\d{5}-?\d{7}-?\d(?!\d)');

/// A consumer number, card number or similar.
final _longRun = RegExp(r'\d{10,}');

/// The first CNIC-shaped number or run of ten or more digits in [title],
/// then in [notes]. Urdu digits count too. The editor offers to move it into
/// Reference and never moves anything by itself.
MisplacedNumber? findMisplacedNumber({
  required String title,
  required String notes,
}) {
  for (final (field, text) in [
    (NumberField.title, title),
    (NumberField.notes, notes),
  ]) {
    // Digit normalization maps one code unit to one code unit, so offsets in
    // the normalized text are offsets in what the user typed.
    final normalized = normalizeDigits(text);
    final match =
        _cnic.firstMatch(normalized) ?? _longRun.firstMatch(normalized);
    if (match != null) {
      return MisplacedNumber(
        field,
        match.start,
        match.end,
        text.substring(match.start, match.end),
      );
    }
  }
  return null;
}
