import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/platform/backup_exclusion.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('yaadi/backup_exclusion');

  setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.iOS);
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  // A failed exclusion must never stop the vault from opening: the file is
  // encrypted either way, and three failed opens would offer an erase.
  test('an engine without the handler still opens the vault', () async {
    await const IosBackupExclusion().exclude('/support/vault');
  });

  test('a handler that fails still opens the vault', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          channel,
          (call) => throw PlatformException(code: 'exclude_failed'),
        );
    await const IosBackupExclusion().exclude('/support/vault');
  });

  test('the directory is passed to the handler on iOS only', () async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return null;
        });

    await const IosBackupExclusion().exclude('/support/vault');
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    await const IosBackupExclusion().exclude('/support/vault');

    expect(calls.map((call) => (call.method, call.arguments)), [
      ('exclude', '/support/vault'),
    ]);
  });
}
