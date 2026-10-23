import 'package:auto_finance/app/theme.dart';
import 'package:auto_finance/core/helpers/bank_helper.dart';
import 'package:auto_finance/core/helpers/category_helper.dart';
import 'package:auto_finance/domain/entities/transaction.dart';
import 'package:auto_finance/domain/entities/transaction_type.dart';
import 'package:flutter/material.dart';
import 'package:fx_helper/formatter_helper.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TransactionItem extends StatelessWidget {
  final Transaction trx;
  final bool showBank;
  final bool showTime;
  final bool showAmount;

  final VoidCallback? onTap;

  const TransactionItem({
    super.key,
    required this.trx,
    this.showBank = true,
    this.showTime = true,
    this.showAmount = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (trx.type) {
      TransactionType.income => AppColors.income,
      TransactionType.expense => AppColors.expense,
      TransactionType.transfer => AppColors.transfer,
    };

    final sign = switch (trx.type) {
      TransactionType.income => "+",
      TransactionType.expense => "-",
      TransactionType.transfer => "",
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        type: MaterialType.transparency,
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap:
              onTap ??
              () {
                context.push("/transaction/${trx.id}");
              },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: BankHelper.color(
                    trx.bank,
                  ).withValues(alpha: 0.10),
                  child: Icon(
                    BankHelper.icon(trx.bank),
                    color: BankHelper.color(trx.bank),
                  ),
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        BankHelper.title(trx.bank),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          Icon(
                            CategoryHelper.icon(trx.category),
                            size: 15,
                            color: CategoryHelper.color(trx.category),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            CategoryHelper.title(trx.category),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (showTime) ...[
                        const SizedBox(height: 4),

                        Text(
                          DateFormat("HH:mm").format(trx.time),
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ],
                  ),
                ),

                if (showAmount)
                  Text(
                    "$sign${FormatterHelper.formatRupiah(trx.amount)}",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: color,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
