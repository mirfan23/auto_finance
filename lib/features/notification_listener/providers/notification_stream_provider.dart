import 'package:auto_finance/data/local/database/app_database.dart';
import 'package:auto_finance/data/repositories/notification_log_dao.dart';
import 'package:auto_finance/features/notification_listener/providers/transaction_provider.dart';
import 'package:auto_finance/features/notification_listener/services/notification_bus.dart';
import 'package:auto_finance/features/notification_listener/services/notification_sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';

final rawNotificationBufferProvider = StateNotifierProvider<RawNotificationNotifier, List<Map<String, dynamic>>>(
  (ref) => RawNotificationNotifier(),
);

class RawNotificationNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  RawNotificationNotifier() : super([]) {
    NotificationBus.stream.listen((event) {
      state = [event, ...state];
    });
  }
}

final notificationStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  return NotificationService.stream;
});

final notificationLogDaoProvider = Provider<NotificationLogDao>((ref) {
  final db = ref.watch(dbProvider);
  return NotificationLogDao(db);
});

final notificationLogStreamProvider = StreamProvider<List<NotificationLogsTableData>>((ref) {
  final dao = ref.watch(notificationLogDaoProvider);
  return dao.watchAll();
});

final notificationSyncServiceProvider = Provider<NotificationSyncService>((ref) => NotificationSyncService());
