import 'package:auto_finance/data/dao/pending_transaction_dao.dart';
import 'package:auto_finance/data/dao/transaction_dao.dart';
import 'package:auto_finance/domain/entities/transaction.dart';
import 'package:auto_finance/domain/entities/transaction_categories.dart';
import 'package:auto_finance/domain/entities/transaction_type.dart';
import 'package:auto_finance/domain/usecases/transaction/duplicate_transaction_usecase.dart';
import 'package:auto_finance/domain/usecases/transaction/finalize_pending_usecase.dart';
import 'package:auto_finance/domain/usecases/transaction/save_transaction_usecase.dart';
import 'package:auto_finance/domain/usecases/transaction/transaction_action_result.dart';
import 'package:auto_finance/domain/usecases/transaction/transaction_pipeline_usecase.dart';
import 'package:auto_finance/domain/usecases/transfer/transfer_pairing_usecase.dart';
import 'package:auto_finance/domain/usecases/wallet/wallet_resolver_usecase.dart';

class TransactionAction {
  final TransactionPipelineUseCase pipeline;
  final DuplicateTransactionUseCase duplicate;
  final TransferPairingUseCase pairing;
  final PendingTransactionDao pendingDao;
  final TransactionDao transactionDao;
  final FinalizePendingUseCase finalizePending;
  final WalletResolverUseCase walletResolver;
  final SaveTransactionUseCase saveTransaction;

  TransactionAction({
    required this.pipeline,
    required this.duplicate,
    required this.pairing,
    required this.pendingDao,
    required this.transactionDao,
    required this.finalizePending,
    required this.walletResolver,
    required this.saveTransaction,
  });

  // Future<void> handle(Map data) async {
  //   //--------------------------------------------------
  //   // Parse notification
  //   //--------------------------------------------------
  //   print("🟢 TRANSACTION ACTION START");

  //   final incoming = pipeline(data);

  //   if (incoming == null) {
  //     print("❌ ACTION STOPPED - PIPELINE RETURNED NULL");
  //     return;
  //   }

  //   print(
  //     "✅ INCOMING TRANSACTION => "
  //     "${incoming.bank} | "
  //     "${incoming.amount} | "
  //     "${incoming.type}",
  //   );

  //   //--------------------------------------------------
  //   // Resolve wallet
  //   //--------------------------------------------------

  //   final wallet = await walletResolver.resolve(incoming.bank);

  //   print(
  //     "👛 WALLET RESOLVED => "
  //     "${wallet?.id} | "
  //     "${wallet?.name}",
  //   );

  //   final resolved = incoming.copyWith(
  //     fromWallet: incoming.type == TransactionType.expense ? wallet?.id : null,
  //     toWallet: incoming.type == TransactionType.income ? wallet?.id : null,
  //   );

  //   //--------------------------------------------------
  //   // Ignore duplicate pending
  //   //--------------------------------------------------

  //   final exists = await pendingDao.exists(resolved.bank, resolved.amount, resolved.type, resolved.rawText);

  //   if (exists) {
  //     print("⛔ duplicate pending ignored");
  //     return;
  //   }

  //   //--------------------------------------------------
  //   // Save pending
  //   //--------------------------------------------------

  //   try {
  //     await pendingDao.insert(resolved);

  //     print(
  //       "🟡 PENDING INSERTED => "
  //       "${resolved.bank} | "
  //       "${resolved.amount} | "
  //       "${resolved.type}",
  //     );
  //   } catch (e, stack) {
  //     print("❌ PENDING INSERT FAILED");
  //     print(e);
  //     print(stack);
  //     return;
  //   }

  //   //--------------------------------------------------
  //   // Load pending
  //   //--------------------------------------------------

  //   final pending = await pendingDao.getPending();

  //   //--------------------------------------------------
  //   // Try pairing
  //   //--------------------------------------------------

  //   final pair = pairing.process(resolved, pending.where((e) => e.id != resolved.id).toList());

  //   //--------------------------------------------------
  //   // No pair
  //   //--------------------------------------------------

