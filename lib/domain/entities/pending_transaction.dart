import 'transaction.dart';
import 'transaction_type.dart';
import 'transaction_categories.dart';

class PendingTransaction {
  final String id;
  final String bank;
  final int amount;
  final String category;
  final String type;
  final DateTime time;
  final String rawText;

  bool pending;

  PendingTransaction({
    required this.id,
    required this.bank,
    required this.amount,
    required this.category,
    required this.type,
    required this.time,
    required this.rawText,
    this.pending = true,
  });

  factory PendingTransaction.fromTransaction(Transaction trx) {
    return PendingTransaction(
      id: trx.id,
      bank: trx.bank,
      amount: trx.amount,
      category: trx.category.name,
      type: trx.type.name,
      time: trx.time,
      rawText: trx.rawText,
    );
  }

  Transaction toTransaction() {
    return Transaction(
      id: id,
      bank: bank,
      fromWallet: null,
      toWallet: null,
      amount: amount,
      type: TransactionType.values.firstWhere((e) => e.name == type),
      category: TransactionCategory.values.firstWhere((e) => e.name == category),
      rawText: rawText,
      time: time,
    );
  }
}
