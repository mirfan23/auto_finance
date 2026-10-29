import 'package:auto_finance/app/theme.dart';
import 'package:auto_finance/core/helpers/category_helper.dart';
import 'package:auto_finance/core/helpers/merchant_name_helper.dart';
import 'package:auto_finance/features/transaction/domain/entities/transaction.dart';
import 'package:auto_finance/features/transaction/domain/entities/transaction_categories.dart';
import 'package:auto_finance/features/transaction/domain/entities/transaction_type.dart';
import 'package:auto_finance/features/wallet/domain/entities/wallet.dart';
import 'package:auto_finance/features/transaction/application/providers/transaction_provider.dart';
import 'package:auto_finance/features/wallet/application/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fx_helper/formatter_helper.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class ManualTransactionPage extends ConsumerStatefulWidget {
  const ManualTransactionPage({super.key});

  @override
  ConsumerState<ManualTransactionPage> createState() =>
      _ManualTransactionPageState();
}

class _ManualTransactionPageState extends ConsumerState<ManualTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  TransactionType _type = TransactionType.expense;
  TransactionCategory _category = TransactionCategory.other;
  String? _walletId;
  DateTime _time = DateTime.now();
  bool _saving = false;

  List<TransactionCategory> get _categories => switch (_type) {
    TransactionType.expense => const [
      TransactionCategory.food,
      TransactionCategory.laundry,
      TransactionCategory.electricity,
      TransactionCategory.shopping,
      TransactionCategory.transport,
      TransactionCategory.bills,
      TransactionCategory.entertainment,
      TransactionCategory.health,
      TransactionCategory.education,
      TransactionCategory.topup,
      TransactionCategory.other,
    ],
    TransactionType.income => const [
      TransactionCategory.salary,
      TransactionCategory.investment,
      TransactionCategory.cashback,
      TransactionCategory.gift,
      TransactionCategory.other,
    ],
    TransactionType.transfer => const [],
  };

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _setType(TransactionType type) {
    setState(() {
      _type = type;
      if (!_categories.contains(_category)) {
        _category = _categories.first;
      }
    });
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _time,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    setState(() {
      _time = DateTime(
        date.year,
        date.month,
        date.day,
        _time.hour,
        _time.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_time),
    );
    if (time == null || !mounted) return;
    setState(() {
      _time = DateTime(
        _time.year,
        _time.month,
        _time.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<bool?> _confirmPossibleDuplicate({
    required Transaction transaction,
    required Wallet wallet,
    required String description,
  }) async {
    final normalizedDescription = MerchantNameHelper.normalize(description);
    if (normalizedDescription.isEmpty) return false;

    final existing = await ref.read(transactionDaoProvider).getAll();
    final possible = existing.where((row) {
      if (row.amount != transaction.amount ||
          row.type != transaction.type.name ||
          row.time.year != transaction.time.year ||
          row.time.month != transaction.time.month ||
          row.time.day != transaction.time.day) {
        return false;
      }
      final sameWallet = transaction.type == TransactionType.expense
          ? row.fromWallet == wallet.id
          : row.toWallet == wallet.id;
      if (!sameWallet ||
          row.time.difference(transaction.time).inSeconds.abs() > 300) {
        return false;
      }
      final storedText = MerchantNameHelper.normalize(row.rawText);
      final storedMerchant = MerchantNameHelper.suggest(row.rawText);
      return storedText.contains(normalizedDescription) ||
          (storedMerchant != null &&
              MerchantNameHelper.normalize(storedMerchant) ==
                  normalizedDescription);
    }).toList();
    if (possible.isEmpty) return false;
    if (!mounted) return null;

    final match = possible.first;
    final sign = transaction.type == TransactionType.expense ? '−' : '+';
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mungkin transaksi duplikat'),
        content: Text(
          'Ada transaksi ${FormatterHelper.formatRupiah(match.amount)} '
          'di ${wallet.name} pada waktu yang berdekatan. Tetap simpan '
          '$sign${FormatterHelper.formatRupiah(transaction.amount)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Periksa dulu'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tetap simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _save(List<Wallet> wallets) async {
    if (!_formKey.currentState!.validate()) return;
    final matchingWallets = wallets
        .where((item) => item.id == _walletId)
        .toList();
    final wallet = matchingWallets.isEmpty ? null : matchingWallets.first;
    if (wallet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih dompet terlebih dahulu.')),
      );
      return;
    }

    final amount = int.tryParse(
      _amountController.text.replaceAll('.', '').trim(),
    );
    if (amount == null || amount <= 0) return;
    final description = _descriptionController.text.trim();
    final transaction = Transaction(
      id: const Uuid().v4(),
      bank: wallet.bank,
      fromWallet: _type == TransactionType.expense ? wallet.id : null,
      toWallet: _type == TransactionType.income ? wallet.id : null,
      amount: amount,
      type: _type,
      category: _category,
      rawText: '$description (input manual)',
      time: _time,
    );

    final allowExactDuplicate = await _confirmPossibleDuplicate(
      transaction: transaction,
      wallet: wallet,
      description: description,
    );
    if (allowExactDuplicate == null || !mounted) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(saveTransactionProvider)
          .saveSingle(transaction, allowExactDuplicate: allowExactDuplicate);
      if (!mounted) return;
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil disimpan.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaksi belum bisa disimpan: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(walletStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah transaksi')),
      body: walletsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Dompet belum bisa dimuat: $error')),
        data: (wallets) {
          final availableWallets = wallets
              .where((wallet) => wallet.active)
              .toList();
          if (_walletId == null && availableWallets.isNotEmpty) {
            _walletId = availableWallets.first.id;
          }
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text('Pengeluaran'),
                      icon: Icon(Icons.north_east_rounded),
                    ),
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text('Pemasukan'),
                      icon: Icon(Icons.south_west_rounded),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (selection) => _setType(selection.first),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    const _ThousandsSeparatorFormatter(),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Nominal',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final amount = int.tryParse(
                      (value ?? '').replaceAll('.', ''),
                    );
                    return amount == null || amount <= 0
                        ? 'Masukkan nominal yang valid.'
                        : null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Nama transaksi',
                    hintText: 'Contoh: ShopeeFood, Laundry, Gaji',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Masukkan nama transaksi.'
                      : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<TransactionCategory>(
                  initialValue: _categories.contains(_category)
                      ? _category
                      : _categories.first,
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
                    if (value != null) setState(() => _category = value);
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue:
                      availableWallets.any((wallet) => wallet.id == _walletId)
                      ? _walletId
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Dompet',
                    border: OutlineInputBorder(),
                  ),
                  items: availableWallets
                      .map(
                        (wallet) => DropdownMenuItem(
                          value: wallet.id,
                          child: Text('${wallet.name} • ${wallet.bank}'),
                        ),
                      )
                      .toList(),
                  onChanged: availableWallets.isEmpty
                      ? null
                      : (value) => setState(() => _walletId = value),
                  validator: (value) => value == null
                      ? 'Tambahkan dompet terlebih dahulu.'
                      : null,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_today_rounded),
                        label: Text(
                          DateFormat('d MMM yyyy', 'id').format(_time),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.access_time_rounded),
                      label: Text(DateFormat('HH:mm').format(_time)),
                    ),
                  ],
                ),
                if (availableWallets.isEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Buat dompet terlebih dahulu sebelum mencatat transaksi.',
                    style: TextStyle(color: AppColors.expense),
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  'Saldo dompet akan diperbarui saat transaksi disimpan.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: _saving
                ? null
                : () => _save(
                    walletsAsync.valueOrNull
                            ?.where((wallet) => wallet.active)
                            .toList() ??
                        const [],
                  ),
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(_saving ? 'Menyimpan…' : 'Simpan transaksi'),
          ),
        ),
      ),
    );
  }
}

class _ThousandsSeparatorFormatter extends TextInputFormatter {
  const _ThousandsSeparatorFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final formatted = digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
