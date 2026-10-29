import 'package:auto_finance/features/transaction/domain/usecases/finalize_pending_usecase.dart';
import 'package:auto_finance/features/transaction/application/providers/transaction_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final finalizePendingProvider = Provider<FinalizePendingUseCase>((ref) {
  return FinalizePendingUseCase(
    pendingDao: ref.watch(pendingDaoProvider),
    saveTransaction: ref.watch(saveTransactionProvider),
  );
});
