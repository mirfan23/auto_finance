import 'package:auto_finance/domain/entities/transaction_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final transactionFilterProvider = StateProvider<TransactionFilter>((ref) {
  return TransactionFilter.all;
});

/// Null shows all history; otherwise the transaction list is limited to a month.
final transactionMonthFilterProvider = StateProvider<DateTime?>((ref) => null);
