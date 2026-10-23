import 'package:auto_finance/features/transaction/providers/transaction_filter_provider.dart';
import 'package:auto_finance/features/transaction/widgets/empty_transaction.dart';
import 'package:auto_finance/features/transaction/widgets/transaction_filter_bar.dart';
import 'package:auto_finance/features/transaction/widgets/transaction_list.dart';
import 'package:auto_finance/features/transaction/widgets/transaction_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionPage extends ConsumerWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(filteredTransactionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Transaksi")),
      body: transactions.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(child: Text(e.toString())),

        data: (list) {
          return Column(
            children: [
              const TransactionSearchBar(),
              const TransactionFilterBar(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Riwayat transaksi',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      '${list.length} transaksi',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: list.isEmpty
                    ? const EmptyTransaction()
                    : TransactionList(transactions: list),
              ),
            ],
          );
        },
      ),
    );
  }
}
