package com.novabytex.aplicativo

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import androidx.core.app.NotificationCompat
import io.flutter.plugin.common.EventChannel
import android.util.Log
import android.os.Handler
import android.os.Looper

class YapeNotificationListenerService : NotificationListenerService() {

    companion object {
        val PACKAGES_YAPE = arrayOf(
            "pe.com.interbank.yape", 
            "com.bcp.yape.app",
            "com.bcp.yape",
            "com.bcp.innovacxion.yapeapp",
            "pe.com.interbank.yape.app",
            "pe.com.interbank.yape.android"
        )
        const val EVENT_CHANNEL = "pe.yape.transporte/notifications"
        var eventSink: EventChannel.EventSink? = null
        const val CHANNEL_ID = "YapeTransporteServiceChannel"
        const val NOTIFICATION_ID = 99
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val notification = createNotification("Servicio de Monitoreo Activo")
        startForeground(NOTIFICATION_ID, notification)
        return START_STICKY
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Yape Transporte Monitor",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(serviceChannel)
        }
    }

    private fun createNotification(contentText: String): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Yape Transporte")
            .setContentText(contentText)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        try {
            Handler(Looper.getMainLooper()).post {
                eventSink?.success(mapOf("status" to "connected"))
            }
        } catch (e: Exception) {
            Log.e("YapeService", "Error notificando conexión", e)
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        
        val notification = sbn ?: return
        val packageName = notification.packageName ?: ""
        
        val extras: Bundle = notification.notification.extras
        val title: String = extras.getString("android.title", "") ?: ""
        val body: String = extras.getString("android.text", "") ?: ""
        val text = if (body.isEmpty()) extras.getString("android.infoText", "") ?: "" else body

        // Log para ver en Logcat
        Log.d("YapeService", "Notificación: $packageName | $title | $text")

        val data = mutableMapOf<String, Any>(
            "debugPackage" to packageName,
            "debugTitle" to title,
            "debugBody" to text,
            "postTime" to notification.postTime
        )

        // Si el paquete es de Yape, añadimos los campos que espera el parser de Dart
        if (PACKAGES_YAPE.contains(packageName)) {
            Log.d("YapeService", "¡NOTIFICACIÓN DE YAPE DETECTADA!")
            data["rawTitle"] = title
            data["rawBody"] = text
            data["packageName"] = packageName
        }

        // Siempre enviamos a Flutter en el hilo principal
        Handler(Looper.getMainLooper()).post {
            try {
                eventSink?.success(data)
            } catch (e: Exception) {
                Log.e("YapeService", "Error enviando a Flutter", e)
            }
        }
    }
}
