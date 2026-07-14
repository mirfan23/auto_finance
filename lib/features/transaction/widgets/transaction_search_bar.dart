import 'package:auto_finance/features/transaction/providers/transaction_search_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionSearchBar extends ConsumerWidget {
  const TransactionSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        decoration: InputDecoration(
          hintText: "Cari transaksi...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onChanged: (value) {
          ref.read(transactionSearchProvider.notifier).state = value;
        },
      ),
    );
  }
}
