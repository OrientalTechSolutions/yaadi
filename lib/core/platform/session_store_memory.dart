import 'session_store.dart';

SessionStore platformSessionStore() => MemorySessionStore();

final class MemorySessionStore implements SessionStore {
  final _values = <String, String>{};

  @override
  String? read(String key) => _values[key];

  @override
  bool write(String key, String value) {
    _values[key] = value;
    return true;
  }

  @override
  void remove(String key) => _values.remove(key);

  @override
  bool get hasFailedWrites => false;
}
