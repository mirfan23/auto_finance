import 'package:auto_finance/core/services/notification_db_service.dart';
import 'package:auto_finance/domain/usecases/parser/parser_dispatcher.dart';
import 'package:auto_finance/domain/usecases/transaction/transaction_action_result.dart';
import 'package:auto_finance/features/transaction/providers/transaction_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_stream_provider.dart';

final notificationSyncProvider = Provider<NotificationSyncProvider>(
  (ref) => NotificationSyncProvider(ref),
);

class NotificationSyncProvider {
  final Ref ref;
  Future<void>? _activeSync;

  NotificationSyncProvider(this.ref);

  Future<void> sync() {
    final activeSync = _activeSync;
    if (activeSync != null) {
      return activeSync;
    }

    late final Future<void> task;
    task = _syncPendingNotifications().whenComplete(() {
      if (identical(_activeSync, task)) _activeSync = null;
    });
    _activeSync = task;
    return task;
  }

  Future<void> _syncPendingNotifications() async {
    debugPrint("===== START SYNC =====");

    final requeuedJago =
        await NotificationDbService.reprocessKnownJagoNotificationsOnce();
    debugPrint(
      "🔁 JAGO NOTIFICATIONS QUEUED FOR ONE-TIME REPROCESS => $requeuedJago",
    );

    // One-time (per sync) cleanup: notifications from packages we can never
    // parse into a transaction would otherwise pile up in Room forever and
    // get re-walked on every sync. Dismiss them in bulk before fetching.
    final cleaned = await NotificationDbService.markUnknownPackagesProcessed(
      ParserDispatcher.supportedPackageHints,
    );

    debugPrint("🧹 CLEANED UNKNOWN PACKAGES => $cleaned");

    final notificationDao = ref.read(notificationLogDaoProvider);

    final action = ref.read(transactionActionProvider);

    final notifications = await NotificationDbService.getPendingNotifications();

    debugPrint(
      "TOTAL PENDING NOTIFICATIONS = "
      "${notifications.length}",
    );

    for (final item in notifications) {
      final id = item["id"];

      try {
        debugPrint(
          "SYNC => "
          "id=$id | "
          "${item["packageName"]} | "
          "${item["title"]} | "
          "${item["text"]}",
        );

        // Opsional jika memang ingin menyimpan log ke Drift
        await notificationDao.insert(item);

        // Proses transaksi
        // await action.handle(item);

        // // Hanya tandai processed setelah proses berhasil
        // await service.markProcessed(id);
        final result = await action.handle(item);

        switch (result) {
          case TransactionActionResult.processed:
          case TransactionActionResult.duplicate:
            await NotificationDbService.markProcessed(id);

            debugPrint("✅ NOTIFICATION PROCESSED => $id");
            break;

          case TransactionActionResult.notTransaction:
            await NotificationDbService.markProcessed(id);

            debugPrint("➖ NOT A TRANSACTION, DISMISSED => $id");
            break;

          case TransactionActionResult.waitingPair:
          case TransactionActionResult.waitingWallet:
          case TransactionActionResult.failed:
            debugPrint("⏳ NOTIFICATION REMAINS PENDING => $id");
            break;
        }

        debugPrint("✅ SYNC SUCCESS => $id");
      } catch (e, stackTrace) {
        debugPrint("❌ SYNC FAILED => $id");

        debugPrint("$e");
        debugPrint("$stackTrace");

        // Jangan mark processed.
        // Akan dicoba lagi pada startup berikutnya.
      }
    }

    debugPrint("===== END SYNC =====");
  }
}
