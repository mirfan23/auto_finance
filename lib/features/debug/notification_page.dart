import 'dart:async';

import 'package:android_intent_plus/android_intent.dart';
import 'package:auto_finance/features/notification/providers/notification_stream_provider.dart';
import 'package:auto_finance/features/transaction/providers/transaction_action_provider.dart';
import 'package:auto_finance/features/transaction/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fx_helper/formatter_helper.dart';

// Future<void> openNotifAccess() async {
//   const intent = AndroidIntent(action: 'android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS');
//   await intent.launch();
// }

// class NotificationPage extends StatefulWidget {
//   const NotificationPage({super.key});

//   @override
//   State<NotificationPage> createState() => _NotificationPageState();
// }

// class _NotificationPageState extends State<NotificationPage> {
//   final List<Map<dynamic, dynamic>> notifications = [];

//   // StreamSubscription? subscription;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final data = ref.watch(transactionStreamProvider);
//     return Scaffold(
//       appBar: AppBar(title: const Text("Notifications")),
//       floatingActionButton: ElevatedButton(onPressed: openNotifAccess, child: Text("Aktifkan Akses Notifikasi")),

//       body: Consumer(
//         builder: (context, ref, _) {
//           final data = ref.watch(transactionStreamProvider);

//           return data.when(
//             data: (list) {
//               final total = list.fold<int>(0, (sum, e) => sum + e.amount);

//               return Column(
//                 children: [
//                   Text("Total: Rp $total"),
//                   Expanded(
//                     child: ListView(
//                       children: list.map((e) {
//                         return ListTile(
//                           title: Text(e.bank),
//                           subtitle: Text(e.category.toString()),
//                           trailing: Text("Rp ${e.amount}"),
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 ],
//               );
//             },
//             loading: () => CircularProgressIndicator(),
//             error: (e, _) => Text("Error"),
//           );
//         },
//       ),
//     );
//   }
// }

Future<void> openNotifAccess() async {
  const intent = AndroidIntent(action: 'android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS');
  await intent.launch();
}

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(transactionStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Transactions")),
      floatingActionButton: SizedBox(
        height: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () async {
                final action = ref.read(transactionActionProvider);

                await action.handle({
                  "packageName": "com.bca.mybca.omni.android",
                  "title": "Financial Diary",
                  "text": "You received IDR 50,000.00 from MUHA**AD **FAN *AD at Account Transfer category.",
                  "timestamp": DateTime.now().millisecondsSinceEpoch,
                });

                await action.handle({
                  "packageName": "com.jago.digitalBanking",
                  "title": "Jago",
                  "text":
                      "Kamu telah melakukan transfer Rp50.000 ke M IRFAN FADHILA. Butuh bantuan? Silakan Tanya Jago di 1500 746.",
                  "timestamp": DateTime.now().millisecondsSinceEpoch + 1,
                });
              },
              child: const Text("Simulate Transfer"),
            ),
            ElevatedButton(
              onPressed: () async {
                final dao = ref.read(transactionDaoProvider);

                final data = await dao.getAll();

                debugPrint("TOTAL TRANSACTIONS = ${data.length}");

                for (final e in data) {
                  debugPrint(
                    "${e.bank} | "
                    "${e.amount} | "
                    "${e.category}",
                  );
                }
              },
              child: const Text("Print Transactions"),
            ),
            ElevatedButton(onPressed: openNotifAccess, child: Text("Aktifkan Akses Notifikasi")),
          ],
        ),
      ),
      body: data.when(
        data: (list) {
          final total = list.fold<int>(0, (sum, e) => sum + e.amount);
          debugPrint("UI TRANSACTION COUNT = ${list.length}");
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    "Total: ${FormatterHelper.formatRupiah(total)}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, i) {
                  final e = list[i];
                  return ListTile(
                    title: Text(e.bank),
                    subtitle: Text(e.category.name),
                    trailing: Text(FormatterHelper.formatRupiah(e.amount)),
                  );
                }, childCount: list.length),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }
}
