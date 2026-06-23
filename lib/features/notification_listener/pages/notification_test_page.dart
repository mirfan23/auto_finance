import 'package:auto_finance/features/notification_listener/providers/notification_stream_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// class NotificationDebugPage extends ConsumerWidget {
//   const NotificationDebugPage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final logs = ref.watch(rawNotificationBufferProvider);

//     return Scaffold(
//       appBar: AppBar(title: const Text("Debug Notifications")),
//       body: logs.isEmpty
//           ? const Center(child: Text("Belum ada notifikasi"))
//           : ListView.builder(
//               itemCount: logs.length,
//               itemBuilder: (_, i) {
//                 final item = logs[i];

//                 return Card(
//                   margin: const EdgeInsets.all(8),
//                   child: Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(item["packageName"] ?? "-", style: const TextStyle(fontWeight: FontWeight.bold)),
//                         Text("Title: ${item["title"] ?? "-"}"),
//                         Text("Text: ${item["text"] ?? "-"}"),
//                         Text("Time: ${item["timestamp"] ?? "-"}"),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

class NotificationDebugPage extends ConsumerWidget {
  const NotificationDebugPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(notificationLogStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Debug Notifications")),
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
