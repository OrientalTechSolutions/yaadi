import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import 'user_text.dart';

/// A text field for titles, notes and search, where the user may type Urdu,
/// English or both whatever the UI language.
///
/// Like [UserText], direction follows the first strong character and is
/// worked out again as the user types. Text with Arabic script is set in
/// Nastaliq with its taller line height; Latin letters, which Nastaliq does
/// not cover, fall back to Roboto.
class AutoDirectionField extends StatelessWidget {
  const AutoDirectionField({
    super.key,
    required this.controller,
    this.focusNode,
    this.decoration = const InputDecoration(),
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.sentences,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final InputDecoration decoration;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyLarge ?? const TextStyle();
    final (:urdu, :latin) = scriptStyles(base);
    // Latin text gets a line as tall as Nastaliq's, centred in it, so the
    // field does not grow and push the results below it down when the
    // first Urdu letter is typed.
    final tallLatin = latin.copyWith(
      height: urduLineHeight * urdu.fontSize! / latin.fontSize!,
      leadingDistribution: TextLeadingDistribution.even,
    );
    final uiDirection = Directionality.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final text = controller.text;
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: decoration,
          style: hasArabicScript(text) ? urdu : tallLatin,
          textDirection: textDirectionOf(text, uiDirection),
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          minLines: minLines,
          maxLines: maxLines,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
        );
      },
    );
  }
}
