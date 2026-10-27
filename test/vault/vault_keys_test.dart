import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/vault/vault_key_store.dart';
import 'package:yaadi/vault/vault_keys.dart';
import 'package:yaadi/vault/vault_setup.dart';

List<int> range(int from, int to) => [for (var i = from; i <= to; i++) i];

void main() {
  group('HKDF-SHA256 matches RFC 5869', () {
    final vectors = [
      (
        'test case 1',
        List.filled(22, 0x0b),
        hexDecode('000102030405060708090a0b0c'),
        hexDecode('f0f1f2f3f4f5f6f7f8f9'),
        42,
        '3cb25f25faacd57a90434f64d0362f2a2d2d0a90cf1a5a4c5db02d56ecc4c5bf'
            '34007208d5b887185865',
      ),
      (
        'test case 2, long inputs',
        range(0x00, 0x4f),
        range(0x60, 0xaf),
        range(0xb0, 0xff),
        82,
        'b11e398dc80327a1c8e7f78c596a49344f012eda2d4efad8a050cc4c19afa97c'
            '59045a99cac7827271cb41c65e590e09da3275600c2f09b8367793a9aca3db71'
            'cc30c58179ec3e87c14c01d5c1f3434f1d87',
      ),
      (
        'test case 3, empty salt and info',
        List.filled(22, 0x0b),
        <int>[],
        <int>[],
        42,
        '8da4e775a563c18f715f802a063c5a31b8a11f5c5ee1879ec3454e5f3c738d2d'
            '9d201395faa4b61a96c8',
      ),
    ];
    for (final (name, inputKey, salt, info, length, expected) in vectors) {
      test(name, () {
        final output = hkdfSha256(
          inputKey: inputKey,
          salt: salt,
          info: info,
          length: length,
        );
        expect(hexEncode(output), expected);
      });
    }
  });

  group('database key', () {
    final record = VaultKeyRecord(List.generate(32, (i) => i));

    test(
      'is a raw 64-digit key that SQLCipher will not treat as a passphrase',
      () {
        final key = deriveDatabaseKey(record);
        expect(isRawDatabaseKey(key), isTrue);
        expect(key, isNot(hexEncode(record.secret)));
      },
    );

    test('is stable for a record and differs between records', () {
      expect(
        deriveDatabaseKey(record),
        deriveDatabaseKey(VaultKeyRecord(record.secret)),
      );
      final other = VaultKeyRecord(List.generate(32, (i) => 31 - i));
      expect(deriveDatabaseKey(other), isNot(deriveDatabaseKey(record)));
    });

    test('raw key check rejects anything else', () {
      for (final key in [
        '',
        'ab' * 31,
        'AB' * 32,
        'zz' * 32,
        "'; DROP TABLE items; --",
      ]) {
        expect(isRawDatabaseKey(key), isFalse, reason: key);
      }
    });
  });

  group('key record', () {
    test('round-trips and never prints the secret', () {
      final record = VaultKeyRecord.generate(Random(7));
      final stored = record.encode();
      expect(VaultKeyRecord.decode(stored), record);
      expect(stored, contains('"v":1'));
      expect(stored, contains('"cipher":"sqlcipher4"'));
      expect(stored, contains('"kdf":"hkdf-sha256"'));
      expect(record.toString(), isNot(contains(hexEncode(record.secret))));
    });

    test('a newer record is reported as such, anything else as malformed', () {
      expect(
        () => VaultKeyRecord.decode(
          '{"v":2,"cipher":"sqlcipher5","kdf":"x","secret":""}',
        ),
        throwsA(isA<UnsupportedKeyRecord>()),
      );
      for (final bad in [
        'not json',
        '[]',
        '{"v":1,"cipher":"aes","kdf":"hkdf-sha256","secret":"${'00' * 32}"}',
        '{"v":1,"cipher":"sqlcipher4","kdf":"hkdf-sha256","secret":"00"}',
        '{"v":1,"cipher":"sqlcipher4","kdf":"hkdf-sha256","secret":"${'zz' * 32}"}',
      ]) {
        expect(
          () => VaultKeyRecord.decode(bad),
          throwsFormatException,
          reason: bad,
        );
      }
    });

    test('a secret must be 32 bytes', () {
      expect(() => VaultKeyRecord(List.filled(16, 0)), throwsArgumentError);
    });
  });

  test('Android options are pinned so the plugin can never erase the key', () {
    final options = vaultAndroidOptions.toMap();
    expect(options, containsPair('resetOnError', 'false'));
    expect(options, containsPair('migrateWithBackup', 'true'));
    expect(options, containsPair('enforceBiometrics', 'false'));
    expect(
      options,
      containsPair(
        'keyCipherAlgorithm',
        'RSA_ECB_OAEPwithSHA_256andMGF1Padding',
      ),
    );
    expect(
      options,
      containsPair('storageCipherAlgorithm', 'AES_GCM_NoPadding'),
    );
    expect(options, containsPair('storageNamespace', 'yaadi_vault'));
  });

  test(
    'the iOS key stays on this device and is readable after first unlock',
    () {
      final options = vaultIosOptions.toMap();
      expect(
        options,
        containsPair(
          'accessibility',
          KeychainAccessibility.first_unlock_this_device.name,
        ),
      );
      expect(options, containsPair('synchronizable', 'false'));
    },
  );
}
