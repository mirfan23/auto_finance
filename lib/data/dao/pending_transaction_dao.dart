import 'package:auto_finance/data/local/database/app_database.dart';
import 'package:auto_finance/domain/entities/pending_transaction.dart';
import 'package:drift/drift.dart';

class PendingTransactionDao {
  final AppDatabase db;

  PendingTransactionDao(this.db);

  Future<void> insert(PendingTransaction trx) async {
    await db
        .into(db.pendingTransactionsTable)
        .insert(
          PendingTransactionsTableCompanion.insert(
            id: trx.id,
            bank: trx.bank,
            amount: trx.amount,
            type: trx.type,
            rawText: trx.rawText,
            time: trx.time,
          ),
        );
  }

  Future<List<PendingTransactionsTableData>> getPending() async {
    return await (db.select(db.pendingTransactionsTable)..where((t) => t.pending.equals(true))).get();
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

  Future<bool> exists(String bank, int amount, String type, String rawText) async {
    final limit = DateTime.now().subtract(const Duration(seconds: 5));

    final rows =
        await (db.select(db.pendingTransactionsTable)..where(
              (t) =>
                  t.bank.equals(bank) &
                  t.amount.equals(amount) &
                  t.type.equals(type) &
                  t.rawText.equals(rawText) &
                  t.time.isBiggerOrEqualValue(limit),
            ))
            .get();

    return rows.isNotEmpty;
  }
}
