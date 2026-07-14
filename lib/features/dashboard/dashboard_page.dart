import 'package:auto_finance/features/dashboard/providers/dashboard_provider.dart';
import 'package:auto_finance/features/dashboard/widgets/dashboard_balance_card.dart';
import 'package:auto_finance/features/dashboard/widgets/dashboard_header.dart';
import 'package:auto_finance/features/dashboard/widgets/recent_transaction.dart';
import 'package:auto_finance/features/dashboard/widgets/wallet_preview.dart';
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
          loading: () => const Center(child: CircularProgressIndicator()),

          error: (e, _) => Center(child: Text(e.toString())),

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

                  SliverToBoxAdapter(child: WalletPreview(wallets: data.wallets)),

                  SliverToBoxAdapter(child: RecentTransaction(transactions: data.recentTransactions)),

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
