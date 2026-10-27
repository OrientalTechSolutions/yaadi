import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/items/data/item_repository.dart';
import '../features/settings/data/settings_repository.dart';
import 'open_vault_native.dart'
    if (dart.library.js_interop) 'open_vault_web.dart'
    as platform;
import 'vault_failure.dart';

enum StorageKind {
  /// The encrypted vault on a phone.
  vault,

  /// The web demo: memory plus the tab's `sessionStorage`, not encrypted.
  webDemo,
}

/// The repositories the app runs on once startup has finished.
final class AppStorage {
  AppStorage({
    required this.kind,
    required this.items,
    required this.settings,
    required this._close,
    required this.eraseAll,
  });

  final StorageKind kind;
  final ItemRepository items;
  final SettingsRepository settings;

  /// Deletes everything. Only the confirmed Reset and Delete all flows call
  /// it.
  final Future<void> Function() eraseAll;

  final Future<void> Function() _close;
  Future<void>? _closing;

  /// Safe to call more than once.
  Future<void> close() => _closing ??= _close();
}

/// Opens storage for the current platform.
abstract interface class StorageBackend {
  /// Throws [VaultOpenFailure] when the vault cannot be opened.
  Future<AppStorage> open();

  /// Crypto-erases a vault that could not be opened: the Recovery screen's
  /// reset, after the user confirmed.
  Future<void> erase();
}

final storageBackendProvider = Provider<StorageBackend>(
  (ref) => platform.createStorageBackend(),
);

/// Opens the vault once. A key or cipher failure must reach its own screen,
/// so this never retries by itself; Try again calls [StorageController.retry].
final storageProvider = AsyncNotifierProvider<StorageController, AppStorage>(
  StorageController.new,
  retry: (_, _) => null,
);

class StorageController extends AsyncNotifier<AppStorage> {
  @override
  Future<AppStorage> build() async {
    final AppStorage storage;
    try {
      storage = await ref.watch(storageBackendProvider).open();
    } on Exception catch (error) {
      throw vaultFailureFrom(error);
    }
    ref.onDispose(storage.close);
    return storage;
  }

  void retry() => ref.invalidateSelf();

  /// Erases the vault and starts again with an empty one.
  Future<void> eraseAndReopen() async {
    final current = state.value;
    try {
      if (current != null) {
        await current.eraseAll();
      } else {
        await ref.read(storageBackendProvider).erase();
      }
    } on Exception catch (error) {
      state = AsyncError(vaultFailureFrom(error), StackTrace.current);
      return;
    }
    ref.invalidateSelf();
  }
}
