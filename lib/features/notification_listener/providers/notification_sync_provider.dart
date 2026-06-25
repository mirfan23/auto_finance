import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_stream_provider.dart';
import '../services/notification_sync_service.dart';

final notificationSyncProvider = Provider((ref) => NotificationSyncProvider(ref));

class NotificationSyncProvider {
  final Ref ref;

  NotificationSyncProvider(this.ref);

  Future<void> sync() async {
    final service = NotificationSyncService();

    final dao = ref.read(notificationLogDaoProvider);

    final notifications = await service.getPendingNotifications();

    for (final item in notifications) {
      await dao.insert(item);
    }
  }
}
