import 'dart:convert';

import 'package:crypto/crypto.dart';

class TransactionFingerprint {
  static String generate({required String bank, required int amount, required String type, required String rawText}) {
    return md5.convert(utf8.encode('$bank$amount$type$rawText')).toString();
  }
}
