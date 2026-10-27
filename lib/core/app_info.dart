import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Facts about the app shown in Settings. A test keeps [version] in step
/// with `pubspec.yaml`.
abstract final class AppInfo {
  static const version = '0.1.0';
  static const maker = 'Oriental Tech Solutions';
  static final github = Uri.parse('https://github.com/OrientalTechSolutions');
  static final upwork = Uri.parse(
    'https://www.upwork.com/freelancers/attaullahhazarvi',
  );
}

/// Opens a web address in the browser, outside the app. Returns false when
/// nothing could open it. Tests replace it.
typedef LinkOpener = Future<bool> Function(Uri uri);

final linkOpenerProvider = Provider<LinkOpener>(
  (ref) =>
      (uri) => launchUrl(uri, mode: LaunchMode.externalApplication),
);
