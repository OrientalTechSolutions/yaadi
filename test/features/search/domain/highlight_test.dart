import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/features/search/domain/highlight.dart';

void main() {
  test('sorts and merges overlapping and touching ranges', () {
    expect(
      tidyRanges('LESCO bill November', const [
        MatchRange(6, 10),
        MatchRange(0, 5),
        MatchRange(3, 6),
        MatchRange(11, 14),
      ]),
      const [MatchRange(0, 10), MatchRange(11, 14)],
    );
  });

  test('widens a range to whole grapheme clusters', () {
    // e followed by a combining acute accent is one cluster.
    final text = String.fromCharCodes([0x43, 0x61, 0x66, 0x65, 0x301, 0x20]);
    expect(tidyRanges(text, const [MatchRange(3, 4)]), const [
      MatchRange(3, 5),
    ]);
    // A haraka stays with its letter.
    expect(tidyRanges('دَوا', const [MatchRange(0, 1)]), const [
      MatchRange(0, 2),
    ]);
  });

  test('keeps ranges inside the text and drops empty ones', () {
    expect(tidyRanges('bill', const [MatchRange(2, 99)]), const [
      MatchRange(2, 4),
    ]);
    expect(tidyRanges('bill', const [MatchRange(2, 2)]), isEmpty);
    expect(tidyRanges('bill', const []), isEmpty);
  });
}
