import 'package:auto_finance/features/wallet/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fx_helper/formatter_helper.dart';

class AddWalletDialog extends ConsumerStatefulWidget {
  const AddWalletDialog({super.key});

  @override
  ConsumerState<AddWalletDialog> createState() => _AddWalletDialogState();
}

class _AddWalletDialogState extends ConsumerState<AddWalletDialog> {
  final nameController = TextEditingController();
  final balanceController = TextEditingController();

  String selectedBank = "BCA";

  final banks = const ["BCA", "Jago", "GoPay", "ShopeePay"];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Tambah Wallet"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Nama Wallet"),
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: selectedBank,
            items: banks.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                selectedBank = v;
              });
            },
          ),
          const SizedBox(height: 16),

          TextField(
            controller: balanceController,
            keyboardType: TextInputType.number,
            inputFormatters: [FormatterHelper.currencyInputFormatter],
            decoration: const InputDecoration(labelText: "Saldo Awal"),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
        FilledButton(
          onPressed: () async {
            await ref
                .read(createWalletProvider)
                .call(
                  name: nameController.text,
                  bank: selectedBank,
                  balance: FormatterHelper.parseCurrency(balanceController.text),
                );

            if (context.mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text("Simpan"),
        ),
      ],
    );
  }
}
