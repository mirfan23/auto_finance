package com.example.auto_finance

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.Worker
import androidx.work.WorkerParameters
import java.util.concurrent.TimeUnit

// Runs independently of the Flutter engine/MainActivity. NotificationListenerService
// capture depends on the "Notification access" special permission staying granted —
// OEMs (MIUI in particular) can silently revoke it without disconnecting the service
// in a way our code would notice. This worker periodically re-checks that permission
// and alerts the user with a plain Android notification if it's gone, since nothing
// else runs unless the app is opened.
class NotificationAccessCheckWorker(context: Context, params: WorkerParameters) : Worker(context, params) {

    override fun doWork(): Result {
        val enabled = isNotificationAccessEnabled(applicationContext)

        Log.d("NOTIF_ACCESS_CHECK", "enabled=$enabled")

        if (!enabled) {
            showAccessRevokedNotification(applicationContext)
        }

        return Result.success()
    }

    private fun isNotificationAccessEnabled(context: Context): Boolean {
        val packageName = context.packageName

        val flat = Settings.Secure.getString(context.contentResolver, "enabled_notification_listeners")

        return flat?.contains(packageName) == true
    }

    private fun showAccessRevokedNotification(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            context.checkSelfPermission(android.Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
        ) {
            Log.w("NOTIF_ACCESS_CHECK", "POST_NOTIFICATIONS permission missing; cannot show access warning")
            return
        }

        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Peringatan Akses Notifikasi",
                NotificationManager.IMPORTANCE_HIGH
            )

            notificationManager.createNotificationChannel(channel)
        }

        val settingsIntent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
        settingsIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK

        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            settingsIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_alert)
            .setContentTitle("Izin notifikasi Auto Finance mati")
            .setContentText("Transaksi tidak akan tercatat. Tap untuk aktifkan ulang.")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .build()

        notificationManager.notify(ALERT_NOTIFICATION_ID, notification)
    }

    companion object {
        private const val CHANNEL_ID = "notification_access_alert"
        private const val ALERT_NOTIFICATION_ID = 9001
        private const val WORK_NAME = "notification_access_check"

        // Safe to call repeatedly (app open, boot) — KEEP means an already
        // scheduled periodic check is left alone instead of being reset.
        fun schedule(context: Context) {
            val request = PeriodicWorkRequestBuilder<NotificationAccessCheckWorker>(12, TimeUnit.HOURS).build()

            WorkManager.getInstance(context)
                .enqueueUniquePeriodicWork(WORK_NAME, ExistingPeriodicWorkPolicy.KEEP, request)
        }
    }
}
