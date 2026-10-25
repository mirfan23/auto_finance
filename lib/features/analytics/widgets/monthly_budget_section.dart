import 'package:auto_finance/app/theme.dart';
import 'package:auto_finance/core/helpers/category_helper.dart';
import 'package:auto_finance/domain/entities/transaction.dart';
import 'package:auto_finance/domain/entities/transaction_categories.dart';
import 'package:auto_finance/domain/entities/transaction_type.dart';
import 'package:auto_finance/features/analytics/pages/category_expense_detail_page.dart';
import 'package:auto_finance/features/transaction/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fx_helper/formatter_helper.dart';
import 'package:intl/intl.dart';

class MonthlyBudgetSection extends ConsumerWidget {
  const MonthlyBudgetSection({
    super.key,
    required this.month,
    required this.transactions,
  });

  final DateTime month;
  final List<Transaction> transactions;

  static final _budgetableCategories = TransactionCategory.values
      .where(
        (category) =>
            category != TransactionCategory.transfer &&
            category != TransactionCategory.salary &&
            category != TransactionCategory.cashback,
      )
      .toList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(monthlyBudgetStreamProvider);
    final expenseByCategory = <TransactionCategory, int>{};
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        expenseByCategory.update(
          transaction.category,
          (amount) => amount + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }

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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Anggaran bulanan',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      DateFormat('MMMM yyyy', 'id').format(month),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => _addBudget(context, ref),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Tambah'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          budgetsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text('Anggaran belum bisa dimuat: $error'),
            data: (budgets) {
              final sorted = [...budgets]
                ..sort((a, b) => a.category.compareTo(b.category));
              if (sorted.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Text(
                    'Atur batas pengeluaran untuk kategori yang ingin dipantau.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }

              final totalBudget = sorted.fold<int>(
                0,
                (total, budget) => total + budget.monthlyLimit,
              );
              final totalSpent = sorted.fold<int>(0, (total, budget) {
                final category = _categoryFromName(budget.category);
                return total +
                    (category == null ? 0 : expenseByCategory[category] ?? 0);
              });

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      '${FormatterHelper.formatRupiah(totalSpent)} dari ${FormatterHelper.formatRupiah(totalBudget)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  ...sorted.map((budget) {
                    final category = _categoryFromName(budget.category);
                    if (category == null) return const SizedBox.shrink();
                    final spent = expenseByCategory[category] ?? 0;
                    return _BudgetRow(
                      category: category,
                      spent: spent,
                      monthlyLimit: budget.monthlyLimit,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => CategoryExpenseDetailPage(
                            category: category,
                            month: month,
                          ),
                        ),
                      ),
                      onEdit: () => _editBudget(
                        context,
                        ref,
                        category,
                        budget.monthlyLimit,
                      ),
                      onDelete: () => _deleteBudget(context, ref, category),
                    );
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  TransactionCategory? _categoryFromName(String name) {
    for (final category in TransactionCategory.values) {
      if (category.name == name) return category;
    }
    return null;
  }

  Future<void> _addBudget(BuildContext context, WidgetRef ref) async {
    final existing = await ref.read(monthlyBudgetDaoProvider).getAll();
    if (!context.mounted) return;
    final configured = existing.map((budget) => budget.category).toSet();
    final available = _budgetableCategories
        .where((category) => !configured.contains(category.name))
        .toList();
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua kategori sudah memiliki anggaran.'),
        ),
      );
      return;
    }

    final draft = await showModalBottomSheet<_BudgetDraft>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => _AddBudgetSheet(categories: available),
    );
    if (draft == null || !context.mounted) return;
    await ref
        .read(monthlyBudgetDaoProvider)
        .save(category: draft.category.name, monthlyLimit: draft.monthlyLimit);
  }

  Future<void> _editBudget(
    BuildContext context,
    WidgetRef ref,
    TransactionCategory category,
    int? currentLimit,
  ) async {
    final controller = TextEditingController(
      text: currentLimit == null
          ? ''
          : FormatterHelper.formatRupiah(currentLimit),
    );
    final formKey = GlobalKey<FormState>();
    final amount = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Anggaran ${CategoryHelper.title(category)}'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FormatterHelper.currencyInputFormatter],
            decoration: const InputDecoration(labelText: 'Batas per bulan'),
            validator: (value) {
              final parsed = FormatterHelper.parseCurrency(value ?? '');
              if (parsed == null || parsed <= 0) {
                return 'Masukkan nominal yang lebih dari nol.';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() != true) return;
              Navigator.pop(
                context,
                FormatterHelper.parseCurrency(controller.text),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (amount == null || !context.mounted) return;
    await ref
        .read(monthlyBudgetDaoProvider)
        .save(category: category.name, monthlyLimit: amount);
  }

  Future<void> _deleteBudget(
    BuildContext context,
    WidgetRef ref,
    TransactionCategory category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus anggaran?'),
        content: Text(
          'Anggaran ${CategoryHelper.title(category)} akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(monthlyBudgetDaoProvider).delete(category.name);
    }
  }
}

class _BudgetDraft {
  const _BudgetDraft({required this.category, required this.monthlyLimit});

  final TransactionCategory category;
  final int monthlyLimit;
}

/// Uses one modal route for both steps so closing the category picker and
/// immediately opening a second route cannot leave Flutter routes overlapping.
class _AddBudgetSheet extends StatefulWidget {
  const _AddBudgetSheet({required this.categories});

  final List<TransactionCategory> categories;

  @override
  State<_AddBudgetSheet> createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends State<_AddBudgetSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  TransactionCategory? _category;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final category = _category;
    if (category == null) return;
    Navigator.of(context).pop(
      _BudgetDraft(
        category: category,
        monthlyLimit: FormatterHelper.parseCurrency(_amountController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = _category;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: category == null
            ? _categoryPicker(context)
            : _amountEntry(context, category),
      ),
    );
  }

  Widget _categoryPicker(BuildContext context) {
    return ListView(
      key: const ValueKey('category-picker'),
      shrinkWrap: true,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Text(
            'Pilih kategori',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ...widget.categories.map(
          (category) => ListTile(
            leading: Icon(
              CategoryHelper.icon(category),
              color: CategoryHelper.color(category),
            ),
            title: Text(CategoryHelper.title(category)),
            onTap: () => setState(() => _category = category),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _amountEntry(BuildContext context, TransactionCategory category) {
    return SingleChildScrollView(
      key: const ValueKey('budget-amount'),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => setState(() => _category = null),
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: 'Pilih kategori lain',
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Anggaran ${CategoryHelper.title(category)}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Tutup',
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FormatterHelper.currencyInputFormatter],
              decoration: const InputDecoration(
                labelText: 'Batas per bulan',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  FormatterHelper.parseCurrency(value ?? '') <= 0
                  ? 'Masukkan nominal yang lebih dari nol.'
                  : null,
              onFieldSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _save,
              child: const Text('Simpan anggaran'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({
    required this.category,
    required this.spent,
    required this.monthlyLimit,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final TransactionCategory category;
  final int spent;
  final int monthlyLimit;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ratio = spent / monthlyLimit;
    final overLimit = ratio > 1;
    final reachedLimit = ratio >= 1;
    final nearLimit = ratio >= 0.8;
    final statusColor = reachedLimit
        ? AppColors.expense
        : nearLimit
        ? Colors.orange.shade800
        : AppColors.forest;
    final statusLabel = overLimit
        ? 'Melebihi ${FormatterHelper.formatRupiah(spent - monthlyLimit)}'
        : reachedLimit
        ? 'Batas tercapai'
        : nearLimit
        ? 'Mendekati batas'
        : 'Sisa ${FormatterHelper.formatRupiah(monthlyLimit - spent)}';

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: CategoryHelper.color(
                      category,
                    ).withValues(alpha: 0.12),
                    child: Icon(
                      CategoryHelper.icon(category),
                      size: 17,
                      color: CategoryHelper.color(category),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      CategoryHelper.title(category),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Text(
                    FormatterHelper.formatRupiah(spent),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Kelola anggaran',
                    onSelected: (value) {
                      if (value == 'delete') onDelete();
                      if (value == 'edit') onEdit();
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Ubah batas')),
                      PopupMenuItem(value: 'delete', child: Text('Hapus')),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 44, top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: ratio.clamp(0.0, 1.0).toDouble(),
                        minHeight: 7,
                        backgroundColor: AppColors.line,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            statusLabel,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: statusColor),
                          ),
                        ),
                        Text(
                          'Batas ${FormatterHelper.formatRupiah(monthlyLimit)}',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
