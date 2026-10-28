import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import '../../../core/time/clock.dart';
import '../../../core/time/local_date.dart';
import '../../today/domain/doses.dart';
import '../domain/item.dart';
import '../domain/item_kind.dart';
import 'items_providers.dart';

enum StatusFilter { open, closed, all }

/// Whether [item] still needs something on [today]: open, and not a
/// medicine course whose last day has passed. Such a course has left Today
/// and is listed with the finished items.
bool isActive(Item item, LocalDate today) =>
    item.isOpen && !item.courseEndedBefore(today);

/// Which items the Items screen lists.
@immutable
final class ItemFilter {
  const ItemFilter({this.status = StatusFilter.open, this.kind});

  final StatusFilter status;

  /// Null lists every kind.
  final ItemKind? kind;

  bool matches(Item item, LocalDate today) =>
      (kind == null || item.kind == kind) &&
      switch (status) {
        StatusFilter.open => isActive(item, today),
        StatusFilter.closed => !isActive(item, today),
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
  /// Starts afresh with other items: after Delete all, or in another demo
  /// household on a phone, last time's filter would only hide things. The
  /// web demo keeps one repository, so its household switch resets this
  /// from the home screen.
  @override
  ItemFilter build() {
    ref.watch(itemRepositoryProvider);
    return const ItemFilter();
  }

  void showStatus(StatusFilter status) =>
      state = state.copyWith(status: status);

  /// Null shows every kind.
  void showKind(ItemKind? kind) => state = state.copyWith(kind: kind);
}

/// The Items screen's list: open items in due order, finished ones most
/// recently changed first.
final filteredItemsProvider = Provider<AsyncValue<List<Item>>>((ref) {
  final filter = ref.watch(itemFilterProvider);
  final today = ref.watch(todayProvider);
  return ref.watch(itemsProvider).whenData((items) {
    final active = [
      for (final item in items)
        if (isActive(item, today) && filter.matches(item, today)) item,
    ];
    final finished = [
      for (final item in items)
        if (!isActive(item, today) && filter.matches(item, today)) item,
    ]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return [...active, ...finished];
  });
});
