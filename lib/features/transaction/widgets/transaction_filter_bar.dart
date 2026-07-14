import 'package:auto_finance/domain/entities/transaction_filter.dart';
import 'package:auto_finance/features/transaction/providers/transaction_filter_state_provider.dart';
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
          const SizedBox(width: 40),
          chip(TransactionFilter.income, "Income"),
          const SizedBox(width: 40),
          chip(TransactionFilter.expense, "Expense"),
          const SizedBox(width: 40),
          chip(TransactionFilter.transfer, "Transfer"),
        ],
      ),
    );
  }
}
