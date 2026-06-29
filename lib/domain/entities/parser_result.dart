import 'package:auto_finance/domain/entities/transaction_categories.dart';
import 'package:auto_finance/domain/entities/transaction_type.dart';

class ParserResult {
  final String bank;

  final int amount;

  final TransactionType type;

  final TransactionCategory category;

  final String rawText;

  final DateTime time;

  const ParserResult({
    required this.bank,
    required this.amount,
    required this.type,
    required this.category,
    required this.rawText,
    required this.time,
  });
}
