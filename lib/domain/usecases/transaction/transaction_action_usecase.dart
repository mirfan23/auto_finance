import 'package:auto_finance/core/helpers/transaction_fingerprint_helper.dart';
import 'package:auto_finance/data/dao/pending_transaction_dao.dart';
import 'package:auto_finance/domain/entities/transaction_categories.dart';
import 'package:auto_finance/domain/entities/transaction_type.dart';
import 'package:auto_finance/domain/usecases/transaction/finalize_pending_usecase.dart';
import 'package:auto_finance/domain/usecases/transfer/transfer_pairing_usecase.dart';
import 'package:auto_finance/data/local/database/app_database.dart';
import 'package:auto_finance/domain/usecases/transaction/transaction_pipeline_usecase.dart';
import 'package:auto_finance/domain/usecases/transaction/duplicate_transaction_usecase.dart';
import 'package:auto_finance/features/transaction/providers/finalize_pending_provider.dart';
import 'package:auto_finance/features/transaction/providers/pairing_provider.dart';
import 'package:auto_finance/features/transaction/providers/transaction_provider.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pipelineProvider = Provider((ref) => TransactionPipelineUseCase());

final duplicateProvider = Provider((ref) => DuplicateTransactionUseCase());

final pendingDaoProvider = Provider((ref) => PendingTransactionDao(ref.watch(dbProvider)));

final transactionActionProvider = Provider<TransactionAction>((ref) {
  return TransactionAction(
    db: ref.watch(dbProvider),
    pipeline: ref.watch(pipelineProvider),
    duplicate: ref.watch(duplicateProvider),
    pairing: ref.watch(pairingProvider),
    pendingDao: ref.watch(pendingDaoProvider),
    finalizePending: ref.watch(finalizePendingProvider),
  );
});

// class TransactionAction {
//   final AppDatabase db;
//   final TransactionPipelineUseCase pipeline;
//   final DuplicateTransactionUseCase duplicate;
//   final TransferPairingUseCase pairing;
//   final PendingTransactionDao pendingDao;
//   final FinalizePendingUseCase finalizePending;

//   TransactionAction({
//     required this.db,
//     required this.pipeline,
//     required this.duplicate,
//     required this.pairing,
//     required this.pendingDao,
//     required this.finalizePending,
//   });

//   Future<void> handle(Map data) async {
//     final incoming = pipeline(data);

//     if (incoming == null) return;

//     final alreadyExist = await pendingDao.exists(incoming.bank, incoming.amount, incoming.type, incoming.rawText);

//     if (alreadyExist) {
//       print("duplicate pending ignored");
//       return;
//     }

//     // simpan dulu ke pending table
//     await pendingDao.insert(incoming);

//     // ambil semua pending=true
//     final rows = await pendingDao.getPending();

//     final pendingList = rows.map((e) {
//       return PendingTransaction(
//         id: e.id,
//         bank: e.bank,
//         amount: e.amount,
//         category: e.category,
//         type: e.type,
//         rawText: e.rawText,
//         time: e.time,
//         pending: e.pending,
//       );
//     }).toList();

//     final pair = pairing.process(incoming, pendingList.where((e) => e.id != incoming.id).toList());

//     if (pair == null) {
//       print("⏳ waiting pair");
//       await finalizePending.execute();
//       return;
//     }

//     final debit = pair.debit!;
//     final credit = pair.credit!;
//     final fingerprint = TransactionFingerprint.generate(
//       bank: "${debit.bank}→${credit.bank}",
//       amount: debit.amount,
//       type: "transfer",
//       rawText: "${debit.rawText}${credit.rawText}",
//     );
//     // hapus dari pending table
//     await pendingDao.deleteMany([debit.id, credit.id]);

//     // buat transfer
//     await db
//         .into(db.transactionsTable)
//         .insert(
//           TransactionsTableCompanion.insert(
//             bank: "${debit.bank} → ${credit.bank}",
//             amount: debit.amount,
//             type: "transfer",
//             category: "transfer",
//             rawText: "${debit.rawText}\n${credit.rawText}",
//             time: credit.time,
//             fingerprint: fingerprint,
//           ),
//         );
//     print("✅ transfer created");
//     await finalizePending.execute();
//   }
// }

class TransactionAction {
  final AppDatabase db;
  final TransactionPipelineUseCase pipeline;
  final DuplicateTransactionUseCase duplicate;
  final TransferPairingUseCase pairing;
  final PendingTransactionDao pendingDao;
  final FinalizePendingUseCase finalizePending;

  TransactionAction({
    required this.db,
    required this.pipeline,
    required this.duplicate,
    required this.pairing,
    required this.pendingDao,
    required this.finalizePending,
  });

  Future<void> handle(Map data) async {
    //----------------------------------------------------
    // Parse notification
    //----------------------------------------------------

    final incoming = pipeline(data);

    if (incoming == null) {
      return;
    }

    //----------------------------------------------------
    // Ignore duplicate pending
    //----------------------------------------------------

    final exists = await pendingDao.exists(incoming.bank, incoming.amount, incoming.type, incoming.rawText);

    if (exists) {
      print("⛔ duplicate pending ignored");
      return;
    }

    //----------------------------------------------------
    // Save to pending
    //----------------------------------------------------

    await pendingDao.insert(incoming);

    //----------------------------------------------------
    // Load pending transaction
    //----------------------------------------------------

    final pending = await pendingDao.getPending();

    //----------------------------------------------------
    // Try pairing
    //----------------------------------------------------

    final pair = pairing.process(incoming, pending.where((e) => e.id != incoming.id).toList());

    //----------------------------------------------------
    // No pair
    //----------------------------------------------------

    if (pair == null) {
      print("⏳ waiting pair");

      await finalizePending.execute();

      return;
    }

    //----------------------------------------------------
    // Pair found
    //----------------------------------------------------

    final debit = pair.debit!;
    final credit = pair.credit!;

    // final fingerprint = TransactionFingerprint.generate(
    //   bank: "${debit.bank}→${credit.bank}",
    //   amount: debit.amount,
    //   type: "transfer",
    //   rawText: "${debit.rawText}${credit.rawText}",
    // );
    final transferId = "transfer_${DateTime.now().microsecondsSinceEpoch}";

    //----------------------------------------------------
    // Remove pending
    //----------------------------------------------------

    await pendingDao.deleteMany([debit.id, credit.id]);

    //----------------------------------------------------
    // Save transfer
    //----------------------------------------------------

    await db
        .into(db.transactionsTable)
        .insert(
          TransactionsTableCompanion.insert(
            id: transferId,
            bank: "${debit.bank} → ${credit.bank}",
            fromWallet: Value(debit.bank),
            toWallet: Value(credit.bank),
            amount: debit.amount,
            type: TransactionType.transfer.name,
            category: TransactionCategory.transfer.name,
            rawText: "${debit.rawText}\n${credit.rawText}",
            time: credit.time,
          ),
        );

    print("✅ transfer created");

    //----------------------------------------------------
    // Finalize remaining pending
    //----------------------------------------------------

    await finalizePending.execute();
  }
}
