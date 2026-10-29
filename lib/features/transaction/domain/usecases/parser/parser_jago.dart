import 'package:auto_finance/core/helpers/jago_notification_helper.dart';
import 'package:auto_finance/features/transaction/domain/entities/parser_result.dart';
import 'package:auto_finance/features/transaction/domain/usecases/parser/base_parser.dart';

class JagoParser extends BaseParser {
  ParserResult? parse(Map data) {
    final text = (data["text"] ?? "").toString();
    final title = (data["title"] ?? "").toString();
    final searchableText = [
      title,
      text,
    ].where((part) => part.trim().isNotEmpty).join(" ");

    // Jago promo messages can contain an amount but are not account activity.
    if (JagoNotificationHelper.isPromotional(searchableText)) return null;

    final match = RegExp(
      r'(?:Rp|IDR)\s?([\d.,]+)',
      caseSensitive: false,
    ).firstMatch(searchableText);

    if (match == null) return null;

    final amount = int.parse(match.group(1)!.replaceAll(RegExp(r'[.,]'), ""));

    final type = classifier(searchableText);
    final rawText = text.trim().isNotEmpty ? text : title;

    return ParserResult(
      bank: "Jago",
      amount: amount,
      type: type,
      category: categorizer(searchableText),
      rawText: rawText,
      time: DateTime.fromMillisecondsSinceEpoch(
        (data["timestamp"] as num).toInt(),
      ),
    );
  }
}
