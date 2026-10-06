package com.novabytex.aplicativo

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.provider.Settings
import android.net.Uri
import android.content.Context
import android.os.Build

class MainActivity : FlutterActivity() {
    private val SETTINGS_CHANNEL = "pe.yape.transporte/settings"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, YapeNotificationListenerService.EVENT_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    YapeNotificationListenerService.eventSink = events
                    toggleNotificationListenerService()
                    events?.success(mapOf("status" to "connected"))
                }

                override fun onCancel(arguments: Any?) {
                    YapeNotificationListenerService.eventSink = null
                }
            })

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SETTINGS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isNotificationServiceEnabled" -> result.success(isNotificationServiceEnabled())
                "openNotificationSettings" -> {
                    startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS))
                    result.success(null)
                }
                "openBatteryOptimizationSettings" -> {
                    try {
                        val intent = Intent()
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            intent.action = Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
                            intent.data = Uri.parse("package:$packageName")
                        } else {
                            intent.action = Settings.ACTION_SETTINGS
                        }
                        startActivity(intent)
                    } catch (_: Exception) {
                        startActivity(Intent(Settings.ACTION_SETTINGS))
                    }
                    result.success(null)
                }
                "getPendingBackgroundPayments" -> {
                    val prefs = getSharedPreferences(YapeNotificationListenerService.PREFS_NAME, Context.MODE_PRIVATE)
                    val pendingJson = prefs.getString(YapeNotificationListenerService.KEY_PENDING_PAYMENTS, "[]") ?: "[]"
                    prefs.edit().putString(YapeNotificationListenerService.KEY_PENDING_PAYMENTS, "[]").apply()
                    result.success(pendingJson)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun toggleNotificationListenerService() {
        try {
            val intent = Intent(this, YapeNotificationListenerService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(intent)
            } else {
                startService(intent)
            }
        } catch (_: Exception) {}
    }

    private fun isNotificationServiceEnabled(): Boolean {
        val flat = Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
        return flat?.contains(packageName) == true
    }
}
