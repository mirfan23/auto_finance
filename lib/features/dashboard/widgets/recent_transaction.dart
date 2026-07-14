import 'package:auto_finance/core/helpers/category_helper.dart';
import 'package:auto_finance/domain/entities/transaction.dart';
import 'package:auto_finance/domain/entities/transaction_type.dart';
import 'package:flutter/material.dart';
import 'package:fx_helper/formatter_helper.dart';
import 'package:go_router/go_router.dart';

class RecentTransaction extends StatelessWidget {
  final List<Transaction> transactions;

  const RecentTransaction({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text("Transaksi Terbaru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              TextButton(
                onPressed: () {
                  context.push("/transaction");
                },
                child: const Text("Lihat Semua"),
              ),
            ],
          ),

          const SizedBox(height: 8),

          if (transactions.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(child: Text("Belum ada transaksi", style: Theme.of(context).textTheme.bodyMedium)),
              ),
            )
          else
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final trx = transactions[index];

                  final income = trx.type == TransactionType.income;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: CategoryHelper.color(trx.category).withOpacity(.15),
                      child: Icon(CategoryHelper.icon(trx.category), color: CategoryHelper.color(trx.category)),
                    ),

                    title: Text(CategoryHelper.title(trx.category)),

                    subtitle: Text(trx.bank),

                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${income ? "+" : "-"}${FormatterHelper.formatRupiah(trx.amount)}",
                          style: TextStyle(color: income ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(FormatterHelper.formatDateFull(trx.time), style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
