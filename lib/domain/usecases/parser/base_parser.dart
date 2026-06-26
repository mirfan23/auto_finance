import 'package:auto_finance/domain/usecases/transaction/classify_transaction_type.dart';

import '../transaction/categorize_transaction.dart';

abstract class BaseParser {
  final categorizer = CategorizeTransactionUseCase();
  final classifier = ClassifyTransactionTypeUseCase();
}
