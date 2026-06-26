import 'dart:async';
import 'package:auto_finance/features/notification/providers/notification_stream_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_service.dart';

class NotificationBus {
  static final StreamController<Map<String, dynamic>> _controller = StreamController.broadcast();

  static Stream<Map<String, dynamic>> get stream => _controller.stream;

  static StreamSubscription? _sub;

  static void start(WidgetRef ref) {
    _sub?.cancel();

    final dao = ref.read(notificationLogDaoProvider);

    _sub = NotificationService.stream.listen((event) async {
      _controller.add(event);

      // 🔥 SAVE KE DB JUGA
      await dao.insert(event);
    });
  }

  static void dispose() {
    _sub?.cancel();
    _controller.close();
  }
}
