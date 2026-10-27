import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/features/search/domain/highlight.dart';
import 'package:yaadi/features/search/presentation/snippet.dart';

void main() {
  test('short notes are shown whole', () {
    final (text, ranges) = snippetAround('Renew at the NADRA office', const [
      MatchRange(13, 18),
    ]);
    expect(text, 'Renew at the NADRA office');
    expect(ranges.single.textInside(text), 'NADRA');
  });

  test('long notes are cut on spaces around the first match', () {
    final notes = '${'word ' * 30}NADRA office${' more' * 30}';
    final start = notes.indexOf('NADRA');
    final (text, ranges) = snippetAround(notes, [MatchRange(start, start + 5)]);

    expect(text, startsWith('… '));
    expect(text, endsWith(' …'));
    expect(text.length, lessThan(notes.length));
    expect(ranges.single.textInside(text), 'NADRA');
    expect(text.substring(2).split(' ').first, isNot(isEmpty));
  });

  test('matches outside the snippet are dropped', () {
    final notes = '${'a ' * 80}first${' b' * 80} second';
    final first = notes.indexOf('first');
    final second = notes.indexOf('second');
    final (text, ranges) = snippetAround(notes, [
      MatchRange(first, first + 5),
      MatchRange(second, second + 6),
    ]);
    expect(ranges.map((range) => range.textInside(text)), ['first']);
  });

  test('Urdu notes are cut on spaces too', () {
    final notes = '${'لفظ ' * 30}ناردا دفتر${' مزید' * 30}';
    final start = notes.indexOf('ناردا');
    final (text, ranges) = snippetAround(notes, [MatchRange(start, start + 5)]);
    expect(ranges.single.textInside(text), 'ناردا');
  });
}
