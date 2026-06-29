import 'package:auto_finance/domain/usecases/transaction/transaction_action_usecase.dart';
import 'package:auto_finance/features/notification/services/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void startNotificationListener(WidgetRef ref) {
  final action = ref.read(transactionActionProvider);

  NotificationService.stream.listen((event) async {
    await action.handle(event);
  });
}
