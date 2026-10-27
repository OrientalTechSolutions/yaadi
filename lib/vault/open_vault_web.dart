import '../core/platform/session_store.dart';
import 'app_storage.dart';
import 'session_demo_backend.dart';

/// The web build never opens a database (ARCHITECTURE.md section 10).
StorageBackend createStorageBackend() =>
    SessionDemoBackend(createSessionStore());
