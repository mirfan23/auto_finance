import 'package:auto_finance/core/services/notification_db_service.dart';
import 'package:auto_finance/features/local_ai/data/services/local_ai_service.dart';
import 'package:auto_finance/features/notification/application/providers/notification_stream_provider.dart';
import 'package:auto_finance/features/notification/domain/entities/received_notification.dart';
import 'package:auto_finance/features/transaction/application/providers/transaction_provider.dart';
import 'package:auto_finance/features/transaction/domain/entities/transaction.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationAttentionCounts {
  const NotificationAttentionCounts({
    required this.processing,
    required this.needsConfirmation,
  });

  final int processing;
  final int needsConfirmation;

  int get total => processing + needsConfirmation;
}

final notificationAttentionCountsProvider =
    FutureProvider.autoDispose<NotificationAttentionCounts>((ref) async {
      ref.listen(notificationStreamProvider, (_, _) => ref.invalidateSelf());

      final transactions = await ref.watch(transactionStreamProvider.future);
      final aiSourcePackages = (await LocalAiService.selectedSourceWallets())
          .keys
          .toSet();
      const packageHints = ['jago', 'bca', 'gojek', 'gopay', 'shopee'];

      var offset = 0;
      var processing = 0;
      var needsConfirmation = 0;
      const batchSize = 100;

      while (true) {
        final batch = await NotificationDbService.getAllNotifications(
          offset: offset,
          limit: batchSize,
        );
        if (batch.isEmpty) break;

        for (final item in batch) {
          final notification = ReceivedNotification.fromMap(item);
          final packageName = notification.packageName.toLowerCase();
          final isRelevant =
              packageHints.any(packageName.contains) ||
              aiSourcePackages.contains(notification.packageName);
          if (!isRelevant || _matchesTransaction(notification, transactions)) {
            continue;
          }

          if (notification.processed) {
            needsConfirmation++;
          } else {
            processing++;
          }
        }

        offset += batch.length;
        if (batch.length < batchSize) break;
      }

      return NotificationAttentionCounts(
        processing: processing,
        needsConfirmation: needsConfirmation,
      );
    });

bool _matchesTransaction(
  ReceivedNotification notification,
  List<Transaction> transactions,
) {
  Transaction? closest;
  var closestDifference = const Duration(days: 36500);

  for (final transaction in transactions) {
    final exactText = transaction.rawText == notification.text;
    final transferText =
        notification.text.isNotEmpty &&
        transaction.rawText.contains(notification.text);
    if (!exactText && !transferText) continue;

    final difference = transaction.time.difference(notification.time).abs();
    final maxDifference = exactText
        ? const Duration(seconds: 6)
        : const Duration(minutes: 2);
    if (difference <= maxDifference && difference < closestDifference) {
      closest = transaction;
      closestDifference = difference;
    }
  }
  return closest != null;
}
