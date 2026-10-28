import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Widest a column of reading content gets on large screens.
const maxContentWidth = 720.0;

/// Side padding that keeps content in a centred column no wider than
/// [maxWidth]. The scrollable around it still spans the window, so it
/// scrolls from anywhere and its scrollbar sits at the edge.
double contentGutter(double width, {double maxWidth = maxContentWidth}) =>
    math.max(16, (width - maxWidth) / 2);

/// A scrolling column of content, centred on wide screens.
class ContentListView extends StatelessWidget {
  const ContentListView({
    super.key,
    required this.children,
    this.top = 8,
    this.bottom = 24,
    this.maxWidth = maxContentWidth,
  });

  final List<Widget> children;
  final double top;
  final double bottom;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gutter = contentGutter(constraints.maxWidth, maxWidth: maxWidth);
        return ListView(
          padding: EdgeInsets.fromLTRB(gutter, top, gutter, bottom),
          children: children,
        );
      },
    );
  }
}

/// An app bar for a top-level screen whose title and actions line up with
/// the [ContentListView] column on wide screens, instead of sitting at the
/// window's edges far from the content.
class ContentAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ContentAppBar({super.key, required this.title, this.actions});

  final Widget title;
  final List<Widget>? actions;

  /// An [AppBar]'s own size, which the Scaffold reads together with the
  /// theme's toolbar height: taller at large text sizes, like every other
  /// app bar.
  @override
  Size get preferredSize => _sizeLikeAppBar;

  static final _sizeLikeAppBar = AppBar().preferredSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gutter = contentGutter(constraints.maxWidth);
        return AppBar(
          title: title,
          titleSpacing: gutter,
          // The Demo badge brings 12 dp of its own at the end.
          actionsPadding: EdgeInsetsDirectional.only(
            end: math.max(0, gutter - 12),
          ),
          actions: actions,
        );
      },
    );
  }
}
