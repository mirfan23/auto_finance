import 'package:auto_finance/core/helpers/category_helper.dart';
import 'package:auto_finance/features/transaction/domain/entities/transaction.dart';
import 'package:auto_finance/features/transaction/application/providers/transaction_provider.dart';
import 'package:auto_finance/features/transaction/presentation/widgets/edit_transaction_sheet.dart';
import 'package:auto_finance/features/wallet/application/providers/wallet_provider.dart';
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
          final isNotificationTransaction =
              transaction.id.startsWith('notification_') ||
              transaction.id.startsWith('transfer_notification_');

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: CategoryHelper.color(
                  transaction.category,
                ).withOpacity(.15),
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
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              OutlinedButton.icon(
                onPressed: () => _editTransaction(context, ref, transaction),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit transaksi'),
              ),

              if (transaction.rawText.endsWith('(input manual)')) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: () =>
                      _deleteManualTransaction(context, ref, transaction),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Hapus transaksi manual'),
                ),
              ],

              if (isNotificationTransaction) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: () =>
                      _markNotTransaction(context, ref, transaction),
                  icon: const Icon(Icons.not_interested_outlined),
                  label: const Text('Bukan transaksi'),
                ),
              ],

              const SizedBox(height: 24),

              _item("Kategori", CategoryHelper.title(transaction.category)),

              _item("Bank", transaction.bank),

              _item(
                "Tanggal",
                DateFormat("dd MMMM yyyy HH:mm", "id").format(transaction.time),
              ),

              _item("Tipe", transaction.type.name),

              if (transaction.fromWallet != null)
                _item("Dari Wallet", transaction.fromWallet!),

              if (transaction.toWallet != null)
                _item("Ke Wallet", transaction.toWallet!),

              const SizedBox(height: 24),

              const Text(
                "Notifikasi lengkap",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
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

  Future<void> _editTransaction(
    BuildContext context,
    WidgetRef ref,
    Transaction transaction,
  ) async {
    try {
      final wallets = await ref.read(walletStreamProvider.future);
      if (!context.mounted) return;
      final saved = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) =>
            EditTransactionSheet(transaction: transaction, wallets: wallets),
      );
      if (saved == true) {
        ref.invalidate(transactionDetailProvider(transaction.id));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaksi diperbarui.')),
          );
        }
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transaksi belum bisa diedit: $error')),
        );
      }
    }
  }

  Future<void> _deleteManualTransaction(
    BuildContext context,
    WidgetRef ref,
    Transaction transaction,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus transaksi manual?'),
        content: const Text(
          'Transaksi ini akan dihapus dan saldo dompet akan disesuaikan untuk membatalkan dampaknya.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(transactionDaoProvider).delete(transaction.id);
      if (context.mounted) Navigator.of(context).pop();
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transaksi belum bisa dihapus: $error')),
        );
      }
    }
  }

  Future<void> _markNotTransaction(
    BuildContext context,
    WidgetRef ref,
    Transaction transaction,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tandai bukan transaksi?'),
        content: const Text(
          'Catatan ini akan dihapus dan saldo dompet disesuaikan. Notifikasi dengan pesan yang sama akan diabaikan jika diterima lagi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Tandai bukan transaksi'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final removed = await ref
          .read(transactionDaoProvider)
          .markNotTransaction(transaction.id);
      if (removed && context.mounted) Navigator.of(context).pop();
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transaksi belum bisa dihapus: $error')),
        );
      }
    }
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
