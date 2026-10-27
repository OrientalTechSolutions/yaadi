import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Rules from ARCHITECTURE.md that are easier to check in the source than at
/// run time.
void main() {
  final handWritten = _handWrittenDart('lib');

  test('finds the sources', () => expect(handWritten, isNotEmpty));

  test('no byte-order marks or literal invisible or bidi characters', () {
    // A literal direction control can make code read differently from how
    // it runs ("Trojan Source"), which matters in a right-to-left codebase.
    // Write them as \u escapes instead.
    final invisible = RegExp(
      '[\u00A0\u061C\u200B-\u200F\u202A-\u202E\u2066-\u2069\uFEFF]',
    );
    final sources = [...handWritten, ..._handWrittenDart('test')];
    final offenders = [
      for (final file in sources)
        if (_startsWithBom(file) || invisible.hasMatch(file.readAsStringSync()))
          file.path,
    ];
    expect(offenders, isEmpty);
  });

  test('lib/ never prints: release logs end up in bug reports', () {
    final printing = RegExp(r'\b(print|debugPrint)\(');
    final offenders = [
      for (final file in handWritten)
        if (printing.hasMatch(file.readAsStringSync())) file.path,
    ];
    expect(offenders, isEmpty);
  });

  test('domain code is pure Dart: no Flutter, Drift or storage imports', () {
    final forbidden = RegExp(
      r"^import 'package:(flutter|drift|sqlite3|flutter_riverpod|flutter_secure_storage)",
      multiLine: true,
    );
    final domain = handWritten.where(
      (file) => file.path.contains(
        '${Platform.pathSeparator}domain${Platform.pathSeparator}',
      ),
    );
    expect(domain, isNotEmpty);
    final offenders = [
      for (final file in domain)
        if (forbidden.hasMatch(file.readAsStringSync())) file.path,
    ];
    expect(offenders, isEmpty);
  });

  test('lib/ has no TODO or FIXME notes: open work lives in the CHANGELOG', () {
    final note = RegExp(r'//.*\b(TODO|FIXME|XXX)\b');
    final offenders = [
      for (final file in handWritten)
        if (note.hasMatch(file.readAsStringSync())) file.path,
    ];
    expect(offenders, isEmpty);
  });

  test('core/ never imports a feature', () {
    final core = handWritten.where(
      (file) => file.path.contains(
        'lib${Platform.pathSeparator}core${Platform.pathSeparator}',
      ),
    );
    final offenders = [
      for (final file in core)
        if (file.readAsStringSync().contains('/features/')) file.path,
    ];
    expect(offenders, isEmpty);
  });
}

/// Dart files under [root], without the output of Drift and gen-l10n.
List<File> _handWrittenDart(String root) => [
  for (final file in Directory(root).listSync(recursive: true))
    if (file is File &&
        file.path.endsWith('.dart') &&
        !file.path.endsWith('.g.dart') &&
        !file.uri.pathSegments.last.startsWith('app_localizations') &&
        !file.path.contains(
          ['drift', 'vault', 'generated'].join(Platform.pathSeparator),
        ))
      file,
];

bool _startsWithBom(File file) {
  final bytes = file.readAsBytesSync();
  return bytes.length >= 3 &&
      bytes[0] == 0xEF &&
      bytes[1] == 0xBB &&
      bytes[2] == 0xBF;
}
