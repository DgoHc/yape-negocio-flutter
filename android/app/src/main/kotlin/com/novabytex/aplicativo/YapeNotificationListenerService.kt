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
import java.util.regex.Pattern
import org.json.JSONArray
import org.json.JSONObject

class YapeNotificationListenerService : NotificationListenerService() {
    companion object {
        const val EVENT_CHANNEL = "pe.yape.transporte/notifications"
        var eventSink: EventChannel.EventSink? = null
        private const val CHANNEL_ID = "sonopay_service_channel"
        private const val NOTIFICATION_ID = 888
        const val PREFS_NAME = "sonopay_native_prefs"
        const val KEY_PENDING_PAYMENTS = "pending_payments_json"
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForegroundService()
        return 1 // START_STICKY
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        Log.d("SonoPayService", "NotificationListener connected successfully")
        startForegroundService()
        val data = mutableMapOf<String, Any>(
            "status" to "connected"
        )
        Handler(Looper.getMainLooper()).post {
            try { eventSink?.success(data) } catch (_: Exception) {}
        }
    }

    override fun onListenerDisconnected() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            super.onListenerDisconnected()
        }
        Log.d("SonoPayService", "NotificationListener disconnected! Forcing rebind...")
        BootReceiver.rebindService(this)
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
            .setContentText("Detectando pagos de Yape y Plin en segundo plano...")
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
        val subText = extras.get("android.subText")?.toString() ?: ""
        val tickerText = sbnNonNull.notification.tickerText?.toString() ?: ""

        val fullContent = listOf(text, bigText, subText, tickerText)
            .filter { it.isNotEmpty() }
            .maxByOrNull { it.length } ?: ""

        val rawBody = if (fullContent.isNotEmpty()) fullContent else title

        Log.d("SonoPayService", "Notification Captured: pkg=$packageName | title=$title | rawBody=$rawBody")

        val data = mutableMapOf<String, Any>(
            "packageName" to packageName, 
            "rawTitle" to title, 
            "rawBody" to rawBody
        )

        // 1. Enviar a Flutter para que Flutter Dart procese el pago y hable por TTS una sola vez
        Handler(Looper.getMainLooper()).post { 
            try { 
                eventSink?.success(data) 
            } catch (e: Exception) { 
                Log.e("SonoPayService", "EventSink error", e)
            } 
        }

        // 2. Guardar en cola nativa de SharedPreferences para sincronización de fondo
        val parsed = parseNativePayment(title, rawBody)
        if (parsed != null) {
            val senderName = parsed.first.replace("*", "").replace("#", "").trim()
            val amount = parsed.second
            savePendingPaymentToPrefs(senderName, amount, "$title $rawBody")
        }
    }

    private fun savePendingPaymentToPrefs(senderName: String, amount: Double, rawText: String) {
        try {
            val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val jsonArrayStr = prefs.getString(KEY_PENDING_PAYMENTS, "[]") ?: "[]"
            val jsonArray = JSONArray(jsonArrayStr)

            val newObj = JSONObject().apply {
                put("senderName", senderName)
                put("amount", amount)
                put("currency", "S/")
                put("rawText", rawText)
                put("parsedAt", System.currentTimeMillis())
            }

            jsonArray.put(newObj)
            prefs.edit().putString(KEY_PENDING_PAYMENTS, jsonArray.toString()).apply()
            Log.d("SonoPayService", "Pending payment saved natively: $senderName | $amount")
        } catch (e: Exception) {
            Log.e("SonoPayService", "Error saving pending payment to prefs", e)
        }
    }

    private fun parseNativePayment(title: String, body: String): Pair<String, Double>? {
        val fullText = "$title $body".replace("\n", " ").trim()
        
        val patterns = listOf(
            Pattern.compile("Confirmaci[óo]n\\s+de\\s+Pago\\s+(?:Yape!?\\s*)?(.+?)\\s*[-–]?\\s*(?:S/|PEN|S\\./)\\s*(\\d+(?:[.,]\\d+)?)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("Te\\s+yapeó\\s+(?:S/|PEN|S\\./)\\s*(\\d+(?:[.,]\\d+)?)\\s+(.+)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(.+?)\\s+te\\s+yapeó\\s+(?:S/|PEN|S\\./)\\s*(\\d+(?:[.,]\\d+)?)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("¡?Te\\s+yapearon!?\\s+(.+?)\\s*[-–]\\s*(?:S/|PEN|S\\./)\\s*(\\d+(?:[.,]\\d+)?)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(.+?)\\s+te\\s+envió\\s+un\\s+pago\\s+por\\s+(?:S/|PEN|S\\./)\\s*(\\d+(?:[.,]\\d+)?)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(?:Has\\s+recibido|Recibiste)\\s+(?:S/|PEN|S\\./)\\s*(\\d+(?:[.,]\\d+)?)\\s+de\\s+(.+)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("^(.+?)\\s*[-–]\\s*(?:S/|PEN|S\\./)\\s*(\\d+(?:[.,]\\d+)?)$", Pattern.CASE_INSENSITIVE)
        )

        for (pattern in patterns) {
            val matcher = pattern.matcher(fullText)
            if (matcher.find()) {
                try {
                    val group1 = matcher.group(1)?.trim() ?: ""
                    val group2 = matcher.group(2)?.trim() ?: ""

                    var amount = group1.replace(",", ".").toDoubleOrNull()
                    var name = group2

                    if (amount == null) {
                        amount = group2.replace(",", ".").toDoubleOrNull()
                        name = group1
                    }

                    if (amount != null && amount > 0 && name.isNotEmpty()) {
                        name = name
                            .replace(Regex("(?i)^(?:Confirmaci[óo]n(?:\\s+de)?(?:\\s+Pago)?(?:\\s+Yape!?)?|Yape:?|Plin:?|¡?Te\\s+yapearon!?|¡?Recibiste\\s+un\\s+(?:Yape|Plin)!?)\\s*"), "")
                            .replace(Regex("(?i)^Confirmaci[óo]n\\s+de\\s+(?:Pago\\s+)?(?:Yape!?)?\\s*"), "")
                            .replace(Regex("(?i)^Yape!|\\bYape!\\b"), "")
                            .replace(Regex("[*＊#_~^•·¡!]+"), " ")
                            .replace(Regex("[^a-zA-ZáéíóúÁÉÍÓÚñÑ0-9]+$"), "")
                            .trim()
                        if (name.isEmpty()) name = "Cliente Yape"
                        return Pair(name, amount)
                    }
                } catch (_: Exception) {}
            }
        }
        return null
    }
}
