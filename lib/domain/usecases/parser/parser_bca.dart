import 'package:auto_finance/domain/entities/parser_result.dart';
import 'package:auto_finance/domain/usecases/parser/base_parser.dart';

class BcaParser extends BaseParser {
  ParserResult? parse(Map data) {
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

    return ParserResult(
      bank: "BCA",
      amount: amount,
      type: classifier(text),
      category: categorizer(text),
      rawText: text,
      time: DateTime.fromMillisecondsSinceEpoch((data["timestamp"] as num).toInt()),
    );
  }
}
