import '../../entities/transaction.dart';
import 'parser_bca.dart';
import 'parser_gopay.dart';
import 'parser_jago.dart';
import 'parser_shopeepay.dart';

class ParserDispatcher {
  final _bcaParser = BcaParser();
  final _jagoParser = JagoParser();
  final _gopayParser = GopayParser();
  final _shopeepayParser = ShopeePayParser();

  Transaction? parse(Map data) {
    final packageName = (data["packageName"] ?? "").toString().toLowerCase();

    if (packageName.contains("bca")) {
      return _bcaParser.parse(data);
    }

    if (packageName.contains("jago")) {
      return _jagoParser.parse(data);
    }

    if (packageName.contains("gojek")) {
      return _gopayParser.parse(data);
    }

    if (packageName.contains("shopee")) {
      return _shopeepayParser.parse(data);
    }

    return null;
  }
}
