import '../../entities/transaction.dart';

class DuplicateTransactionUseCase {
  bool call(Transaction transaction, List<Transaction> existingTransactions) {
    for (final item in existingTransactions) {
      final sameBank = item.bank == transaction.bank;
      final sameAmount = item.amount == transaction.amount;
      final sameType = item.type == transaction.type;

      final diff = item.time.difference(transaction.time).inSeconds.abs();

      if (sameBank && sameAmount && sameType && diff <= 5) {
        return true;
      }
    }

    return false;
  }
}
