import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaadi/core/text/drawable_text.dart';

/// The bundled fonts, whose coverage [bundledFontRanges] must match.
const _fonts = [
  'assets/fonts/roboto/Roboto-Regular.ttf',
  'assets/fonts/roboto/Roboto-Medium.ttf',
  'assets/fonts/roboto/Roboto-Bold.ttf',
  'assets/fonts/noto_nastaliq_urdu/NotoNastaliqUrdu-Regular.ttf',
  'assets/fonts/noto_nastaliq_urdu/NotoNastaliqUrdu-Bold.ttf',
];

String char(int rune) => String.fromCharCode(rune);

void main() {
  test('the table matches the cmap of every bundled font', () {
    final covered = <int>{};
    for (final path in _fonts) {
      covered.addAll(_cmap(File(path).readAsBytesSync()));
    }
    final ranges = <int>[];
    for (final rune in covered.toList()..sort()) {
      if (ranges.isNotEmpty && ranges.last == rune - 1) {
        ranges.last = rune;
      } else {
        ranges.addAll([rune, rune]);
      }
    }
    expect(bundledFontRanges, ranges);
  });

  group('canDraw', () {
    test('Latin, Urdu, digits and the symbols bills use', () {
      for (final text in [
        'LESCO bill',
        'امی کی دوائی',
        '۱۲۳ 123',
        'Rs £ \$ ₹ · – … « »',
        '،۔؟',
      ]) {
        expect(text.runes.every(canDraw), isTrue, reason: text);
      }
    });

    test('spaces, line breaks, joiners and direction marks', () {
      for (final rune in [0x0A, 0x09, 0xA0, 0x202F, 0x200C, 0x200D, 0x2068]) {
        expect(canDraw(rune), isTrue, reason: rune.toRadixString(16));
      }
    });

    test('not emoji, Devanagari or a check mark', () {
      for (final rune in [0x1F48A, 0x1F4A1, 0x0939, 0x2713, 0x4E2D]) {
        expect(canDraw(rune), isFalse, reason: rune.toRadixString(16));
      }
    });
  });

  group('DrawableTextFormatter', () {
    TextEditingValue typed(String text) => TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );

    test('leaves out what cannot be drawn, and says so', () {
      var told = 0;
      final formatter = DrawableTextFormatter(onLeftOut: () => told++);
      final pill = char(0x1F48A);
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        typed('Ammi ki dawai $pill'),
      );
      expect(result.text, 'Ammi ki dawai ');
      expect(result.selection, const TextSelection.collapsed(offset: 14));
      expect(told, 1);
    });

    test('keeps the cursor where it was among the kept text', () {
      final formatter = DrawableTextFormatter();
      final check = char(0x2713);
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(
          text: 'Bill${check}paid',
          selection: const TextSelection.collapsed(offset: 5),
        ),
      );
      expect(result.text, 'Billpaid');
      expect(result.selection.baseOffset, 4);
    });

    test('lets drawable text through untouched', () {
      var told = 0;
      final formatter = DrawableTextFormatter(onLeftOut: () => told++);
      final value = typed('گیس کا بل');
      expect(formatter.formatEditUpdate(TextEditingValue.empty, value), value);
      expect(told, 0);
    });
  });
}

/// The code points a TrueType font maps to a glyph, from its cmap's format
/// 4 and 12 subtables.
Set<int> _cmap(Uint8List bytes) {
  final data = ByteData.sublistView(bytes);
  final tables = data.getUint16(4);
  var cmap = -1;
  for (var i = 0; i < tables; i++) {
    final record = 12 + i * 16;
    if (String.fromCharCodes(bytes.sublist(record, record + 4)) == 'cmap') {
      cmap = data.getUint32(record + 8);
    }
  }
  final covered = <int>{};
  final subtables = data.getUint16(cmap + 2);
  for (var i = 0; i < subtables; i++) {
    final start = cmap + data.getUint32(cmap + 4 + i * 8 + 4);
    switch (data.getUint16(start)) {
      case 4:
        final segments = data.getUint16(start + 6) ~/ 2;
        final ends = start + 14;
        final starts = ends + segments * 2 + 2;
        final deltas = starts + segments * 2;
        final offsets = deltas + segments * 2;
        for (var s = 0; s < segments; s++) {
          final first = data.getUint16(starts + s * 2);
          final last = data.getUint16(ends + s * 2);
          final delta = data.getInt16(deltas + s * 2);
          final offset = data.getUint16(offsets + s * 2);
          for (var c = first; c <= last && c != 0xFFFF; c++) {
            var glyph = 0;
            if (offset == 0) {
              glyph = (c + delta) & 0xFFFF;
            } else {
              glyph = data.getUint16(
                offsets + s * 2 + offset + (c - first) * 2,
              );
              if (glyph != 0) glyph = (glyph + delta) & 0xFFFF;
            }
            if (glyph != 0) covered.add(c);
          }
        }
      case 12:
        final groups = data.getUint32(start + 12);
        for (var g = 0; g < groups; g++) {
          final group = start + 16 + g * 12;
          final last = data.getUint32(group + 4);
          for (var c = data.getUint32(group); c <= last; c++) {
            covered.add(c);
          }
        }
    }
  }
  return covered;
}
