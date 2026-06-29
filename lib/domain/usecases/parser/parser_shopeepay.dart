import 'package:auto_finance/domain/entities/parser_result.dart';
import 'package:auto_finance/domain/usecases/parser/base_parser.dart';

class ShopeePayParser extends BaseParser {
  ParserResult? parse(Map data) {
    final text = (data["text"] ?? "").toString();

    if (text.isEmpty) return null;

    final match = RegExp(r'Rp\s?([\d\.]+)').firstMatch(text);

    if (match == null) return null;

    final amountStr = match.group(1)!.replaceAll(".", "");

    final amount = int.tryParse(amountStr);
    if (amount == null) return null;

    return ParserResult(
      bank: "ShopeePay",
      amount: amount,
      type: classifier(text),
      category: categorizer(text),
      rawText: text,
      time: DateTime.fromMillisecondsSinceEpoch((data["timestamp"] as num).toInt()),
    );
  }
}
