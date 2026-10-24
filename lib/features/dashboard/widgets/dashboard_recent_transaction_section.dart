import 'package:auto_finance/app/theme.dart';
import 'package:auto_finance/app/navigation/bottomnav_provider.dart';
import 'package:auto_finance/domain/entities/transaction.dart';
import 'package:auto_finance/features/transaction/widgets/transaction_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardRecentTransactionSection extends ConsumerWidget {
  final List<Transaction> transactions;

  const DashboardRecentTransactionSection({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Transaksi terbaru",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              TextButton(
                onPressed: () {
                  ref.read(bottomNavIndexProvider.notifier).state = 1;
                },
                child: const Text("Semua transaksi"),
              ),
            ],
          ),

          const SizedBox(height: 8),

          if (transactions.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    color: AppColors.forest,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Belum ada transaksi",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              itemBuilder: (_, index) {
                final trx = transactions[index];

                return TransactionItem(trx: trx);
              },
            ),
        ],
      ),
    );
  }
}
