import 'package:auto_finance/domain/usecases/transaction/transaction_action_usecase.dart';
import 'package:auto_finance/features/transaction/providers/finalize_pending_provider.dart';
import 'package:auto_finance/features/transaction/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DebugTransactionPage extends ConsumerWidget {
  const DebugTransactionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transaction Debug")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            ElevatedButton(
              onPressed: () async {
                final db = ref.read(dbProvider);

                final result = await db.customSelect("PRAGMA table_info(pending_transactions_table)").get();

                for (final row in result) {
                  debugPrint(row.data.toString());
                }
              },
              child: const Text("Pending Table Info"),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final db = ref.read(dbProvider);

                final result = await db.customSelect("SELECT * FROM pending_transactions_table").get();

                for (final row in result) {
                  debugPrint(row.data.toString());
                }
              },
              child: const Text("Print Pending Rows"),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await ref.read(finalizePendingProvider).execute();
              },
              child: const Text("Finalize Pending"),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await ref.read(transactionActionProvider).handle({
                  "packageName": "com.jago.digitalBanking",
                  "title": "Jago",
                  "text":
                      "Kamu telah melakukan transfer Rp50.000 ke M IRFAN FADHILA. Butuh bantuan? Silakan Tanya Jago di 1500 746.",
                  "timestamp": DateTime.now().millisecondsSinceEpoch,
                });
              },
              child: const Text("Fake Jago Debit 50K"),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () async {
                await ref.read(transactionActionProvider).handle({
                  "packageName": "com.bca.mybca.omni.android",
                  "title": "Financial Diary",
                  "text": "You received IDR 50,000.00 from MUHA**AD **FAN *AD at Account Transfer category.",
                  "timestamp": DateTime.now().millisecondsSinceEpoch,
                });
              },
              child: const Text("Fake BCA Credit 50K"),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () async {
                final db = ref.read(dbProvider);

                await db.delete(db.transactionsTable).go();

                debugPrint("TRANSACTION TABLE CLEARED");
              },
              child: const Text("Clear Transactions"),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () async {
                final dao = ref.read(pendingDaoProvider);

                final rows = await dao.getPending();

                debugPrint("PENDING COUNT = ${rows.length}");

                for (final e in rows) {
                  debugPrint("${e.bank} | ${e.amount} | ${e.type}");
                }
              },
              child: const Text("Print Pending"),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () async {
                final db = ref.read(dbProvider);

                final rows = await db.select(db.transactionsTable).get();

                debugPrint("TOTAL TRANSACTIONS = ${rows.length}");

                for (final e in rows) {
                  debugPrint("${e.bank} | ${e.amount} | ${e.type}");
                }
              },
              child: const Text("Print Transactions"),
            ),
          ],
        ),
      ),
    );
  }
}
