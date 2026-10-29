import 'package:auto_finance/features/transaction/domain/entities/transaction_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final transactionFilterProvider = StateProvider<TransactionFilter>((ref) {
  return TransactionFilter.all;
});

DateTime _weekStart(DateTime date) {
  final day = DateTime(date.year, date.month, date.day);
  return day.subtract(Duration(days: day.weekday - DateTime.monday));
}

final transactionWeekStartProvider = StateProvider<DateTime>(
  (ref) => _weekStart(DateTime.now()),
);
