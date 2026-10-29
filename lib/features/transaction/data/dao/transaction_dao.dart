import 'package:auto_finance/data/local/database/app_database.dart';
import 'package:auto_finance/core/helpers/jago_notification_helper.dart';
import 'package:auto_finance/core/helpers/notification_text_merger.dart';
import 'package:auto_finance/features/transaction/domain/entities/transaction.dart';
import 'package:auto_finance/features/transaction/domain/entities/transaction_categories.dart';
import 'package:auto_finance/features/transaction/domain/entities/transaction_type.dart';
import 'package:drift/drift.dart';

class TransactionDao {
  final AppDatabase db;

  TransactionDao(this.db);

  //==========================
  // INSERT SINGLE
  //==========================

  Future<bool> insert(
    Transaction trx, {
    bool allowExactDuplicate = false,
  }) async {
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
      final isDuplicate =
          !allowExactDuplicate &&
          possibleMatches.any(
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

  /// Stores a paired bank transfer and reconciles any single-leg
  /// transactions that may already have been finalized from the same
  /// notifications. All ledger and balance changes happen atomically.
  Future<bool> insertTransferAndReconcile({
    required String id,
    required Transaction debit,
    required Transaction credit,
  }) {
    final fromWallet = debit.fromWallet;
    final toWallet = credit.toWallet;
    if (fromWallet == null || toWallet == null) {
      throw StateError('Transfer tidak memiliki dompet sumber atau tujuan.');
    }

    final bank = '${debit.bank} → ${credit.bank}';
    final rawText = '${debit.rawText}\n${credit.rawText}';
    final transferTime = credit.time;

    return db.transaction(() async {
      final existingById = await getById(id);
      if (existingById != null &&
          !_isSamePairedTransfer(
            existingById,
            bank: bank,
            fromWallet: fromWallet,
            toWallet: toWallet,
            amount: debit.amount,
            rawText: rawText,
          )) {
        throw StateError('ID transfer sudah digunakan transaksi lain.');
      }

      final start = transferTime.subtract(const Duration(seconds: 5));
      final end = transferTime.add(const Duration(seconds: 5));
      final nearbyTransfers =
          await (db.select(db.transactionsTable)..where(
                (table) =>
                    table.bank.equals(bank) &
                    table.type.equals(TransactionType.transfer.name) &
                    table.fromWallet.equals(fromWallet) &
                    table.toWallet.equals(toWallet) &
                    table.amount.equals(debit.amount) &
                    table.time.isBetweenValues(start, end),
              ))
              .get();
      final exactTransfers =
          nearbyTransfers
              .where(
                (row) =>
                    _normalize(row.rawText) == _normalize(rawText) &&
                    _isSamePairedTransfer(
                      row,
                      bank: bank,
                      fromWallet: fromWallet,
                      toWallet: toWallet,
                      amount: debit.amount,
                      rawText: rawText,
                    ),
              )
              .toList()
            ..sort((a, b) => a.time.compareTo(b.time));

      // The two notification legs might already exist as ordinary rows if
      // sync/finalization completed before their counterpart was paired.
      final legRows = <String, TransactionsTableData>{};
      for (final leg in [debit, credit]) {
        final legStart = leg.time.subtract(const Duration(seconds: 5));
        final legEnd = leg.time.add(const Duration(seconds: 5));
        final candidates =
            await (db.select(db.transactionsTable)..where(
                  (table) =>
                      table.bank.equals(leg.bank) &
                      table.amount.equals(leg.amount) &
                      table.time.isBetweenValues(legStart, legEnd),
                ))
                .get();

        for (final row in candidates) {
          if (row.type != leg.type.name ||
              row.fromWallet != leg.fromWallet ||
              row.toWallet != leg.toWallet ||
              _normalize(row.rawText) != _normalize(leg.rawText)) {
            continue;
          }
          legRows[row.id] = row;
        }
      }

      for (final row in legRows.values) {
        await _applyBalanceEffect(_toTransaction(row), -1);
        await (db.delete(
          db.transactionsTable,
        )..where((table) => table.id.equals(row.id))).go();
      }

      // Keep one exact transfer row if a previous attempt already saved it;
      // remove only exact duplicates and reverse their balance effects.
      final keepExistingTransfer = exactTransfers.isNotEmpty
          ? exactTransfers.first
          : existingById;
      for (final duplicate in exactTransfers.skip(1)) {
        await _applyBalanceEffect(_toTransaction(duplicate), -1);
        await (db.delete(
          db.transactionsTable,
        )..where((table) => table.id.equals(duplicate.id))).go();
      }

      if (keepExistingTransfer != null) return false;

      await db
          .into(db.transactionsTable)
          .insert(
            TransactionsTableCompanion.insert(
              id: id,
              bank: bank,
              fromWallet: Value(fromWallet),
              toWallet: Value(toWallet),
              amount: debit.amount,
              type: TransactionType.transfer.name,
              category: TransactionCategory.transfer.name,
              rawText: rawText,
              time: transferTime,
            ),
          );
      await _applyBalanceEffect(
        Transaction(
          id: id,
          bank: bank,
          fromWallet: fromWallet,
          toWallet: toWallet,
          amount: debit.amount,
          type: TransactionType.transfer,
          category: TransactionCategory.transfer,
          rawText: rawText,
          time: transferTime,
        ),
        1,
      );
      return true;
    });
  }

  /// Returns true when [leg] is already represented by a saved paired
  /// transfer. Any stale standalone copy of that leg is removed and its
  /// balance effect is reversed before returning.
  Future<bool> reconcileIfAlreadyPaired(Transaction leg) {
    final walletId = leg.type == TransactionType.expense
        ? leg.fromWallet
        : leg.type == TransactionType.income
        ? leg.toWallet
        : null;
    if (walletId == null || leg.rawText.trim().isEmpty) {
      return Future.value(false);
    }

    final start = leg.time.subtract(const Duration(seconds: 60));
    final end = leg.time.add(const Duration(seconds: 60));
    return db.transaction(() async {
      final transferRows =
          await (db.select(db.transactionsTable)..where(
                (table) =>
                    table.type.equals(TransactionType.transfer.name) &
                    table.amount.equals(leg.amount) &
                    (leg.type == TransactionType.expense
                        ? table.fromWallet.equals(walletId)
                        : table.toWallet.equals(walletId)) &
                    table.time.isBetweenValues(start, end),
              ))
              .get();
      final normalizedLegText = _normalize(leg.rawText);
      final isCoveredByTransfer = transferRows.any(
        (row) => _normalize(row.rawText).contains(normalizedLegText),
      );
      if (!isCoveredByTransfer) return false;

      final duplicateStart = leg.time.subtract(const Duration(seconds: 5));
      final duplicateEnd = leg.time.add(const Duration(seconds: 5));
      final standaloneRows =
          await (db.select(db.transactionsTable)..where(
                (table) =>
                    table.bank.equals(leg.bank) &
                    table.amount.equals(leg.amount) &
                    table.time.isBetweenValues(duplicateStart, duplicateEnd),
              ))
              .get();
      for (final row in standaloneRows) {
        if (row.type != leg.type.name ||
            row.fromWallet != leg.fromWallet ||
            row.toWallet != leg.toWallet ||
            _normalize(row.rawText) != normalizedLegText) {
          continue;
        }
        await _applyBalanceEffect(_toTransaction(row), -1);
        await (db.delete(
          db.transactionsTable,
        )..where((table) => table.id.equals(row.id))).go();
      }
      return true;
    });
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

  /// Repairs old Jago pocket notifications that were saved as expenses before
  /// pocket withdrawals were recognized. A same-wallet transfer has no net
  /// balance effect, so reversing the old expense restores the wallet total.
  Future<int> reconcileJagoPocketMovements() {
    return db.transaction(() async {
      final rows = await db.select(db.transactionsTable).get();
      var reconciled = 0;

      for (final row in rows) {
        if (row.bank.toLowerCase() != 'jago' ||
            row.type == TransactionType.transfer.name ||
            !JagoNotificationHelper.isPocketMovement(row.rawText)) {
          continue;
        }

        final existing = _toTransaction(row);
        final jagoWalletId = existing.fromWallet ?? existing.toWallet;
        final corrected = existing.copyWith(
          type: TransactionType.transfer,
          category: TransactionCategory.transfer,
          fromWallet: jagoWalletId,
          toWallet: jagoWalletId,
        );

        // Reverse the previously applied income/expense effect, then apply
        // the corrected internal transfer in the same database transaction.
        await _applyBalanceEffect(existing, -1);
        await _applyBalanceEffect(corrected, 1);
        await (db.update(
          db.transactionsTable,
        )..where((table) => table.id.equals(row.id))).write(
          TransactionsTableCompanion(
            type: Value(corrected.type.name),
            category: Value(corrected.category.name),
            fromWallet: Value(corrected.fromWallet),
            toWallet: Value(corrected.toWallet),
          ),
        );
        reconciled++;
      }

      return reconciled;
    });
  }

  Future<List<TransactionsTableData>> getPotentialDuplicates(
    Transaction trx, {
    Duration window = const Duration(seconds: 5),
  }) {
    final start = trx.time.subtract(window);
    final end = trx.time.add(window);

    return (db.select(db.transactionsTable)..where(
          (t) =>
              t.bank.equals(trx.bank) &
              t.amount.equals(trx.amount) &
              t.time.isBetweenValues(start, end),
        ))
        .get();
  }

  Future<List<Transaction>> getPotentialTransferLegs(
    Transaction transaction, {
    required Duration window,
  }) async {
    final oppositeType = transaction.type == TransactionType.expense
        ? TransactionType.income
        : transaction.type == TransactionType.income
        ? TransactionType.expense
        : null;
    if (oppositeType == null) return const [];

    final start = transaction.time.subtract(window);
    final end = transaction.time.add(window);
    final rows =
        await (db.select(db.transactionsTable)..where(
              (table) =>
                  table.amount.equals(transaction.amount) &
                  table.bank.equals(transaction.bank).not() &
                  table.type.equals(oppositeType.name) &
                  table.time.isBetweenValues(start, end),
            ))
            .get();
    return rows.map(_toTransaction).toList();
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

  Future<bool> delete(String id) async {
    return db.transaction(() async {
      final row = await (db.select(
        db.transactionsTable,
      )..where((table) => table.id.equals(id))).getSingleOrNull();
      if (row == null) return false;

      await _applyBalanceEffect(_toTransaction(row), -1);
      await (db.delete(
        db.transactionsTable,
      )..where((table) => table.id.equals(id))).go();
      return true;
    });
  }

  Future<int> removeJagoPromotionalTransactions() async {
    return db.transaction(() async {
      final rows = await (db.select(
        db.transactionsTable,
      )..where((table) => table.bank.equals('Jago'))).get();
      var removed = 0;

      for (final row in rows) {
        if (!JagoNotificationHelper.isPromotional(row.rawText)) continue;

        final transaction = Transaction(
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
        await _applyBalanceEffect(transaction, -1);
        await (db.delete(
          db.transactionsTable,
        )..where((table) => table.id.equals(row.id))).go();
        removed++;
      }

      return removed;
    });
  }

  /// Removes one previously saved duplicate pair for the reported GoPay
  /// Google Play charge, preserving the initial payment notification.
  /// The receipt's expense effect is reversed in the same database transaction.
  Future<int> reconcileReportedGoPayGooglePlayDuplicate() {
    return db.transaction(() async {
      final rows =
          await (db.select(db.transactionsTable)..where(
                (table) =>
                    table.amount.equals(8880) &
                    table.type.equals(TransactionType.expense.name),
              ))
              .get();
      final initialNotices = rows
          .where(
            (row) =>
                row.bank.toLowerCase() == 'gopay' &&
                _isGoPayGooglePlayInitialPayment(row.rawText),
          )
          .toList();
      final receiptNotices = rows
          .where(
            (row) =>
                row.bank.toLowerCase() == 'gopay' &&
                _isGoPayGooglePlayReceipt(row.rawText),
          )
          .toList();

      TransactionsTableData? duplicateReceipt;
      TransactionsTableData? survivor;
      var closestDifference = const Duration(days: 1);
      for (final initial in initialNotices) {
        for (final receipt in receiptNotices) {
          if (initial.id == receipt.id ||
              initial.fromWallet != receipt.fromWallet) {
            continue;
          }
          final difference = initial.time.difference(receipt.time);
          final differenceMs = difference.inMilliseconds.abs();
          if (differenceMs > const Duration(minutes: 2).inMilliseconds ||
              differenceMs >= closestDifference.inMilliseconds) {
            continue;
          }
          closestDifference = Duration(milliseconds: differenceMs);
          duplicateReceipt = receipt;
          survivor = initial;
        }
      }

      final matchedReceipt = duplicateReceipt;
      final matchedSurvivor = survivor;
      if (matchedReceipt == null || matchedSurvivor == null) return 0;

      await _applyBalanceEffect(_toTransaction(matchedReceipt), -1);
      final mergedText = NotificationTextMerger.merge(
        matchedSurvivor.rawText,
        matchedReceipt.rawText,
      );
      await (db.update(db.transactionsTable)
            ..where((table) => table.id.equals(matchedSurvivor.id)))
          .write(TransactionsTableCompanion(rawText: Value(mergedText)));
      await (db.delete(
        db.transactionsTable,
      )..where((table) => table.id.equals(matchedReceipt.id))).go();
      return 1;
    });
  }

  Future<void> appendNotificationText(String id, String additionalText) async {
    final row = await (db.select(
      db.transactionsTable,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    if (row == null) return;

    final merged = NotificationTextMerger.merge(row.rawText, additionalText);
    if (merged == row.rawText) return;
    await (db.update(db.transactionsTable)
          ..where((table) => table.id.equals(id)))
        .write(TransactionsTableCompanion(rawText: Value(merged)));
  }

  bool _isGoPayGooglePlayInitialPayment(String text) {
    final lower = text.toLowerCase();
    return lower.contains('kamu baru aja bayar') &&
        lower.contains('ke google play') &&
        lower.contains('gopay saldo');
  }

  bool _isGoPayGooglePlayReceipt(String text) {
    final lower = text.toLowerCase();
    return lower.contains('kamu sudah melakukan transaksi gopay') &&
        lower.contains('di google play');
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

  Transaction _toTransaction(TransactionsTableData row) => Transaction(
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

  bool _isSamePairedTransfer(
    TransactionsTableData row, {
    required String bank,
    required String fromWallet,
    required String toWallet,
    required int amount,
    required String rawText,
  }) =>
      row.bank == bank &&
      row.type == TransactionType.transfer.name &&
      row.fromWallet == fromWallet &&
      row.toWallet == toWallet &&
      row.amount == amount &&
      _normalize(row.rawText) == _normalize(rawText);

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
