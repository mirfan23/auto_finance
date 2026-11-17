import 'package:flutter/services.dart';

class NotificationDbService {
  static const MethodChannel _channel = MethodChannel('notification_db');

  static Future<List<Map<String, dynamic>>> getAllNotifications({
    int offset = 0,
    int limit = 100,
  }) async {
    final result = await _channel.invokeMethod<List<dynamic>>(
      'getAllNotifications',
      {'offset': offset, 'limit': limit},
    );
    if (result == null) return [];

    return result
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getPendingNotifications({
    required int afterId,
    int limit = 50,
  }) async {
    final result = await _channel.invokeMethod<List<dynamic>>(
      'getPendingNotifications',
      {'afterId': afterId, 'limit': limit},
    );

    if (result == null) {
      return [];
    }

    return result.map((e) {
      return Map<String, dynamic>.from(e);
    }).toList();
  }

  static Future<void> markProcessed(int id) async {
    await _channel.invokeMethod('markNotificationProcessed', {'id': id});
  }

  static Future<List<Map<String, dynamic>>> getNotificationSources() async {
    final result = await _channel.invokeMethod<List<dynamic>>(
      'getNotificationSources',
    );
    return result
            ?.map((item) => Map<String, dynamic>.from(item as Map))
            .toList(growable: false) ??
        const [];
  }

  static Future<int> requeueAiSourceNotifications(
    List<String> packageNames,
  ) async {
    final result = await _channel.invokeMethod<int>(
      'requeueAiSourceNotifications',
      {'packageNames': packageNames},
    );
    return result ?? 0;
  }

  static Future<int> reprocessKnownJagoNotificationsOnce() async {
    final result = await _channel.invokeMethod<int>(
      'reprocessKnownJagoNotificationsOnce',
    );
    return result ?? 0;
  }

  // Bulk-dismisses pending rows whose packageName doesn't match any of
  // [knownPackageHints] (same substring match ParserDispatcher uses) so
  // they stop piling up in Room and being re-walked on every sync. Returns
  // how many rows were dismissed.
  static Future<int> markUnknownPackagesProcessed(
    List<String> knownPackageHints, {
    List<String> selectedPackages = const [],
  }
  ) async {
    final result = await _channel.invokeMethod<int>(
      'markUnknownPackagesProcessed',
      {
        'knownPackageHints': knownPackageHints,
        'selectedPackages': selectedPackages,
      },
    );

    return result ?? 0;
  }
}
