package com.novabytex.aplicativo

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import android.util.Log
import android.os.Handler
import android.os.Looper

class YapeAccessibilityService : AccessibilityService() {

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        val eventNonNull = event ?: return
        val packageName = eventNonNull.packageName?.toString() ?: ""

        if (!packageName.contains("yape", ignoreCase = true) &&
            !packageName.contains("bcp", ignoreCase = true) &&
            !packageName.contains("plin", ignoreCase = true) &&
            !packageName.contains("bbva", ignoreCase = true)) {
            return
        }

        val extractedTexts = mutableListOf<String>()
        
        eventNonNull.text?.forEach { charSeq ->
            if (charSeq != null && charSeq.toString().isNotEmpty()) {
                extractedTexts.add(charSeq.toString())
            }
        }

        val rootNode: AccessibilityNodeInfo? = eventNonNull.source
        if (rootNode != null) {
            traverseNode(rootNode, extractedTexts)
        }

        if (extractedTexts.isNotEmpty()) {
            val fullText = extractedTexts.joinToString(" ").replace(Regex("\\s+"), " ").trim()
            Log.d("SonoPayAccessibility", "Full text extracted via Accessibility: $fullText")

            if (fullText.contains("yapeó", ignoreCase = true) || 
                fullText.contains("Confirmación", ignoreCase = true) ||
                fullText.contains("recibiste", ignoreCase = true)) {
                
                val data = mutableMapOf<String, Any>(
                    "packageName" to packageName,
                    "rawTitle" to "Yape",
                    "rawBody" to fullText,
                    "scrapedContent" to fullText
                )

                Handler(Looper.getMainLooper()).post {
                    try {
                        YapeNotificationListenerService.eventSink?.success(data)
                    } catch (e: Exception) {
                        Log.e("SonoPayAccessibility", "EventSink error", e)
                    }
                }
            }
        }
    }

    private fun traverseNode(node: AccessibilityNodeInfo?, list: MutableList<String>) {
        if (node == null) return
        val nodeText = node.text?.toString()
        if (nodeText != null && nodeText.isNotEmpty() && !list.contains(nodeText)) {
            list.add(nodeText)
        }
        for (i in 0 until node.childCount) {
            traverseNode(node.getChild(i), list)
        }
    }

    override fun onInterrupt() {
        Log.d("SonoPayService", "Accessibility Service interrupted")
    }
}
