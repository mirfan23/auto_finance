// import 'package:auto_finance/data/local/database/app_database.dart';
// import 'package:auto_finance/domain/entities/transaction.dart';
// import 'package:drift/drift.dart';
// import 'package:flutter/foundation.dart';

// class TransactionDao {
//   final AppDatabase db;

//   TransactionDao(this.db);

//   Future<void> insert(Transaction trx) async {
//     if (await exists(trx.id)) {
//       debugPrint("TRANSACTION DUPLICATE SKIPPED");
//       return;
//     }

//     await db
//         .into(db.transactionsTable)
//         .insert(
//           TransactionsTableCompanion.insert(
//             id: trx.id,
//             bank: trx.bank,
//             fromWallet: Value(trx.fromWallet),
//             toWallet: Value(trx.toWallet),
//             amount: trx.amount,
//             type: trx.type.name,
//             category: trx.category.name,
//             rawText: trx.rawText,
//             time: trx.time,
//           ),
//         );
//   }

//   Stream<List<TransactionsTableData>> watchAll() {
//     return (db.select(db.transactionsTable)..orderBy([(t) => OrderingTerm.desc(t.time)])).watch();
//   }

//   Future<List<TransactionsTableData>> getAll() {
//     return db.select(db.transactionsTable).get();
//   }

//   Future<bool> exists(String id) async {
//     final result = await (db.select(db.transactionsTable)..where((t) => t.id.equals(id))).get();

//     return result.isNotEmpty;
//   }
// }

import 'package:auto_finance/data/local/database/app_database.dart';
import 'package:auto_finance/domain/entities/transaction.dart';
import 'package:auto_finance/domain/entities/transaction_categories.dart';
import 'package:auto_finance/domain/entities/transaction_type.dart';
import 'package:drift/drift.dart';

class TransactionDao {
  final AppDatabase db;

  TransactionDao(this.db);

  //==========================
  // INSERT SINGLE
  //==========================

  Future<void> insert(Transaction trx) async {
    if (await exists(trx.id)) {
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

  //==========================
  // INSERT TRANSFER
  //==========================

  Future<void> insertTransfer({
    required String id,
    required String bank,
    required String fromWallet,
    required String toWallet,
    required int amount,
    required String rawText,
    required DateTime time,
  }) async {
    if (await exists(id)) {
      return;
    }

    await db
        .into(db.transactionsTable)
        .insert(
          TransactionsTableCompanion.insert(
            id: id,
            bank: bank,
            fromWallet: Value(fromWallet),
            toWallet: Value(toWallet),
            amount: amount,
            type: TransactionType.transfer.name,
            category: TransactionCategory.transfer.name,
            rawText: rawText,
            time: time,
          ),
        );
  }

  //==========================
  // WATCH
  //==========================

  Stream<List<TransactionsTableData>> watchAll() {
    return (db.select(db.transactionsTable)..orderBy([(t) => OrderingTerm.desc(t.time)])).watch();
  }

  //==========================
  // GET
  //==========================

  Future<List<TransactionsTableData>> getAll() {
    return db.select(db.transactionsTable).get();
  }

  Future<TransactionsTableData?> getById(String id) {
    return (db.select(db.transactionsTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  //==========================
  // DELETE
  //==========================

  Future<void> delete(String id) async {
    await (db.delete(db.transactionsTable)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteAll() async {
    await db.delete(db.transactionsTable).go();
  }

  //==========================
  // EXISTS
  //==========================

  Future<bool> exists(String id) async {
    final result = await (db.select(db.transactionsTable)..where((t) => t.id.equals(id))).get();

    return result.isNotEmpty;
  }
}
