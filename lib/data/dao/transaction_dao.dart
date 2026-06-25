import 'dart:convert';

import 'package:auto_finance/data/local/database/app_database.dart';
import 'package:auto_finance/domain/entities/transaction.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

class TransactionDao {
  final AppDatabase db;

  TransactionDao(this.db);

  Future<void> insert(Transaction trx) async {
    final fingerprint = md5
        .convert(
          utf8.encode(
            '${trx.bank}'
            '${trx.amount}'
            '${trx.type}'
            '${trx.rawText}',
          ),
        )
        .toString();

    if (await exists(fingerprint)) {
      debugPrint("TRANSACTION DUPLICATE SKIPPED");
      return;
    }

    await db
        .into(db.transactionsTable)
        .insert(
          TransactionsTableCompanion.insert(
            bank: trx.bank,
            amount: trx.amount,
            type: trx.type,
            category: trx.category.name,
            rawText: trx.rawText,
            time: trx.time,
            fingerprint: fingerprint,
          ),
        );
  }

  Stream<List<TransactionsTableData>> watchAll() {
    return (db.select(db.transactionsTable)..orderBy([(t) => OrderingTerm.desc(t.time)])).watch();
  }

  Future<List<TransactionsTableData>> getAll() {
    return db.select(db.transactionsTable).get();
  }

  Future<bool> exists(String fingerprint) async {
    final result = await (db.select(db.transactionsTable)..where((t) => t.fingerprint.equals(fingerprint))).get();

    return result.isNotEmpty;
  }
}
