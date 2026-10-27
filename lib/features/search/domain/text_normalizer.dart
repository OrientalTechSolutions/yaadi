import 'package:meta/meta.dart';

import '../../../core/text/digits.dart';
import '../../../core/text/script.dart';

/// One word of text as search sees it, with its place in the original
/// string so a match can be highlighted exactly where it was typed.
@immutable
final class SearchToken {
  const SearchToken._(
    this._baseEnds,
    this._foldedEnds, {
    required this.start,
    required this.end,
    required this.base,
    required this.folded,
    required this.isArabic,
  });

  /// Code-unit offsets of the word in the original text, `[start, end)`.
  final int start;
  final int end;

  /// Marks, joiners and bidi controls removed, Latin lowercased and
  /// unaccented, Urdu letter variants and digits unified.
  final String base;

  /// [base] with Roman Urdu spellings folded (bijlee and bijly to bijli,
  /// bill to bil). Equal to [base] for words that are not all Latin.
  final String folded;

  /// Whether the word has Arabic-script letters. Such words are highlighted
  /// whole, because a style change inside a word breaks Nastaliq joining.
  final bool isArabic;

  /// For each code unit of [base] (and [folded]), the original offset just
  /// after the character it came from.
  final List<int> _baseEnds;
  final List<int> _foldedEnds;

  /// The original offset just after the first [length] code units of [base].
  int baseEndAt(int length) => length <= 0 ? start : _baseEnds[length - 1];

  /// The original offset just after the first [length] code units of
  /// [folded].
  int foldedEndAt(int length) => length <= 0 ? start : _foldedEnds[length - 1];

  @override
  String toString() => 'SearchToken($folded @ $start-$end)';
}

/// Splits [text] into search tokens.
///
/// Marks, joiners and bidi controls count as part of a word, so دَوا and
/// words joined with ZWNJ reach normalization whole instead of splitting
/// where a mark sits (ARCHITECTURE.md section 12).
List<SearchToken> tokenize(String text) => [
  for (final match in _word.allMatches(text))
    ?_normalize(text, match.start, match.end),
];

/// The folded keys of [text] joined by spaces: exactly what search compares.
/// Applying it twice gives the same result.
String searchKey(String text) =>
    tokenize(text).map((token) => token.folded).join(' ');

/// Characters that vanish from search keys: harakat and other nonspacing
/// marks, ZWNJ, ZWJ, tatweel and bidi controls.
bool isIgnorable(int rune) =>
    rune == 0x200C ||
    rune == 0x200D ||
    rune == 0x0640 ||
    isBidiControl(rune) ||
    _isNonspacingMark(rune);

// Tatweel is a letter (Lm) to Unicode, so \p{L} already covers it.
final _word = RegExp(
  r'[\p{L}\p{M}\p{N}\u200C-\u200F\u061C\u202A-\u202E\u2066-\u2069]+',
  unicode: true,
);

SearchToken? _normalize(String text, int start, int end) {
  final key = _KeyBuilder();
  var i = start;
  while (i < end) {
    var rune = text.codeUnitAt(i);
    var next = i + 1;
    if (rune >= 0xD800 && rune <= 0xDBFF && next < end) {
      final low = text.codeUnitAt(next);
      if (low >= 0xDC00 && low <= 0xDFFF) {
        rune = 0x10000 + ((rune - 0xD800) << 10) + (low - 0xDC00);
        next++;
      }
    }
    key.fold(rune, i, next);
    i = next;
  }

  if (key.first < 0) return null;
  final base = key.text;
  final ends = key.ends;
  final (folded, foldedEnds) = key.latin && key.hasLetter
      ? _foldRomanUrdu(base, ends)
      : (base, ends);
  return SearchToken._(
    ends,
    foldedEnds,
    start: key.first,
    end: ends.last,
    base: base,
    folded: folded,
    isArabic: key.arabic,
  );
}

/// Collects one word's base key, and for each of its code units the
/// original offset it came from.
final class _KeyBuilder {
  final _text = StringBuffer();
  final ends = <int>[];
  var first = -1;
  var arabic = false;
  var latin = true;
  var hasLetter = false;

  String get text => _text.toString();

  /// Adds what [rune], found at `[from, to)`, becomes in a search key:
  /// nothing, itself, or a replacement.
  void fold(int rune, int from, int to) {
    if (rune < 0x80) {
      _add(rune >= _upperA && rune <= _upperZ ? rune + 0x20 : rune, from, to);
      return;
    }
    if (isIgnorable(rune)) return;
    if (isArabicScript(rune) || isArabicDigit(rune)) {
      final variant = _arabicVariants[rune];
      if (variant != _dropped) _add(asciiDigit(variant ?? rune), from, to);
      return;
    }
    // Dart has no Unicode decomposition, so precomposed Latin letters go
    // through a small table after lowercasing.
    for (final lower in String.fromCharCode(rune).toLowerCase().runes) {
      if (isIgnorable(lower)) continue;
      final plain = _latinLetters[lower];
      if (plain == null) {
        _add(lower, from, to);
      } else {
        for (final unit in plain.codeUnits) {
          _add(unit, from, to);
        }
      }
    }
  }

