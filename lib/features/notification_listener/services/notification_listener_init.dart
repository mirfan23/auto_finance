import 'package:auto_finance/domain/entities/transaction.dart';
import 'package:auto_finance/domain/entities/transaction_categories.dart';
import 'package:auto_finance/features/notification_listener/providers/notification_stream_provider.dart';
import 'package:auto_finance/features/notification_listener/providers/transaction_action_provider.dart';
import 'package:auto_finance/features/notification_listener/providers/transaction_provider.dart';
import 'package:auto_finance/features/notification_listener/services/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// void startNotificationListener(WidgetRef ref) {
//   final action = ref.read(transactionActionProvider);

//   NotificationService.stream.listen((event) {
//     final existing = ref.read(transactionStreamProvider).value ?? [];

//     action.handle(event, existing);
//   });
// }

void startNotificationListener(WidgetRef ref) {
  final action = ref.read(transactionActionProvider);
  final db = ref.read(dbProvider);

  NotificationService.stream.listen((event) async {
    final existingRows = await db.select(db.transactionsTable).get();

    final existing = existingRows.map((e) {
      return Transaction(
        bank: e.bank,
        amount: e.amount,
        type: e.type,
        category: TransactionCategory.values.byName(e.category),
        rawText: e.rawText,
        time: e.time,
      );
    }).toList();

    await action.handle(event, existing);
  });
}
