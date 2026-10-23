import 'package:auto_finance/data/dao/pending_transaction_dao.dart';
import 'package:auto_finance/data/dao/transaction_dao.dart';
import 'package:auto_finance/data/local/database/app_database.dart';
import 'package:auto_finance/domain/entities/transaction.dart';
import 'package:auto_finance/domain/entities/transaction_categories.dart';
import 'package:auto_finance/domain/entities/transaction_type.dart';
import 'package:auto_finance/domain/usecases/transaction/duplicate_transaction_usecase.dart';
import 'package:auto_finance/domain/usecases/transaction/save_transaction_usecase.dart';
import 'package:auto_finance/domain/usecases/transaction/transaction_action_usecase.dart';
import 'package:auto_finance/domain/usecases/transaction/transaction_pipeline_usecase.dart';
import 'package:auto_finance/features/transaction/providers/finalize_pending_provider.dart';
import 'package:auto_finance/features/transaction/providers/pairing_provider.dart';
import 'package:auto_finance/features/wallet/providers/wallet_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Database
final dbProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

/// DAO
final transactionDaoProvider = Provider<TransactionDao>((ref) {
  return TransactionDao(ref.watch(dbProvider));
});

final pendingDaoProvider = Provider<PendingTransactionDao>((ref) {
  return PendingTransactionDao(ref.watch(dbProvider));
});

/// UseCases
final pipelineProvider = Provider((ref) => TransactionPipelineUseCase());

final duplicateProvider = Provider((ref) => DuplicateTransactionUseCase());

final saveTransactionProvider = Provider<SaveTransactionUseCase>((ref) {
  return SaveTransactionUseCase(
    transactionDao: ref.watch(transactionDaoProvider),
    applyTransaction: ref.watch(applyTransactionProvider),
  );
});

/// Transaction Action
final transactionActionProvider = Provider<TransactionAction>((ref) {
  return TransactionAction(
    pipeline: ref.watch(pipelineProvider),
    duplicate: ref.watch(duplicateProvider),
    pairing: ref.watch(pairingProvider),
    pendingDao: ref.watch(pendingDaoProvider),
    transactionDao: ref.watch(transactionDaoProvider),
    finalizePending: ref.watch(finalizePendingProvider),
    walletResolver: ref.watch(walletResolverProvider),
    saveTransaction: ref.watch(saveTransactionProvider),
  );
});

/// Stream Transaction
final transactionStreamProvider = StreamProvider<List<Transaction>>((ref) {
  final dao = ref.watch(transactionDaoProvider);

  return dao.watchAll().map(
    (rows) => rows
        .map(
          (e) => Transaction(
            id: e.id,
            bank: e.bank,
            fromWallet: e.fromWallet,
            toWallet: e.toWallet,
            amount: e.amount,
            type: TransactionType.values.byName(e.type),
            category: TransactionCategory.values.byName(e.category),
            rawText: e.rawText,
            time: e.time,
          ),
        )
        .toList(),
  );
});

final transactionDetailProvider = FutureProvider.family<Transaction?, String>((ref, id) async {
  final dao = TransactionDao(ref.watch(dbProvider));

  final row = await dao.getById(id);

  if (row == null) return null;

  return Transaction(
    id: row.id,
    bank: row.bank,
    fromWallet: row.fromWallet,
    toWallet: row.toWallet,
    amount: row.amount,
    type: TransactionType.values.byName(row.type),
    category: TransactionCategory.values.byName(row.category),
    rawText: row.rawText,
    time: row.time,
  );
});
