/// Turns Arabic-Indic (٠١٢) and Extended Arabic-Indic (۰۱۲) digits into
/// ASCII. Urdu keyboards type the extended set, so every number the user
/// enters passes through here before it is parsed or searched.
String normalizeDigits(String text) {
  final buffer = StringBuffer();
  for (final rune in text.runes) {
    buffer.writeCharCode(asciiDigit(rune));
  }
  return buffer.toString();
}

/// The ASCII digit for an Arabic-Indic or Extended Arabic-Indic digit;
/// any other [rune] is returned unchanged.
int asciiDigit(int rune) {
  if (rune >= 0x0660 && rune <= 0x0669) return 0x30 + rune - 0x0660;
  if (rune >= 0x06F0 && rune <= 0x06F9) return 0x30 + rune - 0x06F0;
  return rune;
}

/// Removes invisible direction marks, embeddings and isolates. `intl` puts an
/// LRM in front of signs in Urdu number formats, and pasted text often
/// carries RLM or isolates that would break comparisons.
String stripBidiControls(String text) => text.replaceAll(_bidiControls, '');

/// LRM, RLM, the Arabic letter mark, embeddings, overrides and isolates.
bool isBidiControl(int rune) =>
    rune == 0x200E ||
    rune == 0x200F ||
    rune == 0x061C ||
    (rune >= 0x202A && rune <= 0x202E) ||
    (rune >= 0x2066 && rune <= 0x2069);

final _bidiControls = RegExp('[\u200E\u200F\u061C\u202A-\u202E\u2066-\u2069]');
