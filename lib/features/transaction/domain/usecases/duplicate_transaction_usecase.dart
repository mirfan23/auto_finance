import '../entities/transaction.dart';
import '../entities/transaction_type.dart';

class DuplicateTransactionUseCase {
  static const _sameNotificationWindow = Duration(seconds: 5);
  static const _gopayGooglePlayWindow = Duration(minutes: 2);

  bool call(Transaction transaction, List<Transaction> existingTransactions) {
    return findMatch(transaction, existingTransactions) != null;
  }

  Transaction? findMatch(
    Transaction transaction,
    List<Transaction> candidates,
  ) {
    Transaction? closest;
    var closestDifference = const Duration(days: 1);
    for (final candidate in candidates) {
      if (!isSameNotificationTransaction(candidate, transaction)) continue;
      final difference = candidate.time.difference(transaction.time);
      final differenceMs = difference.inMilliseconds.abs();
      if (differenceMs < closestDifference.inMilliseconds) {
        closest = candidate;
        closestDifference = Duration(milliseconds: differenceMs);
      }
    }
    return closest;
  }

  bool isSameNotificationTransaction(Transaction first, Transaction second) {
    if (first.bank.toLowerCase() != second.bank.toLowerCase() ||
        first.amount != second.amount) {
      return false;
    }

    final diffInMilliseconds = first.time
        .difference(second.time)
        .inMilliseconds
        .abs();
    if (sameNotificationText(first.rawText, second.rawText)) {
      return diffInMilliseconds <= _sameNotificationWindow.inMilliseconds;
    }

    return diffInMilliseconds <= _gopayGooglePlayWindow.inMilliseconds &&
        first.type == TransactionType.expense &&
        second.type == TransactionType.expense &&
        _areGoPayGooglePlayVariants(first.rawText, second.rawText);
  }

  Duration lookupWindowFor(Transaction transaction) {
    return _isGoPayGooglePlayVariant(transaction.rawText)
        ? _gopayGooglePlayWindow
        : _sameNotificationWindow;
  }

  bool sameNotificationText(String first, String second) =>
      _normalize(first) == _normalize(second);

  String _normalize(String value) =>
      value.replaceAll(RegExp(r'\s+'), ' ').trim();

  bool _areGoPayGooglePlayVariants(String first, String second) {
    final firstType = _goPayGooglePlayVariantType(first);
    final secondType = _goPayGooglePlayVariantType(second);
    return firstType != null && secondType != null && firstType != secondType;
  }

  bool _isGoPayGooglePlayVariant(String text) =>
      _goPayGooglePlayVariantType(text) != null;

  int? _goPayGooglePlayVariantType(String text) {
    final lower = text.toLowerCase();
    if (!lower.contains('google play') || !lower.contains('gopay')) {
      return null;
    }

    if (lower.contains('kamu baru aja bayar') &&
        lower.contains('ke google play') &&
        lower.contains('gopay saldo')) {
      return 1;
    }
    if (lower.contains('kamu sudah melakukan transaksi gopay') &&
        lower.contains('di google play')) {
      return 2;
    }
    return null;
  }
}
