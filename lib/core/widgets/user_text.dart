import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show Bidi;

import '../text/script.dart';
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
    this.textAlign,
    this.highlights = const [],
    this.highlightStyle,
  });

  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  /// Stretches to emphasize, sorted and not overlapping, such as search
  /// matches. Search keeps Arabic-script words whole, so a highlight never
  /// breaks Nastaliq joining.
  final List<TextRange> highlights;
  final TextStyle? highlightStyle;

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

    final spans = <TextSpan>[];
    var offset = 0;
    for (final run in scriptRuns(text)) {
      final runStyle = run.isArabic ? urdu : latin;
      final runEnd = offset + run.text.length;
      var cursor = offset;
      for (final range in highlights) {
        if (range.end <= cursor || range.start >= runEnd) continue;
        final start = math.max(range.start, cursor);
        final end = math.min(range.end, runEnd);
        if (start > cursor) {
          spans.add(
            TextSpan(text: text.substring(cursor, start), style: runStyle),
          );
        }
        spans.add(
          TextSpan(
            text: text.substring(start, end),
            style: runStyle.merge(highlightStyle),
          ),
        );
        cursor = end;
      }
      if (cursor < runEnd) {
        spans.add(
          TextSpan(text: text.substring(cursor, runEnd), style: runStyle),
        );
      }
      offset = runEnd;
    }

    final layout = Directionality.of(context);
    final direction = textDirectionOf(text, layout);
    return Text.rich(
      TextSpan(children: spans),
      textDirection: direction,
      // Flush with the rest of the row: an Urdu title in an English list
      // starts on the left like its subtitle, while still reading
      // right-to-left.
      textAlign:
          textAlign ??
          (direction == layout
              ? TextAlign.start
              : layout == TextDirection.ltr
              ? TextAlign.left
              : TextAlign.right),
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

/// Whether [text] has any Arabic-script letter, and so needs Nastaliq.
bool hasArabicScript(String text) => text.runes.any(isArabicScript);

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
  if (isArabicScript(rune)) return true;
  final char = String.fromCharCode(rune);
  if (_letter.hasMatch(char)) return false;
  return null;
}

final _letter = RegExp(r'\p{L}', unicode: true);
