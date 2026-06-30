import 'package:auto_finance/data/dao/transaction_dao.dart';
import 'package:auto_finance/domain/entities/transaction.dart';
import 'package:auto_finance/domain/usecases/wallet/apply_transaction_usecase.dart';

class SaveTransactionUseCase {
  final TransactionDao transactionDao;
  final ApplyTransactionUseCase applyTransaction;

  SaveTransactionUseCase({required this.transactionDao, required this.applyTransaction});

  //----------------------------------------------------------
  // SINGLE TRANSACTION
  //----------------------------------------------------------

  Future<void> saveSingle(Transaction trx) async {
    await transactionDao.insert(trx);

    await applyTransaction(trx);
  }

  //----------------------------------------------------------
  // TRANSFER
  //----------------------------------------------------------

  Future<void> saveTransfer({required Transaction debit, required Transaction credit}) async {
    final transferId = "transfer_${DateTime.now().microsecondsSinceEpoch}";

    await transactionDao.insertTransfer(
      id: transferId,
      bank: "${debit.bank} → ${credit.bank}",
      fromWallet: debit.fromWallet!,
      toWallet: credit.toWallet!,
      amount: debit.amount,
      rawText: "${debit.rawText}\n${credit.rawText}",
      time: credit.time,
    );

    await applyTransaction.executeTransfer(
      fromWalletId: debit.fromWallet!,
      toWalletId: credit.toWallet!,
      amount: debit.amount,
    );
  }
}
