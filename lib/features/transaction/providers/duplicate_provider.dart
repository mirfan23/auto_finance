import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/usecases/transaction/duplicate_transaction_usecase.dart';

final duplicateProvider = Provider((ref) => DuplicateTransactionUseCase());
