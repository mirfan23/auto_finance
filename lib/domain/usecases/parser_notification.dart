import 'package:auto_finance/domain/entities/transaction_categories.dart';

import '../entities/transaction.dart';

class ParseNotificationUseCase {
  Transaction? call(Map data) {
    final package = data["packageName"] ?? "";
    final text = data["text"] ?? "";
    // final title = data["title"] ?? "";
    final time = DateTime.fromMillisecondsSinceEpoch(data["timestamp"]);

    String bank = "unknown";
    String type = "unknown";
    int amount = 0;

    // BCA
    if (package.contains("bca")) {
      bank = "BCA";

      final match = RegExp(r'(\d[\d\.]+)').firstMatch(text);
      if (match != null) {
        amount = int.parse(match.group(0)!.replaceAll(".", ""));
      }

      type = text.toUpperCase().contains("DB") ? "debit" : "credit";
    }
    // GoPay
    else if (package.contains("gopay") || package.contains("gojek")) {
      bank = "GoPay";

      final match = RegExp(r'Rp ?([\d\.]+)').firstMatch(text);
      if (match != null) {
        amount = int.parse(match.group(1)!.replaceAll(".", ""));
      }

      type = "debit";
    }
    // Shopee
    else if (package.contains("shopee")) {
      bank = "ShopeePay";

      final match = RegExp(r'Rp ?([\d\.]+)').firstMatch(text);
      if (match != null) {
        amount = int.parse(match.group(1)!.replaceAll(".", ""));
      }

      type = "debit";
    }

    if (bank == "unknown") return null;

    return Transaction(
      bank: bank,
      amount: amount,
      type: type,
      time: time,
      category: TransactionCategory.unknown, // nanti kita inject categorizer
      rawText: text,
    );
  }
}
