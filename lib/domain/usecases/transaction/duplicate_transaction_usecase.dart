import '../../entities/transaction.dart';

class DuplicateTransactionUseCase {
  bool call(Transaction transaction, List<Transaction> existingTransactions) {
    final notificationText = _normalize(transaction.rawText);

    for (final item in existingTransactions) {
      final sameBank = item.bank == transaction.bank;
      final sameAmount = item.amount == transaction.amount;
      final sameType = item.type == transaction.type;
      final sameNotification = _normalize(item.rawText) == notificationText;

      final diff = item.time.difference(transaction.time).inSeconds.abs();

      if (sameBank && sameAmount && sameType && sameNotification && diff <= 5) {
        return true;
      }
    }

    return false;
  }

  String _normalize(String value) => value.replaceAll(RegExp(r'\s+'), ' ').trim();
}
