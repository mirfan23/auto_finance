import 'package:auto_finance/core/helpers/date_helper.dart';
import 'package:auto_finance/core/helpers/transaction_group_helper.dart';
import 'package:auto_finance/domain/entities/transaction.dart';
import 'package:auto_finance/features/transaction/widgets/transaction_group.dart';
import 'package:flutter/material.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;

  const TransactionList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final grouped = TransactionGroupHelper.groupByDate(transactions);

    final entries = grouped.entries.toList();
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final entry = entries[index];
          return TransactionGroup(
            title: DateHelper.sectionTitle(entry.key),
            transactions: entry.value,
          );
        }, childCount: entries.length),
      ),
    );
  }
}
