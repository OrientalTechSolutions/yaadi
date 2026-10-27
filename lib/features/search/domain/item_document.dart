import '../../items/domain/item.dart';
import 'concept.dart';
import 'highlight.dart';
import 'household_lexicon.dart';
import 'text_normalizer.dart';

/// Every distinct word of the indexed items, numbered. A query then decides
/// once per distinct word, not once per occurrence, whether it matches.
///
/// It only grows. Words of deleted items stay, which costs a little memory
/// and nothing else.
final class Vocabulary {
  final _ids = <String, int>{};
  final _base = <String>[];
  final _folded = <String>[];

  int get length => _base.length;

  String baseOf(int id) => _base[id];

  String foldedOf(int id) => _folded[id];

  int idOf(SearchToken token) => _ids[token.base] ??= _add(token);

  int _add(SearchToken token) {
    _base.add(token.base);
    _folded.add(token.folded);
    return _base.length - 1;
  }
}

/// One searchable text field of an item.
final class DocumentField {
  DocumentField._(this.tokens, this.words, this.concepts);

  factory DocumentField.of(
    String? text,
    HouseholdLexicon lexicon,
    Vocabulary vocabulary,
  ) {
    if (text == null || text.isEmpty) return empty;
    final tokens = tokenize(text);
    final keys = [for (final token in tokens) token.folded];
    final concepts = <String, List<MatchRange>>{};
    var i = 0;
    while (i < tokens.length) {
      final phrases = lexicon.longestAt(keys, i);
      if (phrases.isEmpty) {
        i++;
        continue;
      }
      final length = phrases.first.length;
      final span = MatchRange(tokens[i].start, tokens[i + length - 1].end);
      for (final phrase in phrases) {
        for (final tag in phrase.concept.itemTags) {
          concepts.putIfAbsent(tag, () => []).add(span);
        }
      }
      i += length;
    }
    return DocumentField._(tokens, [
      for (final token in tokens) vocabulary.idOf(token),
    ], concepts);
  }

  static final empty = DocumentField._(const [], const [], const {});

  final List<SearchToken> tokens;

  /// The vocabulary id of each token.
  final List<int> words;

  /// Concepts the text names, each with the words that named it.
  final Map<String, List<MatchRange>> concepts;
}

/// What search knows about one item, built once and kept while the item is
/// unchanged. The reference is never part of it (ARCHITECTURE.md section 7).
final class ItemDocument {
  ItemDocument.of(this.item, HouseholdLexicon lexicon, Vocabulary vocabulary)
    : title = DocumentField.of(item.title, lexicon, vocabulary),
      notes = DocumentField.of(item.notes, lexicon, vocabulary),
      categoryTag = Concept.categoryId(item.category),
      kindTag = Concept.kindId(item.kind);

  final Item item;
  final DocumentField title;
  final DocumentField notes;
  final String categoryTag;
  final String kindTag;
}
