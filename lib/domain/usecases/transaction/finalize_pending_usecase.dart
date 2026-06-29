import 'package:auto_finance/core/helpers/transaction_fingerprint_helper.dart';
import 'package:auto_finance/data/dao/pending_transaction_dao.dart';
import 'package:auto_finance/data/local/database/app_database.dart';

class FinalizePendingUseCase {
  static const timeout = Duration(seconds: 1);

  final PendingTransactionDao pendingDao;
  final AppDatabase db;

  FinalizePendingUseCase({required this.pendingDao, required this.db});

  Future<void> execute() async {
    final pendingList = await pendingDao.getPending();

    final now = DateTime.now();

    for (final item in pendingList) {
      final age = now.difference(item.time);

      if (age < timeout) {
        continue;
      }

      final fingerprint = TransactionFingerprint.generate(
        bank: item.bank,
        amount: item.amount,
        type: item.type,
        rawText: item.rawText,
      );

      await db
          .into(db.transactionsTable)
          .insert(
            TransactionsTableCompanion.insert(
              bank: item.bank,
              amount: item.amount,
              type: item.type,
              category: item.category,
              rawText: item.rawText,
              time: item.time,
              fingerprint: fingerprint,
            ),
          );

      await pendingDao.delete(item.id);

      print(
        "✅ SINGLE CREATED => "
        "${item.bank} | "
        "${item.amount}",
      );
    }
  }
}
