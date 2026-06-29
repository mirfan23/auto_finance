import 'package:auto_finance/debug/fake_notifications.dart';
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle("🧪 Simulator"),

          _button("Single Expense", () async {
            await ref.read(transactionActionProvider).handle(FakeNotifications.jagoExpense50k());
          }),

          _button("Single Income", () async {
            await ref.read(transactionActionProvider).handle(FakeNotifications.bcaIncome50k());
          }),

          _button("Transfer Pair", () async {
            await FakeNotifications.transfer50k(ref.read(transactionActionProvider));
          }),

          const SizedBox(height: 24),

          _sectionTitle("⏳ Pending"),

          _button("Print Pending", () async {
            final dao = ref.read(pendingDaoProvider);

            final rows = await dao.getPending();

            debugPrint("========== PENDING ==========");

            debugPrint("COUNT = ${rows.length}");

            for (final e in rows) {
              debugPrint(
                "${e.bank} | "
                "${e.amount} | "
                "${e.type.name}",
              );
            }

            debugPrint("=============================");
          }),

          _button("Finalize Pending", () async {
            await ref.read(finalizePendingProvider).execute();
          }),

          _button("Clear Pending", () async {
            final db = ref.read(dbProvider);

            await db.delete(db.pendingTransactionsTable).go();

            debugPrint("✅ PENDING CLEARED");
          }),

          const SizedBox(height: 24),

          _sectionTitle("💰 Transactions"),

          _button("Print Transactions", () async {
            final db = ref.read(dbProvider);

            final rows = await db.select(db.transactionsTable).get();

            debugPrint("======= TRANSACTIONS =======");

            debugPrint("COUNT = ${rows.length}");

            for (final e in rows) {
              debugPrint(
                "${e.bank} | "
                "${e.amount} | "
                "${e.type}",
              );
            }

            debugPrint("============================");
          }),

          _button("Clear Transactions", () async {
            final db = ref.read(dbProvider);

            await db.delete(db.transactionsTable).go();

            debugPrint("✅ TRANSACTIONS CLEARED");
          }),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _button(String title, Future<void> Function() onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        height: 48,
        child: ElevatedButton(onPressed: onPressed, child: Text(title)),
      ),
    );
  }
}
