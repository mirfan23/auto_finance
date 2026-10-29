import 'package:auto_finance/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:auto_finance/features/transaction/domain/entities/transaction.dart';
import 'package:auto_finance/features/transaction/domain/entities/transaction_type.dart';
import 'package:auto_finance/features/wallet/domain/entities/wallet.dart';
import 'package:auto_finance/features/transaction/application/providers/transaction_provider.dart';
import 'package:auto_finance/features/wallet/application/providers/wallet_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardProvider = Provider<AsyncValue<DashboardSummary>>((ref) {
  final walletsAsync = ref.watch(walletStreamProvider);
  final transactionsAsync = ref.watch(transactionStreamProvider);

  // jika wallet masih loading
  if (walletsAsync.isLoading) {
    return const AsyncLoading();
  }

  // jika transaksi masih loading
  if (transactionsAsync.isLoading) {
    return const AsyncLoading();
  }

  // jika wallet error
  if (walletsAsync.hasError) {
    return AsyncError(walletsAsync.error!, walletsAsync.stackTrace!);
  }

  // jika transaksi error
  if (transactionsAsync.hasError) {
    return AsyncError(transactionsAsync.error!, transactionsAsync.stackTrace!);
  }

  final wallets = walletsAsync.value ?? <Wallet>[];
  final transactions = transactionsAsync.value ?? <Transaction>[];
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month);
  final nextMonthStart = DateTime(now.year, now.month + 1);
  final currentMonthTransactions = transactions.where((transaction) {
    return !transaction.time.isBefore(monthStart) &&
        transaction.time.isBefore(nextMonthStart);
  });

  //----------------------------------------
  // Total Asset
  //----------------------------------------

  final totalAsset = wallets.fold<int>(0, (sum, wallet) => sum + wallet.balance);

  //----------------------------------------
  // Income
  //----------------------------------------

  final totalIncome = currentMonthTransactions
      .where((e) => e.type == TransactionType.income)
      .fold<int>(0, (sum, trx) => sum + trx.amount);

  //----------------------------------------
  // Expense
  //----------------------------------------

  final totalExpense = currentMonthTransactions
      .where((e) => e.type == TransactionType.expense)
      .fold<int>(0, (sum, trx) => sum + trx.amount);

  //----------------------------------------
  // Recent Transaction
  //----------------------------------------

  final recentTransactions = [...transactions]..sort((a, b) => b.time.compareTo(a.time));

  final summary = DashboardSummary(
    totalAsset: totalAsset,
    totalIncome: totalIncome,
    totalExpense: totalExpense,
    wallets: wallets,
    recentTransactions: recentTransactions.take(5).toList(),
  );

  return AsyncData(summary);
});
