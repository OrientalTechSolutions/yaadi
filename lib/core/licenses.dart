import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Adds what Yaadi bundles from outside pub.dev to the in-app licence page:
/// the fonts everywhere, and on phones the SQLCipher library the sqlite3
/// hook downloads, with OpenSSL where that library links it. Packages from
/// pub.dev register their own.
void registerBundledLicenses() {
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(const [
      'Noto Nastaliq Urdu',
    ], await rootBundle.loadString('assets/fonts/noto_nastaliq_urdu/OFL.txt'));
    yield LicenseEntryWithLineBreaks(const [
      'Roboto',
    ], await rootBundle.loadString('assets/fonts/roboto/LICENSE.txt'));
    // The web demo has no database library (ARCHITECTURE.md section 10).
    if (kIsWeb) return;
    yield LicenseEntryWithLineBreaks(const [
      'SQLCipher',
    ], await rootBundle.loadString('assets/licenses/sqlcipher/LICENSE.txt'));
    if (sqlCipherLinksOpenSsl(defaultTargetPlatform)) {
      yield LicenseEntryWithLineBreaks(const [
        'OpenSSL',
      ], await rootBundle.loadString('assets/licenses/openssl/LICENSE.txt'));
    }
  });
}

/// The sqlite3 package's SQLCipher build uses OpenSSL on Android, Linux and
/// Windows, and Apple's own crypto library on iOS and macOS.
bool sqlCipherLinksOpenSsl(TargetPlatform platform) => switch (platform) {
  TargetPlatform.iOS || TargetPlatform.macOS => false,
  _ => true,
};
