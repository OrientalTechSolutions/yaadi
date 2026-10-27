import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/error_redaction.dart';
import 'core/licenses.dart';

void main() {
  redactErrorsInRelease();
  registerFontLicenses();
  runApp(const ProviderScope(child: YaadiApp()));
}
