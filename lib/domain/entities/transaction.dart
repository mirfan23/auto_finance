import 'package:auto_finance/domain/entities/transaction_categories.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

@freezed
abstract class Transaction with _$Transaction {
  const factory Transaction({
    required String bank,
    required int amount,
    required String type,
    required TransactionCategory category,
    required String rawText,
    required DateTime time,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
}
