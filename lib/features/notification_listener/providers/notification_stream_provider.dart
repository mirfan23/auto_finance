import 'package:auto_finance/features/notification_listener/providers/transaction_notifer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';

final notificationStreamProvider = Provider((ref) {
  final subscription = NotificationService.stream.listen((event) {
    ref.read(transactionListProvider.notifier).addFromNotification(event);
  });

  ref.onDispose(() {
    subscription.cancel();
  });
});
