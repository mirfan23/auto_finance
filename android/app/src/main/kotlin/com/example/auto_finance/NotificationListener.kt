package com.example.auto_finance

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import android.content.Context
import android.content.ComponentName

import com.example.auto_finance.data.NotificationEntity
import com.example.auto_finance.data.AppDatabase
import com.example.auto_finance.DbProvider

import io.flutter.plugin.common.EventChannel
import java.util.HashMap

class NotificationListener : NotificationListenerService() {

    companion object {
        var eventSink: EventChannel.EventSink? = null
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        Log.d("NOTIF", "Listener connected")
    }
    
    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
    
        requestRebind(
            ComponentName(
                applicationContext,
                NotificationListener::class.java
            )
        )
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {

        val extras = sbn.notification.extras

        val title = extras.getCharSequence("android.title")?.toString() ?: ""
        val text = extras.getCharSequence("android.text")?.toString()
            ?: extras.getCharSequence("android.bigText")?.toString()
            ?: extras.getCharSequence("android.subText")?.toString()
            ?: ""

        Log.d("NOTIF_TEST", "PACKAGE = ${sbn.packageName}")
        Log.d("NOTIF_TEST", "TITLE = $title")
        Log.d("NOTIF_TEST", "TEXT = $text")

        val db = DbProvider.get(applicationContext)

        val entity = NotificationEntity(
            packageName = sbn.packageName,
            title = title,
            text = text,
            timestamp = sbn.postTime
        )

        // ⚠️ jangan main thread
        Thread {
            db.notificationDao().insert(entity)
        }.start()

        val map = HashMap<String, Any>()
        map["packageName"] = sbn.packageName
        map["title"] = title
        map["text"] = text
        map["timestamp"] = sbn.postTime

        eventSink?.success(map)
    }
}