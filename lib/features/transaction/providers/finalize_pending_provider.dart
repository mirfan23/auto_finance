import 'package:auto_finance/domain/usecases/transaction/finalize_pending_usecase.dart';
import 'package:auto_finance/features/transaction/providers/transaction_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final finalizePendingProvider = Provider<FinalizePendingUseCase>((ref) {
  return FinalizePendingUseCase(pendingDao: ref.watch(pendingDaoProvider), db: ref.watch(dbProvider));
});
