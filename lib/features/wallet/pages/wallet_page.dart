import 'package:auto_finance/features/wallet/providers/wallet_provider.dart';
import 'package:auto_finance/features/wallet/widgets/add_wallet_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fx_helper/formatter_helper.dart';

class WalletPage extends ConsumerWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallets = ref.watch(walletStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Wallet")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (_) => const AddWalletDialog());
        },
        child: const Icon(Icons.add),
      ),
      body: wallets.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text("Belum ada wallet"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final wallet = list[index];

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(child: Text(wallet.bank.substring(0, 1))),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(wallet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(wallet.bank),
                            const SizedBox(height: 12),
                            const Text("Saldo", style: TextStyle(fontSize: 12)),
                            Text(
                              FormatterHelper.formatRupiah(wallet.balance),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),

                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == "delete") {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Hapus Wallet"),
                                content: Text("Yakin ingin menghapus ${wallet.name}?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text("Batal"),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text("Hapus"),
                                  ),
                                ],
                              ),
                            );

                            if (ok == true) {
                              await ref.read(deleteWalletProvider).call(wallet.id);
                            }
                          }
                        },
                        itemBuilder: (_) => const [PopupMenuItem(value: "delete", child: Text("Hapus"))],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
