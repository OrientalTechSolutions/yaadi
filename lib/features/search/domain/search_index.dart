import '../../../core/time/local_date.dart';
import '../../items/domain/item.dart';
import 'edit_distance.dart';
import 'highlight.dart';
import 'household_lexicon.dart';
import 'item_document.dart';
import 'search_query.dart';
import 'text_normalizer.dart';

/// One item that matched, with what to highlight.
final class SearchResult {
  SearchResult._(
    this.item,
    this._titleMatches,
    this._notesMatches, {
    required this.tier,
    required this.score,
    required this.categoryMatched,
    required this.kindMatched,
  });

  final Item item;

  /// The weakest tier among the query's terms.
  final MatchTier tier;

  /// Field weight times match quality, summed over fields and terms.
  final double score;

  /// The category or kind matched. With no words to point at, the result
  /// emphasizes its category or kind label instead.
  final bool categoryMatched;
  final bool kindMatched;

  final List<MatchRange> _titleMatches;
  final List<MatchRange> _notesMatches;

  // Tidied on first use: a broad query can match thousands of items, and
  // only the ones on screen are ever highlighted.

  /// Where the title matched, merged and on grapheme boundaries.
  late final List<MatchRange> titleRanges = tidyRanges(
    item.title,
    _titleMatches,
  );

  /// Where the notes matched, merged and on grapheme boundaries.
  late final List<MatchRange> notesRanges = tidyRanges(
    item.notes ?? '',
    _notesMatches,
  );

  @override
  String toString() =>
      'SearchResult(${item.id}, ${tier.name}, ${score.toStringAsFixed(2)})';
}

/// Finds items by what the user types, in English, Urdu or Roman Urdu.
abstract interface class SearchIndex {
  /// Items matching every term of [query], best first. [today] breaks ties
  /// in favour of what is due soonest.
  List<SearchResult> search(String query, {required LocalDate today});
}

/// Field weights from ARCHITECTURE.md section 12.
abstract final class SearchWeights {
  static const title = 3.0;
  static const category = 2.0;
  static const kind = 1.5;
  static const notes = 1.0;
}

/// Keeps one [ItemDocument] per item and rebuilds it only when the item
/// changes, so typing a query never re-tokenizes the household.
final class SearchDocuments {
  SearchDocuments(this.lexicon);

  final HouseholdLexicon lexicon;
  final _vocabulary = Vocabulary();
  final _cache = <String, ItemDocument>{};

  SearchIndex index(Iterable<Item> items) {
    final documents = <ItemDocument>[];
    final seen = <String>{};
    for (final item in items) {
      seen.add(item.id);
      final cached = _cache[item.id];
      // Compared whole rather than by revision: the demo households are
      // rebuilt from their seed with the same ids and revisions but new
      // dates.
      final document = cached != null && cached.item == item
          ? cached
          : _cache[item.id] = ItemDocument.of(item, lexicon, _vocabulary);
      documents.add(document);
    }
    _cache.removeWhere((id, _) => !seen.contains(id));
    return LinearSearchIndex(
      List.unmodifiable(documents),
      lexicon,
      _vocabulary,
    );
  }
}

/// Scans every document for each query. Each query first decides which
/// distinct words match, then the scan is a lookup per word, which keeps
/// 5,000 items within a few milliseconds. The interface leaves room for an
/// inverted index if a profile ever asks for one.
final class LinearSearchIndex implements SearchIndex {
  LinearSearchIndex(this.documents, this.lexicon, this._vocabulary);

  final List<ItemDocument> documents;
  final HouseholdLexicon lexicon;
  final Vocabulary _vocabulary;

  @override
  List<SearchResult> search(String query, {required LocalDate today}) {
    final parsed = SearchQuery.parse(query, lexicon);
    if (parsed.isEmpty) return const [];
    final matchers = [
      for (final term in parsed.terms) _TermMatcher(term, _vocabulary),
    ];

    final ranked = [
      for (final document in documents)
        if (_match(document, matchers) case final result?)
          (result: result, distance: _distance(result.item, today)),
    ]..sort(_compare);
    return [for (final entry in ranked) entry.result];
  }

