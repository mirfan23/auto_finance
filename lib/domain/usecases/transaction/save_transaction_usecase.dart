import 'package:auto_finance/data/dao/transaction_dao.dart';
import 'package:auto_finance/domain/entities/transaction.dart';
import 'package:auto_finance/domain/entities/transaction_type.dart';
import 'package:auto_finance/domain/usecases/wallet/apply_transaction_usecase.dart';

class SaveTransactionUseCase {
  final TransactionDao transactionDao;
  final ApplyTransactionUseCase applyTransaction;

  SaveTransactionUseCase({
    required this.transactionDao,
    required this.applyTransaction,
  });

  //----------------------------------------------------------
  // SINGLE TRANSACTION
  //----------------------------------------------------------

  Future<void> saveSingle(Transaction trx) async {
    print(
      "💾 SAVE SINGLE START => "
      "${trx.bank} | "
      "${trx.amount}",
    );
    final inserted = await transactionDao.insert(trx);
    if (!inserted) {
      print("⛔ DUPLICATE SAVE SKIPPED; WALLET BALANCE UNCHANGED");
      return;
    }
    print("✅ TRANSACTION DAO INSERT SUCCESS");
    await applyTransaction(trx);
    print("✅ WALLET BALANCE APPLIED");
  }

  //----------------------------------------------------------
  // TRANSFER
  //----------------------------------------------------------

  Future<void> saveTransfer({
    required Transaction debit,
    required Transaction credit,
  }) async {
    if (debit.type != TransactionType.expense ||
        credit.type != TransactionType.income ||
        debit.amount != credit.amount) {
      throw StateError('Pasangan transaksi bukan transfer yang valid.');
    }

    // Notification IDs are stable across retries, making the transfer
    // idempotent even if the app is interrupted before pending rows are
    // deleted.
    final transferId = 'transfer_${debit.id}_${credit.id}';
    final inserted = await transactionDao.insertTransferAndReconcile(
      id: transferId,
      debit: debit,
      credit: credit,
    );
    print(
      inserted
          ? '✅ TRANSFER SAVED WITH RECONCILIATION => $transferId'
          : '♻️ TRANSFER ALREADY SAVED; DUPLICATE LEGS RECONCILED => $transferId',
    );
  }
}
