// import 'package:auto_finance/data/dao/wallet_dao.dart';
// import 'package:auto_finance/domain/entities/transaction.dart';
// import 'package:auto_finance/domain/entities/transaction_type.dart';

// class ApplyTransactionUseCase {
//   final WalletDao dao;

//   ApplyTransactionUseCase(this.dao);

//   Future<void> call(Transaction trx) async {
//     switch (trx.type) {
//       case TransactionType.income:
//         await _income(trx);
//         break;

//       case TransactionType.expense:
//         await _expense(trx);
//         break;

//       case TransactionType.transfer:
//         await _transfer(trx);
//         break;
//     }
//   }

//   Future<void> _income(Transaction trx) async {
//     if (trx.toWallet == null) return;

//     await dao.addBalance(trx.toWallet!, trx.amount);
//   }

//   Future<void> _expense(Transaction trx) async {
//     if (trx.fromWallet == null) return;

//     await dao.subtractBalance(trx.fromWallet!, trx.amount);
//   }

//   Future<void> _transfer(Transaction trx) async {
//     if (trx.fromWallet != null) {
//       await dao.subtractBalance(trx.fromWallet!, trx.amount);
//     }

//     if (trx.toWallet != null) {
//       await dao.addBalance(trx.toWallet!, trx.amount);
//     }
//   }
// }

import 'package:auto_finance/data/dao/wallet_dao.dart';
import 'package:auto_finance/domain/entities/transaction.dart';
import 'package:auto_finance/domain/entities/transaction_type.dart';

class ApplyTransactionUseCase {
  final WalletDao walletDao;

  ApplyTransactionUseCase(this.walletDao);

  //--------------------------------------------------
  // Income / Expense
  //--------------------------------------------------

  Future<void> call(Transaction trx) async {
    switch (trx.type) {
      case TransactionType.income:
        if (trx.toWallet != null) {
          await walletDao.addBalance(trx.toWallet!, trx.amount);
        }
        break;

      case TransactionType.expense:
        if (trx.fromWallet != null) {
          await walletDao.subtractBalance(trx.fromWallet!, trx.amount);
        }
        break;

      case TransactionType.transfer:
        // transfer diproses lewat executeTransfer()
        break;
    }
  }

  //--------------------------------------------------
  // Transfer
  //--------------------------------------------------

  Future<void> executeTransfer({required String fromWalletId, required String toWalletId, required int amount}) async {
    await walletDao.subtractBalance(fromWalletId, amount);

    await walletDao.addBalance(toWalletId, amount);
  }
}
