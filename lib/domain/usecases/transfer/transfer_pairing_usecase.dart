import 'package:auto_finance/domain/usecases/transfer/transfer_pair.dart';

// class TransferPairingUseCase {
//   TransferPair? process(PendingTransaction incoming, List<PendingTransaction> existing) {
//     PendingTransaction? match;

//     for (final item in existing) {
//       final sameAmount = item.amount == incoming.amount;

//       final differentBank = item.bank != incoming.bank;

//       final timeDiff = item.time.difference(incoming.time).inSeconds.abs();

//       final oppositeType = item.type != incoming.type;

//       if (sameAmount && differentBank && oppositeType && timeDiff <= 60) {
//         match = item;
//         break;
//       }
//     }

//     if (match == null) return null;

//     final debit = incoming.type == "expense" ? incoming : match;

//     final credit = incoming.type == "income" ? incoming : match;

//     return TransferPair(debit: debit, credit: credit);
//   }
// }

import 'package:auto_finance/domain/entities/transaction.dart';
import 'package:auto_finance/domain/entities/transaction_type.dart';

class TransferPairingUseCase {
  TransferPair? process(Transaction incoming, List<Transaction> existing) {
    Transaction? match;

    for (final item in existing) {
      final sameAmount = item.amount == incoming.amount;

      final differentBank = item.bank != incoming.bank;

      final oppositeType = item.type != incoming.type;

      final timeDiff = item.time.difference(incoming.time).inSeconds.abs();

      if (sameAmount && differentBank && oppositeType && timeDiff <= 60) {
        match = item;
        break;
      }
    }

    if (match == null) {
      return null;
    }

    final debit = incoming.type == TransactionType.expense ? incoming : match;

    final credit = incoming.type == TransactionType.income ? incoming : match;

    return TransferPair(debit: debit, credit: credit);
  }
}
