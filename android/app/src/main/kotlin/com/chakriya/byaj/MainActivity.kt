package com.chakriya.byaj

import android.content.SharedPreferences
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.chakriya.byaj/notification"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                val prefs: SharedPreferences =
                    applicationContext.getSharedPreferences(
                        "NepaliDateWidgetPrefs", MODE_PRIVATE
                    )

                when (call.method) {
                    "showNotification" -> {
                        val useNepali = call.argument<Boolean>("useNepali") ?: true
                        prefs.edit()
                            .putBoolean("notif_enabled", true)
                            .putBoolean("use_nepali_language", useNepali)
                            .apply()
                        NepaliDateNotificationService.postNotification(applicationContext, useNepali)
                        result.success(true)
                    }
                    "cancelNotification" -> {
                        prefs.edit().putBoolean("notif_enabled", false).apply()
                        NepaliDateNotificationService.cancel(applicationContext)
                        result.success(true)
                    }
                    "updateLanguage" -> {
                        val useNepali = call.argument<Boolean>("useNepali") ?: true
                        prefs.edit()
                            .putBoolean("use_nepali_language", useNepali)
                            .apply()
                        val enabled = prefs.getBoolean("notif_enabled", false)
                        if (enabled) {
                            NepaliDateNotificationService.postNotification(applicationContext, useNepali)
                        }
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
