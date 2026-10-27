import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/licenses.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    LicenseRegistry.reset();
    registerBundledLicenses();
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    LicenseRegistry.reset();
  });

  Future<Map<String, String>> licencesOn(TargetPlatform platform) async {
    debugDefaultTargetPlatformOverride = platform;
    return {
      await for (final entry in LicenseRegistry.licenses)
        entry.packages.join(', '): entry.paragraphs
            .map((paragraph) => paragraph.text)
            .join('\n'),
    };
  }

  test('Android lists the fonts, SQLCipher and OpenSSL', () async {
    final licences = await licencesOn(TargetPlatform.android);

    expect(licences.keys, [
      'Noto Nastaliq Urdu',
      'Roboto',
      'SQLCipher',
      'OpenSSL',
    ]);
    expect(licences['SQLCipher'], contains('ZETETIC LLC'));
    expect(licences['SQLCipher'], contains('Redistributions in binary form'));
    expect(licences['OpenSSL'], contains('The OpenSSL Project Authors'));
    expect(licences['OpenSSL'], contains('Apache License'));
    expect(licences['OpenSSL'], contains('END OF TERMS AND CONDITIONS'));
  });

  test('iOS lists SQLCipher without OpenSSL', () async {
    final licences = await licencesOn(TargetPlatform.iOS);

    expect(licences.keys, ['Noto Nastaliq Urdu', 'Roboto', 'SQLCipher']);
  });
}
