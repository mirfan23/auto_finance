import 'dart:async';

import 'package:auto_finance/domain/usecases/transaction/transaction_action_usecase.dart';

class FakeNotifications {
  FakeNotifications._();

  static Map<String, dynamic> jagoExpense50k() {
    return {
      "packageName": "com.jago.digitalBanking",
      "title": "Jago",
      "text":
          "Kamu telah melakukan transfer Rp50.000 ke M IRFAN FADHILA. Butuh bantuan? Silakan Tanya Jago di 1500 746.",
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    };
  }

  static Map<String, dynamic> bcaIncome50k() {
    return {
      "packageName": "com.bca.mybca.omni.android",
      "title": "Financial Diary",
      "text": "You received IDR 50,000.00 from MUHA**AD **FAN *AD at Account Transfer category.",
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    };
  }

  static Future<void> transfer50k(TransactionAction action) async {
    await action.handle(jagoExpense50k());

    await Future.delayed(const Duration(milliseconds: 500));

    await action.handle(bcaIncome50k());
  }
}
