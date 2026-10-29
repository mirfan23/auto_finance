import 'package:auto_finance/features/notification/application/providers/notification_sync_provider.dart';
import 'package:auto_finance/features/transaction/application/providers/transaction_filter_provider.dart';
import 'package:auto_finance/features/transaction/application/providers/transaction_filter_state_provider.dart';
import 'package:auto_finance/features/transaction/presentation/widgets/empty_transaction.dart';
import 'package:auto_finance/features/transaction/presentation/widgets/transaction_filter_bar.dart';
import 'package:auto_finance/features/transaction/presentation/widgets/transaction_list.dart';
import 'package:auto_finance/features/transaction/presentation/widgets/transaction_search_bar.dart';
import 'package:auto_finance/features/transaction/presentation/widgets/weekly_budget_section.dart';
import 'package:auto_finance/features/transaction/presentation/widgets/transaction_week_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TransactionPage extends ConsumerWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(filteredTransactionProvider);
    final selectedWeekStart = ref.watch(transactionWeekStartProvider);
    final today = DateTime.now();
    final currentWeekStart = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: today.weekday - DateTime.monday));
    final weekTitle = selectedWeekStart == currentWeekStart
        ? 'Transaksi minggu ini'
        : 'Transaksi minggu terpilih';

    return Scaffold(
      appBar: AppBar(title: const Text("Transaksi")),
      body: transactions.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(child: Text(e.toString())),

        data: (list) {
          return RefreshIndicator(
            onRefresh: () => ref.read(notificationSyncProvider).sync(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: WeeklyBudgetSection()),
                const SliverToBoxAdapter(child: TransactionWeekSelector()),
                const SliverToBoxAdapter(child: TransactionSearchBar()),
                const SliverToBoxAdapter(child: TransactionFilterBar()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            weekTitle,
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
                ),
                if (list.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyTransaction(),
                  )
                else
                  TransactionList(transactions: list),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/transaction/manual'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah transaksi'),
      ),
    );
  }
}
