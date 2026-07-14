import 'package:auto_finance/domain/entities/transaction.dart';
import 'package:auto_finance/features/transaction/widgets/transaction_item.dart';
import 'package:flutter/material.dart';

class TransactionGroup extends StatelessWidget {
  final String title;
  final List<Transaction> transactions;

  const TransactionGroup({super.key, required this.title, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),

        ...transactions.map((e) => TransactionItem(trx: e)),
      ],
    );
  }
}
