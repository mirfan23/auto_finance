import 'package:auto_finance/domain/entities/wallet.dart';
import 'package:flutter/material.dart';
import 'package:fx_helper/formatter_helper.dart';
import 'package:go_router/go_router.dart';

class WalletPreview extends StatelessWidget {
  final List<Wallet> wallets;

  const WalletPreview({super.key, required this.wallets});

  @override
  Widget build(BuildContext context) {
    final preview = [...wallets]..sort((a, b) => b.balance.compareTo(a.balance));

    final displayWallets = preview.take(3).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text("Wallet", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              TextButton(
                onPressed: () {
                  context.push("/wallet");
                },
                child: const Text("Lihat Semua"),
              ),
            ],
          ),

          const SizedBox(height: 8),

          if (displayWallets.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(child: Text("Belum ada wallet", style: Theme.of(context).textTheme.bodyMedium)),
              ),
            )
          else
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayWallets.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final wallet = displayWallets[index];

                  return ListTile(
                    leading: CircleAvatar(child: Text(wallet.bank.substring(0, 1))),

                    title: Text(wallet.name),

                    subtitle: Text(wallet.bank),

                    trailing: Text(
                      FormatterHelper.formatRupiah(wallet.balance),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
