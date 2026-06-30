// import 'package:auto_finance/data/dao/pending_transaction_dao.dart';
// import 'package:auto_finance/domain/entities/transaction_categories.dart';
// import 'package:auto_finance/domain/entities/transaction_type.dart';
// import 'package:auto_finance/domain/usecases/transaction/finalize_pending_usecase.dart';
// import 'package:auto_finance/domain/usecases/transfer/transfer_pairing_usecase.dart';
// import 'package:auto_finance/data/local/database/app_database.dart';
// import 'package:auto_finance/domain/usecases/transaction/transaction_pipeline_usecase.dart';
// import 'package:auto_finance/domain/usecases/transaction/duplicate_transaction_usecase.dart';
// import 'package:auto_finance/domain/usecases/wallet/apply_transaction_usecase.dart';
// import 'package:auto_finance/domain/usecases/wallet/wallet_resolver_usecase.dart';
// import 'package:drift/drift.dart';

// class TransactionAction {
//   final AppDatabase db;
//   final TransactionPipelineUseCase pipeline;
//   final DuplicateTransactionUseCase duplicate;
//   final TransferPairingUseCase pairing;
//   final PendingTransactionDao pendingDao;
//   final FinalizePendingUseCase finalizePending;
//   final WalletResolverUseCase walletResolver;
//   final ApplyTransactionUseCase applyTransaction;

//   TransactionAction({
//     required this.db,
//     required this.pipeline,
//     required this.duplicate,
//     required this.pairing,
//     required this.pendingDao,
//     required this.finalizePending,
//     required this.walletResolver,
//     required this.applyTransaction,
//   });

//   Future<void> handle(Map data) async {
//     //----------------------------------------------------
//     // Parse notification
//     //----------------------------------------------------

//     final incoming = pipeline(data);

//     if (incoming == null) {
//       return;
//     }

//     //----------------------------------------------------
//     // Resolve wallet
//     //----------------------------------------------------

//     final wallet = await walletResolver.resolve(incoming.bank);

//     final resolved = incoming.copyWith(
//       fromWallet: incoming.type == TransactionType.expense ? wallet?.id : null,
//       toWallet: incoming.type == TransactionType.income ? wallet?.id : null,
//     );

//     //----------------------------------------------------
//     // Ignore duplicate pending
//     //----------------------------------------------------

//     final exists = await pendingDao.exists(resolved.bank, resolved.amount, resolved.type, resolved.rawText);

//     if (exists) {
//       print("⛔ duplicate pending ignored");
//       return;
//     }

//     //----------------------------------------------------
//     // Save to pending
//     //----------------------------------------------------

//     await pendingDao.insert(resolved);

//     //----------------------------------------------------
//     // Load pending
//     //----------------------------------------------------

//     final pending = await pendingDao.getPending();

//     //----------------------------------------------------
//     // Try pairing
//     //----------------------------------------------------

//     final pair = pairing.process(resolved, pending.where((e) => e.id != resolved.id).toList());

//     //----------------------------------------------------
//     // No pair
//     //----------------------------------------------------

//     if (pair == null) {
//       print("⏳ waiting pair");

//       await finalizePending.execute();

//       return;
//     }

//     //----------------------------------------------------
//     // Pair found
//     //----------------------------------------------------

//     final debit = pair.debit!;
//     final credit = pair.credit!;

//     final transferId = "transfer_${DateTime.now().microsecondsSinceEpoch}";

//     //----------------------------------------------------
//     // Remove pending
//     //----------------------------------------------------

//     await pendingDao.deleteMany([debit.id, credit.id]);

//     //----------------------------------------------------
//     // Save transfer
//     //----------------------------------------------------

//     await db
//         .into(db.transactionsTable)
//         .insert(
//           TransactionsTableCompanion.insert(
//             id: transferId,
//             bank: "${debit.bank} → ${credit.bank}",

//             // sekarang menyimpan walletId
//             fromWallet: Value(debit.fromWallet),
//             toWallet: Value(credit.toWallet),

