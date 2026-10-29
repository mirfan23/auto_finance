// import 'package:auto_finance/features/transaction/data/dao/pending_transaction_dao.dart';
// import 'package:auto_finance/data/local/database/app_database.dart';
// import 'package:auto_finance/features/wallet/domain/usecases/apply_transaction_usecase.dart';
// import 'package:auto_finance/features/transaction/application/providers/transaction_provider.dart';
// import 'package:auto_finance/features/wallet/application/providers/wallet_provider.dart';
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

import 'package:auto_finance/features/transaction/data/dao/pending_transaction_dao.dart';
import 'package:auto_finance/features/transaction/domain/usecases/save_transaction_usecase.dart';
import 'package:auto_finance/features/transaction/domain/usecases/transfer/transfer_pairing_usecase.dart';

class FinalizePendingUseCase {
  // Must match (or exceed) TransferPairingUseCase.pairingWindow. Finalizing
  // a pending row as a single transaction before the pairing window closes
  // would steal it away from its debit/credit partner before pairing ever
  // gets a chance to match it.
  static const timeout = TransferPairingUseCase.pairingWindow;

  final PendingTransactionDao pendingDao;
  final SaveTransactionUseCase saveTransaction;

  FinalizePendingUseCase({required this.pendingDao, required this.saveTransaction});

  Future<List<String>> execute() async {
    print("🟣 FINALIZE START");

    final pendingList = await pendingDao.getPending();

    print("🟣 PENDING COUNT => ${pendingList.length}");

    final now = DateTime.now();

    final finalizedIds = <String>[];

    for (final trx in pendingList) {
      final age = now.difference(trx.time);

      print(
        "🟣 CHECK PENDING => "
        "${trx.bank} | "
        "${trx.amount} | "
        "age=${age.inMilliseconds}ms",
      );

      if (age < timeout) {
        print("⏳ TOO YOUNG - SKIP");
        continue;
      }

      //--------------------------------------------------
      // Save transaction
      //--------------------------------------------------
      // print("🟡 SAVING SINGLE TRANSACTION");

      // await saveTransaction.saveSingle(trx);

      // //--------------------------------------------------
      // // Remove pending
      // //--------------------------------------------------

      // await pendingDao.delete(trx.id);

      // print("🔍 PENDING COUNT => ${pendingList.length}");

      // print(
      //   "✅ SINGLE CREATED => "
      //   "${trx.bank} | "
      //   "${trx.amount}",
      // );
      try {
        await saveTransaction.saveSingle(trx);

        print(
          "✅ SINGLE TRANSACTION SAVED => "
          "${trx.id}",
        );

        await pendingDao.delete(trx.id);

        print(
          "🗑️ PENDING DELETED => "
          "${trx.id}",
        );

        finalizedIds.add(trx.id);
      } catch (e, stack) {
        print("❌ SAVE SINGLE FAILED");
        print(e);
        print(stack);
      }
    }
    print("🟣 FINALIZE END");

    return finalizedIds;
  }
}
