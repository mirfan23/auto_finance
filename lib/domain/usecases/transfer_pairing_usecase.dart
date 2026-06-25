import 'package:auto_finance/domain/entities/pending_transaction.dart';
import 'package:auto_finance/domain/usecases/transfer_pair.dart';

class TransferPairingUseCase {
  TransferPair? process(PendingTransaction incoming, List<PendingTransaction> existing) {
    PendingTransaction? match;

    for (final item in existing) {
      final sameAmount = item.amount == incoming.amount;

      final differentBank = item.bank != incoming.bank;

      final timeDiff = item.time.difference(incoming.time).inSeconds.abs();

      if (sameAmount && differentBank && timeDiff <= 60) {
        match = item;
        break;
      }
    }

    if (match == null) return null;

    return TransferPair(
      debit: match.type == "debit" ? match : incoming,
      credit: match.type == "credit" ? match : incoming,
    );
  }
}
