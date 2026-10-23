package com.example.auto_finance

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "auto_finance/notification"
    private val notificationPermissionRequestCode = 9002

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
        ) {
            requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), notificationPermissionRequestCode)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Safety net alongside BootReceiver's scheduling — enqueueUniquePeriodicWork
        // with KEEP is a no-op if the periodic check is already scheduled.
        NotificationAccessCheckWorker.schedule(applicationContext)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call,
                result ->
            if (call.method == "isNotificationListenerEnabled") {

                val packageName = applicationContext.packageName

                val flat =
                        Settings.Secure.getString(contentResolver, "enabled_notification_listeners")

                val enabled = flat?.contains(packageName) == true

                result.success(enabled)
            } else {
                result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "notif_stream")
                .setStreamHandler(
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

        // MethodChannel(
        //     flutterEngine.dartExecutor.binaryMessenger,
        //     "notification_db"
        // ).setMethodCallHandler { call, result ->

        //     when (call.method) {

        //         "getPendingNotifications" -> {

        //             Thread {

        //                 try {

        //                     val db = DbProvider.get(applicationContext)

        //                     Log.d(
        //                         "DB_TEST",
        //                         "GET PENDING NOTIFICATIONS"
        //                     )

        //                     val list = db.notificationDao().getPending()

        //                     Log.d(
        //                         "DB_TEST",
        //                         "PENDING COUNT = ${list.size}"
        //                     )

        //                     list.forEach {
        //                         Log.d(
        //                             "DB_TEST",
        //                             "FOUND => id=${it.id}, processed=${it.processed},
        // package=${it.packageName}"
        //                         )
        //                     }

        //                     // val ids = list.map { it.id }

        //                     // Log.d(
        //                     //     "DB_TEST",
        //                     //     "IDS TO MARK = $ids"
        //                     // )

        //                     // if (ids.isNotEmpty()) {

        //                     //     db.notificationDao().markProcessed(ids)

        //                     //     Log.d(
        //                     //         "DB_TEST",
        //                     //         "MARK PROCESSED SUCCESS"
        //                     //     )
        //                     // }

        //                     val output = list.map {
        //                         hashMapOf(
        //                             "id" to it.id,
        //                             "packageName" to it.packageName,
        //                             "title" to it.title,
        //                             "text" to it.text,
        //                             "timestamp" to it.timestamp,
        //                             "processed" to it.processed,
        //                         )
        //                     }

        //                     runOnUiThread {
        //                         result.success(output)
        //                     }

        //                 } catch (e: Exception) {

        //                     Log.e(
        //                         "DB_TEST",
        //                         "ERROR = ${e.message}",
        //                         e
        //                     )

        //                     runOnUiThread {
        //                         result.error(
        //                             "DB_ERROR",
        //                             e.message,
        //                             null
        //                         )
        //                     }
        //                 }

        //             }.start()
        //         }

        //         else -> result.notImplemented()
        //     }
        // }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "notification_db")
                .setMethodCallHandler { call, result ->
                    when (call.method) {
                        "getPendingNotifications" -> {

                            Thread {
                                        try {

                                            val db = DbProvider.get(applicationContext)

                                            Log.d("DB_TEST", "GET PENDING NOTIFICATIONS")

                                            val list = db.notificationDao().getPending()

                                            Log.d("DB_TEST", "PENDING COUNT = ${list.size}")

                                            val output =
                                                    list.map {
                                                        hashMapOf(
                                                                "id" to it.id,
                                                                "packageName" to it.packageName,
                                                                "title" to it.title,
                                                                "text" to it.text,
                                                                "timestamp" to it.timestamp,
                                                                "processed" to it.processed,
                                                        )
                                                    }

                                            runOnUiThread { result.success(output) }
                                        } catch (e: Exception) {

                                            Log.e("DB_TEST", "GET PENDING ERROR", e)

                                            runOnUiThread {
                                                result.error("DB_ERROR", e.message, null)
                                            }
                                        }
                                    }
                                    .start()
                        }
                        "markNotificationProcessed" -> {

                            val id = call.argument<Number>("id")?.toLong()

                            if (id == null) {
                                result.error("INVALID_ID", "Notification ID is null", null)

                                return@setMethodCallHandler
                            }

                            Thread {
                                        try {

                                            val db = DbProvider.get(applicationContext)

                                            db.notificationDao().markProcessed(id)

                                            Log.d("DB_TEST", "MARK PROCESSED => $id")

                                            runOnUiThread { result.success(true) }
                                        } catch (e: Exception) {

                                            Log.e("DB_TEST", "MARK PROCESSED ERROR", e)

                                            runOnUiThread {
                                                result.error("DB_ERROR", e.message, null)
                                            }
                                        }
                                    }
                                    .start()
                        }
                        "markUnknownPackagesProcessed" -> {

                            val knownPackageHints = call.argument<List<*>>("knownPackageHints")
                                .orEmpty()
                                .filterIsInstance<String>()
                                .map { it.trim() }
                                .filter { it.isNotEmpty() }

                            if (knownPackageHints.isEmpty()) {
                                result.error("INVALID_HINTS", "At least one supported package hint is required", null)
                                return@setMethodCallHandler
                            }

                            Thread {
                                        try {

                                            val db = DbProvider.get(applicationContext)
                                            val clauses = knownPackageHints.joinToString(" OR ") {
                                                "packageName LIKE ? COLLATE NOCASE"
                                            }
                                            val args = knownPackageHints.map { "%$it%" }.toTypedArray()
                                            val query = androidx.sqlite.db.SimpleSQLiteQuery(
                                                "UPDATE notification_logs SET processed = 1 " +
                                                    "WHERE processed = 0 AND NOT ($clauses)",
                                                args,
                                            )
                                            val updated = db.notificationDao().markUnknownProcessed(query)

                                            Log.d("DB_TEST", "CLEANUP UNKNOWN => $updated")

                                            runOnUiThread { result.success(updated) }
                                        } catch (e: Exception) {

                                            Log.e("DB_TEST", "CLEANUP UNKNOWN ERROR", e)

                                            runOnUiThread {
                                                result.error("DB_ERROR", e.message, null)
                                            }
                                        }
                                    }
                                    .start()
                        }
                        else -> result.notImplemented()
                    }
                }
    }
}
