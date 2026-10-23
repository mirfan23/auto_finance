import 'package:auto_finance/core/helpers/category_helper.dart';
import 'package:auto_finance/features/transaction/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fx_helper/formatter_helper.dart';
import 'package:intl/intl.dart';

class TransactionDetailPage extends ConsumerWidget {
  final String transactionId;

  const TransactionDetailPage({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trx = ref.watch(transactionDetailProvider(transactionId));

    return Scaffold(
      appBar: AppBar(title: const Text("Detail Transaksi")),
      body: trx.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (transaction) {
          if (transaction == null) {
            return const Center(child: Text("Transaksi tidak ditemukan"));
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: CategoryHelper.color(transaction.category).withOpacity(.15),
                child: Icon(
                  CategoryHelper.icon(transaction.category),
                  size: 36,
                  color: CategoryHelper.color(transaction.category),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  FormatterHelper.formatRupiah(transaction.amount),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 30),

              _item("Kategori", CategoryHelper.title(transaction.category)),

              _item("Bank", transaction.bank),

              _item("Tanggal", DateFormat("dd MMMM yyyy HH:mm", "id").format(transaction.time)),

              _item("Tipe", transaction.type.name),

              if (transaction.fromWallet != null) _item("Dari Wallet", transaction.fromWallet!),

              if (transaction.toWallet != null) _item("Ke Wallet", transaction.toWallet!),

              const SizedBox(height: 24),

              const Text("Notifikasi lengkap", style: TextStyle(fontWeight: FontWeight.bold)),

              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                ),
                child: SelectableText(
                  transaction.rawText,
                  style: const TextStyle(height: 1.5),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _item(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(title, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}
