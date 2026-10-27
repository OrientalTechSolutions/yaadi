import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the real fonts. With Flutter's test font every Urdu glyph is a box,
/// and Nastaliq's real failure mode, ink clipped inside a row, never shows.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  // A tap that only lands because an ancestor happens to catch it breaks
  // silently when the layout changes; aim at the real target instead.
  WidgetController.hitTestWarningShouldBeFatal = true;
  await _loadFont('Roboto', const [
    'assets/fonts/roboto/Roboto-Regular.ttf',
    'assets/fonts/roboto/Roboto-Medium.ttf',
    'assets/fonts/roboto/Roboto-Bold.ttf',
  ]);
  await _loadFont('NotoNastaliqUrdu', const [
    'assets/fonts/noto_nastaliq_urdu/NotoNastaliqUrdu-Regular.ttf',
    'assets/fonts/noto_nastaliq_urdu/NotoNastaliqUrdu-Bold.ttf',
  ]);
  await testMain();
}

Future<void> _loadFont(String family, List<String> assets) async {
  final loader = FontLoader(family);
  for (final asset in assets) {
    loader.addFont(rootBundle.load(asset));
  }
  await loader.load();
}
