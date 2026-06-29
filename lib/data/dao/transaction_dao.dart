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
    if (await exists(trx.id)) {
      debugPrint("TRANSACTION DUPLICATE SKIPPED");
      return;
    }

    await db
        .into(db.transactionsTable)
        .insert(
          TransactionsTableCompanion.insert(
            id: trx.id,
            bank: trx.bank,
            fromWallet: Value(trx.fromWallet),
            toWallet: Value(trx.toWallet),
            amount: trx.amount,
            type: trx.type.name,
            category: trx.category.name,
            rawText: trx.rawText,
            time: trx.time,
          ),
        );
  }

  Stream<List<TransactionsTableData>> watchAll() {
    return (db.select(db.transactionsTable)..orderBy([(t) => OrderingTerm.desc(t.time)])).watch();
  }

  Future<List<TransactionsTableData>> getAll() {
    return db.select(db.transactionsTable).get();
  }

  Future<bool> exists(String id) async {
    final result = await (db.select(db.transactionsTable)..where((t) => t.id.equals(id))).get();

    return result.isNotEmpty;
  }
}
