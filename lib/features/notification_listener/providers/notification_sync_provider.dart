import 'package:auto_finance/features/notification_listener/providers/transaction_action_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_stream_provider.dart';
import '../services/notification_sync_service.dart';

final notificationSyncProvider = Provider((ref) => NotificationSyncProvider(ref));

class NotificationSyncProvider {
  final Ref ref;

  NotificationSyncProvider(this.ref);

  Future<void> sync() async {
    debugPrint("===== START SYNC =====");

    final service = NotificationSyncService();

    final notificationDao = ref.read(notificationLogDaoProvider);

    final action = ref.read(transactionActionProvider);

    final notifications = await service.getPendingNotifications();

    debugPrint(
      "TOTAL PENDING NOTIFICATIONS = "
      "${notifications.length}",
    );

    for (final item in notifications) {
      await notificationDao.insert(item);

      debugPrint(
        "SYNC => "
        "${item["packageName"]} | "
        "${item["title"]} | "
        "${item["text"]}",
      );

      await action.handle(item);
    }

    debugPrint("===== END SYNC =====");
  }
}
