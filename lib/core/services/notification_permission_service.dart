import 'package:flutter/services.dart';

class NotificationPermissionService {
  static const MethodChannel _channel = MethodChannel('auto_finance/notification');

  static Future<bool> isEnabled() async {
    try {
      final result = await _channel.invokeMethod<bool>('isNotificationListenerEnabled');

      return result ?? false;
    } catch (_) {
      return false;
    }
  }
}
