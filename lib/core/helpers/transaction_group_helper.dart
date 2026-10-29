import 'package:auto_finance/features/transaction/domain/entities/transaction.dart';

class TransactionGroupHelper {
  static Map<DateTime, List<Transaction>> groupByDate(List<Transaction> transactions) {
    final map = <DateTime, List<Transaction>>{};

    final sorted = [...transactions]..sort((a, b) => b.time.compareTo(a.time));

    for (final trx in sorted) {
      final date = DateTime(trx.time.year, trx.time.month, trx.time.day);

      map.putIfAbsent(date, () => []);

      map[date]!.add(trx);
    }

    return map;
  }
}
