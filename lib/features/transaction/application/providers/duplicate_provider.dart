import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:auto_finance/features/transaction/domain/usecases/duplicate_transaction_usecase.dart';

final duplicateProvider = Provider((ref) => DuplicateTransactionUseCase());
