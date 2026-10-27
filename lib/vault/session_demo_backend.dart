import '../core/platform/session_store.dart';
import '../features/items/data/session_item_repository.dart';
import '../features/settings/data/settings_repository.dart';
import 'app_storage.dart';

/// Storage for the web demo: memory, saved to the tab's `sessionStorage`.
/// Nothing is encrypted, which the demo says on screen.
final class SessionDemoBackend implements StorageBackend {
  SessionDemoBackend(this._store);

  final SessionStore _store;

  @override
  Future<AppStorage> open() async => AppStorage(
    kind: StorageKind.webDemo,
    items: sessionItemRepository(_store),
    settings: sessionSettingsRepository(_store),
    close: () async {},
    eraseAll: erase,
  );

  @override
  Future<void> erase() async {
    _store
      ..remove(sessionItemsKey)
      ..remove(sessionSettingsKey);
  }
}
