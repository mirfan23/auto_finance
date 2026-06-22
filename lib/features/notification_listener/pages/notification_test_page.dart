import 'dart:async';

import 'package:flutter/material.dart';

import '../services/notification_service.dart';

class NotificationDebugPage extends StatefulWidget {
  const NotificationDebugPage({super.key});

  @override
  State<NotificationDebugPage> createState() => _NotificationDebugPageState();
}

class _NotificationDebugPageState extends State<NotificationDebugPage> {
  final List<Map<dynamic, dynamic>> notifications = [];

  StreamSubscription? subscription;

  @override
  void initState() {
    super.initState();

    subscription = NotificationService.stream.listen((event) {
      debugPrint("NOTIFICATION RECEIVED => $event");

      setState(() {
        notifications.insert(0, event);
      });
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
      appBar: AppBar(title: const Text("Notification Debug")),

      body: notifications.isEmpty
          ? const Center(child: Text("Belum ada notifikasi"))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (_, index) {
                final item = notifications[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item["packageName"] ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),

                        const SizedBox(height: 8),

                        Text("Title : ${item["title"]}"),

                        const SizedBox(height: 4),

                        Text("Text : ${item["text"]}"),

                        const SizedBox(height: 4),

                        Text(
                          "Timestamp : ${item["timestamp"]}",
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
