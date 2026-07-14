import 'package:auto_finance/domain/entities/transaction.dart';
import 'package:auto_finance/domain/entities/wallet.dart';

class DashboardSummary {
  final int totalAsset;
  final int totalIncome;
  final int totalExpense;

  final List<Wallet> wallets;
  final List<Transaction> recentTransactions;

  const DashboardSummary({
    required this.totalAsset,
    required this.totalIncome,
    required this.totalExpense,
    required this.wallets,
    required this.recentTransactions,
  });
}
