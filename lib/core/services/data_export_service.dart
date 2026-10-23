import 'dart:io';

import 'package:auto_finance/data/local/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class DataExportService {
  static Future<void> share({
    required BuildContext context,
    required List<TransactionsTableData> transactions,
    required List<WalletTableData> wallets,
  }) async {
    final box = context.findRenderObject() as RenderBox?;
    final shareOrigin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    final directory = await getTemporaryDirectory();
    final stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final walletNames = {for (final wallet in wallets) wallet.id: wallet.name};
    final transactionFile = File(
      '${directory.path}/auto_finance_transaksi_$stamp.csv',
    );
    final walletFile = File('${directory.path}/auto_finance_dompet_$stamp.csv');

    await transactionFile.writeAsString(
      '\uFEFF${_csv([
        ['id', 'tanggal', 'layanan', 'tipe', 'kategori', 'nominal', 'dompet_dari', 'dompet_ke', 'notifikasi_lengkap'],
        for (final row in transactions) [row.id, row.time.toIso8601String(), row.bank, row.type, row.category, row.amount.toString(), walletNames[row.fromWallet] ?? '', walletNames[row.toWallet] ?? '', row.rawText],
      ])}',
      flush: true,
    );
    await walletFile.writeAsString(
      '\uFEFF${_csv([
        ['id', 'nama', 'layanan', 'saldo', 'aktif'],
        for (final row in wallets) [row.id, row.name, row.bank, row.balance.toString(), row.active ? 'ya' : 'tidak'],
      ])}',
      flush: true,
    );

    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile(transactionFile.path, mimeType: 'text/csv'),
          XFile(walletFile.path, mimeType: 'text/csv'),
        ],
        title: 'Ekspor data Auto Finance',
        text: 'Salinan transaksi dan dompet Auto Finance dalam format CSV.',
        sharePositionOrigin: shareOrigin,
      ),
    );
  }

  static String _csv(List<List<String>> rows) => rows
      .map(
        (row) =>
            row.map((value) => '"${value.replaceAll('"', '""')}"').join(','),
      )
      .join('\r\n');
}
