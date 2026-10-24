import 'package:auto_finance/app/theme.dart';
import 'package:auto_finance/core/helpers/bank_helper.dart';
import 'package:auto_finance/core/helpers/category_helper.dart';
import 'package:auto_finance/core/providers/money_visibility_provider.dart';
import 'package:auto_finance/domain/entities/transaction.dart';
import 'package:auto_finance/domain/entities/transaction_type.dart';
import 'package:auto_finance/domain/entities/wallet.dart';
import 'package:auto_finance/features/transaction/providers/transaction_provider.dart';
import 'package:auto_finance/features/transaction/widgets/month_filter_bar.dart';
import 'package:auto_finance/features/wallet/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fx_helper/formatter_helper.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

enum _WalletTransactionFilter { all, income, expense }

class WalletDetailPage extends ConsumerStatefulWidget {
  const WalletDetailPage({super.key, required this.walletId});

  final String walletId;

  @override
  ConsumerState<WalletDetailPage> createState() => _WalletDetailPageState();
}

class _WalletDetailPageState extends ConsumerState<WalletDetailPage> {
  _WalletTransactionFilter _filter = _WalletTransactionFilter.all;
  DateTime? _selectedMonth;

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletStreamProvider);
    final transactions = ref.watch(transactionStreamProvider);

    return wallets.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.forest)),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Detail dompet')),
        body: Center(child: Text('Dompet belum bisa dimuat.\n$error')),
      ),
      data: (walletList) {
        Wallet? wallet;
        for (final item in walletList) {
          if (item.id == widget.walletId) {
            wallet = item;
            break;
          }
        }
        if (wallet == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail dompet')),
            body: const Center(child: Text('Dompet tidak ditemukan.')),
          );
        }
        final selectedWallet = wallet!;

        return Scaffold(
          appBar: AppBar(title: Text(selectedWallet.name)),
          body: transactions.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.forest),
            ),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Transaksi belum bisa dimuat.\n$error'),
              ),
            ),
            data: (allTransactions) =>
                _buildContent(selectedWallet, allTransactions),
          ),
        );
      },
    );
  }

  Widget _buildContent(Wallet wallet, List<Transaction> allTransactions) {
    final related = allTransactions.where((transaction) {
      return transaction.fromWallet == wallet.id ||
          transaction.toWallet == wallet.id;
    }).toList()..sort((a, b) => b.time.compareTo(a.time));

    final monthFiltered = _selectedMonth == null
        ? related
        : related.where((transaction) {
            return transaction.time.year == _selectedMonth!.year &&
                transaction.time.month == _selectedMonth!.month;
          }).toList();

    final shown = switch (_filter) {
      _WalletTransactionFilter.all => monthFiltered,
      _WalletTransactionFilter.income =>
        monthFiltered
            .where(
              (transaction) =>
                  transaction.type == TransactionType.income &&
                  transaction.toWallet == wallet.id,
            )
            .toList(),
      _WalletTransactionFilter.expense =>
        monthFiltered
            .where(
              (transaction) =>
                  transaction.type == TransactionType.expense &&
                  transaction.fromWallet == wallet.id,
            )
            .toList(),
    };

    final hidden = ref.watch(hideMoneyValuesProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.forest, AppColors.forestDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundColor: Colors.white.withValues(alpha: 0.14),
                  child: Icon(
                    BankHelper.icon(wallet.bank),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        BankHelper.title(wallet.bank),
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hidden
                            ? '••••••••'
                            : FormatterHelper.formatRupiah(wallet.balance),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      ref.read(hideMoneyValuesProvider.notifier).toggle(),
                  color: Colors.white70,
                  tooltip: hidden ? 'Tampilkan saldo' : 'Sembunyikan saldo',
                  icon: Icon(
                    hidden
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: MonthFilterBar(
            selectedMonth: _selectedMonth,
            onChanged: (month) => setState(() => _selectedMonth = month),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SegmentedButton<_WalletTransactionFilter>(
            segments: const [
              ButtonSegment(
                value: _WalletTransactionFilter.all,
                label: Text('Semua'),
              ),
              ButtonSegment(
                value: _WalletTransactionFilter.income,
                label: Text('Pemasukan'),
              ),
              ButtonSegment(
                value: _WalletTransactionFilter.expense,
                label: Text('Pengeluaran'),
              ),
            ],
            selected: {_filter},
            onSelectionChanged: (selection) =>
                setState(() => _filter = selection.first),
            showSelectedIcon: false,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Transaksi dompet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                '${shown.length} transaksi',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Expanded(
          child: shown.isEmpty
              ? const _EmptyWalletTransactions()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  itemCount: shown.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 2),
                  itemBuilder: (context, index) => _WalletTransactionCard(
                    transaction: shown[index],
                    walletId: wallet.id,
                  ),
                ),
        ),
      ],
    );
  }
}

class _WalletTransactionCard extends StatelessWidget {
  const _WalletTransactionCard({
    required this.transaction,
    required this.walletId,
  });

  final Transaction transaction;
  final String walletId;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final isExpense = transaction.type == TransactionType.expense;
    final isTransferIn =
        transaction.type == TransactionType.transfer &&
        transaction.toWallet == walletId;
    final color = isIncome || isTransferIn
        ? AppColors.income
        : isExpense
        ? AppColors.expense
        : AppColors.muted;
    final amountPrefix = isIncome || isTransferIn
        ? '+'
        : isExpense || transaction.fromWallet == walletId
        ? '−'
        : '';
    final typeLabel = isIncome
        ? 'Pemasukan'
        : isExpense
        ? 'Pengeluaran'
        : isTransferIn
        ? 'Transfer masuk'
        : 'Transfer keluar';
    final rawText = transaction.rawText.trim();

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/transaction/${transaction.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: CategoryHelper.color(
                  transaction.category,
                ).withValues(alpha: 0.12),
                child: Icon(
                  CategoryHelper.icon(transaction.category),
                  size: 18,
                  color: CategoryHelper.color(transaction.category),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      BankHelper.title(transaction.bank),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rawText.isEmpty ? typeLabel : rawText,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.muted,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${CategoryHelper.title(transaction.category)} · $typeLabel · ${DateFormat('d MMM yyyy, HH:mm', 'id').format(transaction.time)}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$amountPrefix${FormatterHelper.formatRupiah(transaction.amount)}',
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyWalletTransactions extends StatelessWidget {
  const _EmptyWalletTransactions();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 34,
            color: AppColors.muted,
          ),
          const SizedBox(height: 10),
          Text(
            'Belum ada transaksi pada filter ini.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    ),
  );
}
