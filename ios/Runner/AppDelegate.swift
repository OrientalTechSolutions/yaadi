import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "YaadiBackupExclusion") {
      BackupExclusion.register(with: registrar.messenger())
    }
  }
}

/// Excludes the vault directory from iCloud and Finder backups. The vault key
/// is this-device-only, so a restored copy of the file could never be opened.
/// The flag on the directory also covers the WAL and SHM files SQLite
/// recreates inside it.
enum BackupExclusion {
  static func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "yaadi/backup_exclusion", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      guard call.method == "exclude", let path = call.arguments as? String else {
        result(FlutterMethodNotImplemented)
        return
      }
      var url = URL(fileURLWithPath: path, isDirectory: true)
      var values = URLResourceValues()
      values.isExcludedFromBackup = true
      do {
        try url.setResourceValues(values)
        result(nil)
      } catch {
        result(FlutterError(code: "exclude_failed", message: nil, details: nil))
      }
    }
  }
}
