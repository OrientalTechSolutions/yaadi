import 'package:flutter/material.dart';

/// A heading screen readers can jump to.
///
/// The semantics node is a container of its own: without that, a header flag
/// merges into the parent node and turns the whole card or section into one
/// long "heading".
class Heading extends StatelessWidget {
  const Heading(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.semanticsLabel,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  /// What screen readers hear instead of [text], such as a count in words.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      container: true,
      label: semanticsLabel,
      excludeSemantics: semanticsLabel != null,
      child: Text(text, style: style, textAlign: textAlign),
    );
  }
}
