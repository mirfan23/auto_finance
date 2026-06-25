import 'package:auto_finance/domain/usecases/classify_transaction_type.dart';

import '../categorize_transaction.dart';

abstract class BaseParser {
  final categorizer = CategorizeTransactionUseCase();
  final classifier = ClassifyTransactionTypeUseCase();
}
