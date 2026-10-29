import 'package:auto_finance/app/theme.dart';
import 'package:auto_finance/core/helpers/bank_helper.dart';
import 'package:auto_finance/core/helpers/category_helper.dart';
import 'package:auto_finance/features/transaction/domain/entities/transaction_categories.dart';
import 'package:auto_finance/features/transaction/domain/entities/transaction_type.dart';
import 'package:auto_finance/features/transaction/application/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fx_helper/formatter_helper.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CategoryExpenseDetailPage extends ConsumerWidget {
  const CategoryExpenseDetailPage({
    super.key,
    required this.category,
    required this.month,
  });

  final TransactionCategory category;
  final DateTime month;

  String get _monthLabel => DateFormat('MMMM yyyy', 'id').format(month);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text(CategoryHelper.title(category))),
      body: transactionsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.forest),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Rincian kategori belum bisa dimuat.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (allTransactions) {
          final transactions = allTransactions.where((transaction) {
            return transaction.type == TransactionType.expense &&
                transaction.category == category &&
                transaction.time.year == month.year &&
                transaction.time.month == month.month;
          }).toList()..sort((a, b) => b.time.compareTo(a.time));
          final total = transactions.fold<int>(
            0,
            (sum, transaction) => sum + transaction.amount,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              Text(_monthLabel, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: CategoryHelper.color(
                        category,
                      ).withValues(alpha: 0.12),
                      child: Icon(
                        CategoryHelper.icon(category),
                        color: CategoryHelper.color(category),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total pengeluaran',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            FormatterHelper.formatRupiah(total),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                    Text('${transactions.length} transaksi'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (transactions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: const Text(
                    'Belum ada transaksi untuk kategori ini di bulan tersebut.',
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...transactions.map((transaction) {
                  final rawText = transaction.rawText.trim();
                  return Card(
                    margin: const EdgeInsets.only(bottom: 9),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () =>
                          context.push('/transaction/${transaction.id}'),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: CategoryHelper.color(
                                category,
                              ).withValues(alpha: 0.12),
                              child: Icon(
                                CategoryHelper.icon(category),
                                size: 17,
                                color: CategoryHelper.color(category),
                              ),
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    BankHelper.title(transaction.bank),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    rawText.isEmpty
                                        ? 'Tidak ada rincian notifikasi'
                                        : rawText,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppColors.muted,
                                          height: 1.35,
                                        ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    DateFormat(
                                      'd MMM yyyy, HH:mm',
                                      'id',
                                    ).format(transaction.time),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelMedium,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              FormatterHelper.formatRupiah(transaction.amount),
                              textAlign: TextAlign.end,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.expense,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
