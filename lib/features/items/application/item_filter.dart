import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import '../domain/item.dart';
import '../domain/item_kind.dart';
import 'items_providers.dart';

enum StatusFilter { open, closed, all }

/// Which items the Items screen lists.
@immutable
final class ItemFilter {
  const ItemFilter({this.status = StatusFilter.open, this.kind});

  final StatusFilter status;

  /// Null lists every kind.
  final ItemKind? kind;

  bool matches(Item item) =>
      (kind == null || item.kind == kind) &&
      switch (status) {
        StatusFilter.open => item.isOpen,
        StatusFilter.closed => !item.isOpen,
        StatusFilter.all => true,
      };

  ItemFilter copyWith({StatusFilter? status, Object? kind = _keep}) =>
      ItemFilter(
        status: status ?? this.status,
        kind: identical(kind, _keep) ? this.kind : kind as ItemKind?,
      );

  @override
  bool operator ==(Object other) =>
      other is ItemFilter && other.status == status && other.kind == kind;

  @override
  int get hashCode => Object.hash(status, kind);
}

const Object _keep = Object();

final itemFilterProvider = NotifierProvider<ItemFilterController, ItemFilter>(
  ItemFilterController.new,
);

class ItemFilterController extends Notifier<ItemFilter> {
  @override
  ItemFilter build() => const ItemFilter();

  void showStatus(StatusFilter status) =>
      state = state.copyWith(status: status);

  /// Null shows every kind.
  void showKind(ItemKind? kind) => state = state.copyWith(kind: kind);
}

/// The Items screen's list: open items in due order, closed ones most
/// recently finished first.
final filteredItemsProvider = Provider<AsyncValue<List<Item>>>((ref) {
  final filter = ref.watch(itemFilterProvider);
  return ref.watch(itemsProvider).whenData((items) {
    final open = [
      for (final item in items)
        if (item.isOpen && filter.matches(item)) item,
    ];
    final closed = [
      for (final item in items)
        if (!item.isOpen && filter.matches(item)) item,
    ]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return [...open, ...closed];
  });
});
