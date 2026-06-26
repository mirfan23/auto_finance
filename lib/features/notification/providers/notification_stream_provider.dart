import 'package:auto_finance/data/dao/transaction_dao.dart';
import 'package:auto_finance/data/local/database/app_database.dart';
import 'package:auto_finance/data/dao/notification_log_dao.dart';
import 'package:auto_finance/features/transaction/providers/transaction_provider.dart';
import 'package:auto_finance/features/notification/services/notification_bus.dart';
import 'package:auto_finance/features/notification/services/notification_sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';

/// This provider is used to store the raw notifications
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

/// This provider is use to stream the notifications
final notificationStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  return NotificationService.stream;
});

/// This provider is used to store the notification logs
final notificationLogDaoProvider = Provider<NotificationLogDao>((ref) {
  final db = ref.watch(dbProvider);
  return NotificationLogDao(db);
});

/// This provider is used to stream the notification logs
final notificationLogStreamProvider = StreamProvider<List<NotificationLogsTableData>>((ref) {
  final dao = ref.watch(notificationLogDaoProvider);
  return dao.watchAll();
});

/// This provider is used to sync the notifications
final notificationSyncServiceProvider = Provider<NotificationSyncService>((ref) => NotificationSyncService());

/// This provider is used to store the transactions
final transactionDaoProvider = Provider<TransactionDao>((ref) {
  final db = ref.watch(dbProvider);
  return TransactionDao(db);
});
