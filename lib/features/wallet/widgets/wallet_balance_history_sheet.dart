import 'package:auto_finance/app/theme.dart';
import 'package:auto_finance/core/providers/money_visibility_provider.dart';
import 'package:auto_finance/data/local/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fx_helper/formatter_helper.dart';
import 'package:intl/intl.dart';

class WalletBalanceHistorySheet extends ConsumerWidget {
  const WalletBalanceHistorySheet({
    super.key,
    required this.walletName,
    required this.adjustments,
  });

  final String walletName;
  final List<WalletBalanceAdjustmentTableData> adjustments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hidden = ref.watch(hideMoneyValuesProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Riwayat penyesuaian',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(walletName, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 14),
            if (adjustments.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(child: Text('Belum ada penyesuaian saldo.')),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * .55,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: adjustments.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = adjustments[index];
                    final difference = item.newBalance - item.previousBalance;
                    final date = DateFormat(
                      'd MMM yyyy, HH:mm',
                    ).format(item.createdAt);
                    final before = hidden
                        ? '••••••'
                        : FormatterHelper.formatRupiah(item.previousBalance);
                    final after = hidden
                        ? '••••••'
                        : FormatterHelper.formatRupiah(item.newBalance);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.mint,
                        child: Icon(
                          difference >= 0
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          color: AppColors.forest,
                        ),
                      ),
                      title: Text('$before  →  $after'),
                      subtitle: Text(
                        item.note.trim().isEmpty ? date : '$date\n${item.note}',
                      ),
                      isThreeLine: item.note.trim().isNotEmpty,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
