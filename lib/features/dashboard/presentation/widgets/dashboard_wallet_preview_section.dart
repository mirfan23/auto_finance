import 'package:auto_finance/app/theme.dart';
import 'package:auto_finance/app/navigation/bottomnav_provider.dart';
import 'package:auto_finance/features/wallet/domain/entities/wallet.dart';
import 'package:auto_finance/features/wallet/presentation/widgets/wallet_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardWalletPreviewSection extends ConsumerWidget {
  final List<Wallet> wallets;

  const DashboardWalletPreviewSection({super.key, required this.wallets});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preview = [...wallets]
      ..sort((a, b) => b.balance.compareTo(a.balance));

    final displayWallets = preview.take(3).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Dompet",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              TextButton(
                onPressed: () {
                  ref.read(bottomNavIndexProvider.notifier).state = 2;
                },
                child: const Text("Semua dompet"),
              ),
            ],
          ),

          const SizedBox(height: 8),

          if (displayWallets.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  const Icon(Icons.wallet_outlined, color: AppColors.forest),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Belum ada dompet",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayWallets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 2),
              itemBuilder: (_, index) {
                final wallet = displayWallets[index];

                return WalletItem(wallet: wallet);
              },
            ),
        ],
      ),
    );
  }
}
