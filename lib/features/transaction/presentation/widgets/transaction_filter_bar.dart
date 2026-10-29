import 'package:auto_finance/features/transaction/domain/entities/transaction_filter.dart';
import 'package:auto_finance/features/transaction/application/providers/transaction_filter_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionFilterBar extends ConsumerWidget {
  const TransactionFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(transactionFilterProvider);

    Widget chip(TransactionFilter filter, String label) {
      return ChoiceChip(
        label: Text(label),
        selected: selected == filter,
        showCheckmark: false,
        onSelected: (_) {
          ref.read(transactionFilterProvider.notifier).state = filter;
        },
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          chip(TransactionFilter.all, "Semua"),
          const SizedBox(width: 8),
          chip(TransactionFilter.income, "Masuk"),
          const SizedBox(width: 8),
          chip(TransactionFilter.expense, "Keluar"),
          const SizedBox(width: 8),
          chip(TransactionFilter.transfer, "Transfer"),
        ],
      ),
    );
  }
}
