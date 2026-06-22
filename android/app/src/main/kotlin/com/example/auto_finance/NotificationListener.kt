package com.example.auto_finance

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import io.flutter.plugin.common.EventChannel

class NotificationListener : NotificationListenerService() {

    companion object {
        var eventSink: EventChannel.EventSink? = null
    }

    override fun onCreate() {
        super.onCreate()
        Log.d("NOTIF_TEST", "SERVICE CREATED")
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        Log.d("NOTIF_TEST", "LISTENER CONNECTED")
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {

        Log.d("NOTIF_TEST", "NOTIFICATION : ${sbn.packageName}")

        val extras = sbn.notification.extras

        val title = extras.getCharSequence("android.title")?.toString() ?: ""

        val text = extras.getCharSequence("android.text")?.toString() ?: ""


        Log.d("NOTIF_TEST", "================")
        Log.d("NOTIF_TEST", "PACKAGE = ${sbn.packageName}")
        Log.d("NOTIF_TEST", "TITLE = $title")
        Log.d("NOTIF_TEST", "TEXT = $text")

        val map = HashMap<String, Any>()

        map["packageName"] = sbn.packageName
        map["title"] = title
        map["text"] = text
        map["timestamp"] = sbn.postTime

        if (eventSink == null) {
            Log.d("NOTIF_TEST", "eventSink NULL")
        } else {
            Log.d("NOTIF_TEST", "eventSink ACTIVE")
        }

        eventSink?.success(map)

        Log.d("NOTIF_TEST", "EVENT SENT")
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d("NOTIF_TEST", "SERVICE DESTROYED")
    }
}
