// import 'package:auto_finance/data/dao/pending_transaction_dao.dart';
// import 'package:auto_finance/data/local/database/app_database.dart';
// import 'package:auto_finance/domain/usecases/wallet/apply_transaction_usecase.dart';
// import 'package:auto_finance/features/transaction/providers/transaction_provider.dart';
// import 'package:auto_finance/features/wallet/providers/wallet_provider.dart';
// import 'package:drift/drift.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class FinalizePendingUseCase {
//   static const timeout = Duration(seconds: 1);

//   final PendingTransactionDao pendingDao;
//   final AppDatabase db;
//   final ApplyTransactionUseCase applyTransaction;

//   FinalizePendingUseCase({required this.pendingDao, required this.db, required this.applyTransaction});

//   Future<void> execute() async {
//     final pendingList = await pendingDao.getPending();

//     final now = DateTime.now();

//     for (final trx in pendingList) {
//       final age = now.difference(trx.time);

//       if (age < timeout) {
//         continue;
//       }

//       // await db
//       //     .into(db.transactionsTable)
//       //     .insert(
//       //       TransactionsTableCompanion.insert(
//       //         id: trx.id,
//       //         bank: trx.bank,
//       //         amount: trx.amount,
//       //         type: trx.type.name,
//       //         category: trx.category.name,
//       //         rawText: trx.rawText,
//       //         time: trx.time,
//       //         fromWallet: Value(trx.fromWallet),
//       //         toWallet: Value(trx.toWallet),
//       //       ),
//       //     );

//       final finalizePendingProvider = Provider(
//         (ref) => FinalizePendingUseCase(
//           pendingDao: ref.watch(pendingDaoProvider),
//           db: ref.watch(dbProvider),
//           applyTransaction: ref.watch(applyTransactionProvider),
//         ),
//       );
//       await applyTransaction(trx);

//       await pendingDao.delete(trx.id);

//       print(
//         "✅ SINGLE CREATED => "
//         "${trx.bank} | "
//         "${trx.amount}",
//       );
//     }
//   }
// }

import 'package:auto_finance/data/dao/pending_transaction_dao.dart';
import 'package:auto_finance/domain/usecases/transaction/save_transaction_usecase.dart';

class FinalizePendingUseCase {
  static const timeout = Duration(seconds: 1);

  final PendingTransactionDao pendingDao;
  final SaveTransactionUseCase saveTransaction;

  FinalizePendingUseCase({required this.pendingDao, required this.saveTransaction});

  Future<void> execute() async {
    final pendingList = await pendingDao.getPending();

    final now = DateTime.now();

    for (final trx in pendingList) {
      final age = now.difference(trx.time);

      if (age < timeout) {
        continue;
      }

      //--------------------------------------------------
      // Save transaction
      //--------------------------------------------------

      await saveTransaction.saveSingle(trx);

      //--------------------------------------------------
      // Remove pending
      //--------------------------------------------------

      await pendingDao.delete(trx.id);

      print(
        "✅ SINGLE CREATED => "
        "${trx.bank} | "
        "${trx.amount}",
      );
    }
  }
}
