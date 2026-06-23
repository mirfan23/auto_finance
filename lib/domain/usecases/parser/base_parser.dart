import '../categorize_transaction.dart';

abstract class BaseParser {
  final categorizer = CategorizeTransactionUseCase();
}
