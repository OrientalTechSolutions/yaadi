import 'package:yaadi/features/items/data/memory_item_repository.dart';
import 'package:yaadi/features/items/domain/item.dart';
import 'package:yaadi/features/settings/data/settings_repository.dart';
import 'package:yaadi/vault/app_storage.dart';
import 'package:yaadi/vault/vault_failure.dart';

/// Opens memory storage, or fails with the next of [failures] first.
final class FakeStorageBackend implements StorageBackend {
  FakeStorageBackend({
    this.kind = StorageKind.vault,
    List<Item> items = const [],
    Map<String, String> settings = const {},
    List<VaultFailureKind> failures = const [],
  }) : _failures = [...failures],
       items = MemoryItemRepository(items: items),
       settings = MemorySettingsRepository(initial: settings);

  final StorageKind kind;
  final MemoryItemRepository items;
  final MemorySettingsRepository settings;
  final List<VaultFailureKind> _failures;

  var opens = 0;
  var erases = 0;

  @override
  Future<AppStorage> open() async {
    opens++;
    if (_failures.isNotEmpty) throw VaultOpenFailure(_failures.removeAt(0));
    return AppStorage(
      kind: kind,
      items: items,
      settings: settings,
      close: () async {},
      eraseAll: erase,
    );
  }

  @override
  Future<void> erase() async => erases++;
}
