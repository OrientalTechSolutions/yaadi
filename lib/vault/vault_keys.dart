import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'vault_key_store.dart';

/// HKDF purpose label for the SQLCipher key. M3 attachments get their own
/// label, so they never share the database key.
const vaultDatabaseKeyPurpose = 'yaadi/vault/sqlcipher/v1';

/// The raw SQLCipher key for [record], as 64 lowercase hex digits. The stored
/// secret itself never reaches SQLCipher.
String deriveDatabaseKey(VaultKeyRecord record) => hexEncode(
  hkdfSha256(
    inputKey: record.secret,
    info: utf8.encode(vaultDatabaseKeyPurpose),
    length: 32,
  ),
);

/// HKDF with HMAC-SHA256, as specified in RFC 5869.
Uint8List hkdfSha256({
  required List<int> inputKey,
  List<int> salt = const [],
  required List<int> info,
  required int length,
}) {
  const hashLength = 32;
  RangeError.checkValueInInterval(length, 1, 255 * hashLength, 'length');

  final pseudoRandomKey = Hmac(
    sha256,
    salt.isEmpty ? Uint8List(hashLength) : salt,
  ).convert(inputKey).bytes;

  final output = BytesBuilder(copy: false);
  var block = <int>[];
  for (var counter = 1; output.length < length; counter++) {
    block = Hmac(
      sha256,
      pseudoRandomKey,
    ).convert([...block, ...info, counter]).bytes;
    output.add(block);
  }
  return Uint8List.sublistView(output.takeBytes(), 0, length);
}

String hexEncode(List<int> bytes) =>
    bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

/// Throws a [FormatException] unless [hex] is an even run of hex digits.
Uint8List hexDecode(String hex) {
  if (hex.length.isOdd || !_hexDigits.hasMatch(hex)) {
    throw const FormatException('Not a hex string');
  }
  return Uint8List.fromList([
    for (var i = 0; i < hex.length; i += 2)
      int.parse(hex.substring(i, i + 2), radix: 16),
  ]);
}

final _hexDigits = RegExp(r'^[0-9a-fA-F]*$');
