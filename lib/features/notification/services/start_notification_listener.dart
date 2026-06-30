import 'package:auto_finance/features/notification/services/notification_service.dart';
import 'package:auto_finance/features/transaction/providers/transaction_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void startNotificationListener(WidgetRef ref) {
  final action = ref.read(transactionActionProvider);

  NotificationService.stream.listen((event) async {
    await action.handle(event);
  });
}
