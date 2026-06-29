import 'package:auto_finance/domain/entities/parser_result.dart';
import 'package:flutter/foundation.dart';

import 'parser_bca.dart';
import 'parser_gopay.dart';
import 'parser_jago.dart';
import 'parser_shopeepay.dart';

class ParserDispatcher {
  final _bcaParser = BcaParser();
  final _jagoParser = JagoParser();
  final _gopayParser = GopayParser();
  final _shopeepayParser = ShopeePayParser();

  ParserResult? parse(Map data) {
    final packageName = (data["packageName"] ?? "").toString().toLowerCase();

    debugPrint("PARSER => $packageName");

    if (packageName.contains("bca")) {
      debugPrint("MATCH BCA");
      return _bcaParser.parse(data);
    }

    if (packageName.contains("jago")) {
      debugPrint("MATCH JAGO");
      return _jagoParser.parse(data);
    }

    if (packageName.contains("gojek")) {
      debugPrint("MATCH GOPAY");
      return _gopayParser.parse(data);
    }

    if (packageName.contains("shopee")) {
      debugPrint("MATCH SHOPEEPAY");
      return _shopeepayParser.parse(data);
    }

    debugPrint("NO PARSER FOUND");

    return null;
  }
}
