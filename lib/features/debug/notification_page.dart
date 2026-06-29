import 'dart:async';

import 'package:android_intent_plus/android_intent.dart';
import 'package:auto_finance/domain/entities/transaction_type.dart';
import 'package:auto_finance/features/notification/providers/notification_stream_provider.dart';
import 'package:auto_finance/features/transaction/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fx_helper/formatter_helper.dart';

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
        height: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
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
          // final total = list.fold<int>(0, (sum, e) => sum + e.amount);
          // final income = list.where((e) => e.type == "income").fold<int>(0, (sum, e) => sum + e.amount);
          final income = list.where((e) => e.type == TransactionType.income).fold<int>(0, (sum, e) => sum + e.amount);
          final expense = list.where((e) => e.type == TransactionType.expense).fold<int>(0, (sum, e) => sum + e.amount);
          final transfer = list
              .where((e) => e.type == TransactionType.transfer)
              .fold<int>(0, (sum, e) => sum + e.amount);

          // final expense = list.where((e) => e.type == "expense").fold<int>(0, (sum, e) => sum + e.amount);
          debugPrint("UI TRANSACTION COUNT = ${list.length}");
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text("Income"),
                        Text(
                          FormatterHelper.formatRupiah(income),
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    Column(
                      children: [
                        const Text("Expense"),
                        Text(
                          FormatterHelper.formatRupiah(expense),
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    Column(
                      children: [
                        const Text("Transactions"),
                        Text(list.length.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // SliverToBoxAdapter(
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(12),
                    //     child: Text(
                    //       "Total: ${FormatterHelper.formatRupiah(total)}",
                    //       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    //     ),
                    //   ),
                    // ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, i) {
                        final e = list[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(switch (e.type) {
                                TransactionType.income => "⬆",
                                TransactionType.expense => "⬇",
                                TransactionType.transfer => "⇄",
                              }),
                            ),

                            title: Text(e.bank),

                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${e.type.name.toUpperCase()} • ${e.category.name}"),

                                const SizedBox(height: 4),

                                Text(FormatterHelper.formatDateWithTime(e.time)),
                              ],
                            ),

                            trailing: Text(
                              "${switch (e.type) {
                                TransactionType.income => "+",
                                TransactionType.expense => "-",
                                TransactionType.transfer => "⇄",
                              }} ${FormatterHelper.formatRupiah(e.amount)}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: switch (e.type) {
                                  TransactionType.income => Colors.green,
                                  TransactionType.expense => Colors.red,
                                  TransactionType.transfer => Colors.blue,
                                },
                              ),
                            ),
                          ),
                        );
                      }, childCount: list.length),
                    ),
                  ],
                ),
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
