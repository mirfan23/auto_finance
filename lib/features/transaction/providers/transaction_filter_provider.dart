import 'package:auto_finance/domain/entities/transaction.dart';
import 'package:auto_finance/features/transaction/providers/transaction_provider.dart';
import 'package:auto_finance/features/transaction/providers/transaction_search_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_finance/domain/entities/transaction_filter.dart';
import 'package:auto_finance/domain/entities/transaction_type.dart';
import 'package:auto_finance/features/transaction/providers/transaction_filter_state_provider.dart';

final filteredTransactionProvider = Provider<AsyncValue<List<Transaction>>>((
  ref,
) {
  final transactions = ref.watch(transactionStreamProvider);

  final keyword = ref.watch(transactionSearchProvider).toLowerCase();

  final filter = ref.watch(transactionFilterProvider);
  final dateFilter = ref.watch(transactionDateFilterProvider);
  print('filter: $filter');

  return transactions.whenData((list) {
    var result = list;

    //--------------------------------
    // Search
    //--------------------------------

    if (keyword.isNotEmpty) {
      result = result.where((trx) {
        return trx.bank.toLowerCase().contains(keyword) ||
            trx.rawText.toLowerCase().contains(keyword);
      }).toList();
    }

    result = result.where((trx) => dateFilter.contains(trx.time)).toList();

    //--------------------------------
    // Filter
    //--------------------------------
    print("filtered before: ${result.length}");

    switch (filter) {
      case TransactionFilter.all:
        break;

      case TransactionFilter.income:
        result = result.where((e) => e.type == TransactionType.income).toList();
        break;

      case TransactionFilter.expense:
        result = result
            .where((e) => e.type == TransactionType.expense)
            .toList();
        break;

      case TransactionFilter.transfer:
        result = result
            .where((e) => e.type == TransactionType.transfer)
            .toList();
        break;
    }
    print("filtered after: ${result.length}");
    return result;
  });
});
