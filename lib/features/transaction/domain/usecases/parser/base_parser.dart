import 'package:auto_finance/features/transaction/domain/usecases/classify_transaction_type.dart';

import '../categorize_transaction.dart';

abstract class BaseParser {
  final categorizer = CategorizeTransactionUseCase();
  final classifier = ClassifyTransactionTypeUseCase();
}