  SearchResult? _match(ItemDocument document, List<_TermMatcher> matchers) {
    var tier = MatchTier.exact;
    var score = 0.0;
    var categoryMatched = false;
    var kindMatched = false;
    List<MatchRange>? titleMatches;
    List<MatchRange>? notesMatches;

    for (final matcher in matchers) {
      final category = matcher.concepts[document.categoryTag];
      final kind = matcher.concepts[document.kindTag];
      final title = matcher.inText(document.title);
      final notes = matcher.inText(document.notes);
      final best = _stronger(
        _stronger(title?.tier, notes?.tier),
        _stronger(category, kind),
      );
      if (best == null) return null;

      if (best.index > tier.index) tier = best;
      score +=
          (title?.quality ?? 0) * SearchWeights.title +
          (notes?.quality ?? 0) * SearchWeights.notes +
          (category?.conceptQuality ?? 0) * SearchWeights.category +
          (kind?.conceptQuality ?? 0) * SearchWeights.kind;
      if (title != null) (titleMatches ??= []).addAll(title.ranges);
      if (notes != null) (notesMatches ??= []).addAll(notes.ranges);
      categoryMatched |= category != null;
      kindMatched |= kind != null;
    }

    return SearchResult._(
      document.item,
      titleMatches ?? const [],
      notesMatches ?? const [],
      tier: tier,
      score: score,
      categoryMatched: categoryMatched,
      kindMatched: kindMatched,
    );
  }
}

MatchTier? _stronger(MatchTier? a, MatchTier? b) {
  if (a == null) return b;
  if (b == null) return a;
  return a.index <= b.index ? a : b;
}

/// The best way one term matched one field, and every place it matched.
final class _FieldMatch {
  _FieldMatch(this.tier, this.quality);

  /// [match] with one more place the term matched; created on the first.
  static _FieldMatch including(
    _FieldMatch? match,
    MatchTier tier,
    double quality,
    MatchRange range, {
    required bool concept,
  }) =>
      (match ?? _FieldMatch(tier, quality))
        .._add(tier, quality, range, concept: concept);

  MatchTier tier;
  double quality;
  final _literal = <MatchRange>[];
  final _concept = <MatchRange>[];

  /// Where to highlight. A concept span that covers a word already matched
  /// literally gives way, so typing "scho" marks "scho" in "school" rather
  /// than the whole word.
  List<MatchRange> get ranges => [
    ..._literal,
    for (final span in _concept)
      if (!_literal.any((r) => r.start < span.end && span.start < r.end)) span,
  ];

  void _add(
    MatchTier tier,
    double quality,
    MatchRange range, {
    required bool concept,
  }) {
    (concept ? _concept : _literal).add(range);
    if (tier.index < this.tier.index ||
        (tier == this.tier && quality > this.quality)) {
      this.tier = tier;
      this.quality = quality;
    }
  }
}

/// Matches one query term against documents. Which words of the vocabulary
/// match each query word, and how well, is worked out once per query, so
/// scanning a document costs one list lookup per word.
final class _TermMatcher {
  _TermMatcher(this.term, Vocabulary vocabulary)
    : _tiers = [
        for (var i = 0; i < term.tokens.length; i++)
          _tiersFor(term, i, vocabulary),
      ];

  final QueryTerm term;

  /// For each query word, the tier at which each vocabulary word matches
  /// it, by vocabulary id; null where it does not.
  final List<List<MatchTier?>> _tiers;

  Map<String, MatchTier> get concepts => term.concepts;

