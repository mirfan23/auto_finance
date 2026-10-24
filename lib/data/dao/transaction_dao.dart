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

  Future<bool> insert(Transaction trx) async {
    print(
      "💽 TRANSACTION DAO INSERT => "
      "${trx.id} | "
      "${trx.bank} | "
      "${trx.amount}",
    );
    final inserted = await db.transaction(() async {
      if (await exists(trx.id)) return false;

      final start = trx.time.subtract(const Duration(seconds: 5));
      final end = trx.time.add(const Duration(seconds: 5));
      final possibleMatches =
          await (db.select(db.transactionsTable)..where(
                (table) =>
                    table.bank.equals(trx.bank) &
                    table.amount.equals(trx.amount) &
                    table.time.isBetweenValues(start, end),
              ))
              .get();
      final isDuplicate = possibleMatches.any(
        (row) => _normalize(row.rawText) == _normalize(trx.rawText),
      );
      if (isDuplicate) return false;

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
      return true;
    });

    if (!inserted) {
      print("⛔ DUPLICATE TRANSACTION INSERT BLOCKED");
      return false;
    }
    print("✅ TRANSACTION INSERTED TO DATABASE");
    return true;
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
    return (db.select(
      db.transactionsTable,
    )..orderBy([(t) => OrderingTerm.desc(t.time)])).watch();
  }

  //==========================
  // GET
  //==========================

  Future<List<TransactionsTableData>> getAll() {
    return db.select(db.transactionsTable).get();
  }

  Future<int> recategorizeOtherTransactions(
    String Function(String rawText) categorize,
  ) async {
    return db.transaction(() async {
      final rows = await (db.select(
        db.transactionsTable,
      )..where((table) => table.category.equals('other'))).get();
      var updated = 0;
      for (final row in rows) {
        final category = categorize(row.rawText);
        if (category == 'other') continue;
        await (db.update(db.transactionsTable)
              ..where((table) => table.id.equals(row.id)))
            .write(TransactionsTableCompanion(category: Value(category)));
        updated++;
      }
      return updated;
    });
  }

  Future<List<TransactionsTableData>> getPotentialDuplicates(Transaction trx) {
    final start = trx.time.subtract(const Duration(seconds: 5));
    final end = trx.time.add(const Duration(seconds: 5));

    return (db.select(db.transactionsTable)..where(
          (t) =>
              t.bank.equals(trx.bank) &
              t.amount.equals(trx.amount) &
              t.time.isBetweenValues(start, end),
        ))
        .get();
  }

  Future<TransactionsTableData?> getById(String id) {
    return (db.select(
      db.transactionsTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> updateTransaction(Transaction updated) async {
    await db.transaction(() async {
      final row = await (db.select(
        db.transactionsTable,
      )..where((table) => table.id.equals(updated.id))).getSingleOrNull();
      if (row == null) throw StateError('Transaksi tidak ditemukan.');

      final current = Transaction(
        id: row.id,
        bank: row.bank,
        fromWallet: row.fromWallet,
        toWallet: row.toWallet,
        amount: row.amount,
        type: TransactionType.values.byName(row.type),
        category: TransactionCategory.values.byName(row.category),
        rawText: row.rawText,
        time: row.time,
      );
      final balanceEffectChanged =
          current.amount != updated.amount ||
          current.type != updated.type ||
          current.fromWallet != updated.fromWallet ||
          current.toWallet != updated.toWallet;

      if (balanceEffectChanged) {
        await _applyBalanceEffect(current, -1);
        await _applyBalanceEffect(updated, 1);
      }

      await (db.update(
        db.transactionsTable,
      )..where((table) => table.id.equals(updated.id))).write(
        TransactionsTableCompanion(
          fromWallet: Value(updated.fromWallet),
          toWallet: Value(updated.toWallet),
          amount: Value(updated.amount),
          type: Value(updated.type.name),
          category: Value(updated.category.name),
          time: Value(updated.time),
        ),
      );
    });
  }

  //==========================
  // DELETE
  //==========================

  Future<void> delete(String id) async {
    await (db.delete(db.transactionsTable)..where((t) => t.id.equals(id))).go();
  }

  Future<void> reconcileDuplicateNotifications({
    required List<Transaction> matches,
    required Transaction corrected,
  }) async {
    if (matches.isEmpty) return;

    await db.transaction(() async {
      final matchIds = matches.map((item) => item.id).toList();
      final rows = await (db.select(
        db.transactionsTable,
      )..where((table) => table.id.isIn(matchIds))).get();
      final currentMatches = rows
          .where(
            (row) =>
                row.bank == corrected.bank &&
                row.amount == corrected.amount &&
                _normalize(row.rawText) == _normalize(corrected.rawText) &&
                row.time.difference(corrected.time).inSeconds.abs() <= 5,
          )
          .map(
            (row) => Transaction(
              id: row.id,
              bank: row.bank,
              fromWallet: row.fromWallet,
              toWallet: row.toWallet,
              amount: row.amount,
              type: TransactionType.values.byName(row.type),
              category: TransactionCategory.values.byName(row.category),
              rawText: row.rawText,
              time: row.time,
            ),
          )
          .toList();
      if (currentMatches.isEmpty) return;

      final survivorId = currentMatches.first.id;

      for (final existing in currentMatches) {
        await _applyBalanceEffect(existing, -1);
      }
      await _applyBalanceEffect(corrected, 1);

      await (db.update(
        db.transactionsTable,
      )..where((table) => table.id.equals(survivorId))).write(
        TransactionsTableCompanion(
          type: Value(corrected.type.name),
          category: Value(corrected.category.name),
          fromWallet: Value(corrected.fromWallet),
          toWallet: Value(corrected.toWallet),
        ),
      );

      for (final duplicate in currentMatches.skip(1)) {
        await (db.delete(
          db.transactionsTable,
        )..where((table) => table.id.equals(duplicate.id))).go();
      }
    });
  }

  Future<void> _applyBalanceEffect(
    Transaction transaction,
    int multiplier,
  ) async {
    final amount = transaction.amount * multiplier;
    switch (transaction.type) {
      case TransactionType.income:
        if (transaction.toWallet != null) {
          await _changeBalance(transaction.toWallet!, amount);
        }
        break;
      case TransactionType.expense:
        if (transaction.fromWallet != null) {
          await _changeBalance(transaction.fromWallet!, -amount);
        }
        break;
      case TransactionType.transfer:
        if (transaction.fromWallet != null) {
          await _changeBalance(transaction.fromWallet!, -amount);
        }
        if (transaction.toWallet != null) {
          await _changeBalance(transaction.toWallet!, amount);
        }
        break;
    }
  }

  Future<void> _changeBalance(String walletId, int delta) async {
    final wallet = await (db.select(
      db.walletTable,
    )..where((table) => table.id.equals(walletId))).getSingleOrNull();
    if (wallet == null) return;
    await (db.update(db.walletTable)
          ..where((table) => table.id.equals(walletId)))
        .write(WalletTableCompanion(balance: Value(wallet.balance + delta)));
  }

  String _normalize(String value) =>
      value.replaceAll(RegExp(r'\s+'), ' ').trim();

  Future<void> deleteAll() async {
    await db.delete(db.transactionsTable).go();
  }

  //==========================
  // EXISTS
  //==========================

  Future<bool> exists(String id) async {
    final result = await (db.select(
      db.transactionsTable,
    )..where((t) => t.id.equals(id))).get();

    return result.isNotEmpty;
  }

  Future<List<TransactionsTableData>> getByWallet(String walletId) {
    return (db.select(db.transactionsTable)..where(
          (t) => t.fromWallet.equals(walletId) | t.toWallet.equals(walletId),
        ))
        .get();
  }
}
