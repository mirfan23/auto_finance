import 'dart:async';

import 'package:auto_finance/features/notification/providers/notification_stream_provider.dart';
import 'package:auto_finance/features/transaction/providers/transaction_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_service.dart';

class NotificationBus {
  static final StreamController<Map<String, dynamic>> _controller = StreamController.broadcast();

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
        await action.handle(event);

        debugPrint("✅ LIVE NOTIFICATION PROCESSED");

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
