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
import 'package:auto_finance/features/wallet/application/providers/wallet_provider.dart';
import 'package:auto_finance/features/wallet/domain/entities/wallet.dart';
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
  bool _expenseByWallet = false;
  bool _incomeByWallet = false;

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

    return DefaultTabController(
      length: 5,
      child: Scaffold(
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
      ),
    );
  }

  Widget _buildContent(List<Transaction> allTransactions) {
    final wallets = ref.watch(walletStreamProvider).valueOrNull ?? const [];
    final monthTransactions = allTransactions
        .where((transaction) => _isSameMonth(transaction.time, _selectedMonth))
        .toList();
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
    final income = _sum(monthTransactions, TransactionType.income);
    final expense = _sum(monthTransactions, TransactionType.expense);
    final net = income - expense;
    final monthStart = DateTime(_selectedMonth.year, _selectedMonth.month);
    final today = DateTime.now();
    final trendMonths = List.generate(6, (index) {
      final month = _shiftMonth(monthStart, index - 5);
      final items = allTransactions
          .where((transaction) => _isSameMonth(transaction.time, month))
          .toList();
      return _MonthTrendData(
        month: month,
        income: _sum(items, TransactionType.income),
        expense: _sum(items, TransactionType.expense),
        selected: _isSameMonth(month, _selectedMonth),
      );
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
          child: _MonthSelector(
            label: _monthLabel(_selectedMonth),
            onPrevious: () => setState(
              () => _selectedMonth = _shiftMonth(_selectedMonth, -1),
            ),
            onNext: _isSameMonth(today, _selectedMonth)
                ? null
                : () => setState(
                    () => _selectedMonth = _shiftMonth(_selectedMonth, 1),
                  ),
          ),
        ),
        TabBar(
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Pengeluaran'),
            Tab(text: 'Pemasukan'),
            Tab(text: 'Anggaran'),
            Tab(text: 'Arus kas'),
            Tab(text: 'Aset'),
          ],
        ),
        Expanded(
          child: TabBarView(
            children: [
              _buildBreakdownTab(
                transactions: expenseTransactions,
                wallets: wallets,
                type: TransactionType.expense,
                byWallet: _expenseByWallet,
                onDimensionChanged: (value) =>
                    setState(() => _expenseByWallet = value),
              ),
              _buildBreakdownTab(
                transactions: incomeTransactions,
                wallets: wallets,
                type: TransactionType.income,
                byWallet: _incomeByWallet,
                onDimensionChanged: (value) =>
                    setState(() => _incomeByWallet = value),
              ),
              ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                children: [
                  MonthlyBudgetSection(
                    month: _selectedMonth,
                    transactions: monthTransactions,
                  ),
                ],
              ),
              _buildCashFlowTab(
                income: income,
                expense: expense,
                net: net,
                transactionCount: monthTransactions.length,
                trendMonths: trendMonths,
              ),
              _buildAssetsTab(wallets),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownTab({
    required List<Transaction> transactions,
    required List<Wallet> wallets,
    required TransactionType type,
    required bool byWallet,
    required ValueChanged<bool> onDimensionChanged,
  }) {
    final total = transactions.fold<int>(
      0,
      (sum, transaction) => sum + transaction.amount,
    );
    final entries = byWallet
        ? _walletBreakdown(transactions, wallets, type)
        : _categoryBreakdown(transactions, type);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      children: [
        Center(
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Kategori')),
              ButtonSegment(value: true, label: Text('Dompet')),
            ],
            selected: {byWallet},
            onSelectionChanged: (selection) =>
                onDimensionChanged(selection.first),
          ),
        ),
        const SizedBox(height: 14),
        if (entries.isEmpty)
          _EmptyCard(
            icon: type == TransactionType.expense
                ? Icons.pie_chart_outline_rounded
                : Icons.south_west_rounded,
            message: type == TransactionType.expense
                ? 'Belum ada pengeluaran di bulan ini.'
                : 'Belum ada pemasukan di bulan ini.',
          )
        else ...[
          _DonutChart(
            entries: entries,
            centerLabel: type == TransactionType.expense
                ? 'Total pengeluaran'
                : 'Total pemasukan',
            total: total,
          ),
          const SizedBox(height: 10),
          _BreakdownList(entries: entries, total: total),
        ],
      ],
    );
  }

  List<_BreakdownItem> _categoryBreakdown(
    List<Transaction> transactions,
    TransactionType type,
  ) {
    final grouped = <TransactionCategory, List<Transaction>>{};
    for (final transaction in transactions) {
      grouped.putIfAbsent(transaction.category, () => []).add(transaction);
    }
    final sorted = grouped.entries.toList()
      ..sort(
        (a, b) =>
            _transactionTotal(b.value).compareTo(_transactionTotal(a.value)),
      );
    return sorted
        .map((entry) {
          final category = entry.key;
          return _BreakdownItem(
            label: CategoryHelper.title(category),
            amount: _transactionTotal(entry.value),
            color: CategoryHelper.color(category),
            icon: CategoryHelper.icon(category),
            onTap: () {
              if (type == TransactionType.expense) {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => CategoryExpenseDetailPage(
                      category: category,
                      month: _selectedMonth,
                    ),
                  ),
                );
              } else {
                _showTransactionDetails(
                  title: 'Pemasukan · ${CategoryHelper.title(category)}',
                  transactions: entry.value,
                  total: _transactionTotal(entry.value),
                );
              }
            },
          );
        })
        .toList(growable: false);
  }

  List<_BreakdownItem> _walletBreakdown(
    List<Transaction> transactions,
    List<Wallet> wallets,
    TransactionType type,
  ) {
    final walletMap = {for (final wallet in wallets) wallet.id: wallet};
    final grouped = <String, List<Transaction>>{};
    for (final transaction in transactions) {
      final walletId = type == TransactionType.expense
          ? transaction.fromWallet
          : transaction.toWallet;
      grouped.putIfAbsent(walletId ?? '', () => []).add(transaction);
    }
    final sorted = grouped.entries.toList()
      ..sort(
        (a, b) =>
            _transactionTotal(b.value).compareTo(_transactionTotal(a.value)),
      );
    const colors = [
      Color(0xFF3968D6),
      Color(0xFF20A6A6),
      Color(0xFFE89B25),
      Color(0xFF9D41B5),
      Color(0xFFE45F72),
      Color(0xFF687A8C),
    ];
    final items = <_BreakdownItem>[];
    for (var index = 0; index < sorted.length; index++) {
      final entry = sorted[index];
      final walletName =
          walletMap[entry.key]?.name ?? 'Dompet belum ditentukan';
      items.add(
        _BreakdownItem(
          label: walletName,
          amount: _transactionTotal(entry.value),
          color: colors[index % colors.length],
          icon: Icons.account_balance_wallet_rounded,
          onTap: () => _showTransactionDetails(
            title:
                '${type == TransactionType.expense ? 'Pengeluaran' : 'Pemasukan'} · $walletName',
            transactions: entry.value,
            total: _transactionTotal(entry.value),
          ),
        ),
      );
    }
    return items;
  }

  int _transactionTotal(List<Transaction> transactions) =>
      transactions.fold(0, (sum, transaction) => sum + transaction.amount);

  Widget _buildCashFlowTab({
    required int income,
    required int expense,
    required int net,
    required int transactionCount,
    required List<_MonthTrendData> trendMonths,
  }) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        _NetCard(net: net),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SmallStatCard(
                icon: Icons.south_west_rounded,
                title: 'Pemasukan',
                value: FormatterHelper.formatRupiah(income),
                subtitle: 'bulan ini',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SmallStatCard(
                icon: Icons.north_east_rounded,
                title: 'Pengeluaran',
                value: FormatterHelper.formatRupiah(expense),
                subtitle: '$transactionCount transaksi',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SectionTitle(
          title: 'Tren pemasukan',
          subtitle: 'Perbandingan enam bulan terakhir',
        ),
        const SizedBox(height: 12),
        _MonthlyTrend(
          months: trendMonths
              .map(
                (month) => _MonthExpense(
                  month: month.month,
                  amount: month.income,
                  selected: month.selected,
                ),
              )
              .toList(growable: false),
          monthNames: _monthNames,
          color: AppColors.income,
        ),
        const SizedBox(height: 22),
        _SectionTitle(
          title: 'Tren pengeluaran',
          subtitle: 'Perbandingan enam bulan terakhir',
        ),
        const SizedBox(height: 12),
        _MonthlyTrend(
          months: trendMonths
              .map(
                (month) => _MonthExpense(
                  month: month.month,
                  amount: month.expense,
                  selected: month.selected,
                ),
              )
              .toList(growable: false),
          monthNames: _monthNames,
          color: AppColors.expense,
        ),
      ],
    );
  }

  Widget _buildAssetsTab(List<Wallet> wallets) {
    final activeWallets = wallets.where((wallet) => wallet.active).toList()
      ..sort((a, b) => b.balance.compareTo(a.balance));
    final positive = activeWallets
        .where((wallet) => wallet.balance > 0)
        .toList(growable: false);
    final total = positive.fold<int>(0, (sum, wallet) => sum + wallet.balance);
    const colors = [
      Color(0xFF3968D6),
      Color(0xFF20A6A6),
      Color(0xFFE89B25),
      Color(0xFF9D41B5),
      Color(0xFFE45F72),
      Color(0xFF687A8C),
    ];
    final entries = [
      for (var index = 0; index < positive.length; index++)
        _BreakdownItem(
          label: positive.elementAt(index).name,
          amount: positive.elementAt(index).balance,
          color: colors[index % colors.length],
          icon: Icons.account_balance_wallet_rounded,
        ),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        if (entries.isEmpty)
          const _EmptyCard(
            icon: Icons.account_balance_wallet_outlined,
            message: 'Belum ada saldo dompet positif untuk ditampilkan.',
          )
        else ...[
          _DonutChart(
            entries: entries,
            centerLabel: 'Total aset',
            total: total,
          ),
          const SizedBox(height: 10),
          _BreakdownList(entries: entries, total: total),
        ],
        if (activeWallets.any((wallet) => wallet.balance < 0)) ...[
          const SizedBox(height: 18),
          _SectionTitle(
            title: 'Saldo negatif',
            subtitle: 'Dompet berikut memiliki saldo di bawah nol',
          ),
          const SizedBox(height: 10),
          ...activeWallets
              .where((wallet) => wallet.balance < 0)
              .map((wallet) => _NegativeWalletRow(wallet: wallet)),
        ],
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

class _MonthTrendData {
  const _MonthTrendData({
    required this.month,
    required this.income,
    required this.expense,
    required this.selected,
  });

  final DateTime month;
  final int income;
  final int expense;
  final bool selected;
}

class _BreakdownItem {
  const _BreakdownItem({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    this.onTap,
  });

  final String label;
  final int amount;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;
}

class _MonthlyTrend extends StatelessWidget {
  const _MonthlyTrend({
    required this.months,
    required this.monthNames,
    required this.color,
  });

  final List<_MonthExpense> months;
  final List<String> monthNames;
  final Color color;

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
                          color: month.selected ? color : AppColors.muted,
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
                      color: month.selected
                          ? color
                          : color.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    monthNames[month.month.month - 1].substring(0, 3),
                    style: TextStyle(
                      fontSize: 10,
                      color: month.selected ? color : AppColors.muted,
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

class _BreakdownList extends StatelessWidget {
  const _BreakdownList({required this.entries, required this.total});

  final List<_BreakdownItem> entries;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: entries.map((entry) {
          final share = total == 0 ? 0.0 : entry.amount / total;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: entry.onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 13),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: entry.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(entry.icon, color: entry.color, size: 19),
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
                                  entry.label,
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
                              valueColor: AlwaysStoppedAnimation(entry.color),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      FormatterHelper.formatRupiah(entry.amount),
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

class _DonutChart extends StatelessWidget {
  const _DonutChart({
    required this.entries,
    required this.centerLabel,
    required this.total,
  });

  final List<_BreakdownItem> entries;
  final String centerLabel;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          SizedBox.square(
            dimension: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size.square(210),
                  painter: _DonutPainter(entries),
                ),
                SizedBox(
                  width: 112,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        centerLabel,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          FormatterHelper.formatRupiah(total),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.entries);

  final List<_BreakdownItem> entries;

  @override
  void paint(Canvas canvas, Size size) {
    final visible = entries.where((entry) => entry.amount > 0).toList();
    final total = visible.fold<int>(0, (sum, entry) => sum + entry.amount);
    if (total <= 0) return;

    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.shortestSide / 2 - 2,
    );
    var startAngle = -math.pi / 2;
    for (final entry in visible) {
      final sweepAngle = entry.amount / total * math.pi * 2;
      canvas.drawArc(
        rect,
        startAngle,
        math.max(0, sweepAngle - 0.012),
        false,
        Paint()
          ..color = entry.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 46
          ..strokeCap = StrokeCap.butt,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.entries != entries;
}

class _NegativeWalletRow extends StatelessWidget {
  const _NegativeWalletRow({required this.wallet});

  final Wallet wallet;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.line),
    ),
    child: Row(
      children: [
        const Icon(Icons.warning_amber_rounded, color: AppColors.expense),
        const SizedBox(width: 10),
        Expanded(child: Text('${wallet.name} · ${wallet.bank}')),
        Text(
          FormatterHelper.formatRupiah(wallet.balance),
          style: const TextStyle(
            color: AppColors.expense,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
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
