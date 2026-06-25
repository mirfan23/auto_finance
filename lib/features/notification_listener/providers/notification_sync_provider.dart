import 'package:auto_finance/domain/usecases/parser/parser_dispatcher.dart';
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
    final service = NotificationSyncService();

    final notificationDao = ref.read(notificationLogDaoProvider);

    final transactionDao = ref.read(transactionDaoProvider);

    final parser = ParserDispatcher();

    final notifications = await service.getPendingNotifications();

    final action = ref.read(transactionActionProvider);

    for (final item in notifications) {
      // simpan raw notification
      await notificationDao.insert(item);

      debugPrint(
        "SYNC => ${item["packageName"]} | "
        "${item["title"]} | "
        "${item["text"]}",
      );

      // parse transaksi
      final trx = parser.parse(item);

      if (trx == null) {
        debugPrint("PARSER RESULT => NULL");
        continue;
      }

      debugPrint(
        "PARSER RESULT => "
        "${trx.bank} | "
        "${trx.amount}",
      );

      // simpan transaksi
      // await transactionDao.insert(trx);
      await action.handle(item);

      debugPrint("TRANSACTION INSERTED");
    }

    debugPrint("SYNC COMPLETED");
  }
}
