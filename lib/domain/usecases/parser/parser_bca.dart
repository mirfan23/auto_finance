import 'package:auto_finance/domain/usecases/parser/base_parser.dart';

import '../../entities/transaction.dart';

class BcaParser extends BaseParser {
  Transaction? parse(Map data) {
    final text = (data["text"] ?? "").toString();

    final match = RegExp(r'(?:IDR|Rp)\s?([\d\.,]+)', caseSensitive: false).firstMatch(text);

    if (match == null) {
      return null;
    }

    var amountStr = match.group(1)!;

    amountStr = amountStr.replaceAll(",", "").replaceAll(".00", "");

    final amount = int.tryParse(amountStr);

    if (amount == null) {
      return null;
    }

    final type = classifier(text);

    return Transaction(
      bank: "BCA",
      amount: amount,
      type: type.name,
      category: categorizer(text),
      rawText: text,
      time: DateTime.now(),
    );
  }
}
