import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FinanceWidgetSyncService {
  static const _channel = MethodChannel('auto_finance/finance_widget');

  Future<void> updateSummary({
    required int totalBalance,
    required int monthlyExpense,
    required DateTime updatedAt,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    await _channel.invokeMethod<void>('updateSummary', {
      'totalBalance': totalBalance,
      'monthlyExpense': monthlyExpense,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    });
  }
}
