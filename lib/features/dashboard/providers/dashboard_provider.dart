import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../notification_listener/providers/transaction_provider.dart';

class DashboardSummary {
  final int totalIncome;
  final int totalExpense;
  final Map<String, int> byCategory;

  DashboardSummary({required this.totalIncome, required this.totalExpense, required this.byCategory});
}

final dashboardSummaryProvider = Provider<DashboardSummary>((ref) {
  final transactions = ref.watch(transactionStreamProvider).value ?? [];

  int income = 0;
  int expense = 0;
  final Map<String, int> categoryMap = {};

  for (final t in transactions) {
    if (t.type == "income") {
      income += t.amount;
    } else {
      expense += t.amount;
    }

    categoryMap[t.category.name] = (categoryMap[t.category.name] ?? 0) + t.amount;
  }

  return DashboardSummary(totalIncome: income, totalExpense: expense, byCategory: categoryMap);
});
