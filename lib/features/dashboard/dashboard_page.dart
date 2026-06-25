import 'package:auto_finance/features/dashboard/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fx_helper/formatter_helper.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard Finance")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text("Total Pengeluaran"),
                subtitle: Text(FormatterHelper.formatRupiah(summary.totalExpense)),
              ),
            ),

            Card(
              child: ListTile(
                title: const Text("Total Pemasukan"),
                subtitle: Text(FormatterHelper.formatRupiah(summary.totalIncome)),
              ),
            ),

            const SizedBox(height: 10),

            const Text("Breakdown Category", style: TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                children: summary.byCategory.entries.map((e) {
                  return ListTile(title: Text(e.key), trailing: Text(FormatterHelper.formatRupiah(e.value)));
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
