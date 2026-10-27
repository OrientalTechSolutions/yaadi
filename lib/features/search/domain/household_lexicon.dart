import 'package:meta/meta.dart';

import 'concept.dart';
import 'edit_distance.dart';
import 'household_terms.dart';
import 'region.dart';
import 'text_normalizer.dart';

/// One lexicon term after normalization: the keys of its words and the
/// concept it names.
@immutable
final class LexiconPhrase {
  const LexiconPhrase(this.base, this.folded, this.concept);

  final List<String> base;
  final List<String> folded;
  final Concept concept;

  int get length => folded.length;

  @override
  String toString() => 'LexiconPhrase(${folded.join(' ')} -> ${concept.id})';
}

/// The household lexicon for one region, normalized and ready to match.
final class HouseholdLexicon {
  HouseholdLexicon._(this.region, this._byFirstWord, this._stopwords);

  /// Builds the lexicon from [concepts], skipping names that belong to
  /// another country.
  factory HouseholdLexicon.forRegion(
    Region region, {
    List<Concept> concepts = householdConcepts,
    List<String> stopwords = householdStopwords,
  }) {
    final byFirstWord = <String, List<LexiconPhrase>>{};
    for (final concept in concepts) {
      if (!concept.appliesIn(region)) continue;
      for (final term in concept.terms) {
        final tokens = tokenize(term);
        if (tokens.isEmpty || tokens.length > maxPhraseWords) {
          throw ArgumentError.value(term, 'term', 'Must be 1 to 3 words');
        }
        final phrase = LexiconPhrase(
          List.unmodifiable(tokens.map((token) => token.base)),
          List.unmodifiable(tokens.map((token) => token.folded)),
          concept,
        );
        byFirstWord.putIfAbsent(phrase.folded.first, () => []).add(phrase);
      }
    }
    for (final phrases in byFirstWord.values) {
      phrases.sort((a, b) => b.length.compareTo(a.length));
    }
    return HouseholdLexicon._(region, byFirstWord, {
      for (final word in stopwords) ...tokenize(word).map((t) => t.folded),
    });
  }

  static const maxPhraseWords = 3;

  final Region region;
  final Map<String, List<LexiconPhrase>> _byFirstWord;
  final Set<String> _stopwords;

  Iterable<LexiconPhrase> get phrases => _byFirstWord.values.expand((p) => p);

  bool isStopword(String folded) => _stopwords.contains(folded);

  /// The longest phrases whose words equal [keys] from [index] on; several
  /// when one spelling names more than one concept. Empty when none does.
  List<LexiconPhrase> longestAt(List<String> keys, int index) {
    final candidates = _byFirstWord[keys[index]];
    if (candidates == null) return const [];
    for (final phrase in candidates) {
      if (_matchesAt(phrase, keys, index)) {
        return [
          for (final other in candidates)
            if (other.length == phrase.length && _matchesAt(other, keys, index))
              other,
        ];
      }
    }
    return const [];
  }

  /// Phrases that run from [index] to the last key and match that last key
  /// only as a prefix: what the user may be in the middle of typing.
  /// [base] and [folded] hold the last word's two keys.
  List<LexiconPhrase> completing(
    List<String> keys,
    int index, {
    required String base,
    required String folded,
  }) {
    final length = keys.length - index;
    final candidates = length == 1 ? phrases : _byFirstWord[keys[index]] ?? [];
    final byFolded = foldedPrefixIsSafe(base);
    return [
      for (final phrase in candidates)
        if (phrase.length == length &&
            _matchesAt(phrase, keys, index, words: length - 1) &&
            (phrase.base.last.startsWith(base) ||
                (byFolded && phrase.folded.last.startsWith(folded))))
          phrase,
    ];
  }

  /// One-word terms within one edit of [folded], for typos such as
  /// "electrisity". Only words of four letters or more qualify.
  List<LexiconPhrase> withinOneEditOf(String folded) => [
    if (folded.length >= minFuzzyLength)
      for (final phrase in phrases)
        if (phrase.length == 1 &&
            phrase.folded.single.length >= minFuzzyLength &&
            withinOneEdit(folded, phrase.folded.single))
          phrase,
  ];

  /// Shorter words have too many neighbours one edit away.
  static const minFuzzyLength = 4;

  bool _matchesAt(
    LexiconPhrase phrase,
    List<String> keys,
    int index, {
    int? words,
  }) {
    final count = words ?? phrase.length;
    if (index + phrase.length > keys.length) return false;
    for (var i = 0; i < count; i++) {
      if (phrase.folded[i] != keys[index + i]) return false;
    }
    return true;
  }
}
