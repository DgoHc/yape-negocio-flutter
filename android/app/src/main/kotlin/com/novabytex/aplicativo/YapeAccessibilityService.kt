package com.novabytex.aplicativo

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import android.util.Log
import io.flutter.plugin.common.EventChannel
import android.os.Handler
import android.os.Looper

class YapeAccessibilityService : AccessibilityService() {

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        // Solo procesamos cambios en la ventana o contenido
        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED || 
            event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            
            val rootNode = rootInActiveWindow ?: return
            scrapeYapeData(rootNode)
        }
    }

    private fun scrapeYapeData(node: AccessibilityNodeInfo) {
        // Buscamos nodos que contengan S/ o montos
        // Esta es una lógica genérica de scrapping que recorre el árbol de la UI
        val text = node.text?.toString() ?: ""
        
        // Ejemplo: Si detectamos el símbolo de moneda, intentamos capturar el contexto cercano
        if (text.contains("S/") || text.contains("S./")) {
            val data = mutableMapOf<String, Any>()
            data["scrapedContent"] = text
            data["source"] = "accessibility"
            data["packageName"] = node.packageName?.toString() ?: ""

            // Enviamos el dato extraído a Flutter
            Handler(Looper.getMainLooper()).post {
                YapeNotificationListenerService.eventSink?.success(data)
            }
        }

        // Recurrencia para revisar hijos
        for (i in 0 until node.childCount) {
            val child = node.getChild(i)
            if (child != null) {
                scrapeYapeData(child)
            }
        }
    }

    override fun onInterrupt() {}
}
