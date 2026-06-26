package com.example.auto_finance

import android.content.ComponentName
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import com.example.auto_finance.data.NotificationEntity
import io.flutter.plugin.common.EventChannel
import java.util.HashMap

class NotificationListener : NotificationListenerService() {

    companion object {
        var eventSink: EventChannel.EventSink? = null
    }

    override fun onCreate() {
        super.onCreate()

        Log.d("NOTIF_SERVICE", "SERVICE CREATED")
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        Log.d("NOTIF", "Listener connected")
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        Log.d("NOTIF_SERVICE", "LISTENER DISCONNECTED")

        requestRebind(ComponentName(applicationContext, NotificationListener::class.java))
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        Log.d("NOTIF_SERVICE", "SERVICE RECEIVED NOTIFICATION")

        val extras = sbn.notification.extras

        val title = extras.getCharSequence("android.title")?.toString() ?: ""
        val text =
                extras.getCharSequence("android.text")?.toString()
                        ?: extras.getCharSequence("android.bigText")?.toString()
                                ?: extras.getCharSequence("android.subText")?.toString() ?: ""

        Log.d("NOTIF_TEST", "PACKAGE = ${sbn.packageName}")
        Log.d("NOTIF_TEST", "TITLE = $title")
        Log.d("NOTIF_TEST", "TEXT = $text")

        val db = DbProvider.get(applicationContext)

        val entity =
                NotificationEntity(
                        packageName = sbn.packageName,
                        title = title,
                        text = text,
                        timestamp = sbn.postTime
                )

        // ⚠️ jangan main thread
        // Thread { db.notificationDao().insert(entity) }.start()
        Thread {
        try {

            db.notificationDao().insert(entity)

            Log.d(
                "DB_TEST",
                "INSERT SUCCESS => ${entity.packageName}"
            )

            val totalRows =
                db.notificationDao()
                    .getAll()
                    .size

            Log.d(
                "DB_TEST",
                "TOTAL ROWS = $totalRows"
            )

        } catch (e: Exception) {

            Log.e(
                "DB_TEST",
                "INSERT FAILED",
                e
            )
        }
    }.start()

        val map = HashMap<String, Any>()
        map["packageName"] = sbn.packageName
        map["title"] = title
        map["text"] = text
        map["timestamp"] = sbn.postTime

        eventSink?.success(map)
    }
}
