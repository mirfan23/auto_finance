import 'package:auto_finance/domain/usecases/parser/base_parser.dart';

import '../../entities/transaction.dart';

class ShopeePayParser extends BaseParser {
  Transaction? parse(Map data) {
    final text = (data["text"] ?? "").toString();

    if (text.isEmpty) return null;

    final match = RegExp(r'Rp\s?([\d\.]+)').firstMatch(text);

    if (match == null) return null;

    final amountStr = match.group(1)!.replaceAll(".", "");

    final amount = int.tryParse(amountStr);
    if (amount == null) return null;

    final isIncome = text.toLowerCase().contains("diterima");

    return Transaction(
      bank: "ShopeePay",
      amount: amount,
      type: isIncome ? "income" : "expense",
      category: categorizer(text),
      rawText: text,
      time: DateTime.fromMillisecondsSinceEpoch((data["timestamp"] as num).toInt()),
    );
  }
}
