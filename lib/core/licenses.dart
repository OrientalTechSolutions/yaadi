import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Adds the bundled fonts to the in-app licence page; packages from pub.dev
/// register their own.
void registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(const [
      'Noto Nastaliq Urdu',
    ], await rootBundle.loadString('assets/fonts/noto_nastaliq_urdu/OFL.txt'));
    yield LicenseEntryWithLineBreaks(const [
      'Roboto',
    ], await rootBundle.loadString('assets/fonts/roboto/LICENSE.txt'));
  });
}
