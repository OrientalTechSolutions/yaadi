import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/time/clock.dart';
import '../../items/application/items_providers.dart';
import '../../items/domain/item.dart';
import '../../settings/application/settings_controller.dart';
import '../domain/household_lexicon.dart';
import '../domain/region.dart';
import '../domain/search_index.dart';

/// Whose billers and proper nouns search understands, from the household's
/// currency.
final searchRegionProvider = Provider<Region>(
  (ref) => Region.forCurrency(
    ref.watch(appSettingsProvider.select((s) => s.defaultCurrency)),
  ),
);

final searchLexiconProvider = Provider<HouseholdLexicon>(
  (ref) => HouseholdLexicon.forRegion(ref.watch(searchRegionProvider)),
);

/// Lives as long as the lexicon, so item documents survive every change to
/// the item list and only changed items are tokenized again.
final _searchDocumentsProvider = Provider<SearchDocuments>(
  (ref) => SearchDocuments(ref.watch(searchLexiconProvider)),
);

final searchIndexProvider = Provider<SearchIndex>((ref) {
  final items = ref.watch(itemsProvider).value ?? const <Item>[];
  return ref.watch(_searchDocumentsProvider).index(items);
});

/// What the user has typed into search.
final searchQueryProvider = NotifierProvider<SearchQueryController, String>(
  SearchQueryController.new,
);

class SearchQueryController extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;

  void clear() => state = '';
}

/// Results for the current query, best first; empty while nothing is typed.
///
/// The index is watched even then, so the items are loaded and tokenized by
/// the time the first letter arrives.
final searchResultsProvider = Provider<List<SearchResult>>((ref) {
  final index = ref.watch(searchIndexProvider);
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return const [];
  return index.search(query, today: ref.watch(todayProvider));
});
