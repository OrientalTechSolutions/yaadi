import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show Bidi;

import '../theme/app_theme.dart';

/// Text the user typed, which may be Urdu, English or both in any UI
/// language.
///
/// Direction follows the string's first strong character, not the UI: "LESCO
/// bill" stays left-to-right in the Urdu UI and "امی کی دوائی" right-to-left
/// in the English one. Arabic-script runs are set in Nastaliq with room for
/// its descenders, and other runs in Roboto.
class UserText extends StatelessWidget {
  const UserText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final base = DefaultTextStyle.of(context).style.merge(style);
    final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
    final urdu = base.copyWith(
      fontFamily: AppFonts.urdu,
      fontFamilyFallback: const [AppFonts.ui],
      height: urduLineHeight(textScale),
    );
    final latin = base.copyWith(
      fontFamily: AppFonts.ui,
      fontFamilyFallback: const [AppFonts.urdu],
    );

    return Text.rich(
      TextSpan(
        children: [
          for (final run in scriptRuns(text))
            TextSpan(text: run.text, style: run.isArabic ? urdu : latin),
        ],
      ),
      textDirection: textDirectionOf(text, Directionality.of(context)),
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// The first strong character decides; strings with none (numbers,
/// punctuation) take [fallback], the UI's direction.
TextDirection textDirectionOf(String text, TextDirection fallback) {
  if (Bidi.startsWithRtl(text)) return TextDirection.rtl;
  if (Bidi.startsWithLtr(text)) return TextDirection.ltr;
  return fallback;
}

/// A stretch of text in one script.
typedef ScriptRun = ({String text, bool isArabic});

/// Splits [text] into Arabic-script and other runs. Spaces, digits and
/// punctuation join the run they sit in, so a Nastaliq word is never split
/// from its own numbers (the font covers ASCII and Urdu digits).
List<ScriptRun> scriptRuns(String text) {
  final runs = <ScriptRun>[];
  final buffer = StringBuffer();
  bool? arabic;

  for (final rune in text.runes) {
    final script = _scriptOf(rune);
    if (script != null && arabic != null && script != arabic) {
      runs.add((text: buffer.toString(), isArabic: arabic));
      buffer.clear();
    }
    arabic = script ?? arabic;
    buffer.writeCharCode(rune);
  }
  if (buffer.isNotEmpty) {
    runs.add((text: buffer.toString(), isArabic: arabic ?? false));
  }
  return runs;
}

/// True for Arabic script, false for other letters, null for neutrals.
bool? _scriptOf(int rune) {
  if (_isArabicScript(rune)) return true;
  final char = String.fromCharCode(rune);
  if (_letter.hasMatch(char)) return false;
  return null;
}

bool _isArabicScript(int rune) =>
    (rune >= 0x0600 && rune <= 0x06FF && !_isArabicDigit(rune)) ||
    (rune >= 0x0750 && rune <= 0x077F) ||
    (rune >= 0x08A0 && rune <= 0x08FF) ||
    (rune >= 0xFB50 && rune <= 0xFDFF) ||
    (rune >= 0xFE70 && rune <= 0xFEFF);

bool _isArabicDigit(int rune) =>
    (rune >= 0x0660 && rune <= 0x0669) || (rune >= 0x06F0 && rune <= 0x06F9);

final _letter = RegExp(r'\p{L}', unicode: true);