//             amount: debit.amount,
//             type: TransactionType.transfer.name,
//             category: TransactionCategory.transfer.name,
//             rawText: "${debit.rawText}\n${credit.rawText}",
//             time: credit.time,
//           ),
//         );

//     await applyTransaction.executeTransfer(
//       fromWalletId: debit.fromWallet!,
//       toWalletId: credit.toWallet!,
//       amount: debit.amount,
//     );

//     print("✅ transfer created");

//     //----------------------------------------------------
//     // Finalize remaining pending
//     //----------------------------------------------------

//     await finalizePending.execute();
//   }
// }

import 'package:auto_finance/data/dao/pending_transaction_dao.dart';
import 'package:auto_finance/domain/entities/transaction_type.dart';
import 'package:auto_finance/domain/usecases/transaction/duplicate_transaction_usecase.dart';
import 'package:auto_finance/domain/usecases/transaction/finalize_pending_usecase.dart';
import 'package:auto_finance/domain/usecases/transaction/save_transaction_usecase.dart';
import 'package:auto_finance/domain/usecases/transaction/transaction_pipeline_usecase.dart';
import 'package:auto_finance/domain/usecases/transfer/transfer_pairing_usecase.dart';
import 'package:auto_finance/domain/usecases/wallet/wallet_resolver_usecase.dart';

class TransactionAction {
  final TransactionPipelineUseCase pipeline;
  final DuplicateTransactionUseCase duplicate;
  final TransferPairingUseCase pairing;
  final PendingTransactionDao pendingDao;
  final FinalizePendingUseCase finalizePending;
  final WalletResolverUseCase walletResolver;
  final SaveTransactionUseCase saveTransaction;

  TransactionAction({
    required this.pipeline,
    required this.duplicate,
    required this.pairing,
    required this.pendingDao,
    required this.finalizePending,
    required this.walletResolver,
    required this.saveTransaction,
  });

  Future<void> handle(Map data) async {
    //--------------------------------------------------
    // Parse notification
    //--------------------------------------------------

    final incoming = pipeline(data);

    if (incoming == null) {
      return;
    }

    //--------------------------------------------------
    // Resolve wallet
    //--------------------------------------------------

    final wallet = await walletResolver.resolve(incoming.bank);

    final resolved = incoming.copyWith(
      fromWallet: incoming.type == TransactionType.expense ? wallet?.id : null,
      toWallet: incoming.type == TransactionType.income ? wallet?.id : null,
    );

    //--------------------------------------------------
    // Ignore duplicate pending
    //--------------------------------------------------

    final exists = await pendingDao.exists(resolved.bank, resolved.amount, resolved.type, resolved.rawText);

    if (exists) {
      print("⛔ duplicate pending ignored");
      return;
    }

    //--------------------------------------------------
    // Save pending
    //--------------------------------------------------

    await pendingDao.insert(resolved);

    //--------------------------------------------------
    // Load pending
    //--------------------------------------------------

    final pending = await pendingDao.getPending();

    //--------------------------------------------------
    // Try pairing
    //--------------------------------------------------

    final pair = pairing.process(resolved, pending.where((e) => e.id != resolved.id).toList());

    //--------------------------------------------------
    // No pair
    //--------------------------------------------------

    if (pair == null) {
      print("⏳ waiting pair");

      await finalizePending.execute();

      return;
    }

    //--------------------------------------------------
    // Pair found
    //--------------------------------------------------

    final debit = pair.debit!;
    final credit = pair.credit!;

    //--------------------------------------------------
    // Remove pending
    //--------------------------------------------------

    await pendingDao.deleteMany([debit.id, credit.id]);

    //--------------------------------------------------
    // Save transfer
    //--------------------------------------------------

    await saveTransaction.saveTransfer(debit: debit, credit: credit);

    print("✅ TRANSFER CREATED");

    //--------------------------------------------------
    // Finalize remaining pending
    //--------------------------------------------------

    await finalizePending.execute();
  }
}
