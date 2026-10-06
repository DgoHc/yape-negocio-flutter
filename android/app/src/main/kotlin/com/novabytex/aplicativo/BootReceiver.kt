package com.novabytex.aplicativo

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.ComponentName
import android.content.pm.PackageManager
import android.service.notification.NotificationListenerService
import android.os.Build
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        val action = intent?.action
        Log.d("SonoPayBoot", "Boot event received: $action")

        if (context == null) return

        if (action == Intent.ACTION_BOOT_COMPLETED || 
            action == Intent.ACTION_LOCKED_BOOT_COMPLETED ||
            action == "android.intent.action.QUICKBOOT_POWERON" ||
            action == "com.htc.intent.action.QUICKBOOT_POWERON") {

            try {
                // 1. Forzar re-vinculación del servicio de notificaciones en el sistema Android
                rebindService(context)

                // 2. Iniciar servicio Foreground
                val serviceIntent = Intent(context, YapeNotificationListenerService::class.java)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(serviceIntent)
                } else {
                    context.startService(serviceIntent)
                }
                Log.d("SonoPayBoot", "BootReceiver executed successfully")
            } catch (e: Exception) {
                Log.e("SonoPayBoot", "Error on boot receiver", e)
            }
        }
    }

    companion object {
        fun rebindService(ctx: Context) {
            try {
                val componentName = ComponentName(ctx, YapeNotificationListenerService::class.java)
                val pm = ctx.packageManager
                pm.setComponentEnabledSetting(
                    componentName,
                    PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                    PackageManager.DONT_KILL_APP
                )
                pm.setComponentEnabledSetting(
                    componentName,
                    PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                    PackageManager.DONT_KILL_APP
                )
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    NotificationListenerService.requestRebind(componentName)
                }
                Log.d("SonoPayBoot", "Rebind forced successfully for YapeNotificationListenerService")
            } catch (e: Exception) {
                Log.e("SonoPayBoot", "Error forcing rebind", e)
            }
        }
    }
}
