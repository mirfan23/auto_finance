import 'dart:async';

import 'package:android_intent_plus/android_intent.dart';
import 'package:auto_finance/domain/usecases/parser_notification.dart';
import 'package:auto_finance/features/notification_listener/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';

Future<void> openNotifAccess() async {
  const intent = AndroidIntent(action: 'android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS');
  await intent.launch();
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final List<Map<dynamic, dynamic>> notifications = [];
  StreamSubscription? subscription;

  @override
  void initState() {
    super.initState();

    subscription = NotificationService.stream.listen((event) {
      final parser = ParseNotificationUseCase();

      final trx = parser(event);

      if (trx != null) {
        setState(() {
          notifications.insert(0, {
            "bank": trx.bank,
            "amount": trx.amount,
            "type": trx.type,
            "text": trx.rawText,
            "time": trx.time.toString(),
          });
        });
      }
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      floatingActionButton: ElevatedButton(onPressed: openNotifAccess, child: Text("Aktifkan Akses Notifikasi")),

      body: Consumer(
        builder: (context, ref, _) {
          final data = ref.watch(transactionStreamProvider);

          return data.when(
            data: (list) {
              final total = list.fold<int>(0, (sum, e) => sum + e.amount);

              return Column(
                children: [
                  Text("Total: Rp $total"),
                  Expanded(
                    child: ListView(
                      children: list.map((e) {
                        return ListTile(
                          title: Text(e.bank),
                          subtitle: Text(e.category.toString()),
                          trailing: Text("Rp ${e.amount}"),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
            loading: () => CircularProgressIndicator(),
            error: (e, _) => Text("Error"),
          );
        },
      ),
    );
  }
}