  static List<MatchTier?> _tiersFor(
    QueryTerm term,
    int index,
    Vocabulary vocabulary,
  ) {
    final word = term.tokens[index];
    final prefix = term.prefix && index == term.tokens.length - 1;
    final byFolded = foldedPrefixIsSafe(word.base);
    final fuzzy = term.fuzzy && term.tokens.length == 1;
    return List.generate(vocabulary.length, (id) {
      final folded = vocabulary.foldedOf(id);
      if (folded == word.folded) return MatchTier.exact;
      if (prefix &&
          (vocabulary.baseOf(id).startsWith(word.base) ||
              (byFolded && folded.startsWith(word.folded)))) {
        return MatchTier.prefix;
      }
      if (fuzzy &&
          folded.length >= HouseholdLexicon.minFuzzyLength &&
          withinOneEdit(word.folded, folded)) {
        return MatchTier.oneEdit;
      }
      return null;
    }, growable: false);
  }

  _FieldMatch? inText(DocumentField field) {
    _FieldMatch? best;
    if (field.concepts.isNotEmpty && term.concepts.isNotEmpty) {
      for (final id in field.concepts.keys) {
        final tier = term.concepts[id];
        if (tier == null) continue;
        for (final span in field.concepts[id]!) {
          best = _FieldMatch.including(
            best,
            tier,
            tier.conceptQuality,
            span,
            concept: true,
          );
        }
      }
    }

    final length = _tiers.length;
    for (var start = 0; start + length <= field.words.length; start++) {
      if (_literalAt(field, start) case (:final tier, :final end)) {
        best = _FieldMatch.including(
          best,
          tier,
          tier.quality,
          MatchRange(field.tokens[start].start, end),
          concept: false,
        );
      }
    }
    return best;
  }

  /// Whether the term's words appear in [field] from word [start] on, at
  /// the weakest tier among them, and where the match ends.
  ({MatchTier tier, int end})? _literalAt(DocumentField field, int start) {
    var tier = MatchTier.exact;
    MatchTier? lastTier;
    for (var i = 0; i < _tiers.length; i++) {
      lastTier = _tiers[i][field.words[start + i]];
      if (lastTier == null) return null;
      if (lastTier.index > tier.index) tier = lastTier;
    }
    final last = field.tokens[start + _tiers.length - 1];
    final end = lastTier == MatchTier.prefix
        ? _prefixEnd(last, term.tokens.last)
        : last.end;
    return (tier: tier, end: end);
  }

  /// Where a prefix match of [word] ends inside [token]. Words in Arabic
  /// script are highlighted whole so Nastaliq joining never breaks.
  int _prefixEnd(SearchToken token, SearchToken word) {
    if (token.isArabic) return token.end;
    if (token.base.startsWith(word.base)) {
      return token.baseEndAt(word.base.length);
    }
    return token.foldedEndAt(word.folded.length);
  }
}

typedef _Ranked = ({SearchResult result, int? distance});

/// Days between [today] and the item's date in either direction, or null
/// for an undated task.
int? _distance(Item item, LocalDate today) => switch (item.effectiveOn(today)) {
  null => null,
  final on => today.daysUntil(on).abs(),
};

/// Tier first, then score. Ties go to open items, then the nearest date,
/// then the title.
int _compare(_Ranked a, _Ranked b) {
  final byTier = a.result.tier.index.compareTo(b.result.tier.index);
  if (byTier != 0) return byTier;
  final byScore = b.result.score.compareTo(a.result.score);
  if (byScore != 0) return byScore;
  final aOpen = a.result.item.isOpen;
  if (aOpen != b.result.item.isOpen) return aOpen ? -1 : 1;
  final aDistance = a.distance;
  final bDistance = b.distance;
  if (aDistance != bDistance) {
    if (aDistance == null) return 1;
    if (bDistance == null) return -1;
    return aDistance.compareTo(bDistance);
  }
  final byTitle = a.result.item.title.toLowerCase().compareTo(
    b.result.item.title.toLowerCase(),
  );
  return byTitle != 0 ? byTitle : a.result.item.id.compareTo(b.result.item.id);
}
