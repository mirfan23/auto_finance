import 'dart:async';

import 'package:auto_finance/core/services/notification_db_service.dart';
import 'package:auto_finance/features/transaction/domain/usecases/transaction_action_result.dart';
import 'package:auto_finance/features/notification/application/providers/notification_stream_provider.dart';
import 'package:auto_finance/features/transaction/application/providers/transaction_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_service.dart';

class NotificationBus {
  static final StreamController<Map<String, dynamic>> _controller =
      StreamController.broadcast();

  static Stream<Map<String, dynamic>> get stream => _controller.stream;

  static StreamSubscription<Map<String, dynamic>>? _sub;

  static void start(WidgetRef ref) {
    if (_sub != null) {
      return;
    }

    final dao = ref.read(notificationLogDaoProvider);
    final action = ref.read(transactionActionProvider);

    _sub = NotificationService.stream.listen((event) async {
      try {
        debugPrint("📥 LIVE NOTIFICATION RECEIVED");

        // 1. Simpan log notification
        await dao.insert(event);

        debugPrint("📝 NOTIFICATION LOG SAVED");

        // 2. Proses transaction
        final result = await action.handle(event);
        final notificationId = event['id'];
        switch (result) {
          case TransactionActionResult.processed:
          case TransactionActionResult.duplicate:
          case TransactionActionResult.notTransaction:
            if (notificationId is num) {
              await NotificationDbService.markProcessed(notificationId.toInt());
            }
            debugPrint('✅ LIVE NOTIFICATION FINALIZED => $result');
            break;
          case TransactionActionResult.waitingPair:
          case TransactionActionResult.waitingWallet:
          case TransactionActionResult.failed:
            debugPrint('⏳ LIVE NOTIFICATION STILL PENDING => $result');
            break;
        }

        // 3. Broadcast ke UI/debug page
        _controller.add(event);
      } catch (e, stackTrace) {
        debugPrint("❌ LIVE NOTIFICATION FAILED");
        debugPrint("$e");
        debugPrint("$stackTrace");
      }
    });
  }

  static Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;

    await _controller.close();
  }
}
