package com.orientaltechsolutions.yaadi

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // What Settings shows under "Will reminders arrive?" (ARCHITECTURE.md
        // section 18). Read-only checks, and a settings screen the user
        // changes themselves: Yaadi never asks to be exempted directly.
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "yaadi/reminder_health",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "batteryUnrestricted" -> {
                    val power = getSystemService(POWER_SERVICE) as PowerManager
                    result.success(power.isIgnoringBatteryOptimizations(packageName))
                }
                "manufacturer" -> result.success(Build.MANUFACTURER)
                "openBatterySettings" -> {
                    val list = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                    val details = Intent(
                        Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                        Uri.fromParts("package", packageName, null),
                    )
                    try {
                        startActivity(list)
                    } catch (_: Exception) {
                        startActivity(details)
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
