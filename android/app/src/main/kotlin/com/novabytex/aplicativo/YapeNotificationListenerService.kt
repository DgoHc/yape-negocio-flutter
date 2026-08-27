package com.novabytex.aplicativo

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.os.Bundle
import android.util.Log
import io.flutter.plugin.common.EventChannel
import android.os.Handler
import android.os.Looper

class YapeNotificationListenerService : NotificationListenerService() {

    companion object {
        const val EVENT_CHANNEL = "pe.yape.transporte/notifications"
        var eventSink: EventChannel.EventSink? = null
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        val sbnNonNull = sbn ?: return
        val packageName = sbnNonNull.packageName ?: ""
        
        // Buscamos coincidencias de Yape o BCP
        val isYape = packageName.contains("yape", ignoreCase = true)
        val isBcp = packageName.contains("bcp", ignoreCase = true)
        
        if (!isYape && !isBcp) return

        val extras: Bundle = sbnNonNull.notification.extras
        val title = extras.get("android.title")?.toString() ?: ""
        val text = extras.get("android.text")?.toString() ?: ""
        val bigText = extras.get("android.bigText")?.toString() ?: ""
        
        val content = if (bigText.length > text.length) bigText else text

        // LOG CRÍTICO PARA DEBUG - VERSION 3.0
        Log.d("YapeService", ">>> CAPTURA TOTAL [v3.0]: $packageName | $content")

        val data = mutableMapOf<String, Any>()
        data["packageName"] = packageName
        data["rawTitle"] = title
        data["rawBody"] = content

        Handler(Looper.getMainLooper()).post {
            try {
                eventSink?.success(data)
            } catch (e: Exception) {
                Log.e("YapeService", "Error EventSink", e)
            }
        }
    }
}
