import 'household_lexicon.dart';
import 'text_normalizer.dart';

/// How well a query word matched. Tiers are compared before any weight, so
/// an exact or concept match always outranks a prefix, and a prefix always
/// outranks a typo.
enum MatchTier {
  exact(1.0),
  prefix(0.75),
  oneEdit(0.5);

  const MatchTier(this.quality);

  /// The quality of a literal match at this tier.
  final double quality;

  /// A concept match is a little weaker than the same word typed exactly.
  double get conceptQuality => this == exact ? 0.9 : quality;
}

/// One thing the query asks for: a word, or a lexicon phrase such as
/// "shanakhti card". Every term must match for an item to be found.
final class QueryTerm {
  const QueryTerm({
    required this.tokens,
    required this.concepts,
    this.prefix = false,
    this.fuzzy = false,
  });

  /// The query words this term covers, in order.
  final List<SearchToken> tokens;

  /// Concept ids the words name, each with the tier it was reached at.
  final Map<String, MatchTier> concepts;

  /// The last word is still being typed and may match as a prefix.
  final bool prefix;

  /// A word one edit away also counts.
  final bool fuzzy;
}

/// A query split into terms.
final class SearchQuery {
  const SearchQuery._(this.terms);

  /// Reads [text] the way it is typed.
  ///
  /// Lexicon phrases are matched first, longest first, so "id card" and "sui
  /// gas" stay together. Stopwords and lone letters are then dropped, so
  /// "bijli ka bill" asks for bijli and bill. The last word counts as a
  /// prefix from two characters while nothing follows it, so results do not
  /// vanish and come back between keystrokes. A word that is itself a
  /// lexicon term is never fuzzy: "lesco" must not find IESCO.
  factory SearchQuery.parse(String text, HouseholdLexicon lexicon) {
    final tokens = tokenize(text);
    if (tokens.isEmpty) return empty;
    final keys = [for (final token in tokens) token.folded];
    final typing = text.substring(tokens.last.end).runes.every(isIgnorable);

    final terms = <QueryTerm>[];
    var i = 0;
    while (i < tokens.length) {
      final exact = lexicon.longestAt(keys, i);
      if (exact.isNotEmpty && exact.first.length > 1) {
        final length = exact.first.length;
        terms.add(
          QueryTerm(
            tokens: tokens.sublist(i, i + length),
            concepts: {
              for (final phrase in exact) phrase.concept.id: MatchTier.exact,
            },
          ),
        );
        i += length;
        continue;
      }

      if (typing && tokens.length - i > 1) {
        final last = tokens.last;
        final partial = lexicon.completing(
          keys,
          i,
          base: last.base,
          folded: last.folded,
        );
        if (partial.isNotEmpty) {
          terms.add(
            QueryTerm(
              tokens: tokens.sublist(i),
              concepts: {
                for (final phrase in partial)
                  phrase.concept.id: MatchTier.prefix,
              },
              prefix: true,
            ),
          );
          break;
        }
      }

      final token = tokens[i];
      i++;
      final isTerm = exact.isNotEmpty;
      if (!isTerm &&
          (lexicon.isStopword(token.folded) || _isLoneLetter(token))) {
        continue;
      }

      final prefix = typing && i == tokens.length && token.base.length >= 2;
      final fuzzy =
          !isTerm &&
          !_isNumber(token) &&
          token.folded.length >= HouseholdLexicon.minFuzzyLength;
      final concepts = <String, MatchTier>{
        for (final phrase in exact) phrase.concept.id: MatchTier.exact,
      };
      if (prefix) {
        for (final phrase in lexicon.completing(
          keys,
          tokens.length - 1,
          base: token.base,
          folded: token.folded,
        )) {
          concepts.putIfAbsent(phrase.concept.id, () => MatchTier.prefix);
        }
      }
      if (fuzzy) {
        for (final phrase in lexicon.withinOneEditOf(token.folded)) {
          concepts.putIfAbsent(phrase.concept.id, () => MatchTier.oneEdit);
        }
      }
      terms.add(
        QueryTerm(
          tokens: [token],
          concepts: concepts,
          prefix: prefix,
          fuzzy: fuzzy,
        ),
      );
    }

    // A word being typed can start out as a stopword: "me" on the way to
    // "meeting", "ki" to "kiran". Alone, it is kept as a prefix, or the
    // results would vanish and come back between keystrokes.
    final last = tokens.last;
    if (terms.isEmpty && typing && last.base.length >= 2) {
      terms.add(
        QueryTerm(
          tokens: [last],
          concepts: {
            for (final phrase in lexicon.completing(
              keys,
              tokens.length - 1,
              base: last.base,
              folded: last.folded,
            ))
              phrase.concept.id: MatchTier.prefix,
          },
          prefix: true,
        ),
      );
    }
    return SearchQuery._(List.unmodifiable(terms));
  }

  static const empty = SearchQuery._([]);

  final List<QueryTerm> terms;

  bool get isEmpty => terms.isEmpty;
}

bool _isLoneLetter(SearchToken token) =>
    token.base.length == 1 && !_isNumber(token);

final _digits = RegExp(r'^[0-9]+$');

bool _isNumber(SearchToken token) => _digits.hasMatch(token.base);