  //   if (pair == null) {
  //     print("⏳ waiting pair");

  //     await Future.delayed(const Duration(seconds: 1));

  //     await finalizePending.execute();

  //     return;
  //   }

  //   //--------------------------------------------------
  //   // Pair found
  //   //--------------------------------------------------

  //   final debit = pair.debit!;
  //   final credit = pair.credit!;

  //   //--------------------------------------------------
  //   // Remove pending
  //   //--------------------------------------------------

  //   await pendingDao.deleteMany([debit.id, credit.id]);

  //   //--------------------------------------------------
  //   // Save transfer
  //   //--------------------------------------------------

  //   await saveTransaction.saveTransfer(debit: debit, credit: credit);

  //   print("✅ TRANSFER CREATED");

  //   //--------------------------------------------------
  //   // Finalize remaining pending
  //   //--------------------------------------------------

  //   await finalizePending.execute();
  // }

  Future<TransactionActionResult> handle(Map data) async {
    print("🟢 TRANSACTION ACTION START");

    final incoming = pipeline(data);

    if (incoming == null) {
      // Not a transaction notification at all (unrecognized package/format).
      // Parsing is deterministic, so retrying this later will never
      // succeed — this is not a "failure" worth keeping pending forever.
      print("➖ NOT A TRANSACTION - PIPELINE RETURNED NULL");

      return TransactionActionResult.notTransaction;
    }

    final savedTransactions = (await transactionDao.getPotentialDuplicates(incoming))
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

    if (duplicate(incoming, savedTransactions)) {
      print("⛔ DUPLICATE SAVED TRANSACTION IGNORED");
      return TransactionActionResult.duplicate;
    }

    final wallet = await walletResolver.resolve(incoming.bank);

    final resolved = incoming.copyWith(
      fromWallet: incoming.type == TransactionType.expense ? wallet?.id : null,
      toWallet: incoming.type == TransactionType.income ? wallet?.id : null,
    );

    final exists = await pendingDao.exists(resolved.bank, resolved.amount, resolved.type, resolved.rawText);

    if (exists) {
      print("⛔ DUPLICATE PENDING IGNORED");

      return TransactionActionResult.duplicate;
    }

    try {
      await pendingDao.insert(resolved);
    } catch (e, stack) {
      print("❌ PENDING INSERT FAILED");
      print(e);
      print(stack);

      return TransactionActionResult.failed;
    }

    final pending = await pendingDao.getPending();

    final pair = pairing.process(resolved, pending.where((e) => e.id != resolved.id).toList());

    if (pair == null) {
      print("⏳ WAITING PAIR");

      final finalizedIds = await finalizePending.execute();

      if (finalizedIds.contains(resolved.id)) {
        print("✅ SINGLE FINALIZED => ${resolved.id}");

        return TransactionActionResult.processed;
      }

      print("⏳ STILL PENDING => ${resolved.id}");

      return TransactionActionResult.waitingPair;
    }

    final debit = pair.debit!;
    final credit = pair.credit!;

    //--------------------------------------------------
    // Wallet not resolved yet — keep the pair pending.
    // Do not delete it, do not guess, do not crash.
    //--------------------------------------------------

    if (debit.fromWallet == null || credit.toWallet == null) {
      print(
        "⏳ WAITING WALLET => "
        "debit=${debit.fromWallet} | "
        "credit=${credit.toWallet}",
      );

      return TransactionActionResult.waitingWallet;
    }

    try {
      // Save first, delete pending only after the transfer is confirmed
      // saved — otherwise a failed save would lose both pending rows.
      await saveTransaction.saveTransfer(debit: debit, credit: credit);

      print("✅ TRANSFER CREATED");

      await pendingDao.deleteMany([debit.id, credit.id]);

      await finalizePending.execute();

      return TransactionActionResult.processed;
    } catch (e, stack) {
      print("❌ TRANSFER PROCESS FAILED");
      print(e);
      print(stack);

      return TransactionActionResult.failed;
    }
  }
}
