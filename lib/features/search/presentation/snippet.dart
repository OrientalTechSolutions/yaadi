import 'package:flutter/painting.dart' show TextRange;

import '../domain/highlight.dart';

/// Notes longer than this are cut down to the part around the first match.
const snippetLength = 90;

/// [text] cut down to the stretch around the first of [ranges], with the
/// ranges moved to match. Cuts fall on spaces, so no word or grapheme
/// cluster is split, and an ellipsis marks each cut.
(String, List<TextRange>) snippetAround(String text, List<MatchRange> ranges) {
  List<TextRange> shifted(int from, int to, int offset) => [
    for (final range in ranges)
      if (range.end > from && range.start < to)
        TextRange(
          start: (range.start < from ? from : range.start) - from + offset,
          end: (range.end > to ? to : range.end) - from + offset,
        ),
  ];

  if (text.length <= snippetLength || ranges.isEmpty) {
    return (text, shifted(0, text.length, 0));
  }
  final first = ranges.first;
  var from = text.lastIndexOf(' ', (first.start - 30).clamp(0, first.start));
  from = from < 0 ? 0 : from + 1;
  var to = text.indexOf(
    ' ',
    (from + snippetLength).clamp(first.end, text.length),
  );
  if (to < 0) to = text.length;

  final prefix = from > 0 ? '… ' : '';
  final suffix = to < text.length ? ' …' : '';
  return (
    '$prefix${text.substring(from, to)}$suffix',
    shifted(from, to, prefix.length),
  );
}
