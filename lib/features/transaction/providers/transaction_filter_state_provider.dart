import 'package:auto_finance/domain/entities/transaction_filter.dart';
import 'package:auto_finance/core/models/date_filter_selection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final transactionFilterProvider = StateProvider<TransactionFilter>((ref) {
  return TransactionFilter.all;
});

/// Shared month/range selection for the transaction list.
final transactionDateFilterProvider = StateProvider<DateFilterSelection>(
  (ref) => const DateFilterSelection.all(),
);
