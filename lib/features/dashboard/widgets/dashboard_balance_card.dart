import 'package:flutter/material.dart';
import 'package:fx_helper/formatter_helper.dart';

class DashboardBalanceCard extends StatelessWidget {
  final int totalAsset;
  final int totalIncome;
  final int totalExpense;

  const DashboardBalanceCard({
    super.key,
    required this.totalAsset,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Total Asset", style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 8),

            Text(
              FormatterHelper.formatRupiah(totalAsset),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _Item(title: "Income", value: totalIncome, color: Colors.green),
                ),
                Expanded(
                  child: _Item(title: "Expense", value: totalExpense, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String title;
  final int value;
  final Color color;

  const _Item({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: color)),
        const SizedBox(height: 6),
        Text(FormatterHelper.formatRupiah(value), style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
