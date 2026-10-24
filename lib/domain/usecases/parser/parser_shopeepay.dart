import 'package:auto_finance/domain/entities/parser_result.dart';
import 'package:auto_finance/domain/usecases/parser/base_parser.dart';

class ShopeePayParser extends BaseParser {
  ParserResult? parse(Map data) {
    final text = (data["text"] ?? "").toString();
    final title = (data["title"] ?? "").toString();
    final searchableText = [
      title,
      text,
    ].where((part) => part.trim().isNotEmpty).join(" ");

    if (searchableText.isEmpty) return null;

    final match = RegExp(
      r'(?:Rp|IDR)\s?([\d.,]+)',
      caseSensitive: false,
    ).firstMatch(searchableText);

    if (match == null) return null;

    final amountStr = match.group(1)!.replaceAll(RegExp(r'[.,]'), "");

    final amount = int.tryParse(amountStr);
    if (amount == null) return null;

    return ParserResult(
      bank: "ShopeePay",
      amount: amount,
      type: classifier(searchableText),
      category: categorizer(searchableText),
      rawText: text.trim().isNotEmpty ? text : title,
      time: DateTime.fromMillisecondsSinceEpoch(
        (data["timestamp"] as num).toInt(),
      ),
    );
  }
}
