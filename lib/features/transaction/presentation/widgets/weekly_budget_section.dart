import 'package:auto_finance/app/theme.dart';
import 'package:auto_finance/core/helpers/category_helper.dart';
import 'package:auto_finance/features/transaction/domain/entities/transaction_categories.dart';
import 'package:auto_finance/features/transaction/domain/entities/transaction_type.dart';
import 'package:auto_finance/features/transaction/application/providers/transaction_filter_state_provider.dart';
import 'package:auto_finance/features/transaction/application/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fx_helper/formatter_helper.dart';
import 'package:intl/intl.dart';

class WeeklyBudgetSection extends ConsumerStatefulWidget {
  const WeeklyBudgetSection({super.key});

  @override
  ConsumerState<WeeklyBudgetSection> createState() =>
      _WeeklyBudgetSectionState();
}

class _WeeklyBudgetSectionState extends ConsumerState<WeeklyBudgetSection> {
  // Start compact; users can open the section to see the detailed cards.
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final selectedWeek = ref.watch(transactionWeekStartProvider);
    final weekEnd = selectedWeek.add(const Duration(days: 7));
    final transactions = ref.watch(transactionStreamProvider);
    final budgets = ref.watch(monthlyBudgetStreamProvider);
    final weekLabel =
        '${DateFormat('d MMM', 'id').format(selectedWeek)} – '
        '${DateFormat('d MMM yyyy', 'id').format(weekEnd.subtract(const Duration(days: 1)))}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: budgets.when(
        loading: () => const LinearProgressIndicator(),
        error: (error, _) =>
            Text('Anggaran mingguan belum bisa dimuat: $error'),
        data: (allBudgets) {
          final weeklyBudgets =
              allBudgets
                  .where((budget) => budget.includeInWeeklyBudget)
                  .map((budget) {
                    final category = _categoryFromName(budget.category);
                    if (category == null) return null;
                    final daysInMonth = DateUtils.getDaysInMonth(
                      selectedWeek.year,
                      selectedWeek.month,
                    );
                    final limit = (budget.monthlyLimit * 7 / daysInMonth)
                        .round();
                    return _WeeklyBudget(category: category, limit: limit);
                  })
                  .whereType<_WeeklyBudget>()
                  .toList()
                ..sort((a, b) => a.category.index.compareTo(b.category.index));

          return transactions.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text('Transaksi belum bisa dimuat: $error'),
            data: (allTransactions) {
              final expenses = <TransactionCategory, int>{};
              for (final transaction in allTransactions) {
                if (transaction.type != TransactionType.expense ||
                    transaction.time.isBefore(selectedWeek) ||
                    !transaction.time.isBefore(weekEnd)) {
                  continue;
                }
                expenses.update(
                  transaction.category,
                  (amount) => amount + transaction.amount,
                  ifAbsent: () => transaction.amount,
                );
              }

              return _buildPanel(context, weeklyBudgets, expenses, weekLabel);
            },
          );
        },
      ),
    );
  }

  Widget _buildPanel(
    BuildContext context,
    List<_WeeklyBudget> budgets,
    Map<TransactionCategory, int> expenses,
    String weekLabel,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Anggaran mingguan',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          weekLabel,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.muted,
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: !_expanded
                ? _collapsedContent(context, budgets, expenses)
                : _expandedContent(context, budgets, expenses),
          ),
        ],
      ),
    );
  }

  Widget _collapsedContent(
    BuildContext context,
    List<_WeeklyBudget> budgets,
    Map<TransactionCategory, int> expenses,
  ) {
    if (budgets.isEmpty) return _emptyMessage(context);
    return Column(
      children: [
        const SizedBox(height: 10),
        ...budgets.map((budget) {
          final spent = expenses[budget.category] ?? 0;
          final progress = budget.limit == 0 ? 0.0 : spent / budget.limit;
          final color = CategoryHelper.color(budget.category);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      CategoryHelper.icon(budget.category),
                      size: 14,
                      color: color,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        CategoryHelper.title(budget.category),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '${FormatterHelper.formatRupiah(spent)} / ${FormatterHelper.formatRupiah(budget.limit)}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 5,
                    backgroundColor: color.withValues(alpha: 0.14),
                    color: color,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _expandedContent(
    BuildContext context,
    List<_WeeklyBudget> budgets,
    Map<TransactionCategory, int> expenses,
  ) {
    if (budgets.isEmpty) return _emptyMessage(context);
    return SizedBox(
      height: 126,
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 12, bottom: 2),
        scrollDirection: Axis.horizontal,
        itemCount: budgets.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final budget = budgets[index];
          final spent = expenses[budget.category] ?? 0;
          final progress = budget.limit == 0 ? 0.0 : spent / budget.limit;
          final color = CategoryHelper.color(budget.category);
          return Container(
            width: 190,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 45,
                  height: 45,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 45,
                        height: 45,
                        child: CircularProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          strokeWidth: 4,
                          backgroundColor: color.withValues(alpha: 0.15),
                          color: color,
                        ),
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        CategoryHelper.title(budget.category),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        FormatterHelper.formatRupiah(spent),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'dari ${FormatterHelper.formatRupiah(budget.limit)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _emptyMessage(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 2),
    child: Text(
      'Belum ada anggaran yang disertakan untuk mingguan. Atur dari Anggaran bulanan di tab Analitik.',
      style: Theme.of(context).textTheme.bodyMedium,
    ),
  );

  TransactionCategory? _categoryFromName(String name) {
    for (final category in TransactionCategory.values) {
      if (category.name == name) return category;
    }
    return null;
  }
}

class _WeeklyBudget {
  const _WeeklyBudget({required this.category, required this.limit});

  final TransactionCategory category;
  final int limit;
}
