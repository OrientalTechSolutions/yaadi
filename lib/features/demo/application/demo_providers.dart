import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../vault/app_storage.dart';

/// Whether the screen shows demo data rather than the user's own vault. The
/// web build is always a demo.
final showingDemoProvider = Provider<bool>(
  (ref) => ref.watch(storageProvider).value?.kind == StorageKind.webDemo,
);
