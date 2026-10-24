import 'dart:convert';

import 'package:auto_finance/data/dao/transaction_dao.dart';
import 'package:auto_finance/data/local/database/app_database.dart';
import 'package:auto_finance/domain/entities/transaction.dart' as entity;
import 'package:auto_finance/domain/entities/transaction_categories.dart';
import 'package:auto_finance/domain/entities/transaction_type.dart';

class DataImportSummary {
  final int imported;
  final int skipped;

  const DataImportSummary({required this.imported, required this.skipped});
}

class DataImportService {
  static List<entity.Transaction> parseTransactionsCsv(
    List<int> bytes,
    List<WalletTableData> wallets,
  ) {
    var csvText = utf8.decode(bytes, allowMalformed: false);
    if (csvText.startsWith('\uFEFF')) csvText = csvText.substring(1);
    final rows = _parseCsv(csvText);
    if (rows.isEmpty) throw const FormatException('File CSV kosong.');

    final headers = rows.first;
    const requiredHeaders = [
      'id',
      'tanggal',
      'layanan',
      'tipe',
      'kategori',
      'nominal',
      'dompet_dari',
      'dompet_ke',
      'notifikasi_lengkap',
    ];
    if (headers.length != requiredHeaders.length ||
        !requiredHeaders.every(headers.contains)) {
      throw const FormatException(
        'Kolom tidak cocok. Pilih CSV transaksi hasil ekspor AutoFinance.',
      );
    }
    final columns = {for (var i = 0; i < headers.length; i++) headers[i]: i};
    String value(List<String> row, String key) => row[columns[key]!].trim();
    String? walletId(String name, String bank) {
      if (name.isEmpty) return null;
      final matches = wallets.where(
        (wallet) => wallet.name.trim().toLowerCase() == name.toLowerCase(),
      );
      final bankMatches = matches
          .where((wallet) => wallet.bank.toLowerCase() == bank.toLowerCase())
          .toList();
      if (bankMatches.length == 1) return bankMatches.single.id;
      if (matches.length == 1) return matches.single.id;
      return null;
    }

    final transactions = <entity.Transaction>[];
    for (var rowIndex = 1; rowIndex < rows.length; rowIndex++) {
      final row = rows[rowIndex];
      if (row.every((field) => field.trim().isEmpty)) continue;
      if (row.length != headers.length) {
        throw FormatException(
          'Jumlah kolom baris ${rowIndex + 1} tidak cocok.',
        );
      }
      try {
        final id = value(row, 'id');
        final bank = value(row, 'layanan');
        final fromName = value(row, 'dompet_dari');
        final toName = value(row, 'dompet_ke');
        final type = TransactionType.values.byName(value(row, 'tipe'));
        final category = TransactionCategory.values.byName(
          value(row, 'kategori'),
        );
        final amount = int.parse(value(row, 'nominal'));
        if (id.isEmpty || amount <= 0) {
          throw const FormatException('ID atau nominal tidak valid.');
        }
        transactions.add(
          entity.Transaction(
            id: id,
            bank: bank,
            fromWallet: walletId(fromName, bank),
            toWallet: walletId(toName, bank),
            amount: amount,
            type: type,
            category: category,
            rawText: value(row, 'notifikasi_lengkap'),
            time: DateTime.parse(value(row, 'tanggal')),
          ),
        );
      } catch (error) {
        throw FormatException('Data baris ${rowIndex + 1} tidak valid: $error');
      }
    }
    if (transactions.isEmpty) {
      throw const FormatException('Tidak ada transaksi untuk diimpor.');
    }
    return transactions;
  }

  static Future<DataImportSummary> importTransactions({
    required List<entity.Transaction> transactions,
    required TransactionDao transactionDao,
  }) async {
    var imported = 0;
    for (final transaction in transactions) {
      if (await transactionDao.insert(transaction)) imported++;
    }
    return DataImportSummary(
      imported: imported,
      skipped: transactions.length - imported,
    );
  }

  static List<List<String>> _parseCsv(String input) {
    final rows = <List<String>>[];
    var row = <String>[];
    final field = StringBuffer();
    var quoted = false;
    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      if (quoted) {
        if (char == '"') {
          if (i + 1 < input.length && input[i + 1] == '"') {
            field.write('"');
            i++;
          } else {
            quoted = false;
          }
        } else {
          field.write(char);
        }
      } else if (char == '"' && field.isEmpty) {
        quoted = true;
      } else if (char == ',') {
        row.add(field.toString());
        field.clear();
      } else if (char == '\n' || char == '\r') {
        row.add(field.toString());
        field.clear();
        if (row.any((value) => value.isNotEmpty)) rows.add(row);
        row = <String>[];
        if (char == '\r' && i + 1 < input.length && input[i + 1] == '\n') {
          i++;
        }
      } else {
        field.write(char);
      }
    }
    if (quoted)
      throw const FormatException('CSV memiliki kutip yang belum ditutup.');
    if (field.isNotEmpty || row.isNotEmpty) {
      row.add(field.toString());
      if (row.any((value) => value.isNotEmpty)) rows.add(row);
    }
    return rows;
  }
}
