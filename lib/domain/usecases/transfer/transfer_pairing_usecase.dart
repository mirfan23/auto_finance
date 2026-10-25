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
import 'package:auto_finance/domain/entities/transaction_categories.dart';
import 'package:auto_finance/domain/entities/transaction_type.dart';

class TransferPairingUseCase {
  // How far apart a debit/credit pair may be and still be considered a
  // transfer. FinalizePendingUseCase must wait at least this long before
  // giving up on pairing and finalizing a pending row as a single
  // transaction, otherwise the pairing window never gets a real chance.
  static const pairingWindow = Duration(seconds: 60);

  TransferPair? process(Transaction incoming, List<Transaction> existing) {
    if (incoming.type != TransactionType.expense &&
        incoming.type != TransactionType.income) {
      return null;
    }

    final matches =
        existing.where((item) {
          final oppositeType =
              (incoming.type == TransactionType.expense &&
                  item.type == TransactionType.income) ||
              (incoming.type == TransactionType.income &&
                  item.type == TransactionType.expense);
          final matchingWallets = incoming.type == TransactionType.expense
              ? incoming.fromWallet != null && item.toWallet != null
              : incoming.toWallet != null && item.fromWallet != null;
          final differentWallets = incoming.type == TransactionType.expense
              ? incoming.fromWallet != item.toWallet
              : incoming.toWallet != item.fromWallet;
          final transferEvidence = incoming.type == TransactionType.expense
              ? _hasDebitTransferEvidence(incoming) &&
                    _hasCreditTransferEvidence(item)
              : _hasDebitTransferEvidence(item) &&
                    _hasCreditTransferEvidence(incoming);

          return item.amount == incoming.amount &&
              item.bank != incoming.bank &&
              oppositeType &&
              matchingWallets &&
              differentWallets &&
              transferEvidence &&
              item.time.difference(incoming.time).abs() <= pairingWindow;
        }).toList()..sort(
          (a, b) => a.time
              .difference(incoming.time)
              .abs()
              .compareTo(b.time.difference(incoming.time).abs()),
        );

    if (matches.isEmpty) return null;
    if (matches.length > 1 &&
        matches[0].time.difference(incoming.time).abs() ==
            matches[1].time.difference(incoming.time).abs()) {
      // Two equally plausible matches are ambiguous; leave them pending
      // instead of silently joining unrelated transactions.
      return null;
    }

    final match = matches.first;

    final debit = incoming.type == TransactionType.expense ? incoming : match;

    final credit = incoming.type == TransactionType.income ? incoming : match;

    return TransferPair(debit: debit, credit: credit);
  }

  bool _hasDebitTransferEvidence(Transaction transaction) {
    if (transaction.category == TransactionCategory.transfer) return true;
    final text = transaction.rawText.toLowerCase();
    return text.contains('transfer') ||
        text.contains('pemindahan dana') ||
        text.contains('memindahkan');
  }

  bool _hasCreditTransferEvidence(Transaction transaction) {
    if (transaction.category == TransactionCategory.transfer) return true;
    final text = transaction.rawText.toLowerCase();
    return text.contains('transfer') ||
        text.contains('kiriman') ||
        text.contains('ke kamu') ||
        text.contains('telah mengirim');
  }
}
