import 'package:characters/characters.dart';
import 'package:meta/meta.dart';

import '../../../core/text/script.dart';
import 'text_normalizer.dart';

/// A stretch of the original text to highlight, in code units:
/// `[start, end)`.
@immutable
final class MatchRange {
  const MatchRange(this.start, this.end);

  final int start;
  final int end;

  @override
  bool operator ==(Object other) =>
      other is MatchRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => '[$start, $end)';
}

/// [ranges] sorted, widened to whole grapheme clusters and merged where they
/// overlap or touch.
///
/// Widening keeps a haraka or an accent with its letter, so a highlight can
/// never cut a cluster in two. Every range stays inside [text].
List<MatchRange> tidyRanges(String text, Iterable<MatchRange> ranges) {
  if (ranges.isEmpty) return const [];

  final clamped = [
    for (final range in ranges)
      MatchRange(
        range.start.clamp(0, text.length),
        range.end.clamp(0, text.length),
      ),
  ];
  final needsSegmentation = clamped.any(
    (range) =>
        !_clusterStartsAt(text, range.start) ||
        !_clusterStartsAt(text, range.end),
  );
  final snapped = needsSegmentation ? _snapToClusters(text, clamped) : clamped;
  snapped.sort((a, b) => a.start.compareTo(b.start));

  final merged = <MatchRange>[];
  for (final range in snapped) {
    if (range.end <= range.start) continue;
    final last = merged.isEmpty ? null : merged.last;
    if (last != null && range.start <= last.end) {
      if (range.end > last.end) {
        merged.last = MatchRange(last.start, range.end);
      }
    } else {
      merged.add(range);
    }
  }
  return List.unmodifiable(merged);
}

/// Whether a grapheme cluster certainly starts at [at]. Cheap and
/// conservative, so the full segmentation runs only for text with marks,
/// joiners, surrogates or other characters that combine.
bool _clusterStartsAt(String text, int at) {
  if (at <= 0 || at >= text.length) return true;
  final unit = text.codeUnitAt(at);
  final previous = text.codeUnitAt(at - 1);
  if (previous == 0x200D) return false;
  if (unit < 0x0300) return !(unit == 0x0A && previous == 0x0D);
  return isArabicScript(unit) && !isIgnorable(unit);
}

List<MatchRange> _snapToClusters(String text, List<MatchRange> ranges) {
  final boundaries = <int>[0];
  var offset = 0;
  for (final cluster in text.characters) {
    offset += cluster.length;
    boundaries.add(offset);
  }

  int snapDown(int at) {
    var result = 0;
    for (final boundary in boundaries) {
      if (boundary > at) break;
      result = boundary;
    }
    return result;
  }

  int snapUp(int at) {
    for (final boundary in boundaries) {
      if (boundary >= at) return boundary;
    }
    return text.length;
  }

  return [
    for (final range in ranges)
      MatchRange(snapDown(range.start), snapUp(range.end)),
  ];
}
