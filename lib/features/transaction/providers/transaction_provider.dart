import 'package:auto_finance/data/dao/pending_transaction_dao.dart';
import 'package:auto_finance/domain/entities/transaction_type.dart';
import 'package:auto_finance/domain/usecases/transaction/duplicate_transaction_usecase.dart';
import 'package:auto_finance/domain/usecases/transaction/transaction_action_usecase.dart';
import 'package:auto_finance/domain/usecases/transaction/transaction_pipeline_usecase.dart';
import 'package:auto_finance/features/transaction/providers/finalize_pending_provider.dart';
import 'package:auto_finance/features/transaction/providers/pairing_provider.dart';
import 'package:auto_finance/features/wallet/providers/wallet_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_finance/data/local/database/app_database.dart';
import 'package:auto_finance/domain/entities/transaction.dart';
import 'package:auto_finance/domain/entities/transaction_categories.dart';

final pipelineProvider = Provider((ref) => TransactionPipelineUseCase());

final duplicateProvider = Provider((ref) => DuplicateTransactionUseCase());

final pendingDaoProvider = Provider((ref) => PendingTransactionDao(ref.watch(dbProvider)));

final dbProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

final pendingTransactionDaoProvider = Provider((ref) => PendingTransactionDao(ref.watch(dbProvider)));

final transactionActionProvider = Provider<TransactionAction>((ref) {
  return TransactionAction(
    db: ref.watch(dbProvider),
    pipeline: ref.watch(pipelineProvider),
    duplicate: ref.watch(duplicateProvider),
    pairing: ref.watch(pairingProvider),
    pendingDao: ref.watch(pendingDaoProvider),
    finalizePending: ref.watch(finalizePendingProvider),
    walletResolver: ref.watch(walletResolverProvider),
  );
});

final transactionStreamProvider = StreamProvider<List<Transaction>>((ref) {
  final db = ref.watch(dbProvider);

  return db.select(db.transactionsTable).watch().map((rows) {
    return rows.map((e) {
      return Transaction(
        id: e.id,
        bank: e.bank,
        fromWallet: e.fromWallet,
        toWallet: e.toWallet,
        amount: e.amount,
        type: TransactionType.values.byName(e.type),
        category: TransactionCategory.values.byName(e.category),
        rawText: e.rawText,
        time: e.time,
      );
    }).toList();
  });
});
