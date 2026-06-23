import 'package:auto_finance/domain/usecases/parser/base_parser.dart';

import '../../entities/transaction.dart';

class BcaParser extends BaseParser {
  Transaction? parse(Map data) {
    final text = (data["text"] ?? "").toString();

    final amountRegex = RegExp(r'Rp[\.\s]?([\d\.]+)', caseSensitive: false);

    final match = amountRegex.firstMatch(text);

    if (match == null) return null;

    final amount = int.parse(match.group(1)!.replaceAll(".", ""));

    return Transaction(
      bank: "BCA",
      amount: amount,
      type: "expense",
      category: categorizer(text),
      rawText: text,
      time: DateTime.now(),
    );
  }
}
