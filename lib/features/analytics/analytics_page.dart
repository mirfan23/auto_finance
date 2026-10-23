import 'package:auto_finance/app/theme.dart';
import 'package:auto_finance/features/dashboard/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fx_helper/formatter_helper.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analitik')),
      body: summary.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.forest),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Ringkasan belum bisa dimuat.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (data) {
          final totalFlow = data.totalIncome + data.totalExpense;
          final incomeShare = totalFlow == 0
              ? 0.5
              : data.totalIncome / totalFlow;
          final incomeFlex = (incomeShare * 1000).round().clamp(1, 999).toInt();
          final net = data.totalIncome - data.totalExpense;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              Text(
                'Arus keuangan',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                'Ringkasan dari seluruh transaksi yang tersimpan.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _FlowCard(
                      title: 'Pemasukan',
                      amount: data.totalIncome,
                      color: AppColors.income,
                      icon: Icons.south_west_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FlowCard(
                      title: 'Pengeluaran',
                      amount: data.totalExpense,
                      color: AppColors.expense,
                      icon: Icons.north_east_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selisih pemasukan dan pengeluaran',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      FormatterHelper.formatRupiah(net),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: net >= 0
                                ? AppColors.income
                                : AppColors.expense,
                          ),
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Row(
                        children: [
                          Expanded(
                            flex: incomeFlex,
                            child: Container(
                              height: 10,
                              color: AppColors.income,
                            ),
                          ),
                          Expanded(
                            flex: 1000 - incomeFlex,
                            child: Container(
                              height: 10,
                              color: AppColors.expense,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const _Legend(color: AppColors.income, label: 'Masuk'),
                        const Spacer(),
                        _Legend(color: AppColors.expense, label: 'Keluar'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.mint.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.forest),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Angka ini mencakup semua transaksi yang tersimpan, bukan hanya bulan berjalan.',
                        style: TextStyle(
                          color: AppColors.forestDark,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FlowCard extends StatelessWidget {
  const _FlowCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String title;
  final int amount;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(height: 14),
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              FormatterHelper.formatRupiah(amount),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: color, fontSize: 17),
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
