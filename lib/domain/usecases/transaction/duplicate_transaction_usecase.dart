import '../../entities/transaction.dart';

class DuplicateTransactionUseCase {
  bool call(Transaction transaction, List<Transaction> existingTransactions) {
    for (final item in existingTransactions) {
      final sameBank = item.bank == transaction.bank;
      final sameAmount = item.amount == transaction.amount;
      final sameNotification = sameNotificationText(
        item.rawText,
        transaction.rawText,
      );

      final diff = item.time.difference(transaction.time).inSeconds.abs();

      if (sameBank && sameAmount && sameNotification && diff <= 5) {
        return true;
      }
    }

    return false;
  }

  bool sameNotificationText(String first, String second) =>
      _normalize(first) == _normalize(second);

  String _normalize(String value) =>
      value.replaceAll(RegExp(r'\s+'), ' ').trim();
}
