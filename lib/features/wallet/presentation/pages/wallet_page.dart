import 'package:auto_finance/app/theme.dart';
import 'package:auto_finance/core/providers/money_visibility_provider.dart';
import 'package:auto_finance/features/wallet/application/providers/wallet_provider.dart';
import 'package:auto_finance/features/wallet/presentation/widgets/add_wallet_dialog.dart';
import 'package:auto_finance/features/wallet/presentation/widgets/adjust_wallet_balance_dialog.dart';
import 'package:auto_finance/features/wallet/presentation/widgets/wallet_balance_history_sheet.dart';
import 'package:auto_finance/features/wallet/presentation/widgets/wallet_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fx_helper/formatter_helper.dart';

class WalletPage extends ConsumerWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallets = ref.watch(walletStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dompet')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const AddWalletDialog(),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah dompet'),
      ),
      body: wallets.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.forest),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Dompet belum bisa dimuat.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (list) {
          final hidden = ref.watch(hideMoneyValuesProvider);
          final total = list.fold<int>(
            0,
            (sum, wallet) => sum + wallet.balance,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.forest, AppColors.forestDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Colors.white70,
                          size: 19,
                        ),
                        SizedBox(width: 8),
                        const Text(
                          'Total saldo dompet',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      hidden ? '••••••••' : FormatterHelper.formatRupiah(total),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () =>
                            ref.read(hideMoneyValuesProvider.notifier).toggle(),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        icon: Icon(
                          hidden
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 18,
                        ),
                        label: Text(
                          hidden ? 'Tampilkan saldo' : 'Sembunyikan saldo',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${list.length} dompet terhubung',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Semua dompet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Text(
                    '${list.length}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (list.isEmpty)
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.wallet_outlined,
                        size: 34,
                        color: AppColors.forest,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada dompet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Tambahkan saldo awal agar ringkasan keuanganmu lebih lengkap.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              else
                ...list.map(
                  (wallet) => WalletItem(
                    wallet: wallet,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'adjust') {
                          final changed = await showDialog<bool>(
                            context: context,
                            builder: (_) =>
                                AdjustWalletBalanceDialog(wallet: wallet),
                          );
                          if (changed == true && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Saldo berhasil disesuaikan.'),
                              ),
                            );
                          }
                          return;
                        }
                        if (value == 'history') {
                          final history = await ref
                              .read(walletDaoProvider)
                              .getBalanceAdjustments(wallet.id);
                          if (!context.mounted) return;
                          await showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            backgroundColor: Colors.white,
                            builder: (_) => WalletBalanceHistorySheet(
                              walletName: wallet.name,
                              adjustments: history,
                            ),
                          );
                          return;
                        }
                        if (value != 'delete') return;
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Hapus dompet?'),
                            content: Text(
                              'Yakin ingin menghapus ${wallet.name}?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Batal'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Hapus'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await ref.read(deleteWalletProvider).call(wallet.id);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'adjust',
                          child: Row(
                            children: [
                              Icon(Icons.tune_rounded),
                              SizedBox(width: 10),
                              Text('Sesuaikan saldo'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'history',
                          child: Row(
                            children: [
                              Icon(Icons.history_rounded),
                              SizedBox(width: 10),
                              Text('Riwayat penyesuaian'),
                            ],
                          ),
                        ),
                        PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded),
                              SizedBox(width: 10),
                              Text('Hapus dompet'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
