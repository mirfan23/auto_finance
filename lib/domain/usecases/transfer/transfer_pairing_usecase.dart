import 'package:auto_finance/domain/entities/pending_transaction.dart';
import 'package:auto_finance/domain/usecases/transfer/transfer_pair.dart';

class TransferPairingUseCase {
  TransferPair? process(PendingTransaction incoming, List<PendingTransaction> existing) {
    PendingTransaction? match;

    for (final item in existing) {
      final sameAmount = item.amount == incoming.amount;

      final differentBank = item.bank != incoming.bank;

      final timeDiff = item.time.difference(incoming.time).inSeconds.abs();

      final oppositeType = item.type != incoming.type;

      if (sameAmount && differentBank && oppositeType && timeDiff <= 60) {
        match = item;
        break;
      }
    }

    if (match == null) return null;

    final debit = incoming.type == "expense" ? incoming : match;

    final credit = incoming.type == "income" ? incoming : match;

    return TransferPair(debit: debit, credit: credit);
  }
}
