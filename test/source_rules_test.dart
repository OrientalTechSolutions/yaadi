import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Rules from ARCHITECTURE.md that are easier to check in the source than at
/// run time.
void main() {
  final handWritten = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .where((file) => !file.path.endsWith('.g.dart'))
      .where(
        (file) => !file.path.contains(
          '${Platform.pathSeparator}l10n${Platform.pathSeparator}',
        ),
      )
      .toList();

  test('finds the sources', () => expect(handWritten, isNotEmpty));

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
