import 'package:auto_finance/domain/entities/parser_result.dart';
import 'package:auto_finance/domain/usecases/parser/base_parser.dart';

class JagoParser extends BaseParser {
  ParserResult? parse(Map data) {
    final text = (data["text"] ?? "").toString();

    final match = RegExp(r'Rp([\d\.]+)').firstMatch(text);

    if (match == null) return null;

    final amount = int.parse(match.group(1)!.replaceAll(".", ""));

    final type = classifier(text);

    return ParserResult(
      bank: "Jago",
      amount: amount,
      type: type,
      category: categorizer(text),
      rawText: text,
      time: DateTime.fromMillisecondsSinceEpoch((data["timestamp"] as num).toInt()),
    );
  }
}
