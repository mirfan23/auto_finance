import 'package:auto_finance/app/theme.dart';
import 'package:auto_finance/domain/entities/transaction.dart';
import 'package:auto_finance/domain/entities/transaction_categories.dart';
import 'package:auto_finance/domain/entities/transaction_type.dart';
import 'package:auto_finance/domain/entities/wallet.dart';
import 'package:auto_finance/features/transaction/providers/transaction_provider.dart';
import 'package:auto_finance/core/helpers/category_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class EditTransactionSheet extends ConsumerStatefulWidget {
  const EditTransactionSheet({
    super.key,
    required this.transaction,
    required this.wallets,
  });

  final Transaction transaction;
  final List<Wallet> wallets;

  @override
  ConsumerState<EditTransactionSheet> createState() =>
      _EditTransactionSheetState();
}

class _EditTransactionSheetState extends ConsumerState<EditTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late TransactionType _type;
  late TransactionCategory _category;
  String? _fromWalletId;
  String? _toWalletId;
  late DateTime _time;
  bool _saving = false;

  List<TransactionCategory> get _categories => TransactionCategory.values
      .where((category) => category != TransactionCategory.transfer)
      .toList();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.transaction.amount.toString(),
    );
    _type = widget.transaction.type;
    _category = widget.transaction.category;
    _time = widget.transaction.time;
    final walletIds = widget.wallets.map((wallet) => wallet.id).toSet();
    _fromWalletId = walletIds.contains(widget.transaction.fromWallet)
        ? widget.transaction.fromWallet
        : null;
    _toWalletId = walletIds.contains(widget.transaction.toWallet)
        ? widget.transaction.toWallet
        : null;
    if (_type == TransactionType.transfer) {
      _category = TransactionCategory.transfer;
    } else if (_category == TransactionCategory.transfer) {
      _category = TransactionCategory.other;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _changeType(TransactionType? type) {
    if (type == null) return;
    setState(() {
      _type = type;
      if (type == TransactionType.transfer) {
        _category = TransactionCategory.transfer;
      } else if (_category == TransactionCategory.transfer) {
        _category = TransactionCategory.other;
      }
    });
  }

  Future<void> _chooseDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _time,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _time = DateTime(
        selected.year,
        selected.month,
        selected.day,
        _time.hour,
        _time.minute,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = int.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return;
    if (_type == TransactionType.transfer && _fromWalletId == _toWalletId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih dua dompet yang berbeda.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final updated = widget.transaction.copyWith(
        amount: amount,
        type: _type,
        category: _category,
        fromWallet: _type == TransactionType.income ? null : _fromWalletId,
        toWallet: _type == TransactionType.expense ? null : _toWalletId,
        time: _time,
      );
      await ref.read(transactionDaoProvider).updateTransaction(updated);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transaksi belum bisa disimpan: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.9,
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomInset + 20),
      decoration: const BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Edit transaksi',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.only(top: 8, bottom: 20),
                  children: [
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Nominal',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final amount = int.tryParse(value?.trim() ?? '');
                        return amount == null || amount <= 0
                            ? 'Masukkan nominal yang valid.'
                            : null;
                      },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<TransactionType>(
                      initialValue: _type,
                      decoration: const InputDecoration(
                        labelText: 'Tipe transaksi',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: TransactionType.income,
                          child: Text('Pemasukan'),
                        ),
                        DropdownMenuItem(
                          value: TransactionType.expense,
                          child: Text('Pengeluaran'),
                        ),
                        DropdownMenuItem(
                          value: TransactionType.transfer,
                          child: Text('Transfer'),
                        ),
                      ],
                      onChanged: _changeType,
                    ),
                    const SizedBox(height: 14),
                    if (_type != TransactionType.transfer)
                      DropdownButtonFormField<TransactionCategory>(
                        initialValue: _category,
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                          border: OutlineInputBorder(),
                        ),
                        items: _categories
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(CategoryHelper.title(category)),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _category = value);
                          }
                        },
                      )
                    else
                      InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(CategoryHelper.title(_category)),
                      ),
                    const SizedBox(height: 14),
                    if (_type != TransactionType.income)
                      _walletDropdown(
                        label: _type == TransactionType.transfer
                            ? 'Dompet asal'
                            : 'Dompet sumber',
                        value: _fromWalletId,
                        onChanged: (value) =>
                            setState(() => _fromWalletId = value),
                      ),
                    if (_type == TransactionType.transfer)
                      const SizedBox(height: 14),
                    if (_type != TransactionType.expense)
                      _walletDropdown(
                        label: _type == TransactionType.transfer
                            ? 'Dompet tujuan'
                            : 'Dompet tujuan pemasukan',
                        value: _toWalletId,
                        onChanged: (value) =>
                            setState(() => _toWalletId = value),
                      ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: _chooseDate,
                      icon: const Icon(Icons.calendar_today_rounded),
                      label: Text(
                        DateFormat('EEEE, d MMMM yyyy', 'id').format(_time),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Teks notifikasi asli tetap disimpan sebagai catatan.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan perubahan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _walletDropdown({
    required String label,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: widget.wallets
          .map(
            (wallet) => DropdownMenuItem(
              value: wallet.id,
              child: Text(wallet.name, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (selected) => selected == null ? 'Pilih dompet.' : null,
    );
  }
}
