import 'dart:math' as math;

import 'package:auto_finance/app/theme.dart';
import 'package:auto_finance/core/helpers/bank_helper.dart';
import 'package:auto_finance/core/helpers/category_helper.dart';
import 'package:auto_finance/features/transaction/domain/entities/transaction.dart';
import 'package:auto_finance/features/transaction/domain/entities/transaction_categories.dart';
import 'package:auto_finance/features/transaction/domain/entities/transaction_type.dart';
import 'package:auto_finance/features/analytics/presentation/widgets/monthly_budget_section.dart';
import 'package:auto_finance/features/analytics/presentation/pages/category_expense_detail_page.dart';
import 'package:auto_finance/features/transaction/application/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fx_helper/formatter_helper.dart';
import 'package:intl/intl.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  static const _monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  String _monthLabel(DateTime month) =>
      '${_monthNames[month.month - 1]} ${month.year}';

  bool _isSameMonth(DateTime date, DateTime month) =>
      date.year == month.year && date.month == month.month;

  DateTime _shiftMonth(DateTime date, int amount) =>
      DateTime(date.year, date.month + amount);

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: transactionsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.forest),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Statistik belum bisa dimuat.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (transactions) => _buildContent(transactions),
      ),
    );
  }

  Widget _buildContent(List<Transaction> allTransactions) {
    final monthTransactions = allTransactions
        .where((transaction) => _isSameMonth(transaction.time, _selectedMonth))
        .toList();
    final previousMonth = _shiftMonth(_selectedMonth, -1);
    final previousTransactions = allTransactions
        .where((transaction) => _isSameMonth(transaction.time, previousMonth))
        .toList();

    final income = _sum(monthTransactions, TransactionType.income);
    final expense = _sum(monthTransactions, TransactionType.expense);
    final previousExpense = _sum(previousTransactions, TransactionType.expense);
    final net = income - expense;
    final incomeTransactions =
        monthTransactions
            .where((transaction) => transaction.type == TransactionType.income)
            .toList()
          ..sort((a, b) => b.time.compareTo(a.time));
    final expenseTransactions =
        monthTransactions
            .where((transaction) => transaction.type == TransactionType.expense)
            .toList()
          ..sort((a, b) => b.time.compareTo(a.time));
    final expenseByCategory = <TransactionCategory, int>{};
    for (final transaction in expenseTransactions) {
      expenseByCategory.update(
        transaction.category,
        (amount) => amount + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }
    final sortedCategories = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final monthStart = DateTime(_selectedMonth.year, _selectedMonth.month);
    final daysInMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
    ).day;
    final today = DateTime.now();
    final isCurrentMonth = _isSameMonth(today, _selectedMonth);
    final elapsedDays = isCurrentMonth ? today.day : daysInMonth;
    final averageDailyExpense = expense == 0
        ? 0
        : (expense / elapsedDays).round();
    final comparison = _expenseComparison(expense, previousExpense);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
      children: [
        _MonthSelector(
          label: _monthLabel(_selectedMonth),
          onPrevious: () =>
              setState(() => _selectedMonth = _shiftMonth(_selectedMonth, -1)),
          onNext: _isSameMonth(today, _selectedMonth)
              ? null
              : () => setState(
                  () => _selectedMonth = _shiftMonth(_selectedMonth, 1),
                ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _AmountCard(
                title: 'Pemasukan',
                amount: income,
                color: AppColors.income,
                icon: Icons.south_west_rounded,
                onTap: () => _showTransactionDetails(
                  title: 'Detail pemasukan',
                  transactions: incomeTransactions,
                  total: income,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AmountCard(
                title: 'Pengeluaran',
                amount: expense,
                color: AppColors.expense,
                icon: Icons.north_east_rounded,
                onTap: () => _showTransactionDetails(
                  title: 'Detail pengeluaran',
                  transactions: expenseTransactions,
                  total: expense,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _NetCard(net: net),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SmallStatCard(
                icon: Icons.receipt_long_rounded,
                title: 'Transaksi',
                value: '${monthTransactions.length}',
                subtitle: 'termasuk transfer',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SmallStatCard(
                icon: Icons.calendar_today_rounded,
                title: 'Rata-rata keluar',
                value: FormatterHelper.formatRupiah(averageDailyExpense),
                subtitle: 'per hari',
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        MonthlyBudgetSection(
          month: _selectedMonth,
          transactions: monthTransactions,
        ),
        const SizedBox(height: 24),
        _SectionTitle(
          title: 'Tren pengeluaran',
          subtitle: 'Perbandingan enam bulan terakhir',
        ),
        const SizedBox(height: 12),
        _MonthlyTrend(
          months: List.generate(6, (index) {
            final month = _shiftMonth(monthStart, index - 5);
            return _MonthExpense(
              month: month,
              amount: _sum(
                allTransactions
                    .where(
                      (transaction) => _isSameMonth(transaction.time, month),
                    )
                    .toList(),
                TransactionType.expense,
              ),
              selected: _isSameMonth(month, _selectedMonth),
            );
          }),
          monthNames: _monthNames,
        ),
        const SizedBox(height: 24),
        _SectionTitle(
          title: 'Pengeluaran per kategori',
          subtitle:
              comparison ??
              'Belum ada data bulan sebelumnya untuk dibandingkan',
        ),
        const SizedBox(height: 12),
        if (sortedCategories.isEmpty)
          const _EmptyCard(
            icon: Icons.pie_chart_outline_rounded,
            message: 'Belum ada pengeluaran di bulan ini.',
          )
        else
          _CategoryBreakdown(
            categories: sortedCategories,
            total: expense,
            onTap: (category) {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CategoryExpenseDetailPage(
                    category: category,
                    month: _selectedMonth,
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 14),
        const _TransferNote(),
      ],
    );
  }

  int _sum(List<Transaction> transactions, TransactionType type) => transactions
      .where((transaction) => transaction.type == type)
      .fold(0, (total, transaction) => total + transaction.amount);

  Future<void> _showTransactionDetails({
    required String title,
    required List<Transaction> transactions,
    required int total,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TransactionDetailsSheet(
        title: title,
        monthLabel: _monthLabel(_selectedMonth),
        transactions: transactions,
        total: total,
      ),
    );
  }

  String? _expenseComparison(int current, int previous) {
    if (previous == 0) return null;
    final change = ((current - previous) / previous * 100).round();
    if (change == 0) return 'Sama dengan bulan sebelumnya';
    final direction = change > 0 ? 'naik' : 'turun';
    return 'Pengeluaran $direction ${change.abs()}% dari bulan sebelumnya';
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: onPrevious,
          tooltip: 'Bulan sebelumnya',
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: Center(
            child: Text(label, style: Theme.of(context).textTheme.titleLarge),
          ),
        ),
        IconButton.filledTonal(
          onPressed: onNext,
          tooltip: 'Bulan berikutnya',
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class _AmountCard extends StatelessWidget {
  const _AmountCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final int amount;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 19),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded, color: AppColors.muted),
                ],
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 5),
              Text(
                'Lihat rincian',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionDetailsSheet extends StatelessWidget {
  const _TransactionDetailsSheet({
    required this.title,
    required this.monthLabel,
    required this.transactions,
    required this.total,
  });

  final String title;
  final String monthLabel;
  final List<Transaction> transactions;
  final int total;

  @override
  Widget build(BuildContext context) {
    final grouped = <TransactionCategory, List<Transaction>>{};
    for (final transaction in transactions) {
      grouped.putIfAbsent(transaction.category, () => []).add(transaction);
    }
    final categories = grouped.entries.toList()
      ..sort((a, b) {
        final aTotal = a.value.fold<int>(0, (sum, item) => sum + item.amount);
        final bTotal = b.value.fold<int>(0, (sum, item) => sum + item.amount);
        return bTotal.compareTo(aTotal);
      });

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.86,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.canvas,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(monthLabel, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          FormatterHelper.formatRupiah(total),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${transactions.length} transaksi',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (transactions.isEmpty)
              const _EmptyCard(
                icon: Icons.receipt_long_outlined,
                message: 'Belum ada transaksi untuk periode ini.',
              )
            else
              ...categories.expand((entry) {
                final categoryTotal = entry.value.fold<int>(
                  0,
                  (sum, transaction) => sum + transaction.amount,
                );
                return [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 10, 2, 8),
                    child: Row(
                      children: [
                        Icon(
                          CategoryHelper.icon(entry.key),
                          color: CategoryHelper.color(entry.key),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            CategoryHelper.title(entry.key),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          FormatterHelper.formatRupiah(categoryTotal),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  ...entry.value.map(
                    (transaction) =>
                        _AnalyticsTransactionRow(transaction: transaction),
                  ),
                ];
              }),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsTransactionRow extends StatelessWidget {
  const _AnalyticsTransactionRow({required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final rawText = transaction.rawText.trim();
    final color = transaction.type == TransactionType.income
        ? AppColors.income
        : AppColors.expense;
    final sign = transaction.type == TransactionType.income ? '+' : '−';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: CategoryHelper.color(
              transaction.category,
            ).withValues(alpha: 0.12),
            child: Icon(
              CategoryHelper.icon(transaction.category),
              size: 17,
              color: CategoryHelper.color(transaction.category),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  BankHelper.title(transaction.bank),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 3),
                Text(
                  rawText.isEmpty ? 'Tidak ada rincian notifikasi' : rawText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('d MMM, HH:mm', 'id').format(transaction.time),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$sign${FormatterHelper.formatRupiah(transaction.amount)}',
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _NetCard extends StatelessWidget {
  const _NetCard({required this.net});

  final int net;

  @override
  Widget build(BuildContext context) {
    final color = net >= 0 ? AppColors.income : AppColors.expense;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.mint.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.account_balance_wallet_rounded, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selisih bulan ini',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 3),
                Text(
                  FormatterHelper.formatRupiah(net),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  const _SmallStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: AppColors.forest),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: 3),
          Text(subtitle, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 4),
      Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
    ],
  );
}

class _MonthExpense {
  const _MonthExpense({
    required this.month,
    required this.amount,
    required this.selected,
  });

  final DateTime month;
  final int amount;
  final bool selected;
}

class _MonthlyTrend extends StatelessWidget {
  const _MonthlyTrend({required this.months, required this.monthNames});

  final List<_MonthExpense> months;
  final List<String> monthNames;

  @override
  Widget build(BuildContext context) {
    final maxAmount = months.fold<int>(
      0,
      (maxValue, month) => math.max(maxValue, month.amount),
    );
    return Container(
      height: 190,
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: months.map((month) {
          final fraction = maxAmount == 0 ? 0.0 : month.amount / maxAmount;
          final barHeight = month.amount == 0 ? 4.0 : 12 + fraction * 92;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 18,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        month.amount == 0 ? '—' : _compactAmount(month.amount),
                        style: TextStyle(
                          fontSize: 10,
                          color: month.selected
                              ? AppColors.forest
                              : AppColors.muted,
                          fontWeight: month.selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 24,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: month.selected ? AppColors.forest : AppColors.mint,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    monthNames[month.month.month - 1].substring(0, 3),
                    style: TextStyle(
                      fontSize: 10,
                      color: month.selected
                          ? AppColors.forest
                          : AppColors.muted,
                      fontWeight: month.selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _compactAmount(int amount) {
    if (amount >= 1000000000) {
      return ' ${(amount / 1000000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}jt';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}rb';
    return '$amount';
  }
}

class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({
    required this.categories,
    required this.total,
    required this.onTap,
  });

  final List<MapEntry<TransactionCategory, int>> categories;
  final int total;
  final ValueChanged<TransactionCategory> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: categories.map((entry) {
          final categoryColor = CategoryHelper.color(entry.key);
          final share = total == 0 ? 0.0 : entry.value / total;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onTap(entry.key),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 13),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        CategoryHelper.icon(entry.key),
                        color: categoryColor,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  CategoryHelper.title(entry.key),
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontSize: 14),
                                ),
                              ),
                              Text(
                                '${(share * 100).round()}%',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: share.clamp(0.0, 1.0),
                              minHeight: 6,
                              backgroundColor: AppColors.canvas,
                              valueColor: AlwaysStoppedAnimation(categoryColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      FormatterHelper.formatRupiah(entry.value),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.muted,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.line),
    ),
    child: Column(
      children: [
        Icon(icon, size: 30, color: AppColors.muted),
        const SizedBox(height: 10),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    ),
  );
}

class _TransferNote extends StatelessWidget {
  const _TransferNote();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.mint.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline_rounded, color: AppColors.forest, size: 19),
        SizedBox(width: 9),
        Expanded(
          child: Text(
            'Transaksi transfer tidak dihitung sebagai pemasukan atau pengeluaran agar statistik arus uang tetap akurat.',
            style: TextStyle(
              color: AppColors.forestDark,
              height: 1.4,
              fontSize: 12,
            ),
          ),
        ),
      ],
    ),
  );
}
