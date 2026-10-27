/// Turns Arabic-Indic (٠١٢) and Extended Arabic-Indic (۰۱۲) digits into
/// ASCII. Urdu keyboards type the extended set, so every number the user
/// enters passes through here before it is parsed or searched.
String normalizeDigits(String text) {
  final buffer = StringBuffer();
  for (final rune in text.runes) {
    if (rune >= 0x0660 && rune <= 0x0669) {
      buffer.writeCharCode(0x30 + rune - 0x0660);
    } else if (rune >= 0x06F0 && rune <= 0x06F9) {
      buffer.writeCharCode(0x30 + rune - 0x06F0);
    } else {
      buffer.writeCharCode(rune);
    }
  }
  return buffer.toString();
}

/// Removes invisible direction marks, embeddings and isolates. `intl` puts an
/// LRM in front of signs in Urdu number formats, and pasted text often
/// carries RLM or isolates that would break comparisons.
String stripBidiControls(String text) => text.replaceAll(_bidiControls, '');

final _bidiControls = RegExp('[\u200E\u200F\u061C\u202A-\u202E\u2066-\u2069]');
