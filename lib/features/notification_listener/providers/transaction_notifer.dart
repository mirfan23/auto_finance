import 'package:auto_finance/data/local/database/app_database.dart';
import 'package:auto_finance/domain/entities/transaction.dart';
import 'package:auto_finance/domain/usecases/transaction_pipeline_usecase.dart';
import 'package:auto_finance/features/notification_listener/providers/transaction_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pipelineProvider = Provider((ref) => TransactionPipelineUseCase());

final transactionListProvider = StateNotifierProvider<TransactionNotifier, List<Transaction>>((ref) {
  return TransactionNotifier(ref.watch(dbProvider), ref.watch(pipelineProvider));
});

class TransactionNotifier extends StateNotifier<List<Transaction>> {
  final AppDatabase db;
  final TransactionPipelineUseCase pipeline;

  TransactionNotifier(this.db, this.pipeline) : super([]);

  Future<void> addFromNotification(Map data) async {
    final trx = pipeline(data);
    if (trx == null) return;

    // update state
    state = [trx, ...state];

    // insert to DB
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
  }
}
