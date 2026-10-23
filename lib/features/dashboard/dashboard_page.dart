import 'package:auto_finance/app/theme.dart';
import 'package:auto_finance/features/dashboard/providers/dashboard_provider.dart';
import 'package:auto_finance/features/dashboard/widgets/dashboard_balance_card.dart';
import 'package:auto_finance/features/dashboard/widgets/dashboard_header.dart';
import 'package:auto_finance/features/dashboard/widgets/dashboard_recent_transaction_section.dart';
import 'package:auto_finance/features/dashboard/widgets/dashboard_wallet_preview_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardProvider);

    return Scaffold(
      body: SafeArea(
        child: summary.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.forest),
          ),

          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Ringkasan belum bisa dimuat.\n$e',
                textAlign: TextAlign.center,
              ),
            ),
          ),

          data: (data) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(dashboardProvider);
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),

                slivers: [
                  const SliverToBoxAdapter(child: DashboardHeader()),

                  SliverToBoxAdapter(
                    child: DashboardBalanceCard(
                      totalAsset: data.totalAsset,
                      totalIncome: data.totalIncome,
                      totalExpense: data.totalExpense,
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: DashboardWalletPreviewSection(wallets: data.wallets),
                  ),

                  SliverToBoxAdapter(
                    child: DashboardRecentTransactionSection(
                      transactions: data.recentTransactions,
                    ),
                  ),

                  const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
