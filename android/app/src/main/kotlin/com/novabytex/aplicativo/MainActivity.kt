package com.novabytex.aplicativo

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.provider.Settings
import android.text.TextUtils
import android.app.NotificationManager
import android.content.Context
import android.content.ComponentName
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
                "isAccessibilityServiceEnabled" -> result.success(isAccessibilityServiceEnabled())
                "openAccessibilitySettings" -> {
                    startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun toggleNotificationListenerService() {
        try {
            val intent = Intent(this, YapeNotificationListenerService::class.java)
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                startForegroundService(intent)
            } else {
                startService(intent)
            }
        } catch (e: Exception) {}
    }

    private fun isNotificationServiceEnabled(): Boolean {
        val flat = Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
        return flat?.contains(packageName) == true
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val flat = Settings.Secure.getString(contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES)
        return flat?.contains(packageName) == true
    }
}
