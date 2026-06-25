import '../entities/transaction_type.dart';

class ClassifyTransactionTypeUseCase {
  TransactionType call(String text) {
    final lower = text.toLowerCase();

    // income
    if (_containsAny(lower, [
      "diterima",
      "received",
      "masuk",
      "credited",
      "deposit",
      "mengirim rp",
      "ke kamu",
      "dana masuk",
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
