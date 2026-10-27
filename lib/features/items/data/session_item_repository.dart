import 'dart:convert';

import '../../../core/platform/session_store.dart';
import '../domain/completion.dart';
import '../domain/item.dart';
import 'item_json.dart';
import 'memory_item_repository.dart';

/// Where the web demo keeps its items in the browser session.
const sessionItemsKey = 'yaadi.demo.items.v1';

/// The web demo's items: memory, written to the tab's `sessionStorage` after
/// every change. Nothing here is encrypted, and the demo says so on screen.
MemoryItemRepository sessionItemRepository(SessionStore store) {
  final (items, completions) = _load(store.read(sessionItemsKey));
  return MemoryItemRepository(
    items: items,
    completions: completions,
    onChanged: (items, completions) => store.write(
      sessionItemsKey,
      jsonEncode({
        'items': [for (final item in items) itemToJson(item)],
        'completions': [
          for (final completion in completions) completionToJson(completion),
        ],
      }),
    ),
  );
}

/// Skips anything that does not read back, so a half-written or older copy
/// costs those entries rather than the whole demo.
(List<Item>, List<Completion>) _load(String? saved) {
  if (saved == null) return (const [], const []);
  final Object? json;
  try {
    json = jsonDecode(saved);
  } on FormatException {
    return (const [], const []);
  }
  if (json is! Map<String, Object?>) return (const [], const []);

  final items = [
    for (final item in _readEach(json['items'], itemFromJson))
      if (item.violations.isEmpty) item,
  ];
  final ids = {for (final item in items) item.id};
  final completions = [
    for (final completion in _readEach(json['completions'], completionFromJson))
      if (ids.contains(completion.itemId)) completion,
  ];
  return (items, completions);
}

List<T> _readEach<T>(Object? list, T Function(Map<String, Object?>) read) {
  if (list is! List<Object?>) return const [];
  final result = <T>[];
  for (final entry in list) {
    if (entry is! Map<String, Object?>) continue;
    try {
      result.add(read(entry));
    } on Object {
      continue;
    }
  }
  return result;
}
