import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Keeps a directory out of device backups.
abstract interface class BackupExclusion {
  Future<void> exclude(String directoryPath);
}

/// Sets `NSURLIsExcludedFromBackupKey` on iOS through a small handler in
/// `AppDelegate.swift`. Without it an iCloud or Finder restore would bring
/// the vault onto a new phone without its this-device-only key. Android
/// excludes the vault with `data_extraction_rules.xml` instead, so this does
/// nothing there.
final class IosBackupExclusion implements BackupExclusion {
  const IosBackupExclusion();

  static const _channel = MethodChannel('yaadi/backup_exclusion');

  @override
  Future<void> exclude(String directoryPath) async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;
    try {
      await _channel.invokeMethod<void>('exclude', directoryPath);
    } on PlatformException {
      // The file is encrypted either way. A restored copy without its key
      // lands on the Recovery screen, which is better than no vault at all.
    } on MissingPluginException {
      // Engines started without the Runner's handler, such as M2's
      // background engines, cannot set the flag. The next foreground open
      // does, and the vault must open regardless.
    }
  }
}
