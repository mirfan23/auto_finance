import 'package:auto_finance/domain/entities/transaction_categories.dart';
import 'package:auto_finance/domain/entities/transaction_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

// dart run build_runner build --delete-conflicting-outputs
@freezed
abstract class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required String bank,
    String? fromWallet,
    String? toWallet,
    required int amount,
    required TransactionType type,
    required TransactionCategory category,
    required String rawText,
    required DateTime time,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
}
