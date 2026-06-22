import 'package:auto_finance/domain/entities/transaction_categories.dart';

import '../entities/transaction.dart';

class TransactionPipelineUseCase {
  Transaction? call(Map data) {
    final package = data["packageName"] ?? "";
    final text = data["text"] ?? "";
    final time = DateTime.fromMillisecondsSinceEpoch(data["timestamp"]);

    String bank = "unknown";
    String type = "debit";
    int amount = 0;

    if (package.contains("bca")) {
      bank = "BCA";
      final match = RegExp(r'(\d[\d\.]+)').firstMatch(text);
      if (match != null) {
        amount = int.parse(match.group(0)!.replaceAll(".", ""));
      }
    } else if (package.contains("gopay") || package.contains("gojek")) {
      bank = "GoPay";
      final match = RegExp(r'Rp ?([\d\.]+)').firstMatch(text);
      if (match != null) {
        amount = int.parse(match.group(1)!.replaceAll(".", ""));
      }
    } else if (package.contains("shopee")) {
      bank = "ShopeePay";
      final match = RegExp(r'Rp ?([\d\.]+)').firstMatch(text);
      if (match != null) {
        amount = int.parse(match.group(1)!.replaceAll(".", ""));
      }
    } else {
      return null;
    }

    return Transaction(
      bank: bank,
      amount: amount,
      type: type,
      category: TransactionCategory.unknown,
      rawText: text,
      time: time,
    );
  }
}
