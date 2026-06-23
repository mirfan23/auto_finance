import 'package:auto_finance/domain/entities/transaction.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_finance/data/local/database/app_database.dart';
import 'package:auto_finance/domain/usecases/transaction_pipeline_usecase.dart';
import 'package:auto_finance/domain/usecases/duplicate_transaction_usecase.dart';
import 'transaction_provider.dart';

final pipelineProvider = Provider((ref) => TransactionPipelineUseCase());

final duplicateProvider = Provider((ref) => DuplicateTransactionUseCase());

final transactionActionProvider = Provider<TransactionAction>((ref) {
  return TransactionAction(
    db: ref.watch(dbProvider),
    pipeline: ref.watch(pipelineProvider),
    duplicate: ref.watch(duplicateProvider),
  );
});

class TransactionAction {
  final AppDatabase db;
  final TransactionPipelineUseCase pipeline;
  final DuplicateTransactionUseCase duplicate;

  TransactionAction({required this.db, required this.pipeline, required this.duplicate});

  Future<void> handle(Map data, List<Transaction> existing) async {
    final trx = pipeline(data);
    if (trx == null) return;

    final isDuplicate = duplicate(trx, existing);
    if (isDuplicate) return;

    await db
        .into(db.transactionsTable)
        .insert(
          TransactionsTableCompanion.insert(
            bank: trx.bank,
            amount: trx.amount,
            type: trx.type,
            category: trx.category.name,
            rawText: trx.rawText,
            time: trx.time,
          ),
        );

    print("✅ INSERT SUCCESS: ${trx.bank} - ${trx.amount}");
  }
}
