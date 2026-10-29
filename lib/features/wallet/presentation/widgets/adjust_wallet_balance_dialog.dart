import 'package:auto_finance/app/theme.dart';
import 'package:auto_finance/features/wallet/domain/entities/wallet.dart';
import 'package:auto_finance/features/wallet/application/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fx_helper/formatter_helper.dart';

class AdjustWalletBalanceDialog extends ConsumerStatefulWidget {
  const AdjustWalletBalanceDialog({super.key, required this.wallet});

  final Wallet wallet;

  @override
  ConsumerState<AdjustWalletBalanceDialog> createState() =>
      _AdjustWalletBalanceDialogState();
}

class _AdjustWalletBalanceDialogState
    extends ConsumerState<AdjustWalletBalanceDialog> {
  late final TextEditingController _balanceController;
  final _noteController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _balanceController = TextEditingController(
      text: widget.wallet.balance.toString(),
    );
  }

  @override
  void dispose() {
    _balanceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Sesuaikan saldo ${widget.wallet.name}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saldo di aplikasi saat ini: ${FormatterHelper.formatRupiah(widget.wallet.balance)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _balanceController,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                FormatterHelper.currencyInputFormatter,
              ],
              decoration: const InputDecoration(
                labelText: 'Saldo sebenarnya',
                prefixText: 'Rp ',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLength: 120,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                hintText: 'Contoh: penyesuaian saldo awal',
                prefixIcon: Icon(Icons.notes_rounded),
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.mint.withValues(alpha: .65),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Transaksi tetap utuh. Perubahan saldo ini akan tersimpan di riwayat penyesuaian.',
                style: TextStyle(color: AppColors.forestDark, height: 1.4),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Menyimpan…' : 'Simpan saldo'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final raw = _balanceController.text.trim();
    if (raw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan saldo sebenarnya.')),
      );
      return;
    }

    final newBalance = FormatterHelper.parseCurrency(raw);
    setState(() => _saving = true);
    try {
      final changed = await ref
          .read(walletDaoProvider)
          .adjustBalance(
            walletId: widget.wallet.id,
            walletName: widget.wallet.name,
            newBalance: newBalance,
            note: _noteController.text,
          );
      if (mounted) Navigator.pop(context, changed);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saldo belum berhasil disesuaikan.')),
      );
    }
  }
}
