import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The code points Roboto and Noto Nastaliq Urdu, the fonts the app bundles,
/// can draw: inclusive start and end pairs, merged and sorted, read from
/// their cmap tables. A test checks this list against the font files.
@visibleForTesting
const bundledFontRanges = <int>[
  0x0, 0x0, 0x2, 0x2, 0xD, 0xD, 0x20, 0x7E, 0xA0, 0x17F, 0x18F, 0x18F, //
  0x192, 0x192, 0x1A0, 0x1A1, 0x1AF, 0x1B0, 0x1F0, 0x1F0, 0x1FA, 0x1FF, //
  0x218, 0x21B, 0x237, 0x237, 0x259, 0x259, 0x2BC, 0x2BC, 0x2C6, 0x2C7, //
  0x2C9, 0x2C9, 0x2D8, 0x2DD, 0x2F3, 0x2F3, 0x300, 0x301, 0x303, 0x303, //
  0x309, 0x309, 0x30F, 0x30F, 0x323, 0x323, 0x384, 0x38A, 0x38C, 0x38C, //
  0x38E, 0x3A1, 0x3A3, 0x3CE, 0x3D1, 0x3D2, 0x3D6, 0x3D6, 0x400, 0x486, //
  0x488, 0x513, 0x600, 0x604, 0x609, 0x615, 0x61B, 0x61C, 0x61E, 0x65B, //
  0x65D, 0x673, 0x679, 0x6A1, 0x6A3, 0x6A9, 0x6AB, 0x6D5, 0x6DD, 0x6DE, //
  0x6E0, 0x6E1, 0x6E9, 0x6E9, 0x6EE, 0x6F9, 0x6FF, 0x6FF, 0x750, 0x77D, //
  0x8A0, 0x8B4, 0x8B6, 0x8C8, 0x8E3, 0x8FF, 0x1E00, 0x1E01, 0x1E3E, //
  0x1E3F, 0x1E80, 0x1E85, 0x1EA0, 0x1EF9, 0x1F4D, 0x1F4D, 0x2000, 0x2011, //
  0x2013, 0x2015, 0x2017, 0x201E, 0x2020, 0x2022, 0x2025, 0x2027, 0x2030, //
  0x2030, 0x2032, 0x2033, 0x2039, 0x203A, 0x203C, 0x203C, 0x2044, 0x2044, //
  0x2074, 0x2074, 0x207F, 0x207F, 0x20A3, 0x20A4, 0x20A6, 0x20AC, 0x20B1, //
  0x20B1, 0x20B9, 0x20BA, 0x20BC, 0x20BD, 0x2105, 0x2105, 0x2113, 0x2113, //
  0x2116, 0x2116, 0x2122, 0x2122, 0x2126, 0x2126, 0x212E, 0x212E, 0x215B, //
  0x215E, 0x2202, 0x2202, 0x2206, 0x2206, 0x220F, 0x220F, 0x2211, 0x2212, //
  0x221A, 0x221A, 0x221E, 0x221E, 0x222B, 0x222B, 0x2248, 0x2248, 0x2260, //
  0x2260, 0x2264, 0x2265, 0x25CA, 0x25CA, 0x25CC, 0x25CC, 0xEE01, 0xEE02, //
  0xF6C3, 0xF6C3, 0xFB01, 0xFB04, 0xFBB2, 0xFBC1, 0xFD3E, 0xFD3F, 0xFDF2, //
  0xFDF2, 0xFDF4, 0xFDF4, 0xFDFA, 0xFDFD, 0xFEAE, 0xFEAE, 0xFEEE, 0xFEEE, //
  0xFEFF, 0xFEFF, 0xFFFC, 0xFFFD,
];

/// Spaces, line breaks, joiners and direction marks: drawn as nothing, so
/// the web engine never looks for a font for them.
final _invisible = RegExp(r'[\p{Z}\p{Cc}\p{Cf}]', unicode: true);

/// Whether the bundled fonts can draw [rune], or it needs no glyph at all.
bool canDraw(int rune) {
  var low = 0;
  var high = bundledFontRanges.length ~/ 2 - 1;
  while (low <= high) {
    final mid = (low + high) ~/ 2;
    if (rune < bundledFontRanges[mid * 2]) {
      high = mid - 1;
    } else if (rune > bundledFontRanges[mid * 2 + 1]) {
      low = mid + 1;
    } else {
      return true;
    }
  }
  return _invisible.hasMatch(String.fromCharCode(rune));
}

/// Leaves out what the bundled fonts cannot draw, such as emoji, Hindi or a
/// check mark, as it is typed or pasted, and calls [onLeftOut] so the user
/// can be told.
///
/// Only the web build needs it. On a phone the system's fonts draw such
/// characters; in a browser the engine would fetch fallback fonts, from
/// Google unless told otherwise, and the web demo requests nothing beyond
/// its own files (ARCHITECTURE.md section 10).
final class DrawableTextFormatter extends TextInputFormatter {
  DrawableTextFormatter({this.onLeftOut});

  final VoidCallback? onLeftOut;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.runes.every(canDraw)) return newValue;

    final kept = StringBuffer();
    var keptBeforeCursor = 0;
    var offset = 0;
    final cursor = newValue.selection.extentOffset;
    for (final rune in text.runes) {
      final length = rune > 0xFFFF ? 2 : 1;
      if (canDraw(rune)) {
        kept.writeCharCode(rune);
        if (offset < cursor) keptBeforeCursor += length;
      }
      offset += length;
    }
    onLeftOut?.call();
    return TextEditingValue(
      text: kept.toString(),
      selection: TextSelection.collapsed(offset: keptBeforeCursor),
    );
  }
}

/// The formatters a text field adds in this build: on the web, one that
/// leaves out what the bundled fonts cannot draw.
List<TextInputFormatter> drawableTextFormatters(VoidCallback onLeftOut) => [
  if (kIsWeb) DrawableTextFormatter(onLeftOut: onLeftOut),
];
