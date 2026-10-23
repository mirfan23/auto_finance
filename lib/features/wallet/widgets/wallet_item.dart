import 'package:auto_finance/core/helpers/bank_helper.dart';
import 'package:auto_finance/core/providers/money_visibility_provider.dart';
import 'package:auto_finance/domain/entities/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fx_helper/formatter_helper.dart';

class WalletItem extends ConsumerWidget {
  final Wallet wallet;

  final Widget? trailing;

  final VoidCallback? onTap;

  const WalletItem({
    super.key,
    required this.wallet,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hidden = ref.watch(hideMoneyValuesProvider);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: BankHelper.color(
                    wallet.bank,
                  ).withValues(alpha: .10),
                  child: Icon(
                    BankHelper.icon(wallet.bank),
                    color: BankHelper.color(wallet.bank),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wallet.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),

                      const SizedBox(height: 4),

                      Text(
                        BankHelper.title(wallet.bank),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        hidden
                            ? '••••••'
                            : FormatterHelper.formatRupiah(wallet.balance),
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(fontSize: 18),
                      ),
                    ],
                  ),
                ),

                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
