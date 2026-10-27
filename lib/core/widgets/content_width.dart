import 'dart:math' as math;

import 'package:flutter/widgets.dart';

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
