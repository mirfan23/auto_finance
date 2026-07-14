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

  const TransactionItem({super.key, required this.trx});

  @override
  Widget build(BuildContext context) {
    final color = switch (trx.type) {
      TransactionType.income => Colors.green,
      TransactionType.expense => Colors.red,
      TransactionType.transfer => Colors.blue,
    };

    final sign = switch (trx.type) {
      TransactionType.income => "+",
      TransactionType.expense => "-",
      TransactionType.transfer => "",
    };

    return Card(
      // elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Material(
        type: MaterialType.transparency,
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push("/transaction/${trx.id}"),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: BankHelper.color(trx.bank).withValues(alpha: 0.12),
                  child: Icon(BankHelper.icon(trx.bank), color: BankHelper.color(trx.bank)),
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        BankHelper.title(trx.bank),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          Icon(CategoryHelper.icon(trx.category), size: 15, color: CategoryHelper.color(trx.category)),
                          const SizedBox(width: 4),
                          Text(CategoryHelper.title(trx.category), style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat("HH:mm").format(trx.time),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),

                Text(
                  "$sign${FormatterHelper.formatRupiah(trx.amount)}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
