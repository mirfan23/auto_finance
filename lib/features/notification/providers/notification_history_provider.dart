import 'package:auto_finance/core/services/notification_db_service.dart';
import 'package:auto_finance/domain/entities/received_notification.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationHistoryProvider =
    FutureProvider.autoDispose<List<ReceivedNotification>>((ref) async {
      final notifications = await NotificationDbService.getAllNotifications();
      return notifications.map(ReceivedNotification.fromMap).toList();
    });
