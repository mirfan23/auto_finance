// import 'package:auto_finance/data/local/database/app_database.dart';
// import 'package:auto_finance/domain/entities/pending_transaction.dart';
// import 'package:drift/drift.dart';

// class PendingTransactionDao {
//   final AppDatabase db;

//   PendingTransactionDao(this.db);

//   Future<void> insert(PendingTransaction trx) async {
//     await db
//         .into(db.pendingTransactionsTable)
//         .insert(
//           PendingTransactionsTableCompanion.insert(
//             id: trx.id,
//             bank: trx.bank,
//             amount: trx.amount,
//             category: trx.category,
//             type: trx.type,
//             rawText: trx.rawText,
//             time: trx.time,
//           ),
//         );
//   }

//   Future<List<PendingTransactionsTableData>> getPending() async {
//     return await (db.select(db.pendingTransactionsTable)..where((t) => t.pending.equals(true))).get();
//   }

//   Future<void> markDone(String id) async {
//     await (db.update(
//       db.pendingTransactionsTable,
//     )..where((t) => t.id.equals(id))).write(const PendingTransactionsTableCompanion(pending: Value(false)));
//   }

//   Future<void> delete(String id) async {
//     await (db.delete(db.pendingTransactionsTable)..where((t) => t.id.equals(id))).go();
//   }

//   Future<void> deleteMany(List<String> ids) async {
//     await (db.delete(db.pendingTransactionsTable)..where((t) => t.id.isIn(ids))).go();
//   }

//   Future<bool> exists(String bank, int amount, String type, String rawText) async {
//     final limit = DateTime.now().subtract(const Duration(seconds: 5));

//     final rows =
//         await (db.select(db.pendingTransactionsTable)..where(
//               (t) =>
//                   t.bank.equals(bank) &
//                   t.amount.equals(amount) &
//                   t.type.equals(type) &
//                   t.rawText.equals(rawText) &
//                   t.time.isBiggerOrEqualValue(limit),
//             ))
//             .get();

//     return rows.isNotEmpty;
//   }
// }

import 'package:auto_finance/data/local/database/app_database.dart';
import 'package:auto_finance/domain/entities/transaction.dart';
import 'package:auto_finance/domain/entities/transaction_categories.dart';
import 'package:auto_finance/domain/entities/transaction_type.dart';
import 'package:drift/drift.dart';

class PendingTransactionDao {
  final AppDatabase db;

  PendingTransactionDao(this.db);

  Future<void> insert(Transaction trx) async {
    await db
        .into(db.pendingTransactionsTable)
        .insert(
          PendingTransactionsTableCompanion.insert(
            id: trx.id,
            bank: trx.bank,
            amount: trx.amount,
            category: trx.category.name,
            type: trx.type.name,
            rawText: trx.rawText,
            time: trx.time,
          ),
        );
  }

  Future<List<Transaction>> getPending() async {
    final rows = await (db.select(db.pendingTransactionsTable)..where((t) => t.pending.equals(true))).get();

    return rows.map(_mapRowToTransaction).toList();
  }

  Future<void> markDone(String id) async {
    await (db.update(
      db.pendingTransactionsTable,
    )..where((t) => t.id.equals(id))).write(const PendingTransactionsTableCompanion(pending: Value(false)));
  }

  Future<void> delete(String id) async {
    await (db.delete(db.pendingTransactionsTable)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteMany(List<String> ids) async {
    await (db.delete(db.pendingTransactionsTable)..where((t) => t.id.isIn(ids))).go();
  }

  Future<bool> exists(String bank, int amount, TransactionType type, String rawText) async {
    final limit = DateTime.now().subtract(const Duration(seconds: 5));

    final rows =
        await (db.select(db.pendingTransactionsTable)..where(
              (t) =>
                  t.bank.equals(bank) &
                  t.amount.equals(amount) &
                  t.type.equals(type.name) &
                  t.rawText.equals(rawText) &
                  t.time.isBiggerOrEqualValue(limit),
            ))
            .get();

    return rows.isNotEmpty;
  }

  Transaction _mapRowToTransaction(PendingTransactionsTableData row) {
    return Transaction(
      id: row.id,

      bank: row.bank,

      fromWallet: null,

      toWallet: null,

      amount: row.amount,

      type: TransactionType.values.firstWhere((e) => e.name == row.type),

      category: TransactionCategory.values.firstWhere((e) => e.name == row.category),

      rawText: row.rawText,

      time: row.time,
    );
  }
}
