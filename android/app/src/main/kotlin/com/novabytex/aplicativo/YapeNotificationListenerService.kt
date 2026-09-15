package com.novabytex.aplicativo

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.os.Bundle
import android.util.Log
import io.flutter.plugin.common.EventChannel
import android.os.Handler
import android.os.Looper
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.content.Intent
import android.content.pm.ServiceInfo

class YapeNotificationListenerService : NotificationListenerService() {
    companion object {
        const val EVENT_CHANNEL = "pe.yape.transporte/notifications"
        var eventSink: EventChannel.EventSink? = null
        private const val CHANNEL_ID = "sonopay_service_channel"
        private const val NOTIFICATION_ID = 888
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForegroundService()
        return 1
    }

    private fun startForegroundService() {
        val channelName = "SonoPay Background Service"
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val chan = NotificationChannel(CHANNEL_ID, channelName, NotificationManager.IMPORTANCE_LOW)
            chan.setShowBadge(false)
            manager.createNotificationChannel(chan)
        }

        val notificationBuilder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            Notification.Builder(this)
        }

        val notification = notificationBuilder.setOngoing(true)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle("SonoPay Activo")
            .setContentText("Detectando pagos en segundo plano...")
            .setCategory(Notification.CATEGORY_SERVICE)
            .build()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC)
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        val sbnNonNull = sbn ?: return
        val packageName = sbnNonNull.packageName ?: ""
        
        val isYape = packageName.contains("yape", ignoreCase = true)
        val isBcp = packageName.contains("bcp", ignoreCase = true)
        val isPlin = packageName.contains("bbva", ignoreCase = true) || 
                     packageName.contains("scotiabank", ignoreCase = true) ||
                     packageName.contains("interbank", ignoreCase = true) ||
                     packageName.contains("banbif", ignoreCase = true) ||
                     packageName.contains("pichincha", ignoreCase = true) ||
                     packageName.contains("plin", ignoreCase = true)

        if (!isYape && !isBcp && !isPlin) return

        val extras: Bundle = sbnNonNull.notification.extras
        val title = extras.get("android.title")?.toString() ?: ""
        val text = extras.get("android.text")?.toString() ?: ""
        val bigText = extras.get("android.bigText")?.toString() ?: ""
        val content = if (bigText.length > text.length) bigText else text

        val data = mutableMapOf<String, Any>(
            "packageName" to packageName, 
            "rawTitle" to title, 
            "rawBody" to content
        )

        Handler(Looper.getMainLooper()).post { 
            try { 
                eventSink?.success(data) 
            } catch (e: Exception) { 
                Log.e("SonoPayService", "EventSink error", e)
            } 
        }
    }
}
