import 'package:web/web.dart' as web;

import 'session_store.dart';

SessionStore platformSessionStore() => _BrowserSessionStore();

/// Every access is guarded: Safari's private mode, blocked site data and a
/// full quota all throw from `sessionStorage`.
final class _BrowserSessionStore implements SessionStore {
  var _failed = false;

  @override
  String? read(String key) {
    try {
      return web.window.sessionStorage.getItem(key);
    } on Object {
      return null;
    }
  }

  @override
  bool write(String key, String value) {
    try {
      web.window.sessionStorage.setItem(key, value);
      return true;
    } on Object {
      _failed = true;
      return false;
    }
  }

  @override
  void remove(String key) {
    try {
      web.window.sessionStorage.removeItem(key);
    } on Object {
      _failed = true;
    }
  }

  @override
  bool get hasFailedWrites => _failed;
}
