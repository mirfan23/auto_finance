import 'package:flutter/services.dart';

class NotificationService {
  static const EventChannel _channel = EventChannel('notif_stream');

  static final Stream<Map<String, dynamic>> stream = _channel.receiveBroadcastStream().map((event) {
    return Map<String, dynamic>.from(event);
  });
}
