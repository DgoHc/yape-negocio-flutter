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
import android.speech.tts.TextToSpeech
import java.util.Locale
import java.util.regex.Pattern
import org.json.JSONArray
import org.json.JSONObject

class YapeNotificationListenerService : NotificationListenerService(), TextToSpeech.OnInitListener {
    companion object {
        const val EVENT_CHANNEL = "pe.yape.transporte/notifications"
        var eventSink: EventChannel.EventSink? = null
        private const val CHANNEL_ID = "sonopay_service_channel"
        private const val NOTIFICATION_ID = 888
        const val PREFS_NAME = "sonopay_native_prefs"
        const val KEY_PENDING_PAYMENTS = "pending_payments_json"
    }

    private var tts: TextToSpeech? = null
    private var isTtsReady = false

    override fun onCreate() {
        super.onCreate()
        try {
            startForegroundService()
            initTts()
        } catch (e: Exception) {
            Log.e("SonoPayService", "Error en onCreate del servicio", e)
        }
    }

    private fun initTts() {
        try {
            tts = TextToSpeech(applicationContext, this)
        } catch (e: Exception) {
            Log.e("SonoPayService", "Error inicializando TTS nativo", e)
        }
    }

    override fun onInit(status: Int) {
        if (status == TextToSpeech.SUCCESS) {
            val result = tts?.setLanguage(Locale("es", "PE"))
            if (result != TextToSpeech.LANG_MISSING_DATA && result != TextToSpeech.LANG_NOT_SUPPORTED) {
                isTtsReady = true
                Log.d("SonoPayService", "TTS nativo listo para es-PE")
            } else {
                tts?.setLanguage(Locale("es", "ES"))
                isTtsReady = true
            }
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForegroundService()
        return 1 // START_STICKY
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        Log.d("SonoPayService", "NotificationListener conectado exitosamente")
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
        Log.d("SonoPayService", "NotificationListener desconectado! Re-vinculando...")
        BootReceiver.rebindService(this)
    }

    private fun startForegroundService() {
        try {
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
                .setContentText("Detectando pagos de Yape, Plin y Mi Banco en tiempo real...")
                .setCategory(Notification.CATEGORY_SERVICE)
                .build()

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC)
            } else {
                startForeground(NOTIFICATION_ID, notification)
            }
        } catch (e: Exception) {
            Log.e("SonoPayService", "Error al iniciar servicio en primer plano", e)
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        val sbnNonNull = sbn ?: return
        val packageName = sbnNonNull.packageName ?: ""

        // 1. VERIFICAR SI LA DETECCIÓN FUE PAUSADA DESDE FLUTTER PARA AHORRAR BATERÍA
        try {
            val flutterPrefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val isDetectionEnabled = flutterPrefs.getBoolean("flutter.detection_enabled", true)
            if (!isDetectionEnabled) return
        } catch (_: Exception) {}

        // 2. LISTA BLANCA ESTRICTA DE APPS FINANCIERAS EN PERÚ Y COMANDO ADB
        val isYape = packageName.equals("com.bcp.innovacxion.yapeapp", ignoreCase = true) || packageName.contains("yape", ignoreCase = true)
        val isBcp = packageName.contains("bcp", ignoreCase = true)
        val isMiBanco = packageName.contains("mibanco", ignoreCase = true) || packageName.contains("mi.banco", ignoreCase = true)
        val isPlin = packageName.contains("bbva", ignoreCase = true) || 
                     packageName.contains("scotiabank", ignoreCase = true) ||
                     packageName.contains("interbank", ignoreCase = true) ||
                     packageName.contains("banbif", ignoreCase = true) ||
                     packageName.contains("pichincha", ignoreCase = true) ||
                     packageName.contains("plin", ignoreCase = true) ||
                     packageName.contains("caja", ignoreCase = true) ||
                     packageName.contains("cmac", ignoreCase = true)

        val isAdbShell = packageName.equals("com.android.shell", ignoreCase = true) ||
                         packageName.contains("notification_simulator", ignoreCase = true) ||
                         packageName.contains("notification_tester", ignoreCase = true)

        if (!isYape && !isBcp && !isMiBanco && !isPlin && !isAdbShell) return

        val extras: Bundle = sbnNonNull.notification.extras
        val title = extras.get("android.title")?.toString() ?: ""
        val text = extras.get("android.text")?.toString() ?: ""
        val bigText = extras.get("android.bigText")?.toString() ?: ""
        val subText = extras.get("android.subText")?.toString() ?: ""
        val tickerText = sbnNonNull.notification.tickerText?.toString() ?: ""

        // CONCATENAR TODOS LOS TEXTOS PARA NO PERDER EL CONTENIDO
        val fullContent = listOf(title, text, bigText, subText, tickerText)
            .filter { it.isNotEmpty() }
            .distinct()
            .joinToString(" ")

        val rawBody = if (fullContent.isNotEmpty()) fullContent else title
        val lowerText = rawBody.lowercase()

        // IGNORAR NOTIFICACIONES VACÍAS (RESÚMENES DE GRUPO EN XIAOMI / SAMSUNG)
        if (rawBody.trim().isEmpty()) {
            Log.d("SonoPayService", "Ignorando notificación con texto vacío de $packageName")
            return
        }

        // SI ES COMANDO ADB, EXIGIR QUE CONTENGA UNA PALABRA CLAVE DE PAGO
        if (isAdbShell) {
            val containsPaymentKeyword = listOf("yape", "plin", "banco", "pago", "recibiste", "envió", "enviado", "yapeó", "s/", "soles", "pen")
                .any { lowerText.contains(it) }
            if (!containsPaymentKeyword) return
        }

        // FILTRO DE PAGOS SALIENTES
        val strictOutgoingKeywords = listOf(
            "enviaste un yape", "yapeaste s/", "yapeaste a ", "le enviaste",
            "transferencia realizada con éxito", "has enviado s/", "pago realizado a ",
            "pago exitoso a "
        )

        for (keyword in strictOutgoingKeywords) {
            if (lowerText.contains(keyword)) {
                Log.d("SonoPayService", "Ignorando notificación de pago saliente: $title $rawBody")
                return
            }
        }

        Log.d("SonoPayService", "Notification Capturada: pkg=$packageName | title=$title | rawBody=$rawBody")

        val data = mutableMapOf<String, Any>(
            "packageName" to packageName, 
            "rawTitle" to title, 
            "rawBody" to rawBody
        )

        // 1. Si Flutter está abierto en primer plano, enviar evento por EventChannel
        Handler(Looper.getMainLooper()).post { 
            try { 
                eventSink?.success(data) 
            } catch (e: Exception) { 
                Log.e("SonoPayService", "EventSink error", e)
            } 
        }

        // 2. Procesamiento Nativo de Respaldo (Si Flutter está cerrado o no responde)
        val parsed = parseNativePayment(title, rawBody)
        if (parsed != null) {
            val senderName = parsed.first.replace("*", "").replace("#", "").trim()
            val amount = parsed.second

            // Si Flutter está cerrado, hablar por voz nativa y guardar en prefs
            if (eventSink == null) {
                speakNative("$senderName envió $amount soles")
                savePendingPaymentToPrefs(senderName, amount, "$title $rawBody")
            }
        }
    }