  void _add(int char, int from, int to) {
    if (first < 0) first = from;
    _text.writeCharCode(char);
    ends.add(to);
    if (char > 0xFFFF) ends.add(to);
    if (char >= _a && char <= _z) {
      hasLetter = true;
    } else if (char < _zero || char > _nine) {
      latin = false;
      if (isArabicScript(char)) arabic = true;
    }
  }
}

/// ee to i, oo to u, v to w, q to k, a final y to i, then repeated letters
/// collapsed: the spellings people actually type for the same Urdu word.
(String, List<int>) _foldRomanUrdu(String base, List<int> ends) {
  final chars = <int>[];
  final charEnds = <int>[];
  for (var i = 0; i < base.length; i++) {
    final char = base.codeUnitAt(i);
    final doubled = i + 1 < base.length && base.codeUnitAt(i + 1) == char;
    if (doubled && (char == _e || char == _o)) {
      chars.add(char == _e ? _i : _u);
      charEnds.add(ends[i + 1]);
      i++;
      continue;
    }
    chars.add(switch (char) {
      _v => _w,
      _q => _k,
      _ => char,
    });
    charEnds.add(ends[i]);
  }
  if (chars.last == _y) chars.last = _i;

  final folded = StringBuffer();
  final foldedEnds = <int>[];
  for (var i = 0; i < chars.length; i++) {
    final char = chars[i];
    // Digits are left alone: 100 is not 10.
    if (i > 0 && char == chars[i - 1] && char >= _a && char <= _z) {
      foldedEnds.last = charEnds[i];
      continue;
    }
    folded.writeCharCode(char);
    foldedEnds.add(charEnds[i]);
  }
  return (folded.toString(), foldedEnds);
}

bool _isNonspacingMark(int rune) {
  if (rune < 0x0300) return false;
  if (rune <= 0x036F) return true;
  if (rune >= 0x0610 && rune <= 0x061A) return true;
  if (rune >= 0x064B && rune <= 0x065F) return true;
  if (rune == 0x0670) return true;
  if (rune >= 0x06D6 && rune <= 0x06ED) {
    return rune != 0x06DD &&
        rune != 0x06DE &&
        rune != 0x06E5 &&
        rune != 0x06E6 &&
        rune != 0x06E9;
  }
  if (rune >= 0x0600 && rune <= 0x06FF) return false;
  return _markPattern.hasMatch(String.fromCharCode(rune));
}

final _markPattern = RegExp(r'^\p{Mn}$', unicode: true);

const _dropped = -1;

/// Urdu and Arabic spellings of the same letter, folded to the form Urdu
/// keyboards type. Losing the difference between ے and ی, ھ and ہ, or ں and
/// ن costs search nothing and matches what people type on Arabic and
/// phonetic keyboards.
const _arabicVariants = <int, int>{
  0x064A: 0x06CC, // ي
  0x0649: 0x06CC, // ى
  0x06D0: 0x06CC, // ې
  0x0626: 0x06CC, // ئ
  0x06D2: 0x06CC, // ے
  0x06D3: 0x06CC, // ۓ
  0x0643: 0x06A9, // ك
  0x0647: 0x06C1, // ه
  0x0629: 0x06C1, // ة
  0x06C0: 0x06C1, // ۀ
  0x06C2: 0x06C1, // ۂ
  0x06C3: 0x06C1, // ۃ
  0x06BE: 0x06C1, // ھ
  0x0623: 0x0627, // أ
  0x0625: 0x0627, // إ
  0x0622: 0x0627, // آ
  0x0671: 0x0627, // ٱ
  0x0624: 0x0648, // ؤ
  0x06BA: 0x0646, // ں
  0x0621: _dropped, // standalone ء
};

/// Precomposed lowercase Latin letters and their plain spelling, including
/// the macrons and dots of transliterated Urdu (ā, ṭ, ḍ).
final _latinLetters = <int, String>{
  for (final MapEntry(key: plain, value: accented) in const {
    'a': 'àáâãäåāăą',
    'ae': 'æ',
    'c': 'çćč',
    'd': 'ďđḍ',
    'e': 'èéêëēėęě',
    'g': 'ğ',
    'h': 'ḥ',
    'i': 'ìíîïīįı',
    'l': 'łľĺ',
    'n': 'ñńňṅ',
    'o': 'òóôõöøōő',
    'oe': 'œ',
    'r': 'řṛ',
    's': 'śšşṣ',
    'ss': 'ß',
    't': 'ţťṭ',
    'u': 'ùúûüūůűų',
    'y': 'ýÿ',
    'z': 'źżž',
  }.entries)
    for (final rune in accented.runes)
      if (!_isNonspacingMark(rune)) rune: plain,
};

const _upperA = 0x41;
const _upperZ = 0x5A;
const _a = 0x61;
const _e = 0x65;
const _i = 0x69;
const _k = 0x6B;
const _o = 0x6F;
const _q = 0x71;
const _u = 0x75;
const _v = 0x76;
const _w = 0x77;
const _y = 0x79;
const _z = 0x7A;
const _zero = 0x30;
const _nine = 0x39;
