import 'package:flutter/services.dart';

class NotificationService {
  static const EventChannel _channel = EventChannel('notif_stream');

  static Stream<Map<String, dynamic>> get stream {
    return _channel.receiveBroadcastStream().map((event) {
      return Map<String, dynamic>.from(event);
    });
  }
}
