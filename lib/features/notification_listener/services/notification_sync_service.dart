import 'package:flutter/services.dart';

class NotificationSyncService {
  static const MethodChannel _channel = MethodChannel('notification_db');

  Future<List<Map<String, dynamic>>> getPendingNotifications() async {
    final result = await _channel.invokeMethod('getPendingNotifications');

    if (result == null) return [];

    return List<Map<String, dynamic>>.from((result as List).map((e) => Map<String, dynamic>.from(e)));
  }
}
