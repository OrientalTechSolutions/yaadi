import 'package:flutter/foundation.dart';

/// Release builds still send uncaught errors to logcat and os_log, and from
/// there into bug reports. An error's text can carry a title, a note or a
/// reference, so only its type is kept (ARCHITECTURE.md section 9).
void redactErrorsInRelease() {
  if (!kReleaseMode) return;
  FlutterError.onError = (details) => FlutterError.presentError(
    FlutterErrorDetails(
      exception: RedactedError(details.exception.runtimeType),
      library: details.library,
    ),
  );
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    FlutterError.presentError(
      FlutterErrorDetails(exception: RedactedError(error.runtimeType)),
    );
    return true;
  };
}

/// Stands in for an error whose message must not be logged.
final class RedactedError implements Exception {
  const RedactedError(this.type);

  final Type type;

  @override
  String toString() => 'Redacted $type';
}
