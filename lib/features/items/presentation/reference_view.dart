import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../../../core/text/drawable_text.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/auto_direction_field.dart' show showLeftOut;
import '../../../core/widgets/user_text.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/item.dart';
import '../domain/reference.dart';

/// How long a shown reference stays visible.
const referenceRevealDuration = Duration(seconds: 30);

/// Hides a shown reference again when the app leaves the foreground and
/// after [referenceRevealDuration]. This narrows the window in which an
/// app-switcher snapshot can hold it but does not close it: Android may take
/// the snapshot before the hidden frame is drawn (ARCHITECTURE.md section 6).
mixin _HidesOnLeave<T extends StatefulWidget> on State<T> {
  late final AppLifecycleListener _lifecycle;
  Timer? _timer;

  bool get isShown;
  void setShown(bool shown);

  void show() {
    setShown(true);
    _timer?.cancel();
    _timer = Timer(referenceRevealDuration, hide);
  }

  void hide() {
    _timer?.cancel();
    _timer = null;
    if (mounted && isShown) setShown(false);
  }

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onInactive: hide, onHide: hide);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }
}

/// The Reference field on an item's page: masked until the user taps Show.
///
/// It is not selectable and has no copy action. While masked, screen readers
/// hear that it is hidden and never the value.
class ReferenceView extends StatefulWidget {
  const ReferenceView({super.key, required this.reference});

  final String reference;

  @override
  State<ReferenceView> createState() => _ReferenceViewState();
}

class _ReferenceViewState extends State<ReferenceView>
    with _HidesOnLeave<ReferenceView> {
  var _shown = false;

  @override
  bool get isShown => _shown;

  @override
  void setShown(bool shown) => setState(() => _shown = shown);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final toggle = _shown ? hide : show;
    final label = _shown
        ? l10n.referenceShownLabel(widget.reference)
        : l10n.referenceHiddenLabel;
    final at = _shown ? label.indexOf(widget.reference) : -1;

    return Semantics(
      // Its own node, so the label is exactly this and never merged with
      // the text around it.
      container: true,
      button: true,
      // A shown number is read digit by digit, not as one huge number.
      attributedLabel: AttributedString(
        label,
        attributes: [
          if (at >= 0)
            SpellOutStringAttribute(
              range: TextRange(start: at, end: at + widget.reference.length),
            ),
        ],
      ),
      // The platform says how to activate it; this says what it does.
      onTapHint: _shown ? l10n.referenceHide : l10n.referenceShow,
      onTap: toggle,
      excludeSemantics: true,
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                _shown ? widget.reference : maskReference(widget.reference),
                // Account and ID numbers read left to right in either
                // language, and Nastaliq has no bullet.
                textDirection: TextDirection.ltr,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: AppFonts.ui,
                  fontFamilyFallback: const [AppFonts.urdu],
                  letterSpacing: 1.2,
                  height: 1.4,
                ),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: toggle,
            icon: Icon(
              _shown
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            label: Text(_shown ? l10n.referenceHide : l10n.referenceShow),
          ),
        ],
      ),
    );
  }
}

/// The editor's Reference field: obscured until the user taps the eye, and
/// kept out of keyboard learning, suggestions and autofill.
class ReferenceField extends StatefulWidget {
  const ReferenceField({
    super.key,
    required this.controller,
    this.helperText,
    this.errorText,
  });

  final TextEditingController controller;
  final String? helperText;
  final String? errorText;

  @override
  State<ReferenceField> createState() => _ReferenceFieldState();
}

class _ReferenceFieldState extends State<ReferenceField>
    with _HidesOnLeave<ReferenceField> {
  var _shown = false;

  @override
  bool get isShown => _shown;

  @override
  void setShown(bool shown) => setState(() => _shown = shown);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final latin = latinFieldStyles(context);
    return TextField(
      controller: widget.controller,
      obscureText: !_shown,
      obscuringCharacter: '•',
      textDirection: TextDirection.ltr,
      // Reads left to right, but sits under its label at the start side.
      textAlign: alignWithLayout(context),
      style: latin.style,
      strutStyle: latin.strutStyle,
      keyboardType: TextInputType.visiblePassword,
      autocorrect: false,
      enableSuggestions: false,
      enableIMEPersonalizedLearning: false,
      // Only null keeps the field away from the platform's autofill
      // service; the default empty list still offers it to a password
      // manager, which could save the number and sync it.
      autofillHints: null,
      inputFormatters: [
        ...drawableTextFormatters(() => showLeftOut(context)),
        LengthLimitingTextInputFormatter(ItemLimits.referenceMax),
      ],
      decoration: InputDecoration(
        labelText: l10n.fieldReference,
        labelStyle: latin.labelStyle,
        helperText: widget.helperText,
        helperMaxLines: 3,
        errorText: widget.errorText,
        suffixIcon: IconButton(
          tooltip: _shown ? l10n.referenceHide : l10n.referenceShow,
          icon: Icon(
            _shown ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          ),
          onPressed: _shown ? hide : show,
        ),
      ),
    );
  }
}
