import 'package:auto_finance/features/notification_listener/providers/notification_stream_provider.dart';
import 'package:auto_finance/features/notification_listener/providers/notification_sync_provider.dart';
import 'package:auto_finance/features/notification_listener/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationDebugPage extends ConsumerWidget {
  const NotificationDebugPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(notificationLogStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Debug Notifications")),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      floatingActionButton: SizedBox(
        height: 200,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () async {
                await ref.read(notificationLogDaoProvider).clear();

                debugPrint("DRIFT CLEARED");
              },
              child: const Text("Clear Drift"),
            ),
            ElevatedButton(
              onPressed: () async {
                final db = ref.read(dbProvider);
                final data = await db.select(db.transactionsTable).get();
                final data2 = await db.select(db.notificationLogsTable).get();
                final result = await db.customSelect("PRAGMA table_info(transactions_table)").get();

                for (final row in result) {
                  debugPrint(row.data.toString());
                }
                for (final e in data) {
                  debugPrint("DB Transaction => ${e.bank} | ${e.amount}");
                }
                for (final e in data2) {
                  debugPrint(
                    "DB NotificationLog => packageName: ${e.packageName} | Name: ${e.title} | rawText: ${e.rawText} | timestamp: ${e.timestamp}",
                  );
                }
              },
              child: Text("Print DB"),
            ),
            ElevatedButton(
              onPressed: () async {
                const channel = MethodChannel('notification_db');

                final data = await channel.invokeMethod('getPendingNotifications');

                debugPrint("NATIVE DATA => $data");
              },
              child: const Text('Load Native Notifications'),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(notificationSyncProvider).sync();

                debugPrint("SYNC COMPLETED");
              },
              child: const Text('Sync Sync Sync'),
            ),
          ],
        ),
      ),
      body: logs.when(
        data: (data) => ListView.builder(
          itemCount: data.length,
          itemBuilder: (_, i) {
            final item = data[i];

            return Card(
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.packageName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("Title: ${item.title}"),
                    Text("Text: ${item.rawText}"),
                    Text("Time: ${item.timestamp}"),
                  ],
                ),
              ),
            );
          },
        ),
        loading: () => const CircularProgressIndicator(),
        error: (e, _) => Text("Error: $e"),
      ),
    );
  }
}
