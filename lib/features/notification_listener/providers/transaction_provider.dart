// import 'package:auto_finance/data/local/database/app_database.dart';
// import 'package:auto_finance/domain/entities/transaction.dart';
// import 'package:auto_finance/domain/entities/transaction_categories.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../domain/usecases/transaction_pipeline_usecase.dart';

// final dbProvider = Provider<AppDatabase>((ref) {
//   return AppDatabase.instance;
// });

// final pipelineProvider = Provider((ref) => TransactionPipelineUseCase());

// final transactionStreamProvider = StreamProvider<List<Transaction>>((ref) {
//   final db = ref.watch(dbProvider);

//   return db.select(db.transactionsTable).watch().map((rows) {
//     return rows.map((e) {
//       return Transaction(
//         bank: e.bank,
//         amount: e.amount,
//         type: e.type,
//         category: TransactionCategory.values.byName(e.category),
//         rawText: e.rawText,
//         time: e.time,
//       );
//     }).toList();
//   });
// });

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_finance/data/local/database/app_database.dart';
import 'package:auto_finance/domain/entities/transaction.dart';
import 'package:auto_finance/domain/entities/transaction_categories.dart';

final dbProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

final transactionStreamProvider = StreamProvider<List<Transaction>>((ref) {
  final db = ref.watch(dbProvider);

  return db.select(db.transactionsTable).watch().map((rows) {
    return rows.map((e) {
      return Transaction(
        bank: e.bank,
        amount: e.amount,
        type: e.type,
        category: TransactionCategory.values.byName(e.category),
        rawText: e.rawText,
        time: e.time,
      );
    }).toList();
  });
});
