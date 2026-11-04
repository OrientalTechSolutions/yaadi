import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/error_redaction.dart';
import 'core/licenses.dart';
import 'features/reminders/application/reminder_providers.dart';
import 'features/reminders/data/local_notifications_gateway.dart';

void main() {
  redactErrorsInRelease();
  registerBundledLicenses();
  final phone =
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  runApp(
    ProviderScope(
      overrides: [
        // Phones remind; the web demo and tests keep the stand-in.
        if (phone)
          reminderGatewayProvider.overrideWithValue(
            LocalNotificationsGateway(),
          ),
      ],
      child: const YaadiApp(),
    ),
  );
}
