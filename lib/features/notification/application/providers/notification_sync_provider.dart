import 'package:auto_finance/core/services/notification_db_service.dart';
import 'package:auto_finance/features/transaction/domain/usecases/parser/parser_dispatcher.dart';
import 'package:auto_finance/features/transaction/domain/usecases/transaction_action_result.dart';
import 'package:auto_finance/features/transaction/application/providers/transaction_provider.dart';
import 'package:auto_finance/features/local_ai/data/services/local_ai_service.dart';
import 'package:auto_finance/features/wallet/application/providers/wallet_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_stream_provider.dart';

final notificationSyncProvider = Provider<NotificationSyncProvider>(
  (ref) => NotificationSyncProvider(ref),
);

class NotificationSyncSummary {
  const NotificationSyncSummary({
    required this.attempted,
    required this.completed,
    required this.stillWaiting,
  });

  final int attempted;
  final int completed;
  final int stillWaiting;
}

class NotificationSyncProvider {
  final Ref ref;
  Future<NotificationSyncSummary>? _activeSync;

  NotificationSyncProvider(this.ref);

  Future<NotificationSyncSummary> sync() {
    final activeSync = _activeSync;
    if (activeSync != null) {
      return activeSync;
    }

    late final Future<NotificationSyncSummary> task;
    task = _syncPendingNotifications().whenComplete(() {
      if (identical(_activeSync, task)) _activeSync = null;
    });
    _activeSync = task;
    return task;
  }

  Future<NotificationSyncSummary> _syncPendingNotifications() async {
    debugPrint("===== START SYNC =====");

    final sourceWalletIds = await LocalAiService.selectedSourceWallets();
    final walletRows = await ref.read(walletDaoProvider).getAll();
    final walletsById = {for (final wallet in walletRows) wallet.id: wallet};
    final availableSources = await LocalAiService.getAvailableSources();
    final sourceLabels = {
      for (final source in availableSources)
        source['packageName'].toString(): source['label'].toString(),
    };

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
      selectedPackages: sourceWalletIds.keys.toList(growable: false),
    );

    debugPrint("🧹 CLEANED UNKNOWN PACKAGES => $cleaned");

    final notificationDao = ref.read(notificationLogDaoProvider);

    final action = ref.read(transactionActionProvider);

    const batchSize = 50;
    var cursor = 0;
    var attempted = 0;
    var completed = 0;
    var stillWaiting = 0;

    while (true) {
      final batch = await NotificationDbService.getPendingNotifications(
        afterId: cursor,
        limit: batchSize,
      );
      if (batch.isEmpty) break;

      debugPrint('PENDING BATCH => ${batch.length}');
      for (final item in batch) {
        final id = (item['id'] as num).toInt();
        if (id > cursor) cursor = id;
        attempted++;

        try {
          debugPrint(
            'SYNC => id=$id | ${item["packageName"]} | '
            '${item["title"]} | ${item["text"]}',
          );

          await notificationDao.insert(item);
          final packageName = (item['packageName'] ?? '').toString();
          final selectedWalletId = sourceWalletIds[packageName];
          final selectedWallet = selectedWalletId == null
              ? null
              : walletsById[selectedWalletId];
          if (selectedWalletId != null && selectedWallet == null) {
            stillWaiting++;
            debugPrint('⏳ AI SOURCE WALLET MISSING => $packageName');
            continue;
          }
          final actionData = selectedWallet == null
              ? item
              : <String, dynamic>{
                  ...item,
                  'walletBank': selectedWallet.bank,
                  'walletId': selectedWallet.id,
                  'sourceAppLabel': sourceLabels[packageName] ?? packageName,
                };
          final result = await action.handle(actionData);

          switch (result) {
            case TransactionActionResult.processed:
            case TransactionActionResult.duplicate:
            case TransactionActionResult.notTransaction:
              await NotificationDbService.markProcessed(id);
              completed++;
              debugPrint('✅ NOTIFICATION PROCESSED => $id');
              break;

            case TransactionActionResult.waitingPair:
            case TransactionActionResult.waitingWallet:
            case TransactionActionResult.failed:
              stillWaiting++;
              debugPrint('⏳ NOTIFICATION REMAINS PENDING => $id');
              break;
          }
        } catch (error, stackTrace) {
          stillWaiting++;
          debugPrint('❌ SYNC FAILED => $id');
          debugPrint('$error');
          debugPrint('$stackTrace');
          // Keep failed notifications pending for a later retry.
        }
      }
    }

    debugPrint("===== END SYNC =====");
    return NotificationSyncSummary(
      attempted: attempted,
      completed: completed,
      stillWaiting: stillWaiting,
    );
  }
}
