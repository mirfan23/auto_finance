import '../../entities/transaction_type.dart';
import '../../../core/helpers/jago_notification_helper.dart';

class ClassifyTransactionTypeUseCase {
  TransactionType call(String text) {
    final lower = text.toLowerCase();

    // A movement between Jago pockets stays within the same Jago account.
    // Keep it as a transfer so it never reduces the account's total balance.
    if (JagoNotificationHelper.isPocketMovement(text)) {
      return TransactionType.transfer;
    }

    // These ShopeePay notifications describe funds arriving into the wallet.
    // The sender's name can vary, so check the incoming destination phrase.
    if ((lower.contains('mengirimkan dana') ||
            lower.contains('mengirim dana')) &&
        (lower.contains('shopeepay-mu') || lower.contains('ke shopeepay'))) {
      return TransactionType.income;
    }

    // income
    if (_containsAny(lower, [
      "diterima",
      "menerima kiriman",
      "telah menerima",
      "menerima pencairan dana",
      "pencairan dana sebesar",
      "menerima",
      "menerima rp",
      "received",
      "masuk",
      "credited",
      "deposit",
      "mengirim rp",
      "ke kamu",
      "dana masuk",
      "pengisian saldo",
      "telah ditambahkan ke shopeepay",
    ])) {
      return TransactionType.income;
    }

    // expense
    if (_containsAny(lower, [
      "you spent",
      "payment",
      "paid",
      "debit",
      "withdraw",
      "tarik tunai",
      "transfer ke",
      "berhasil dibayar",
      "transaksi berhasil",
      "kamu telah membayar",
      "telah membayar",
      "membayar rp",
      "kamu telah melakukan transfer",
      "telah melakukan transfer",
      "telah mengirim",
    ])) {
      return TransactionType.expense;
    }

    return TransactionType.expense;
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any(text.contains);
  }
}
