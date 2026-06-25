// package com.example.auto_finance

// import android.util.Log
// import io.flutter.embedding.android.FlutterActivity
// import io.flutter.embedding.engine.FlutterEngine
// import io.flutter.plugin.common.EventChannel
// import io.flutter.plugin.common.MethodChannel

// class MainActivity : FlutterActivity() {

//     override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//         super.configureFlutterEngine(flutterEngine)

//         EventChannel(flutterEngine.dartExecutor.binaryMessenger, "notif_stream")
//                 .setStreamHandler(
//                         object : EventChannel.StreamHandler {

//                             override fun onListen(
//                                     arguments: Any?,
//                                     events: EventChannel.EventSink?
//                             ) {

//                                 Log.d("NOTIF_TEST", "FLUTTER LISTEN")

//                                 NotificationListener.eventSink = events
//                             }

//                             override fun onCancel(arguments: Any?) {

//                                 Log.d("NOTIF_TEST", "FLUTTER CANCEL")

//                                 NotificationListener.eventSink = null
//                             }
//                         }
//                 )
//         MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "notification_db")
//                 .setMethodCallHandler { call, result ->
//                     when (call.method) {
//                         "getPendingNotifications" -> {

//                             Thread {
//                                         val db = DbProvider.get(applicationContext)

//                                         val list = db.notificationDao().getPending()

//                                         val ids = list.map { it.id }

//                                         if (ids.isNotEmpty()) {
//                                             db.notificationDao().markProcessed(ids)
//                                         }

//                                         val output =
//                                                 list.map {
//                                                     hashMapOf(
//                                                             "id" to it.id,
//                                                             "packageName" to it.packageName,
//                                                             "title" to it.title,
//                                                             "text" to it.text,
//                                                             "timestamp" to it.timestamp,
//                                                             "processed" to it.processed,
//                                                     )
//                                                 }

//                                         runOnUiThread { result.success(output) }
//                                     }
//                                     .start()
//                         }
//                         else -> result.notImplemented()
//                     }
//                 }
//     }
// }


package com.example.auto_finance

import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "notif_stream"
        ).setStreamHandler(
            object : EventChannel.StreamHandler {

                override fun onListen(
                    arguments: Any?,
                    events: EventChannel.EventSink?
                ) {
                    Log.d("NOTIF_TEST", "FLUTTER LISTEN")
                    NotificationListener.eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    Log.d("NOTIF_TEST", "FLUTTER CANCEL")
                    NotificationListener.eventSink = null
                }
            }
        )

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "notification_db"
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "getPendingNotifications" -> {

                    Thread {

                        try {

                            val db = DbProvider.get(applicationContext)

                            Log.d(
                                "DB_TEST",
                                "GET PENDING NOTIFICATIONS"
                            )

                            val list = db.notificationDao().getPending()

                            Log.d(
                                "DB_TEST",
                                "PENDING COUNT = ${list.size}"
                            )

                            list.forEach {
                                Log.d(
                                    "DB_TEST",
                                    "FOUND => id=${it.id}, processed=${it.processed}, package=${it.packageName}"
                                )
                            }

                            val ids = list.map { it.id }

                            Log.d(
                                "DB_TEST",
                                "IDS TO MARK = $ids"
                            )

                            if (ids.isNotEmpty()) {

                                db.notificationDao().markProcessed(ids)

                                Log.d(
                                    "DB_TEST",
                                    "MARK PROCESSED SUCCESS"
                                )
                            }

                            val output = list.map {
                                hashMapOf(
                                    "id" to it.id,
                                    "packageName" to it.packageName,
                                    "title" to it.title,
                                    "text" to it.text,
                                    "timestamp" to it.timestamp,
                                    "processed" to it.processed,
                                )
                            }

                            runOnUiThread {
                                result.success(output)
                            }

                        } catch (e: Exception) {

                            Log.e(
                                "DB_TEST",
                                "ERROR = ${e.message}",
                                e
                            )

                            runOnUiThread {
                                result.error(
                                    "DB_ERROR",
                                    e.message,
                                    null
                                )
                            }
                        }

                    }.start()
                }

                else -> result.notImplemented()
            }
        }
    }
}