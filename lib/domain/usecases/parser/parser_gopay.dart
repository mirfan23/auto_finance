import 'package:auto_finance/domain/usecases/parser/base_parser.dart';

import '../../entities/transaction.dart';

class GopayParser extends BaseParser {
  Transaction? parse(Map data) {
    final text = (data["text"] ?? "").toString();

    final match = RegExp(r'Rp([\d\.]+)').firstMatch(text);

    if (match == null) return null;

    final amount = int.parse(match.group(1)!.replaceAll(".", ""));

    return Transaction(
      bank: "GoPay",
      amount: amount,
      type: "expense",
      category: categorizer(text),
      rawText: text,
      time: DateTime.now(),
    );
  }
}
