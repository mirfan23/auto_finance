import 'package:auto_finance/data/dao/pending_transaction_dao.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_finance/data/local/database/app_database.dart';
import 'package:auto_finance/domain/entities/transaction.dart';
import 'package:auto_finance/domain/entities/transaction_categories.dart';

final dbProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

final pendingTransactionDaoProvider = Provider((ref) => PendingTransactionDao(ref.watch(dbProvider)));

final transactionStreamProvider = StreamProvider<List<Transaction>>((ref) {
  final db = ref.watch(dbProvider);

  return db.select(db.transactionsTable).watch().map((rows) {
    return rows.map((e) {
      return Transaction(
        bank: e.bank,
        amount: e.amount,
        type: e.type,
        category: TransactionCategory.values.byName(e.category),
        rawText: e.rawText,
        time: e.time,
      );
    }).toList();
  });
});
