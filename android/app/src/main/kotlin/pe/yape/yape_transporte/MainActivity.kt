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
        
        // EventChannel para notificaciones
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, YapeNotificationListenerService.EVENT_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    YapeNotificationListenerService.eventSink = events
                    // Forzar reconexión del servicio nativo
                    toggleNotificationListenerService()
                    events?.success(mapOf("status" to "connected"))
                }

                override fun onCancel(arguments: Any?) {
                    YapeNotificationListenerService.eventSink = null
                }
            })

        // MethodChannel para ajustes y permisos
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SETTINGS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isNotificationServiceEnabled" -> {
                    result.success(isNotificationServiceEnabled())
                }
                "openNotificationSettings" -> {
                    startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS))
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun toggleNotificationListenerService() {
        try {
            // Intentamos iniciar el servicio como foreground service explícitamente
            val intent = Intent(this, YapeNotificationListenerService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(intent)
            } else {
                startService(intent)
            }

            val componentName = ComponentName(this, YapeNotificationListenerService::class.java)
            val packageManager = packageManager
            packageManager.setComponentEnabledSetting(
                componentName,
                android.content.pm.PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                android.content.pm.PackageManager.DONT_KILL_APP
            )
            packageManager.setComponentEnabledSetting(
                componentName,
                android.content.pm.PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                android.content.pm.PackageManager.DONT_KILL_APP
            )
        } catch (e: Exception) {}
    }

    override fun onResume() {
        super.onResume()
        // Cuando la app vuelve al primer plano, notificamos el estado del servicio
        YapeNotificationListenerService.eventSink?.success(mapOf("status" to if (isNotificationServiceEnabled()) "connected" else "disconnected"))
    }

    private fun isNotificationServiceEnabled(): Boolean {
        val pkgName = packageName
        val flat = Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
        if (!TextUtils.isEmpty(flat)) {
            val names = flat.split(":").toTypedArray()
            for (name in names) {
                val cn = ComponentName.unflattenFromString(name)
                if (cn != null) {
                    if (TextUtils.equals(pkgName, cn.packageName)) {
                        return true
                    }
                }
            }
        }
        return false
    }
}