    private fun speakNative(text: String) {
        try {
            if (tts == null) {
                initTts()
            }
            if (isTtsReady && tts != null) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    tts?.speak(text, TextToSpeech.QUEUE_FLUSH, null, "sonopay_native_tts")
                } else {
                    @Suppress("DEPRECATION")
                    tts?.speak(text, TextToSpeech.QUEUE_FLUSH, null)
                }
            } else {
                Log.w("SonoPayService", "TTS nativo no listo aún, reintentando...")
            }
        } catch (e: Exception) {
            Log.e("SonoPayService", "Error en speakNative", e)
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
            Log.d("SonoPayService", "Pago pendiente guardado nativamente: $senderName | $amount")
        } catch (e: Exception) {
            Log.e("SonoPayService", "Error guardando pago pendiente", e)
        }
    }

    private fun parseNativePayment(title: String, body: String): Pair<String, Double>? {
        val fullText = "$title $body".replace("\n", " ").trim()
        val cleanText = fullText.replace(Regex("(?i)\\.\\s*El\\s+c[óo]d(?:\\.|igo)?\\s+de\\s+seguridad\\s+es:?.*$"), "").trim()

        val patterns = listOf(
            Pattern.compile("Confirmaci[óo]n\\s+de\\s+Pago\\s+(?:Yape!?\\s*)?(.+?)\\s*[-–]?\\s*(?:S/|PEN|S\\./)\\s*(\\d+(?:[.,]\\d+)?)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("Te\\s+yapeó\\s+(?:S/|PEN|S\\./)\\s*(\\d+(?:[.,]\\d+)?)\\s+(.+)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(.+?)\\s+te\\s+yapeó\\s+(?:S/|PEN|S\\./)\\s*(\\d+(?:[.,]\\d+)?)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("¡?Te\\s+yapearon!?\\s+(.+?)\\s*[-–]\\s*(?:S/|PEN|S\\./)\\s*(\\d+(?:[.,]\\d+)?)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(?:Confirmaci[óo]n\\s+)?(.+?)\\s+te\\s+envi[óo]\\s+(?:un\\s+pago\\s+)?(?:por|de)\\s*(?:S/|PEN|S\\./)?\\s*(\\d+(?:[.,]\\d+)?)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(?:Has\\s+recibido|Recibiste)\\s+(?:S/|PEN|S\\./)\\s*(\\d+(?:[.,]\\d+)?)\\s+de\\s+(.+)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("^(.+?)\\s*[-–]\\s*(?:S/|PEN|S\\./)\\s*(\\d+(?:[.,]\\d+)?)$", Pattern.CASE_INSENSITIVE)
        )

        var name: String? = null
        var amount: Double? = null

        for (pattern in patterns) {
            val matcher = pattern.matcher(cleanText)
            if (matcher.find()) {
                try {
                    val group1 = matcher.group(1)?.trim() ?: ""
                    val group2 = matcher.group(2)?.trim() ?: ""

                    var parsedAmount = group1.replace(",", ".").toDoubleOrNull()
                    var parsedName = group2

                    if (parsedAmount == null) {
                        parsedAmount = group2.replace(",", ".").toDoubleOrNull()
                        parsedName = group1
                    }

                    if (parsedAmount != null && parsedAmount > 0 && parsedName.isNotEmpty()) {
                        amount = parsedAmount
                        name = cleanNativeSenderName(parsedName)
                        break
                    }
                } catch (_: Exception) {}
            }
        }

        // FALLBACK INTELIGENTE NATIVO CON PALABRAS CLAVE DE PAGO EXIGIDAS
        if (amount == null || name.isNullOrEmpty()) {
            val matcher = Pattern.compile("(?:S/|PEN|S\\./)?\\s*(\\d+(?:[.,]\\d+)?)\\s*(?:soles|PEN|S/)?", Pattern.CASE_INSENSITIVE).matcher(cleanText)
            if (matcher.find()) {
                val parsedAmount = matcher.group(1)?.replace(",", ".")?.toDoubleOrNull()
                val lowerClean = cleanText.lowercase()
                val hasPaymentContext = listOf("yape", "plin", "banco", "pago", "recibiste", "envió", "yapeó", "soles", "s/").any { lowerClean.contains(it) }
                
                if (parsedAmount != null && parsedAmount > 0 && hasPaymentContext) {
                    amount = parsedAmount
                    val rawName = cleanText.replace(matcher.group(0) ?: "", "")
                    name = cleanNativeSenderName(rawName)
                }
            }
        }

        if (amount != null && amount > 0 && !name.isNullOrEmpty()) {
            return Pair(name!!, amount!!)
        }

        return null
    }

    private fun cleanNativeSenderName(rawName: String): String {
        val cleaned = rawName
            .replace(Regex("(?i)\\s+te\\s+(?:envi[óo]|yape[óo]).*$"), "")
            .replace(Regex("(?i)\\s+(?:por|de)\\s*(?:S/|PEN|S\\./)?\\s*\\d+.*$"), "")
            .replace(Regex("(?i)\\b(?:Confirmaci[óo]n|de|Pago|Yape|Plin|Mi|Banco|Recibiste|un|te|envi[óo]|yape[óo]|por|soles|PEN|S/|Tag\\d*)\\b"), " ")
            .replace(Regex("[*＊#_~^•·¡!]+"), " ")
            .replace(Regex("^[^a-zA-ZáéíóúÁÉÍÓÚñÑ0-9]+"), "")
            .replace(Regex("[^a-zA-ZáéíóúÁÉÍÓÚñÑ0-9]+$"), "")
            .replace(Regex("\\s+"), " ")
            .trim()
        return if (cleaned.isEmpty()) "Cliente" else cleaned
    }

    override fun onDestroy() {
        try {
            tts?.stop()
            tts?.shutdown()
        } catch (_: Exception) {}
        super.onDestroy()
    }
}
