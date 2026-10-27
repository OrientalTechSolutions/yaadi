import 'session_store_memory.dart'
    if (dart.library.js_interop) 'session_store_web.dart';

/// Key-value strings for the web demo, kept in the tab's `sessionStorage`.
///
/// Off the web this is plain memory, so tests and the VM never touch a
/// browser API.
abstract interface class SessionStore {
  String? read(String key);

  /// Returns false when the browser refused to save, for example over quota
  /// or with storage blocked. The demo then carries on in memory.
  bool write(String key, String value);

  void remove(String key);

  /// True once any write has failed, so the demo can say it is not saving.
  bool get hasFailedWrites;
}

SessionStore createSessionStore() => platformSessionStore();
