import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/auto_direction_field.dart';
import '../../../core/widgets/content_list_view.dart';
import '../../../core/widgets/heading.dart';
import '../../../core/widgets/message_view.dart';
import '../../../core/widgets/user_text.dart';
import '../../../l10n/app_localizations.dart';
import '../../demo/presentation/demo_badge.dart';
import '../../items/presentation/item_labels.dart';
import '../../items/presentation/item_routes.dart';
import '../../items/presentation/item_tile.dart';
import '../application/search_providers.dart';
import '../domain/region.dart';
import '../domain/search_index.dart';
import 'snippet.dart';

/// Offline search in English, Urdu script and Roman Urdu, with the matches
/// highlighted as the user types.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _query = TextEditingController(
    text: ref.read(searchQueryProvider),
  );

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _search(String query) {
    if (_query.text != query) _query.text = query;
    ref.read(searchQueryProvider.notifier).update(query);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = ref.watch(searchQueryProvider);
    final results = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: ContentAppBar(
        title: Text(l10n.navSearch),
        actions: const [DemoBadge()],
      ),
      body: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final gutter = contentGutter(constraints.maxWidth);
              return Padding(
                padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 8),
                child: AutoDirectionField(
                  controller: _query,
                  textInputAction: TextInputAction.search,
                  textCapitalization: TextCapitalization.none,
                  onChanged: _search,
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    // No floating label here, so the text sits in the
                    // middle; the Urdu theme's extra room is for labels.
                    contentPadding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: l10n.clearSearch,
                            icon: const Icon(Icons.close),
                            onPressed: () => _search(''),
                          ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(28)),
                    ),
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: query.trim().isEmpty
                ? _Suggestions(onPick: _search)
                : results.isEmpty
                // Announced like the result count, so a query with no
                // matches is not silence.
                ? Semantics(
                    liveRegion: true,
                    container: true,
                    child: MessageView(
                      icon: Icons.search_off,
                      title: l10n.searchNoResults,
                      body: l10n.searchNoResultsHint,
                    ),
                  )
                : _Results(results: results),
          ),
        ],
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.results});

  final List<SearchResult> results;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final gutter = contentGutter(constraints.maxWidth);
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(gutter, 0, gutter, 24),
          itemCount: results.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Semantics(
                liveRegion: true,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 4),
                  child: Text(
                    l10n.searchResultCount(results.length),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              );
            }
            final result = results[index - 1];
            return _ResultTile(key: ValueKey(result.item.id), result: result);
          },
        );
      },
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({super.key, required this.result});

  final SearchResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final item = result.item;
    final highlight = TextStyle(
      backgroundColor: theme.colorScheme.tertiaryContainer,
      color: theme.colorScheme.onTertiaryContainer,
    );
    final notes = item.notes;
    final (snippet, snippetRanges) = notes == null || result.notesRanges.isEmpty
        ? ('', const <TextRange>[])
        : snippetAround(notes, result.notesRanges);

    return ListTile(
      contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 4),
      leading: KindAvatar(kind: item.kind),
      title: UserText(
        item.title,
        highlights: [
          for (final range in result.titleRanges)
            TextRange(start: range.start, end: range.end),
        ],
        highlightStyle: highlight,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: l10n.categoryLabel(item.category),
                  style: result.categoryMatched ? highlight : null,
                ),
                const TextSpan(text: ' · '),
                TextSpan(
                  text: l10n.kindLabel(item.kind),
                  style: result.kindMatched ? highlight : null,
                ),
                TextSpan(text: ' · ${l10n.dateSummary(item)}'),
              ],
            ),
          ),
          if (snippet.isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 2),
              child: UserText(
                snippet,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                highlights: snippetRanges,
                highlightStyle: highlight,
              ),
            ),
        ],
      ),
      trailing: item.isOpen
          ? null
          : StatusBadge(label: l10n.statusLabel(item.status)),
      onTap: () => openItemDetails(context, item.id),
    );
  }
}

/// Before anything is typed: what search understands, with a few words to
/// try in the household's own mix of languages.
class _Suggestions extends ConsumerWidget {
  const _Suggestions({required this.onPick});

  final ValueChanged<String> onPick;

  static const _pakistan = [
    'bijli ka bill',
    'گیس',
    'ammi ki dawai',
    'shanakhti card',
    'fees',
    'کرایہ',
  ];
  static const _english = [
    'council tax',
    'dentist',
    'prescription',
    'MOT',
    'passport',
    'energy',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final words = ref.watch(searchRegionProvider) == Region.pk
        ? _pakistan
        : _english;
    return ContentListView(
      children: [
        Text(
          l10n.searchExplain,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Heading(l10n.searchTry, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final word in words)
              // On the web a chip is announced as an unchecked checkbox;
              // these are buttons.
              Semantics(
                button: true,
                label: word,
                onTap: () => onPick(word),
                excludeSemantics: true,
                child: ActionChip(
                  label: UserText(word),
                  onPressed: () => onPick(word),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
