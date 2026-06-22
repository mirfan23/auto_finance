package com.example.auto_finance

import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "notif_stream"
        ).setStreamHandler(object : EventChannel.StreamHandler {

            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {

                Log.d("NOTIF_TEST", "FLUTTER LISTEN")

                NotificationListener.eventSink = events
            }

            override fun onCancel(arguments: Any?) {

                Log.d("NOTIF_TEST", "FLUTTER CANCEL")

                NotificationListener.eventSink = null
            }
        })
    }
}